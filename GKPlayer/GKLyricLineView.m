//
//  GKGreenLyricsLabel.m
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "GKLyricLineView.h"

@interface GKLyricLineView()

@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, assign) BOOL isAnimationPausing;

@end

@implementation GKLyricLineView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.whiteLineLabel];
        [self addSubview:self.colorLineLabel];
        //设置默认颜色为绿色
        self.colorLineLabel.textColor = [UIColor greenColor];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)initWithAnimationColor:(UIColor *)color{
    self = [self init];
    if (self) {
        self.colorLineLabel.textColor = color;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    _maskLayer.frame = CGRectOffset(self.colorLineLabel.frame, -self.colorLineLabel.frame.size.width, 0);
}

#pragma mark -- Animation Methods

- (void)startAnimationWithDuration:(CFTimeInterval)duration{
    NSLog(@"[动画开始]%@",self.whiteLineLabel.text);
    if (self.isAnimationPausing) {
        NSLog(@"动画正在暂停中");
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
    NSLog(@"[动画暂停]%@",self.whiteLineLabel.text);
    CFTimeInterval pausedTime = [self.maskLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.maskLayer.speed = 0.0;
    self.maskLayer.timeOffset = pausedTime;
    self.isAnimationPausing = YES;
}

- (void)resumeAnimation{
    NSLog(@"[动画恢复启动]%@",self.whiteLineLabel.text);
    CFTimeInterval pausedTime = [self.maskLayer timeOffset];
    self.maskLayer.speed = 1.0;
    self.maskLayer.timeOffset = 0.0;
    CFTimeInterval timeSincePause = [self.maskLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.maskLayer.beginTime = timeSincePause;
    self.isAnimationPausing = NO;
}

- (void)removeAnimation{
    NSLog(@"[动画移除]%@",self.whiteLineLabel.text);
    [self.maskLayer removeAnimationForKey:@"MaskAnimation"];
}

#pragma mark -- Layout

- (void)setupConstraints{
    [self.colorLineLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.whiteLineLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *bindings = NSDictionaryOfVariableBindings(_colorLineLabel, _whiteLineLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_whiteLineLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_whiteLineLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_colorLineLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_colorLineLabel]|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil
                                                                   views:bindings]];
    
}

#pragma mark -- Setters And Getters

- (UILabel *)whiteLineLabel{
    if (_whiteLineLabel == nil) {
        _whiteLineLabel = [[UILabel alloc] init];
        _whiteLineLabel.backgroundColor = [UIColor clearColor];
        _whiteLineLabel.textColor = [UIColor whiteColor];
    }
    
    return _whiteLineLabel;
}

- (UILabel *)colorLineLabel{
    if (_colorLineLabel == nil) {
        _colorLineLabel = [[UILabel alloc] init];
        _colorLineLabel.backgroundColor = [UIColor clearColor];
        _colorLineLabel.layer.mask = self.maskLayer;
    }
    return _colorLineLabel;
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
    self.whiteLineLabel.text = text;
    self.colorLineLabel.text = text;
}


@end
