//
//  FTRequwst.m
//  ASIHttpRequest封装
//
//  Created by Wolffy on 15-1-3.
//  Copyright (c) 2015年 Wolffy. All rights reserved.
//

#import "FTRequest.h"
#import "AFNetworking.h"
#import "MYConnection.h"
@implementation FTRequest{
    NSURLSessionDataTask * _task;
}

//下载数据，回传数据
- (void)requestURL{
//    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
////    设置请求数据是JSON数据，如果是JSON，则自动解析，这里设置为非JSON数据，得到data，为了写入数据库
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
////    请求GET
//    [manager GET:self.url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
////        成功回调
//        self.data = responseObject;
//        
//        if(self.finished){
//            self.finished(self.data);
////            NSLog(@"下载成功");
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
////        失败回调
//
//        
//        if(self.failed){
//            self.failed();
//        }
//    }];
    
    if([UIDevice currentDevice].systemVersion.floatValue > 7.0){
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        //    设置请求数据是JSON数据，如果是JSON，则自动解析，这里设置为非JSON数据，得到data，为了写入数据库
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 30.f;
        //    请求GET
       _task = [manager GET:self.url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //        成功回调
            self.data = responseObject;
            
            if(self.finished){
                self.finished(self.data);
                //            NSLog(@"下载成功");
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //        失败回调
            NSLog(@"******************下载失败:\n%@ errorCode:%ld   %@ ",self.url,error.code,error);
            
            if(self.failed){
                self.failed();
            }
            
        }];
        

        
        
        
    }else{
        [MYConnection connectionWithURL:self.url finish:^(NSData *data,NSURLResponse *response) {
            //        成功回调
            self.data = data;
            
            if(self.finished){
                self.finished(self.data);
                //            NSLog(@"下载成功");
            }
            

        } failed:^{
            //        失败回调
            
            
            if(self.failed){
                self.failed();
            }
            

        }];
    }
    


}

/**
 取消单个请求

 @param url url description
 */
- (void)cancelTaskWithUrl:(NSString *)url{
    [_task cancel];
}

@end
