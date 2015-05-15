//
//  GKLyricsView.h
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKLyricsTableViewCell.h"

@interface GKLyricsView : UIView

@property (nonatomic, strong, readonly) NSMutableArray *lyricsList;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)loadLyricsFile:(NSString *)path;


@end
