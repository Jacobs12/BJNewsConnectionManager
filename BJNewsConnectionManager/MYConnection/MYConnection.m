//
//  MYConnection.m
//  BJNewsAppBeta
//
//  Created by paiBo on 15-2-11.
//  Copyright (c) 2015年 paiBo. All rights reserved.
//

#import "MYConnection.h"
#import <UIKit/UIKit.h>

@implementation MYConnection

/**
 GET 请求

 @param url url -> string
 @param finish finish block
 @param failed failed block -> internet unconnected or connection failed
 */
+ (void)connectionWithURL:(NSString *)url finish:(FinishBlock)finish failed:(FailedBlock)failed{
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0){
        MYReuqest * request = [[MYReuqest alloc]init];
        request.url = url;
        request.finishBlock = finish;
        request.failedBlock = failed;
        NSURLCache * cache = [NSURLCache sharedURLCache];
        [cache removeAllCachedResponses];
        [request startRequest];
    }else{
        NSURLCache * cache = [NSURLCache sharedURLCache];
        [cache removeAllCachedResponses];
    
        FTSessionRequest * session = [[FTSessionRequest alloc]init];
        session.url = url;
        session.finishedBlock = finish;
        session.failedBlock = failed;
        [session startRequest];
    }
}

/**
 GET请求并自动缓存/更新缓存
 
 @param url url
 @param cache cache block
 @param finish finish block
 @param failed failed block
 */
+ (void)connectionWithURL:(NSString *)url cacheData:(CacheBlock)cache finish:(FinishBlock)finish failed:(FailedBlock)failed{
    NSData * cacheData = [[FTCachesManager defaultManager] dataForURL:url];
    if(cacheData && cacheData.length > 10){
        cache(cacheData);
    }
    [MYConnection connectionWithURL:url finish:^(NSData *responseData, NSURLResponse *response) {
        finish(responseData,response);
        if(cacheData){
            [[FTCachesManager defaultManager] removeRecordwithURL:url];
        }
        [[FTCachesManager defaultManager] synchroiedURL:url data:responseData];
    } failed:^{
        failed();
    }];

}

/**
 POST请求

 @param url url -> string
 @param body body -> string
 @param finish finish block
 @param failed internet unconnected or connection failed
 */
+ (void)postRequestToHostUrl:(NSString *)url withBody:(NSString *)body finished:(postFinishBlock)finish failed:(postFailedBlock)failed{
//    clear caches
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0){ // available 8.0 or later
        NSURL * URL = [NSURL URLWithString:url];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];
        [request setHTTPMethod:@"POST"];
        [request setTimeoutInterval:30];
        [request setAllHTTPHeaderFields:nil];
        NSData * bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:bodyData];

        NSURLSession * session = [NSURLSession sharedSession];
        NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(!error){
                    if(finish){
                        finish(data);
                    }
                }else{
                    if(failed){
                        failed();
                    }
                }
            });
        }];
        [task resume];
    }else{ // available 8.0 earlier
        NSURL *storeURL = [NSURL URLWithString:url];
        NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
        [storeRequest setHTTPMethod:@"POST"];
        [storeRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        // Make a connection to the iTunes Store on a background queue.
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            NSLog(@"connection");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(connectionError){
                    if(failed){
                        failed();
                    }
                }else{
                    if(finish){
                        finish(data);
                    }
                }
            });
            
        }];
    }
    
}


/**
 Json解析时判断是否为空
 
 @param item item -> id
 @return 是否为空
 */
+ (BOOL)isJsonDataNull:(id)item{
    if(item == nil){
        return YES;
    }
    if([item isKindOfClass:[NSNull class]]){
        return YES;
    }
    NSString * str = [NSString stringWithFormat:@"%@",item];
    if([str isEqualToString:@"(null)"]){
        return YES;
    }
    return NO;
}

@end
