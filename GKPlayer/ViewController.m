//
//  ViewController.m
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "ViewController.h"
#import "GKLyricsView.h"

#import "GKPlayer.h"

@interface ViewController ()

@end

@implementation ViewController{
    GKLyricsView *_lyricsView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *songPath =[[NSBundle mainBundle] pathForResource:@"月半小夜曲" ofType:@"mp3"];
    NSString *lyricsPath = [[NSBundle mainBundle] pathForResource:@"李克勤 - 月半夜小夜曲" ofType:@"lrc"];

    GKPlayer *player = [[GKPlayer alloc] initWithFrame:self.view.frame];
    [self.view addSubview:player];
    [player loadSongFile:songPath andLyricsFile:lyricsPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
