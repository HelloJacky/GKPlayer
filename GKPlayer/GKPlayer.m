//
//  GKPlayerView.m
//  GKPlayer
//
//  Created by Jacky on 15/5/12.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "GKPlayer.h"
#import "GKLyricsView.h"
#import <AVFoundation/AVFoundation.h>
#import "GKPlayerDefine.h"


@interface GKPlayer()<AVAudioPlayerDelegate>
@property (nonatomic) BOOL isPlay;
@end

@implementation GKPlayer{
    GKLyricsView *_lyricsView;      //歌词视图
    UIView *_controlView;           //控制条视图
    UIButton *_playPauseButton;     //播放暂停按钮
    
    dispatch_source_t _timer;       //歌词显示控制timer
    BOOL _isTimerRunning;           //timer是否正在运行标志位
    NSInteger _timeCounter;         //timer的计数器，单位：毫秒
    
    NSMutableArray *_lyricsList;    //歌词数组
    
    AVAudioPlayer *_player;         //音乐播放器
    
    GKLyric *_currentLyric;       //当前播放的歌词
    
    
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

#pragma mark -- Setup Methods

- (void)setup{
    
    [self setupControlView];
    [self setupLyricView];
    [self setupTimer];
}

- (void)setupLyricView{
    _lyricsView = [[GKLyricsView alloc] initWithFrame:CGRectMake(0.f,
                                                                 0.f,
                                                                 self.frame.size.width,
                                                                 CGRectGetMinY(_controlView.frame))];
    [self addSubview:_lyricsView];
}

- (void)setupControlView{
    CGFloat controlViewHeight = 100.f;
    _controlView = [[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                            self.frame.size.height - controlViewHeight,
                                                            self.frame.size.width,
                                                            controlViewHeight)];
    _controlView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_controlView];
    
    CGFloat playPauseBtnWidth = 60.f;
    _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
//    [_playPauseButton setImageEdgeInsets:UIEdgeInsetsMake(0.f, 5.f, 0.f, 0.f)];
//    _playPauseButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _playPauseButton.layer.masksToBounds = YES;
    _playPauseButton.frame = CGRectMake((_controlView.frame.size.width - playPauseBtnWidth)/2,
                                        (controlViewHeight - playPauseBtnWidth)/2,
                                        playPauseBtnWidth,
                                        playPauseBtnWidth);
    _playPauseButton.layer.borderWidth = 1.f;
    _playPauseButton.layer.cornerRadius = playPauseBtnWidth/2;
    _playPauseButton.layer.borderColor = UIColorFrom16RGBA(0xF5A623, 1.0).CGColor;
    [_controlView addSubview:_playPauseButton];
    [_playPauseButton addTarget:self action:@selector(playPauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- Player Timer Methods

- (void)setupTimer{
    uint64_t interval = NSEC_PER_MSEC;
    dispatch_queue_t queue = dispatch_queue_create("com.gkplayer.timer", NULL);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
    dispatch_source_set_event_handler(_timer, ^{
        _timeCounter++;
        GKLyric *lyric = _lyricsList[0];
        if (lyric != nil) {
            if(_currentLyric != nil){
                _currentLyric.currentPlayTime = +_timeCounter;
            }
            if (_timeCounter == lyric.playTime) {
                NSLog(@"[%ld]%@", (long)_timeCounter, lyric.text);
                
                [_lyricsList removeObject:lyric];
                
                //设置两句之间的时间跳跃间隔，降低比较次数
                dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_MSEC), interval, 0);
                _timeCounter += 30;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //将上一句歌词的是否正在播放设置为NO
                    _currentLyric.isPlaying = NO;
                    lyric.isPlaying = YES;
                    _currentLyric = lyric;
                });
            }
        }
        if (_lyricsList.count == 0) {
            [self stopTimer];
        }
    });
}

- (void)startTimer{
    if (!_isTimerRunning) {
        _isTimerRunning = YES;
        dispatch_resume(_timer);
        NSLog(@"开始播放");
    }
    
}

- (void)stopTimer{
    if (_isTimerRunning) {
        _isTimerRunning = NO;
        dispatch_suspend(_timer);
        NSLog(@"停止播放");
    }
    
}

#pragma mark -- Player Control Methods

- (void)playPauseButtonClick{
    if (!self.isPlay) { //处于暂停状态
        [self play];
    }else{
        [self pause];
    }
    
}

- (void)play{
    self.isPlay = YES;
    [_player play];
    [self startTimer];
    _currentLyric.isPausing = NO;
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PLAYLYRICS object:nil];
    
}

- (void)pause{
    self.isPlay = NO;
    [self stopTimer];
    [_player pause];
    
    _currentLyric.isPausing = YES;
//    _currentLyric.pauseTime = _timeCounter;
}

- (void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    if (isPlay) {
        _playPauseButton.selected = YES;
    }else{
        _playPauseButton.selected = NO;
    }
}





#pragma mark -- Lyrics Manage Methods

- (void)loadSongFile:(NSString *)songPath andLyricsFile:(NSString *)lyricsPath{
    NSURL *songURL = [[NSURL alloc] initFileURLWithPath:songPath];
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:&error];
    if (error) {
        NSLog(@"读取歌曲错误:%@", error.localizedDescription);
    }
    _player.delegate = self;
    
    [_lyricsView loadLyricsFile:lyricsPath];
    _lyricsList = [[NSMutableArray alloc] initWithArray:_lyricsView.lyricsList];
}

#pragma mark -- AVAudioPlayerDelegate Methods
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    NSLog(@"dsds");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.isPlay = NO;
    [self stopTimer];
    _timeCounter = 0;
}

@end