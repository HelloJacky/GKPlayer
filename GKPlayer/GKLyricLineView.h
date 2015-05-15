//
//  GKGreenLyricsLabel.h
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKLyric.h"

@interface GKLyricLineView : UIView

- (void)startAnimation;

- (void)pauseAnimation;

- (void)removeAnimation;

- (void)setLyricText:(NSString *)text
        withDuration:(double)duration
   andPlayedDuration:(double)playedDuration;

@end
