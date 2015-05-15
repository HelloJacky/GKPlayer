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

#define kLabelHeight 20.f

@implementation GKLyricsTableViewCell{
    GKLyric *_lyric;
    GKLyricLineView *_lyricLineView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
        _lyricLineView = [[GKLyricLineView alloc] init];
//        _lyricsLabel.layer.borderWidth = 1.f;
        [self.contentView addSubview:_lyricLineView];
        
        [_lyricLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *bindings = NSDictionaryOfVariableBindings(_lyricLineView);
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_lyricLineView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_lyricLineView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1
                                                                      constant:0]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=0)-[_lyricLineView]-(>=0)-|"
                                                                                 options:NSLayoutFormatAlignAllLeft
                                                                                 metrics:nil
                                                                                   views:bindings]];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayNotification:) name:kNOTIFICATION_SHOWLYRICS object:nil];
    }
    
    return self;
}



- (void)prepareForReuse{
    [super prepareForReuse];
    _lyric = nil;
    [_lyricLineView removeAnimation];
    [_lyric removeObserver:self forKeyPath:@"isPausing"];
    [_lyric removeObserver:self forKeyPath:@"isPlaying"];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [_lyricLineView layoutIfNeeded];
}

- (void)configCellWithLyric:(GKLyric *)lyric{
    _lyric = lyric;
    double playedDuration = 0;
    if (lyric.isPausing || lyric.isPlaying) {
        playedDuration  = _lyric.currentPlayTime - _lyric.playTime;
    }
    
    [_lyricLineView  setLyricText:lyric.text
                     withDuration:_lyric.playDuration
                andPlayedDuration:playedDuration];
    
    if (_lyric.isPlaying && !_lyric.isPausing) {
        [_lyricLineView startAnimation];
    }
    
    [_lyric addObserver:self
             forKeyPath:@"isPausing"
                options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                context:NULL];
    
    [_lyric addObserver:self
             forKeyPath:@"isPlaying"
                options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isPausing"]) {
        if (_lyric.isPausing) {
            [_lyricLineView pauseAnimation];
        }else{
            [_lyricLineView startAnimation];
        }
    }
    
    if ([keyPath isEqualToString:@"isPlaying"]) {
        if (_lyric.isPlaying && !_lyric.isPausing) {
            [_lyricLineView startAnimation];
        }
    }
}



//- (void)handlePlayNotification:(NSNotification *)notif{
//    GKLyric *lyric = notif.object;
//    if (lyric.playTime == _lyric.playTime) {
//        [_lyricLineView startAnimationWithDuration:_lyric.playInterval/1000];
//    }
//}


@end
