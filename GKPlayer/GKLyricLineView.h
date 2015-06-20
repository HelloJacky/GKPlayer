//
//  GKGreenLyricsLabel.h
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKLyricLineView : UIView



- (instancetype)initWithAnimationColor:(UIColor *)color;

- (void)setLineText:(NSString *)text;

- (void)startAnimationWithDuration:(CFTimeInterval)duration;

- (void)pauseAnimation;

- (void)resumeAnimation;

- (void)removeAnimation;

@end
