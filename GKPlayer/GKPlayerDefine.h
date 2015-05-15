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

#define kNOTIFICATION_SHOWLYRICS    @"ShowLyrics"

#define kNOTIFICATION_PLAYLYRICS    @"PlayLyrics"

#define kNOTIFICATION_PAUSELYRICS   @"PauseLyrics"

#endif
