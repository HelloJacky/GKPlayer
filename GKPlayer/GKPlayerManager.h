//
//  GKPlayerManager.h
//  GKPlayer
//
//  Created by Jacky on 15/6/19.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKSong.h"
#import "GKLyric.h"
#import "GKPlayerDefine.h"

@interface GKPlayerManager : NSObject

@property (nonatomic, assign, readonly) BOOL isPlay;                //播放器是否正在运行
@property (nonatomic, strong, readonly) GKSong *currentSong;        //当前播放的歌曲

+ (instancetype)sharedInstance;

- (void)play;

- (void)pause;

- (void)loadSongFile:(NSString *)songPath
       andLyricsFile:(NSString *)lyricsPath
          completion:(void (^)(GKSong *song))completion;

@end
