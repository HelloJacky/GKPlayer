//
//  GKSong.h
//  GKPlayer
//
//  Created by Jacky on 15/6/19.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKSong : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, assign) double duration;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSArray *lyricList;

@end
