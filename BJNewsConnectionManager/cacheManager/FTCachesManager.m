//
//  FTCachesManager.m
//  FTDataBase缓存管理
//
//  Created by Wolffy on 15-1-5.
//  Copyright (c) 2015年 Wolffy. All rights reserved.
//

#import "FTCachesManager.h"
#import "FMResultSet.h"

//将表名和列名声明为宏，不容易写错
#define TABLE_NAME @"requestCache"
#define URL @"url"
#define DATA @"data"
#define FT_CACHE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/cache.db"]

static FTCachesManager * ft_cache_manager;

@implementation FTCachesManager

/**单例创建*/
+ (instancetype)defaultManager
{
    if (!ft_cache_manager) {
        NSString * path = FT_CACHE_PATH;
//        NSString * path = @"/Users/qianfeng/Desktop/test/data.db";
        ft_cache_manager = [[FTCachesManager alloc] initWithPath:path];
        ft_cache_manager.onTimeHours = 3;
        [ft_cache_manager createTable];
    }
    
    return ft_cache_manager;
}

//创建表单
- (void)createTable
{
    [self createTableWithName:TABLE_NAME primaryKey:URL type:@"varchar(1000)" otherColumn:@{DATA : @"varchar(4000)"}];
}

/**判断一个缓存是否有效，是否超时*/
- (BOOL)isOnTimeForURL:(NSString *)url
{
    //返回某条记录，距现在时间
    NSTimeInterval timeInterval = [self timeIntervalForColumns:@{URL : url} fromTable:TABLE_NAME];
    BOOL ret = timeInterval < self.onTimeHours * 3600;
    if (!ret) {
        //如果超时，删除当前缓存
        [self removeRecordWithColumns:@{URL : url} fromTable:TABLE_NAME];
    }
    return ret;
}
//  删除一条信息
- (void)removeRecordwithURL:(NSString *)url{
    [self removeRecordWithColumns:@{URL : url} fromTable:TABLE_NAME];
}
/**同步，储存一个网址和数据*/
- (void)synchroiedURL:(NSString *)url data:(NSData *)data
{
//    如果sqlite不存在，重新创建（清除缓存后，sqlite不存在，无法插入数据）;
//    2017-01-03修改
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:FT_CACHE_PATH];
    if(isExist == NO){
        ft_cache_manager = nil; // 重新创建
        [FTCachesManager defaultManager];
    }
    [self insertRecordWithColumns:@{URL : url , DATA : data} toTable:TABLE_NAME];
}

/**根据网址，返回缓存数据*/
- (NSData *)dataForURL:(NSString *)url
{
    FMResultSet * set = [self findColumnNames:@[DATA] recordsWithColumns:@{URL : url} fromTable:TABLE_NAME];
    if ([set next]) {
        NSData * data = [set dataForColumn:DATA];
        return data;
    }
    return nil;
}

/**
 删除所有缓存数据
 */
- (void)cleanDataBase{
    NSString * path = FT_CACHE_PATH;
    NSFileManager * manager = [NSFileManager defaultManager];;
    NSError * error = nil;
    BOOL isSucess = [manager removeItemAtPath:path error:&error];
    if(!isSucess){
        perror("删除失败");
    }
    NSString * str = @"init_db";
    NSData * db_data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [[FTCachesManager defaultManager] synchroiedURL:@"init_db" data:db_data];
}
@end
