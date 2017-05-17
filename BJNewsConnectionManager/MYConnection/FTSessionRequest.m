//
//  FTSessionRequest.m
//  BJNewsApp
//
//  Created by wolffy on 16/2/19.
//  Copyright © 2016年 灰太狼. All rights reserved.
//

#import "FTSessionRequest.h"
@interface FTSessionRequest ()<NSURLSessionDelegate>{
    
}
@end

@implementation FTSessionRequest
- (void)startRequest{
    /*
     一般模式（default）：工作模式类似于原来的NSURLConnection，可以使用缓存的Cache，Cookie，鉴权。
     及时模式（ephemeral）：不使用缓存的Cache，Cookie，鉴权。
     后台模式（background）：在后台完成上传下载，创建Configuration对象的时候需要给一个NSString的ID用于追踪完成工作的Session是哪一个
     */
    NSURLSessionConfiguration * ephemralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession * ephemralSession = [NSURLSession sessionWithConfiguration:ephemralConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:self.url];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask * dataTask = [ephemralSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"NSURLSession下载失败");
            if(self.failedBlock){
                self.failedBlock();
            }
        }else{
//            NSLog(@"使用session下载成功");
            if(self.finishedBlock){
                self.finishedBlock(data,response);
            }
        }
    }];
    [dataTask resume];
}
@end
