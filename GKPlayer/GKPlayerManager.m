//
//  GKPlayerManager.m
//  GKPlayer
//
//  Created by Jacky on 15/6/19.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "GKPlayerManager.h"
#import <AVFoundation/AVFoundation.h>


@interface GKPlayerManager() <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;            //播放器实例

@property (nonatomic, strong) dispatch_source_t timer;          //歌词播放计时器
@property (nonatomic, assign) BOOL isTimerRunning;              //计时器是否运行标识量
@property (nonatomic, assign) NSInteger timeCounter;            //为计时器维护的计数器

@property (nonatomic, strong) GKLyric *currentLyric;            //当前正在播放的歌词

@property (nonatomic, assign) NSInteger currentLyricListIndex;  //当前播放的歌词列表索引

@end

@implementation GKPlayerManager

+ (instancetype)sharedInstance{
    static GKPlayerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GKPlayerManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        [self setupTimer];
    }
    
    return self;
}

#pragma mark -- Control Methods
- (void)play{
    [self.player play];
    [self startTimer];
    _isPlay = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PLAYER_PLAY object:self.currentLyric];
}

- (void)pause{
    [self stopTimer];
    [self.player pause];
    _isPlay = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PLAYER_PAUSEL object:self.currentLyric];
}

#pragma mark -- Song And Lyrics Handle Methods

- (void)loadSongFile:(NSString *)songPath andLyricsFile:(NSString *)lyricsPath completion:(void (^)(GKSong *))completion{
    if (songPath == nil) {
        return;
    }
    NSURL *songURL = [[NSURL alloc] initFileURLWithPath:songPath];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:&error];
    if (error) {
        NSLog(@"读取歌曲错误:%@", error.localizedDescription);
    }
    self.player.delegate = self;
    
    _currentSong = [[GKSong alloc] init];
    //解析歌词文件
    _currentSong.lyricList = [self handleLyricsFile:lyricsPath];
    //解析歌曲文件
    [self handleSongFile:songPath completion:completion];
}

//获取歌曲封面图片
- (void)handleSongFile:(NSString *)songPath completion:(void (^)(GKSong *))completion{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:songPath] options:nil];
    NSArray *keys = [NSArray arrayWithObjects:@"commonMetadata", nil];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSArray *artworks = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                           withKey:AVMetadataCommonKeyArtwork
                                                          keySpace:AVMetadataKeySpaceCommon];
        NSData *data;
        for (AVMetadataItem *item in artworks) {
            if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
                //                NSDictionary *dict = [ copyWithZone:nil];
                 data= [item.value copyWithZone:nil];
                break;
            } else if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
                data = [item.value copyWithZone:nil];
                break;
            }
        }
        _currentSong.imageData = data;
        dispatch_sync(dispatch_get_main_queue(), ^{
            completion(_currentSong);
        });
    }];
    
}

//加载歌词文件
- (NSArray *)handleLyricsFile:(NSString *)path{
    NSError *error;
    NSMutableArray *lyricList = [NSMutableArray array];
    NSString *lyricsString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSArray *lineList = [lyricsString componentsSeparatedByString:@"\n"];
    NSString *timeRegexStr = @"^\\[\\d+:\\d+.\\d+\\]";
    for (NSString *line in lineList) {
        NSRegularExpression *timeReg = [NSRegularExpression regularExpressionWithPattern:timeRegexStr
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
        NSArray *timeMatches = [timeReg matchesInString:line
                                                options:0
                                                  range:NSMakeRange(0, [line length])];
        
        if (timeMatches.count > 0) {
            NSTextCheckingResult *result = [timeMatches lastObject];
            NSString *timeString = [line substringWithRange:result.range];
            GKLyric *lyric = [[GKLyric alloc] init];
            NSInteger palyTime = [self lyricsPlayTimeFromString:timeString];
            lyric.playTime = palyTime;
            lyric.text = [line substringWithRange:NSMakeRange(result.range.location + result.range.length, line.length - result.range.length)];
            
            //取出上一句歌词，用来计算歌词的播放时间
            GKLyric *prevLyric = [lyricList lastObject];
            if (prevLyric) {
                prevLyric.playDuration = lyric.playTime - prevLyric.playTime;
            }
            
            [lyricList addObject:lyric];
        }else{
            continue;
        }
    }
    
    return [self filterInvalidLyrics:lyricList];
}

//过滤非法歌词对象
- (NSArray *)filterInvalidLyrics:(NSMutableArray *)list{
    if (list.count == 0) {
        return nil;
    }
    NSMutableArray *filterList = [NSMutableArray array];
    for (GKLyric *tmpLyrics in list) {
        if (tmpLyrics.text.length == 0 || tmpLyrics.playTime == 0) {
            [filterList addObject:tmpLyrics];
        }
    }
    [list removeObjectsInArray:filterList];
    return list;
}

//获取歌词播放时刻
- (NSInteger)lyricsPlayTimeFromString:(NSString *)str{
    NSString *minuteStr = [str substringWithRange:NSMakeRange(1, 2)];
    NSString *secondStr = [str substringWithRange:NSMakeRange(4, 2)];
    NSString *milliSecondStr = [str substringWithRange:NSMakeRange(7, 2)];
    
    NSInteger totleMilliSecond = [minuteStr integerValue] * 60 * 1000 + [secondStr integerValue] * 1000 + [milliSecondStr integerValue];
    
    return totleMilliSecond;
}

#pragma mark -- Player Timer Methods

- (void)setupTimer{
    uint64_t interval = NSEC_PER_MSEC;
    dispatch_queue_t queue = dispatch_queue_create("com.gkplayer.timer", NULL);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        self.timeCounter++;
        GKLyric *lyric = self.currentSong.lyricList[self.currentLyricListIndex];
        if (lyric != nil) {
            //判读是否到了当前歌词播放的时间
            if (self.timeCounter == lyric.playTime) {
                //设置两句之间的时间跳跃间隔，降低比较次数
                dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_MSEC), interval, 0);
                self.timeCounter += 30;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //更新当前歌词
                    self.currentLyric = lyric;
                    //放出通知，开始歌词动画
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PLAYER_PLAY object:lyric];
                });
                //索引自增
                self.currentLyricListIndex++;
            }
        }
        if (self.currentLyricListIndex == self.currentSong.lyricList.count - 1) {
            [self stopTimer];
            self.timeCounter = 0;
        }
    });
}

- (void)startTimer{
    if (!self.isTimerRunning) {
        self.isTimerRunning = YES;
        dispatch_resume(self.timer);
        NSLog(@"开始播放");
    }
}

- (void)stopTimer{
    if (self.isTimerRunning) {
        self.isTimerRunning = NO;
        dispatch_suspend(self.timer);
        NSLog(@"停止播放");
    }
}

#pragma mark -- AVAudioPlayerDelegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    _isPlay = NO;
    [self stopTimer];
    self.timeCounter = 0;
    self.currentLyric = nil;
    self.currentLyricListIndex = 0;
}

@end
