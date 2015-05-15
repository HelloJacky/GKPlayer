//
//  GKGreenLyricsLabel.m
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "GKLyricLineView.h"

@implementation GKLyricLineView{
    UILabel *_whiteLabel;
    UILabel *_greenLabel;
    CALayer *_greenMaskLayer;
    
    double _duration;        //播放的总时长
    double _playedDuration;  //已经播放的时长
    
    BOOL _isPausing;        //当前是否处于暂停状态
//    GKLyric *_lyric;
}

- (id)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _whiteLabel = [[UILabel alloc] init];
        _whiteLabel.backgroundColor = [UIColor clearColor];
        _whiteLabel.textColor = [UIColor whiteColor];
        [self addSubview:_whiteLabel];
        
        _greenLabel = [[UILabel alloc] init];
        _greenLabel.backgroundColor = [UIColor clearColor];
        _greenLabel.textColor = [UIColor greenColor];
        [self addSubview:_greenLabel];
        
        _greenMaskLayer = [CALayer layer];
        _greenMaskLayer.backgroundColor = [UIColor blackColor].CGColor;
        _greenMaskLayer.anchorPoint = CGPointZero;
        _greenLabel.layer.mask = _greenMaskLayer;
//        _greenLabel.layer.borderWidth = 1.f;
        
        [self setupConstraints];
    }
    return self;
}


- (void)setupConstraints{
    [_greenLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_whiteLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(_greenLabel, _whiteLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_whiteLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_whiteLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_greenLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_greenLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
}



- (void)setLyricText:(NSString *)text withDuration:(double)duration andPlayedDuration:(double)playedDuration{
    [self removeAnimation];
    _whiteLabel.text = text;
    _greenLabel.text = text;
    _duration = duration;
    _playedDuration = playedDuration;
    
    _greenMaskLayer.speed = 1.0;
    _greenMaskLayer.timeOffset = 0.0;
    _greenMaskLayer.beginTime = 0.0;
//    _greenMaskLayer.frame = CGRectZero;
    
    _isPausing = NO;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (_playedDuration != 0) {
        //求出已播放时间占比
        double playedProportion = _playedDuration / _duration;
        
        _duration -= _playedDuration;
        
        _greenMaskLayer.frame = CGRectOffset(_greenLabel.frame,
                                             -_greenLabel.frame.size.width * (1- playedProportion),
                                             0);
    }else{
        _greenMaskLayer.frame = CGRectOffset(_greenLabel.frame,
                                             -_greenLabel.frame.size.width,
                                             0);
    }
    
}


- (void)startAnimation{
    if (_isPausing) {
        [self resumeAnimation];
        return;
    }
    
//    NSMutableArray *keyTimes = [NSMutableArray arrayWithArray:@[@0.1,@0.2,@0.3,@0.4,@0.5,@0.6,@0.7,@0.8,@0.9,@1]];
    
//    CGFloat wordWidth = self.frame.size.width/_greenLabel.text.length;
    NSMutableArray *values = [NSMutableArray array];
    
//    for (int i = 0; i <= _greenLabel.text.length; i++) {
//        CGPoint p = CGPointMake(-(self.frame.size.width - i*wordWidth), 0);
//        [values addObject:[NSValue valueWithCGPoint:p]];
//    }
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(_greenMaskLayer.frame.origin.x, 0)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //    animation.beginTime = CACurrentMediaTime() + _lyrics.playTime/1000;
//    animation.keyTimes = keyTimes;
    animation.values = values;
    animation.duration = _duration/1000;
    animation.calculationMode = kCAAnimationLinear;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.delegate = self;
    [_greenMaskLayer addAnimation:animation forKey:@"MaskAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    //动画结束后，回复leyer的初始位置
    if (flag) {
        _greenMaskLayer.frame = CGRectMake(-1000, 0, 0, 0);
    }

}


- (void)pauseAnimation{
    CFTimeInterval pausedTime = [_greenMaskLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    _greenMaskLayer.speed = 0.0;
    _greenMaskLayer.timeOffset = pausedTime;
    _isPausing = YES;
}

-(void)resumeAnimation{
    CFTimeInterval pausedTime = [_greenMaskLayer timeOffset];
    _greenMaskLayer.speed = 1.0;
    _greenMaskLayer.timeOffset = 0.0;
//    _greenMaskLayer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [_greenMaskLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    _greenMaskLayer.beginTime = timeSincePause;
}

- (void)removeAnimation{
    [_greenMaskLayer removeAnimationForKey:@"MaskAnimation"];
    _greenMaskLayer.frame = CGRectMake(-1000, 0, 0, 0);
}


@end
