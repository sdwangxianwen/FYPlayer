//
//  FYPlayerModel.h
//  avplayer
//
//  Created by wang on 2018/12/10.
//  Copyright © 2018 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FYPlayerModel : NSObject

@property(nonatomic,copy) NSString *name; //歌曲名称
@property(nonatomic,copy) NSString  *source; //本地歌曲路径
@property(nonatomic,copy) NSString  *urlString; //网络歌曲URL
@property(nonatomic,assign) NSInteger itemID; //播放内容的Id

@end

NS_ASSUME_NONNULL_END
