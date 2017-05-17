//
//  FTRquestManager.h
//  ASIHttpRequest封装
//
//  Created by Wolffy on 15-1-3.
//  Copyright (c) 2015年 Wolffy. All rights reserved.
        //

#import <Foundation/Foundation.h>
#import "FTRequest.h"

@interface FTRequestManager : NSObject
/**
 最大的同事下载数，超过总数，等待缓存
 */
@property NSUInteger maxCurrentReuquest;

/**
 创建单例对象

 @return default manager
 */
+ (instancetype)defaultManager;

/**
 add request

 @param url host url -> string
 @param target target
 @param finished finished block
 @param failed failer block
 */
- (void)addRequestWithURL:(NSString *)url target:(id)target finished:(SortFinishBlock)finished failed:(SortFailedBlock)failed;

/**
 remove request after request finshed -> imporment

 @param url request url
 */
- (void)removeRequestWithURL:(NSString *)url;

/**
 我也忘了这个方法是干嘛的了

 @param url 忘了
 */
- (void)manageSdImageRequest:(NSString *)url;

/**
 取消单个请求
 
 @param url url description
 */
- (void)cancelTaskWithUrl:(NSString *)url;

@end
