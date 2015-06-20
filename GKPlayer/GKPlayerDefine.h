//
//  GKPlayerDefine.h
//  GKPlayer
//
//  Created by Jacky on 15/5/14.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#ifndef GKPlayer_GKPlayerDefine_h
#define GKPlayer_GKPlayerDefine_h

#define UIColorFrom16RGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

//#define kNOTIFICATION_SHOWLYRICS    @"ShowLyrics"

#define kNOTIFICATION_PLAYER_PLAY       @"PlayerPlay"

#define kNOTIFICATION_PLAYER_PAUSEL     @"PlayerPause"

#define kNOTIFICATION_PLAYER_STOP       @"PlayerStop"

#define KCOLOR_DEFAULT                  UIColorFrom16RGBA(0Xf1c40f, 1.0)

#endif
