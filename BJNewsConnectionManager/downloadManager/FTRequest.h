//
//  FTRequwst.h
//  ASIHttpRequest封装
//
//  Created by Wolffy on 15-1-3.
//  Copyright (c) 2015年 Wolffy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SortFinishBlock) (NSData * data);
typedef void (^SortFailedBlock) ();
@interface FTRequest : NSObject
//记录当前需要请求的httpURL
@property (nonatomic,copy) NSString * url;
//记录接收数据的对象
@property (weak) id target;
//记录接收数据成功的方法
@property (nonatomic,copy) SortFinishBlock finished;
//记录接收数据失败的方法
@property (nonatomic,copy) SortFailedBlock failed;
//储存相关数据
@property (nonatomic,strong) NSData * data;
//记录是否有缓存
@property (nonatomic) BOOL isCache;
- (void)requestURL;
/**
 取消单个请求
 
 @param url url description
 */
- (void)cancelTaskWithUrl:(NSString *)url;

@end
