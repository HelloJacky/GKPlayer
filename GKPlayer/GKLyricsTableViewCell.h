//
//  GKLyricsTableViewCell.h
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKLyric.h"

@interface GKLyricsTableViewCell : UITableViewCell

- (void)configCellWithLyric:(GKLyric *)lyrics;

@end
