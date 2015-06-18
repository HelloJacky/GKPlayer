//
//  GKPlayerView.h
//  GKPlayer
//
//  Created by Jacky on 15/5/12.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKPlayer : UIView

/**
 *  初始化播放器并设置frame和歌词播放时的颜色
 *
 *  @param frame 播放器的frame
 *
 *  @return return value description
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  播放歌曲和歌词
 *
 *  @param songPath   歌曲文件
 *  @param lyricsPath 歌词文件
 */
- (void)loadSongFile:(NSString *)songPath andLyricsFile:(NSString *)lyricsPath;


@end
