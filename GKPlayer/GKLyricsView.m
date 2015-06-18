//
//  GKLyricsView.m
//  GKPlayer
//
//  Created by Jacky on 15/5/6.
//  Copyright (c) 2015年 Jacky. All rights reserved.
//

#import "GKLyricsView.h"

@interface GKLyricsView() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *lyricsFile;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) BOOL isTimerRunning;

@end

@implementation GKLyricsView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark -- Lyrics File Handle Methods

- (void)loadLyricsFile:(NSString *)path{
    _lyricsList = [NSMutableArray array];
    _lyricsFile = [path copy];
    NSError *error;
    NSString *lyricsString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    [self handleLyricsString:lyricsString];
    [self.tableView reloadData];
}

- (void)handleLyricsString:(NSString *)lyricsString{
    NSArray *lineList = [lyricsString componentsSeparatedByString:@"\n"];
    NSString *timeRegexStr = @"^\\[\\d+:\\d+.\\d+\\]";
    for (NSString *line in lineList) {
        NSRegularExpression *timeReg = [NSRegularExpression regularExpressionWithPattern:timeRegexStr
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
        NSArray *timeMatches = [timeReg matchesInString:line
                                                options:0
                                                  range:NSMakeRange(0, [line length])];
        
        if (timeMatches.count > 0) {
            NSTextCheckingResult *result = [timeMatches lastObject];
            NSString *timeString = [line substringWithRange:result.range];
            GKLyric *lyrics = [[GKLyric alloc] init];
            NSInteger palyTime = [self lyricsPlayTimeFromString:timeString];
            lyrics.playTime = palyTime;
            lyrics.text = [line substringWithRange:NSMakeRange(result.range.location + result.range.length, line.length - result.range.length)];
            
            //取出上一句歌词，用来计算歌词的播放时间
            GKLyric *prevLyrics = [_lyricsList lastObject];
            if (prevLyrics) {
                prevLyrics.playDuration = lyrics.playTime - prevLyrics.playTime;
            }
            
            [_lyricsList addObject:lyrics];
        }else{
            continue;
        }
    }
    [self filterInvalidLyrics:_lyricsList];
}

- (void)filterInvalidLyrics:(NSMutableArray *)list{
    if (list.count == 0) {
        return;
    }
    NSMutableArray *filterList = [NSMutableArray array];
    for (GKLyric *tmpLyrics in _lyricsList) {
        if (tmpLyrics.text.length == 0 || tmpLyrics.playTime == 0) {
            [filterList addObject:tmpLyrics];
        }
    }
    
    [_lyricsList removeObjectsInArray:filterList];
}

- (NSInteger)lyricsPlayTimeFromString:(NSString *)str{
    NSString *minuteStr = [str substringWithRange:NSMakeRange(1, 2)];
    NSString *secondStr = [str substringWithRange:NSMakeRange(4, 2)];
    NSString *milliSecondStr = [str substringWithRange:NSMakeRange(7, 2)];
    
    NSInteger totleMilliSecond = [minuteStr integerValue] * 60 * 1000 + [secondStr integerValue] * 1000 + [milliSecondStr integerValue];
    
    return totleMilliSecond;
}

#pragma mark -- UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _lyricsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdetifier = [NSString stringWithFormat:@"LyricsCell_%ld",(long)indexPath.row];
    GKLyricsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdetifier];
    if (!cell) {
        cell = [[GKLyricsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdetifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    GKLyric *lyrics = _lyricsList[indexPath.row];
    [cell configCellWithLyric:lyrics];
    
    return cell;
}

#pragma mark -- UITableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

#pragma mark -- Setters And Getters

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.frame];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

@end
