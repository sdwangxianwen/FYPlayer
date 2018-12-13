//
//  FYAVPlayer.h
//  avplayer
//
//  Created by wang on 2018/11/27.
//  Copyright © 2018 wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class FYAVPlayer;
@protocol FYPlayerDelegate <NSObject>
/// 结束播放音频
- (void)audioPlayFinished;
@optional
/// 正在播放音频（总时长，当前时长）
- (void)audioPlaying:(NSTimeInterval)totalTime time:(NSTimeInterval)currentTime;
//进入后台的代理
-(void)enterBack;
//进入前台的处理
-(void)enterFrant;
@end


NS_ASSUME_NONNULL_BEGIN

typedef void(^playFinshBlock)(void); //播放完毕的Block
@interface FYAVPlayer : NSObject
/// 代理
@property (nonatomic, weak) id<FYPlayerDelegate> delegate;
@property(nonatomic,assign) NSInteger playerSourceTag; //当前播放的数据的id
@property(nonatomic,assign) BOOL isCycle; //是否循环播放,默认否

//block回调播放完成的初始化方式
-(instancetype)initWith:(NSString *)filePath delegate:(id<FYPlayerDelegate>)delegate playerSourceTag:(NSInteger)playerSourceTag playFinshed:(playFinshBlock)playFinshed;
/// 开始播放单曲
- (void)playerStart:(NSString *)filePath;

//播放数据,播放完成的回调
-(void)playWith:(NSString *)filePath playFinshed:(playFinshBlock)playFinshed;
/**
 播放
 */
-(void)play;
/**
 暂停播放
 */
-(void)pause;
//停止播放
-(void)stop;
//跳转进度
-(void)seekToTimeWith:(CGFloat)value;
/**
 获取总时长
 */
-(NSTimeInterval)getTotalTimeInterval;

@end

NS_ASSUME_NONNULL_END
