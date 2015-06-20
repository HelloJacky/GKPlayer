//
//  GKPlayerView.m
//  GKPlayer
//
//  Created by Jacky on 15/5/12.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "GKPlayer.h"
#import "GKLyricsTableViewCell.h"
#import "UIImageView+LBBlurredImage.h"
#import "GKPlayerManager.h"

#define ControlViewHeight 120.f

@interface GKPlayer() <UITableViewDelegate, UITableViewDataSource>

//@property (nonatomic, strong) GKLyricsView *lyricsView;
@property (nonatomic, strong) NSString *lyricsFile;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundCoverView;
@property (nonatomic, strong) UISlider *progressSlider;

@property (nonatomic, strong) UIView *gradientView;

@property (nonatomic, assign) BOOL isPlay;

@property (nonatomic, strong) GKPlayerManager *playerManager;
@property (nonatomic, strong) GKSong *currentSong;



@end

@implementation GKPlayer

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        self.playerManager = [GKPlayerManager sharedInstance];
    }
    return self;
}

#pragma mark -- Setup Methods

- (void)setupViews{
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.backgroundCoverView];
    [self.controlView addSubview:self.playPauseButton];
    [self addSubview:self.tableView];
    [self addSubview:self.controlView];
    [self.controlView addSubview:self.progressSlider];
    //    [self addSubview:self.gradientView];
}


#pragma mark -- Load Song
- (void)loadSongFile:(NSString *)songPath
       andLyricsFile:(NSString *)lyricsPath{
    [self.playerManager loadSongFile:songPath
                       andLyricsFile:lyricsPath
                          completion:^(GKSong *song) {
                              self.currentSong = song;
                              [self.backgroundImageView setImageToBlur:[UIImage imageWithData:song.imageData] blurRadius:0 completionBlock:nil];
                              [self.tableView reloadData];
                          }];
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
    [self.playerManager play];
}

- (void)pause{
    self.isPlay = NO;
    [self.playerManager pause];
}


#pragma mark -- UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentSong.lyricList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdetifier = [NSString stringWithFormat:@"LyricsCell_%ld",(long)indexPath.row];
    GKLyricsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdetifier];
    if (!cell) {
        cell = [[GKLyricsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdetifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    GKLyric *lyrics =self.currentSong.lyricList[indexPath.row];
    [cell configCellWithLyric:lyrics];
    
    return cell;
}

#pragma mark -- UITableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

#pragma mark -- Setters And Getters

- (void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    if (isPlay) {
        //        _playPauseButton.selected = YES;
        [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }else{
        //        _playPauseButton.selected = NO;
        [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height - ControlViewHeight)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    
    return _tableView;
}

- (UIImageView *)backgroundImageView{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return _backgroundImageView;
}

- (UIView *)backgroundCoverView{
    if (_backgroundCoverView == nil) {
        _backgroundCoverView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundCoverView.backgroundColor = UIColorFrom16RGBA(0x333333, 0.3);
    }
    
    return _backgroundCoverView;
}

- (UIView *)gradientView{
    if (_gradientView == nil) {
        _gradientView = [[UIView alloc] initWithFrame:self.tableView.frame];
        _gradientView.userInteractionEnabled = NO;
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = _gradientView.frame;
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0.3 alpha:0.1].CGColor,
                                 (__bridge id)[UIColor clearColor].CGColor,
                                 (__bridge id)[UIColor clearColor].CGColor,
                                 (__bridge id)[UIColor colorWithWhite:0.3 alpha:0.1].CGColor];
        gradientLayer.locations =  @[@0.0, @0.25, @0.75, @1];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        [_gradientView.layer addSublayer:gradientLayer];
    }
    
    return _gradientView;
}

- (UIView *)controlView{
    if (_controlView == nil) {
        _controlView = [[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                                self.frame.size.height - ControlViewHeight,
                                                                self.frame.size.width,
                                                                ControlViewHeight)];
        _controlView.backgroundColor = [UIColor clearColor];
    }
    return _controlView;
}

- (UIButton *)playPauseButton{
    if (_playPauseButton == nil) {
        CGFloat playPauseBtnWidth = 60.f;
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playPauseButton.adjustsImageWhenHighlighted = NO;
        _playPauseButton.layer.masksToBounds = YES;
        [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        _playPauseButton.frame = CGRectMake((self.controlView.frame.size.width - playPauseBtnWidth)/2,
                                            (self.controlView.frame.size.height - playPauseBtnWidth)/2,
                                            playPauseBtnWidth,
                                            playPauseBtnWidth);
        _playPauseButton.layer.borderWidth = 2.f;
        _playPauseButton.layer.cornerRadius = playPauseBtnWidth/2;
        _playPauseButton.layer.borderColor = KCOLOR_DEFAULT.CGColor;
        [_playPauseButton addTarget:self action:@selector(playPauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playPauseButton;
}

- (UISlider *)progressSlider{
    if (_progressSlider == nil) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(0.f, 0.f, self.controlView.frame.size.width, 10.f)];
        self.progressSlider.maximumTrackTintColor = [UIColor lightGrayColor];
        self.progressSlider.minimumTrackTintColor = KCOLOR_DEFAULT;
        self.progressSlider.thumbTintColor = KCOLOR_DEFAULT;
        //        self.progressSlider.layer.borderWidth = 1.f;
    }
    
    return _progressSlider;
}


@end
