//
//  GKPlayerView.h
//  GKPlayer
//
//  Created by Jacky on 15/5/12.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKPlayer : UIView

- (void)loadSongFile:(NSString *)songPath andLyricsFile:(NSString *)lyricsPath;

@end
