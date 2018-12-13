//
//  ViewController.m
//  avplayer
//
//  Created by wang on 2018/11/26.
//  Copyright © 2018 wang. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FYAVPlayer.h"
#import "FYPlayerModel.h"

@interface ViewController ()<FYPlayerDelegate> {
     AVAudioPlayer *_musicPlay;//音乐播放器
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL hasObserver;
@property(nonatomic,strong) FYAVPlayer  *audioPlayer;
@property(nonatomic,strong) FYAVPlayer  *audioPlayer1;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property(nonatomic,assign) CGFloat progress; //播放进度

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


//拖拽的响应事件
- (IBAction)progressChaged:(UISlider *)sender {
    self.playBtn.selected = YES;
   [self.audioPlayer seekToTimeWith:sender.value];
}

- (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime {
    self.progress = currentTime / totalTime;
    self.progressSlider.value = self.progress;

}
-(void)audioPlayFinished {
 
}
- (void)enterFrant {
    //进入前台的操作
    NSLog(@"进入前台");
}
-(void)enterBack {
    //进入后台的操作
    NSLog(@"进入后台");
}

- (FYAVPlayer *)audioPlayer {
    if (_audioPlayer == nil) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"starpop" ofType:@"mp3"];
        _audioPlayer = [[FYAVPlayer alloc] initWith:filePath delegate:self playerSourceTag:10000 playFinshed:^{
             NSLog(@"90播放完成");
        }];
        _audioPlayer.isCycle = YES;
    }
    return _audioPlayer;
}
- (FYAVPlayer *)audioPlayer1 {
    if (_audioPlayer1 == nil) {
        _audioPlayer1 = [[FYAVPlayer alloc] init];
        _audioPlayer1.delegate = self;
    }
    return _audioPlayer1;
}


//播放
- (IBAction)play:(UIButton *)sender {
    if (sender.selected) {
        [self.audioPlayer pause];
        sender.selected = NO;
    } else {
        [self.audioPlayer play];
         sender.selected = YES;
    }
}

//停止
- (IBAction)stop:(id)sender {
    self.playBtn.selected = NO;
    [self.audioPlayer stop];
}


@end
