//
//  GKGreenLyricsLabel.m
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "GKLyricLineView.h"
#import "GKPlayerDefine.h"

@interface GKLyricLineView()
@property (nonatomic, strong) UILabel *backLineLabel;
@property (nonatomic, strong) UILabel *frontLineLabel;
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, assign) BOOL isAnimationPausing;

@end

@implementation GKLyricLineView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backLineLabel];
        [self addSubview:self.frontLineLabel];
        //设置默认颜色为绿色
        self.frontLineLabel.textColor = KCOLOR_DEFAULT;
        [self setupConstraints];
    }
    return self;
}

- (instancetype)initWithAnimationColor:(UIColor *)color{
    self = [self init];
    if (self) {
        self.frontLineLabel.textColor = color;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    _maskLayer.frame = CGRectOffset(self.frontLineLabel.frame, -self.frontLineLabel.frame.size.width, 0);
}

#pragma mark -- Animation Methods

- (void)startAnimationWithDuration:(CFTimeInterval)duration{
    if (self.isAnimationPausing) {
        [self resumeAnimation];
        return;
    }
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(self.maskLayer.frame.origin.x, 0)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.values = values;
    animation.duration = duration/1000;
    animation.calculationMode = kCAAnimationLinear;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    [self.maskLayer addAnimation:animation forKey:@"MaskAnimation"];
}

- (void)pauseAnimation{
    CFTimeInterval pausedTime = [self.maskLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.maskLayer.speed = 0.0;
    self.maskLayer.timeOffset = pausedTime;
    self.isAnimationPausing = YES;
}

- (void)resumeAnimation{
    CFTimeInterval pausedTime = [self.maskLayer timeOffset];
    self.maskLayer.speed = 1.0;
    self.maskLayer.timeOffset = 0.0;
    CFTimeInterval timeSincePause = [self.maskLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.maskLayer.beginTime = timeSincePause;
    self.isAnimationPausing = NO;
}

- (void)removeAnimation{
    [self.maskLayer removeAnimationForKey:@"MaskAnimation"];
}

#pragma mark -- Layout

- (void)setupConstraints{
    [self.frontLineLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.backLineLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(_frontLineLabel, _backLineLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_backLineLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backLineLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_frontLineLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_frontLineLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
}

#pragma mark -- Setters And Getters

- (UILabel *)backLineLabel{
    if (_backLineLabel == nil) {
        _backLineLabel = [[UILabel alloc] init];
        _backLineLabel.backgroundColor = [UIColor clearColor];
        _backLineLabel.textColor = [UIColor whiteColor];
    }
    
    return _backLineLabel;
}

- (UILabel *)frontLineLabel{
    if (_frontLineLabel == nil) {
        _frontLineLabel = [[UILabel alloc] init];
        _frontLineLabel.backgroundColor = [UIColor clearColor];
        _frontLineLabel.layer.mask = self.maskLayer;
    }
    return _frontLineLabel;
}

- (CALayer *)maskLayer{
    if (_maskLayer == nil) {
        _maskLayer = [CALayer layer];
        _maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        _maskLayer.anchorPoint = CGPointZero;
    }
    return _maskLayer;
}

- (void)setLineText:(NSString *)text{
    self.backLineLabel.text = text;
    self.frontLineLabel.text = text;
}


@end
