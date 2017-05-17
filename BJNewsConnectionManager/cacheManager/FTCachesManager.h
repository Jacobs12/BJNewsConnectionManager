//
//  FTCachesManager.h
//  FTDataBase缓存管理
//
//  Created by Wolffy on 15-1-5.
//  Copyright (c) 2015年 Wolffy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FTDataBaseManager.h"

/**
 缓存管理类
 */
@interface FTCachesManager : FTDataBaseManager

/**设置缓存有效时间*/
@property CGFloat onTimeHours;
/**
 单例创建

 @return cache manager
 */
+ (instancetype)defaultManager;

/**
 判断一个缓存是否有效，是否超时 -> enabled = NO

 @param url url key
 @return BOOL
 */
- (BOOL)isOnTimeForURL:(NSString *)url;

/**
 同步，储存一个网址和数据

 @param url key
 @param data value -> data
 */
- (void)synchroiedURL:(NSString *)url data:(NSData *)data;

/**
 根据网址，返回缓存数据

 @param url key
 @return value -> data
 */
- (NSData *)dataForURL:(NSString *)url;

/**
 删除一条信息

 @param url key
 */
- (void)removeRecordwithURL:(NSString *)url;

/**
 删除所有缓存数据
 */
- (void)cleanDataBase;

@end
