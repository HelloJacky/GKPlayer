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

@property (nonatomic, strong) GKLyricsView *lyricsView;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *playPauseButton;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSInteger timeCounter;
@property (nonatomic, assign) BOOL isTimerRunning;
@property (nonatomic, assign) BOOL isPlay;

@property (nonatomic, strong) NSMutableArray *lyricsList;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) GKLyric *currentLyric;

@end

@implementation GKPlayer

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self setupTimer];
    }
    return self;
}

#pragma mark -- Setup Methods

- (void)setupViews{
    [self.controlView addSubview:self.playPauseButton];
    [self addSubview:self.controlView];
    [self addSubview:self.lyricsView];
}

- (void)setupTimer{
    uint64_t interval = NSEC_PER_MSEC;
    dispatch_queue_t queue = dispatch_queue_create("com.gkplayer.timer", NULL);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        self.timeCounter++;
        GKLyric *lyric = _lyricsList[0];
        if (lyric != nil) {
            //判读是否到了当前歌词播放的时间
            if (self.timeCounter == lyric.playTime) {
                NSLog(@"[%ld]%@", (long)_timeCounter, lyric.text);
            
                //设置两句之间的时间跳跃间隔，降低比较次数
                dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_MSEC), interval, 0);
                self.timeCounter += 30;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    //更新当前歌词
                    self.currentLyric = lyric;
                    //放出通知，开始歌词动画
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PLAYER_PLAY object:lyric];
                    //播放后就移除该句歌词
                    [self.lyricsList removeObject:lyric];
                });
            }
        }
        if (self.lyricsList.count == 0) {
            [self stopTimer];
        }
    });
}

#pragma mark -- Player Timer Methods

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

#pragma mark -- Player Control Methods

- (void)playPauseButtonClick{
    if (!self.isPlay) {
        //处于暂停状态
        [self play];
    }else{
        //处于播放状态
        [self pause];
    }
    
}

- (void)play{
    self.isPlay = YES;
    [self.player play];
    [self startTimer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PLAYER_PLAY object:_currentLyric];
}

- (void)pause{
    self.isPlay = NO;
    [self stopTimer];
    [self.player pause];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_PLAYER_PAUSEL object:_currentLyric];
}

#pragma mark -- Lyrics Manage Methods

- (void)loadSongFile:(NSString *)songPath andLyricsFile:(NSString *)lyricsPath{
    NSURL *songURL = [[NSURL alloc] initFileURLWithPath:songPath];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:&error];
    if (error) {
        NSLog(@"读取歌曲错误:%@", error.localizedDescription);
    }
    self.player.delegate = self;
    
    [self.lyricsView loadLyricsFile:lyricsPath];
    self.lyricsList = [[NSMutableArray alloc] initWithArray:_lyricsView.lyricsList];
}

#pragma mark -- AVAudioPlayerDelegate Methods

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    NSLog(@"dsds");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.isPlay = NO;
    [self stopTimer];
    self.timeCounter = 0;
}

#pragma mark -- Setters And Getters

- (void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    if (isPlay) {
        _playPauseButton.selected = YES;
    }else{
        _playPauseButton.selected = NO;
    }
}

- (GKLyricsView *)lyricsView{
    if (_lyricsView == nil) {
        _lyricsView = [[GKLyricsView alloc] initWithFrame:CGRectMake(0.f,
                                                                     0.f,
                                                                     self.frame.size.width,
                                                                     CGRectGetMinY(_controlView.frame))];
    }
    return _lyricsView;
}

- (UIView *)controlView{
    if (_controlView == nil) {
        CGFloat controlViewHeight = 100.f;
        _controlView = [[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                                self.frame.size.height - controlViewHeight,
                                                                self.frame.size.width,
                                                                controlViewHeight)];
        _controlView.backgroundColor = [UIColor whiteColor];
    }
    return _controlView;
}

- (UIButton *)playPauseButton{
    if (_playPauseButton == nil) {
        CGFloat playPauseBtnWidth = 60.f;
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        _playPauseButton.layer.masksToBounds = YES;
        _playPauseButton.frame = CGRectMake((self.controlView.frame.size.width - playPauseBtnWidth)/2,
                                            (self.controlView.frame.size.height - playPauseBtnWidth)/2,
                                            playPauseBtnWidth,
                                            playPauseBtnWidth);
        _playPauseButton.layer.borderWidth = 1.f;
        _playPauseButton.layer.cornerRadius = playPauseBtnWidth/2;
        _playPauseButton.layer.borderColor = UIColorFrom16RGBA(0xF5A623, 1.0).CGColor;
        [_playPauseButton addTarget:self action:@selector(playPauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playPauseButton;
}


@end
