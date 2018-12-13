//
//  FYAVPlayer.m
//  avplayer
//
//  Created by wang on 2018/11/27.
//  Copyright © 2018 wang. All rights reserved.
//

#import "FYAVPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "FYPlayerModel.h"

@interface FYAVPlayer () {
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
}

/**当前音频总时长*/
@property (nonatomic, assign) CGFloat totalTime;
@property(nonatomic,copy) playFinshBlock playFinshBlock;

@end

@implementation FYAVPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

-(instancetype)initWith:(NSString *)filePath  delegate:(id<FYPlayerDelegate>)delegate playerSourceTag:(NSInteger)playerSourceTag playFinshed:(playFinshBlock)playFinshed {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.playerSourceTag = playerSourceTag;
        [self playerStart:filePath];
        self.playFinshBlock = playFinshed;
    }
    return self;
}


-(void)playWith:(NSString *)filePath playFinshed:(playFinshBlock)playFinshed {
    [self playerStart:filePath];
    self.playFinshBlock = playFinshed;
}


/**加载 AVPlayer*/
- (void)loadPlayerWithItemUrl:(NSURL *)url{
    _playerItem = [[AVPlayerItem alloc] initWithURL:url];
    _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    [self addObserver];
    self.totalTime = CMTimeGetSeconds(_player.currentItem.asset.duration);
}

//MARK:开始播放
- (void)playerStart:(NSString *)filePath {
    [self stop];
    if (!filePath || filePath.length <= 0) {
        return;
    }
    // 设置播放的url
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([filePath hasPrefix:@"http"]) {
        url = [NSURL URLWithString:filePath];
    }
    [self loadPlayerWithItemUrl:url];
   
}

-(void)setIsCycle:(BOOL)isCycle {
    _isCycle = isCycle;
}

#pragma mark - 监听
// 添加监听
-(void)respondDelegate:(CMTime)time {
    [self.delegate audioPlaying:CMTimeGetSeconds(_playerItem.duration) time:CMTimeGetSeconds(time)];
}
- (void)addObserver {
    FYAVPlayer __weak *weakSelf = self;
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlaying:time:)]) {
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [weakSelf respondDelegate:time];
        }];
    }
    [self addPlayerObserver];
}

-(void)addPlayerObserver {
    //将要进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fy_playerWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    //已经进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fy_playerDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    //监测耳机
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fy_playerAudioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    //监听播放器被打断（别的软件播放音乐，来电话）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fy_playerAudioBeInterrupted:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //监测其他app是否占据AudioSession
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fy_playerSecondaryAudioHint:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:nil];
    //播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
}
//进入后台
-(void)fy_playerWillResignActive:(NSNotification *)notificatio {
    if (self.delegate && [self.delegate respondsToSelector:@selector(enterBack)]) {
        [self.delegate enterBack];
    } else {
        [self pause];
    }
}
//进入前台
-(void)fy_playerDidEnterForeground:(NSNotification *)notificatio {
    if (self.delegate && [self.delegate respondsToSelector:@selector(enterFrant)]) {
        [self.delegate enterFrant];
    } else {
        [self play];
    }
}
//监听耳机
-(void)fy_playerAudioRouteChange:(NSNotification *)notification {
     NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable://耳机h插入
            [self play];
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable://耳机拔出，停止播放操作
            [self pause];
            break;
        default:
            break;
    }
    
}
//打电话打扰或者切换到QQ音乐,网易音乐等
-(void)fy_playerAudioBeInterrupted:(NSNotification *)notification {
     NSDictionary *dic = notification.userInfo;
    if ([dic[AVAudioSessionInterruptionTypeKey] integerValue] == 1) {//被打扰
        [self pause];
    } else {
        //打断结束,是指杀死QQ音乐的进程,暂停和将QQ音乐切入g后台该方法不走,必须杀死
        [self play];
    }
    
}
//其他音频app占据
-(void)fy_playerSecondaryAudioHint:(NSNotification *)notification{
    NSInteger type = [notification.userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] integerValue];
    if (type == 1) {//开始被其他音频占据
        NSLog(@"--  其他音频占据开始");
    }else{//占据结束
        NSLog(@"-- 其他音频占据结束");
    }
}

// 移除监听
- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//MARK:播放完成
- (void)playFinish:(NSNotification *)notification {
    [self stop];
    if (self.isCycle) {
        [self play];
    }
    if (self.playFinshBlock) {
        self.playFinshBlock();
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayFinished)]) {
        [self.delegate audioPlayFinished];
    }
}
//获取总时长
-(NSTimeInterval)getTotalTimeInterval {
   return CMTimeGetSeconds(_player.currentItem.asset.duration);
}
//MARK:播放
-(void)play {
    [_player play];
}

//MARK:暂停播放
-(void)pause {
    [_player pause];
}

//MARK:停止播放
-(void)stop {
    [_player seekToTime:kCMTimeZero];
    [_player pause];
}
//MARK:拖拽跳转
-(void)seekToTimeWith:(CGFloat)value {
    [self pause];
    [_player seekToTime:CMTimeMake(self.totalTime * value, 1)
            toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1)
          completionHandler:^(BOOL finished) {
              if (finished) {
                  [self play];
              }
          }];
}

-(void)dealloc {
    NSLog(@"移除通知");
    [self removeObserver];
    _playerItem = nil;
    [_player replaceCurrentItemWithPlayerItem:_playerItem];
}

@end
