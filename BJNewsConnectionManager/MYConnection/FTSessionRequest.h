//
//  FTSessionRequest.h
//  BJNewsApp
//
//  Created by wolffy on 16/2/19.
//  Copyright © 2016年 灰太狼. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTSessionRequest : NSObject

@property (nonatomic,copy) NSString * url;
@property (nonatomic,copy) void (^finishedBlock) (NSData * responseData,NSURLResponse * response);
@property (nonatomic,copy) void (^failedBlock) ();

/**
 start request
 */
- (void)startRequest;

@end
