//
//  GKLyricsTableViewCell.m
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "GKLyricsTableViewCell.h"
#import "GKLyricLineView.h"
#import "GKPlayerDefine.h"

@interface GKLyricsTableViewCell()

@property (nonatomic, strong) GKLyric *lyric;
@property (nonatomic, strong) GKLyricLineView *lyricLineView;

@end

@implementation GKLyricsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.lyricLineView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayNotification:) name:kNOTIFICATION_PLAYER_PLAY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePauseNotification:) name:kNOTIFICATION_PLAYER_PAUSEL object:nil];
        
        [self setupConstraints];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- Layout

- (void)setupConstraints{
    [self.lyricLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *bindings = NSDictionaryOfVariableBindings(_lyricLineView);
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.lyricLineView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.lyricLineView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=0)-[_lyricLineView]-(>=0)-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:bindings]];
}

#pragma mark -- Config Method

- (void)configCellWithLyric:(GKLyric *)lyric{
    self.lyric = lyric;
    [self.lyricLineView setLineText:lyric.text];
}

#pragma mark -- Notification Methods

- (void)handlePlayNotification:(NSNotification *)notification{
    GKLyric *handleLyric = notification.object;
    if (handleLyric.playTime == self.lyric.playTime) {
        [self.lyricLineView startAnimationWithDuration:self.lyric.playDuration];
    }
}

- (void)handlePauseNotification:(NSNotification *)notification{
    GKLyric *handleLyric = notification.object;
    if (handleLyric.playTime == self.lyric.playTime) {
        [self.lyricLineView pauseAnimation];
    }
}

#pragma mark -- Setters And Getters

- (GKLyricLineView *)lyricLineView{
    if (_lyricLineView == nil) {
        _lyricLineView = [[GKLyricLineView alloc] init];
    }
    return _lyricLineView;
}

@end
