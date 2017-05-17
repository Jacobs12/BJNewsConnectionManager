//
//  MYConnection.h
//  BJNewsAppBeta
//
//  Created by paiBo on 15-2-11.
//  Copyright (c) 2015年 灰太狼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYReuqest.h"
#import "FTSessionRequest.h"

typedef void (^postFinishBlock) (NSData *responseData);
typedef void (^postFailedBlock) ();
typedef void (^CacheBlock) (NSData * cacheData);

@interface MYConnection : NSObject

/**
 GET 请求
 
 @param url url
 @param finish finish block
 @param failed failed block -> internet unconnected or connection failed
 */
+ (void)connectionWithURL:(NSString *)url finish:(FinishBlock)finish failed:(FailedBlock)failed;

/**
 GET请求并自动缓存/更新缓存

 @param url url
 @param cache cache block
 @param finish finish block
 @param failed failed block
 */
+ (void)connectionWithURL:(NSString *)url cacheData:(CacheBlock)cache finish:(FinishBlock)finish failed:(FailedBlock)failed;
/**
 POST请求
 
 @param url url -> string
 @param body body -> string
 @param finish finish block
 @param failed internet unconnected or connection failed
 */
+ (void)postRequestToHostUrl:(NSString *)url withBody:(NSString *)body finished:(postFinishBlock)finish failed:(postFailedBlock)failed;

/**
 Json解析时判断是否为空

 @param item item -> id
 @return 是否为空
 */
+ (BOOL)isJsonDataNull:(id)item;

@end
