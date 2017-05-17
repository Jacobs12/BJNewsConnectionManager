//
//  MYReuqest.m
//  BJNewsAppBeta
//
//  Created by paiBo on 15-2-11.
//  Copyright (c) 2015年 paiBo. All rights reserved.
//

#import "MYReuqest.h"
#import <UIKit/UIKit.h>
@interface MYReuqest ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>{
    NSMutableData * _mData;
    NSURLResponse * _response;
}
@end
@implementation MYReuqest


/**
 start request
 */
- (void)startRequest{
    _mData = [[NSMutableData alloc]init];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.url]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

/**
 did receive response

 @param connection NSURLConnection
 @param response NSURLResponse
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _response = response;
}

/**
  loading data

 @param connection NSURLConnection
 @param data NSData
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_mData appendData:data];
}

/**
 connnect finish

 @param connection NSURLConnection
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(self.finishBlock){
        self.finishBlock(_mData,_response);
    }
}

/**
 connection failed

 @param connection NSURLConnection
 @param error conection error
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if(self.failedBlock){
        self.failedBlock();
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
