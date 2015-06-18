//
//  GKLyrics.h
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKLyric : NSObject

//歌词
@property (nonatomic, copy) NSString *text;

//播放时刻，毫秒
@property (nonatomic, assign) double playTime;

//播放时长，毫秒
@property (nonatomic, assign) double playDuration;



@end
