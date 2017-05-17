//
//  FTRquestManager.m
//  ASIHttpRequest封装
//
//  Created by Wolffy on 15-1-3.
//  Copyright (c) 2015年 Wolffy. All rights reserved.
//

#import "FTRequestManager.h"

#define MAX_CURRENT_REQUESTS 1
@interface FTRequestManager(){
    NSMutableDictionary * _requestDict;
    NSMutableArray * _requestCacheStack;
}
@end

@implementation FTRequestManager
- (instancetype)init{
    if(self = [super init]){
        _requestDict = [[NSMutableDictionary alloc]init];

        self.maxCurrentReuquest = MAX_CURRENT_REQUESTS;
    }
    return self;
}

//创建单例对象
+ (instancetype)defaultManager{
    static FTRequestManager * manager = nil ;
    if(manager == nil){
        manager = [[FTRequestManager alloc]init];
    }
    return manager;
}

//管理sdWebImage
- (void)manageSdImageRequest:(NSString *)url{
    //    从字典中取得需要下载的数据
    FTRequest * request = _requestDict[url];
    if(request){
        //        正在下载
                NSLog(@"当前下载数目:  %lu",(unsigned long)_requestDict.count);
        return;
    }
    if(_requestCacheStack && _requestCacheStack.count){
        for (NSInteger i=0; i<_requestCacheStack.count; i++) {
            FTRequest * rq = _requestCacheStack[i];
            if([rq.url isEqualToString:url]){
                [_requestCacheStack removeObject:rq];
                break;
            }
        }
    }
    //    创建一个请求
    request = [[FTRequest alloc]init];
    request.url = url;

    //    如果字典中请求过多，缓存请求
    if(_requestDict.count >= self.maxCurrentReuquest){
        [self pushStack:request];
        return;
    }
    [_requestDict setObject:request forKey:request.url];
    [request requestURL];
}

//添加请求
- (void)addRequestWithURL:(NSString *)url target:(id)target finished:(SortFinishBlock)finished failed:(SortFailedBlock)failed{
//    从字典中取得需要下载的数据
    FTRequest * request = _requestDict[url];
    if(request){
//        正在下载
//        NSLog(@"当前下载数目:  %d",_requestDict.count);
//        当下载项目已存在时，应该改变回调 _requestDict需要检测是否存在 -> finish failed target
//        _requestCacheStack后面会移除
        for (NSString * requestKey in _requestDict.allKeys) {
            if([requestKey isEqualToString:url]){
                FTRequest * currentRequest = _requestDict[requestKey];
                if(currentRequest){
                    currentRequest.target = target;
                    currentRequest.finished = finished;
                    currentRequest.failed = failed;
                    NSLog(@"request 切换成功%@",url);
                }
            }
        }
        return;
    }
//    未修改，只做注释
//    栈中拖过存在请求，移除，之后添加进去
    if(_requestCacheStack && _requestCacheStack.count){
        for (NSInteger i=0; i<_requestCacheStack.count; i++) {
            FTRequest * rq = _requestCacheStack[i];
            if([rq.url isEqualToString:url]){
                [_requestCacheStack removeObject:rq];
                break;
            }
        }
    }
//    创建一个请求
    request = [[FTRequest alloc]init];
    request.url = url;
    request.target = target;
    request.finished = finished;
    request.failed = failed;
//    如果字典中请求过多，缓存请求
    if(_requestDict.count >= self.maxCurrentReuquest){
        [self pushStack:request];
        return;
    }
    [_requestDict setObject:request forKey:request.url];
    [request requestURL];
}
//移除已经完成的下载
- (void)removeRequestWithURL:(NSString *)url{
    if(_requestDict && _requestDict.count > 0){
        for (NSString * key in _requestDict.allKeys) {
            if([url isEqualToString:key]){
                [_requestDict removeObjectForKey:url];
                if(_requestDict.count < self.maxCurrentReuquest){
                    //        下完一个，下排队的
                    FTRequest * request = [self popStack];
                    if(request){
                        [_requestDict setObject:request forKey:request.url];
                        [request requestURL];
                    }
                }
            }
        }
    }
//    NSLog(@"剩余下载数目:%d",_requestDict.count);
}

#pragma mark - 栈
- (void)pushStack:(FTRequest *)request{
    if(_requestCacheStack == nil){
        _requestCacheStack = [[NSMutableArray alloc]init];
    }
    [_requestCacheStack insertObject:request atIndex:0];
    
    if(_requestCacheStack.count >= 3){
        while (_requestCacheStack.count >= 3) {
            [_requestCacheStack removeObject:[_requestCacheStack lastObject]];
        }
    }
    
    NSLog(@"入栈---当前有%lu个请求在排队",(unsigned long)_requestCacheStack.count);
}
- (FTRequest *)popStack{
    if(!_requestCacheStack || _requestCacheStack.count == 0){
        return nil;
    }
    FTRequest * request = _requestCacheStack[0];
    [_requestCacheStack removeObjectAtIndex:0];
    NSLog(@"出栈---当前还有%lu个请求排队",(unsigned long)_requestCacheStack.count);
    return request;
}

/**
 取消单个请求
 
 @param url url description
 */
- (void)cancelTaskWithUrl:(NSString *)url{
    if(_requestDict && _requestDict.count > 0){
        for (NSString * key in _requestDict.allKeys) {
            if([url isEqualToString:key]){
//                NSLog(@"%@ 正在请求中，取消请求",url);
                FTRequest * request = _requestDict[url];
                [request cancelTaskWithUrl:request.url];
                [self removeRequestWithURL:request.url];
            }
        }
    }
    if(_requestCacheStack && _requestCacheStack.count > 0){
        NSMutableArray * deleteArray = [[NSMutableArray alloc]init];
        for (FTRequest * request in _requestCacheStack) {
            if([request.url isEqualToString:url]){
                [deleteArray addObject:request];
            }
        }
        
        for (FTRequest * request in deleteArray) {
            [_requestCacheStack removeObject:request];
        }
        [deleteArray removeAllObjects];
    }
    NSLog(@"_requestDict:%ld   _requestCacheStack:%ld",_requestDict.count,_requestCacheStack.count);
}

@end
