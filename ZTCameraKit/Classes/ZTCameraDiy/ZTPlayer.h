//
//  ZTPlayer.h
//  ZTCameraKit
//
//  Created by zttina on 2019/3/15.
//  Copyright © 2019年 zttina. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZTPlayer : UIView

@property (nonatomic, strong) NSURL *videoUrl;

/**
 开始播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 重置
 */
- (void)reset;

/**
 是否正在播放
 */
- (BOOL)isPlay;
@end

NS_ASSUME_NONNULL_END
