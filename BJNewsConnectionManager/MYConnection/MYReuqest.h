//
//  MYReuqest.h
//  BJNewsAppBeta
//
//  Created by paiBo on 15-2-11.
//  Copyright (c) 2015年 paiBo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FinishBlock)(NSData * responseData,NSURLResponse * response);
typedef void (^FailedBlock)();

@interface MYReuqest : NSObject

@property (nonatomic,copy) NSString * url;
@property (nonatomic,copy) FinishBlock finishBlock;
@property (nonatomic,copy) FailedBlock failedBlock;

/**
 start request
 */
- (void)startRequest;

@end
