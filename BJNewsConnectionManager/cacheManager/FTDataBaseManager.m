//
//  FTDataBaseManager.m
//  FTDataBase缓存管理
//
//  Created by Wolffy on 15-1-3.
//  Copyright (c) 2015年 Wolffy. All rights reserved.
//

#import "FTDataBaseManager.h"
#import "FMDatabase.h"

#define __INSERT_DATE_TIME @"__insert_date"
@implementation FTDataBaseManager
{
//    数据库
    FMDatabase * _dataBase;
//    线程锁
    NSLock * _lock;
}
- (instancetype)initWithPath:(NSString *)path{
    if(self = [super init]){
        _dataBase = [[FMDatabase alloc]initWithPath:path];
//        打开数据库，如果数据库不存在，创建数据库
        BOOL ret = [_dataBase open];
        if(!ret){
            perror("缓存数据库打开");
        }
        _lock = [[NSLock alloc]init];
    }
    return self;
}
/**建表*/
- (void)createTableWithName:(NSString *)name primaryKey:(NSString *)key type:(NSString *)type otherColumn:(NSDictionary *)dict
{
    [_lock lock];
    //字典中，key是列的名字，值是列的类型，如果有附加参数，直接写到值中
    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ %@ PRIMARY KEY, %@ DATETIME", name, key, type, __INSERT_DATE_TIME];
    
    for (NSString * columnName in dict) {
        sql = [sql stringByAppendingFormat:@", %@ %@", columnName, dict[columnName]];
    }
    
    sql = [sql stringByAppendingString:@");"];
    
    BOOL ret = [_dataBase executeUpdate:sql];
    if (ret == NO) {
        perror("建表错误");
    }
    
    [_lock unlock];
}

/**插入记录*/
- (void)insertRecordWithColumns:(NSDictionary *)dict toTable:(NSString *)tableName
{
    [_lock lock];
    NSString * columnNames = [dict.allKeys componentsJoinedByString:@", "];
    
    NSMutableArray * xArray = [NSMutableArray array];
    for (NSString * key in dict) {
//        消除警告信息
        [NSString stringWithFormat:@"%@",key];
        [xArray addObject:@"?"];
    }
    
    NSString * valueStr = [xArray componentsJoinedByString:@", "];
    
    NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@, %@) VALUES(%@, ?);", tableName, columnNames, __INSERT_DATE_TIME, valueStr];
    //INSERT INTO 女演员(姓名, ID) VALUES(?, ?)
    
    BOOL ret = [_dataBase executeUpdate:sql withArgumentsInArray:[dict.allValues arrayByAddingObject:[NSDate date]]];
    if (ret == NO) {
        perror("插入错误");
    }
    
    [_lock unlock];
}


/**删除记录*/
- (void)removeRecordWithColumns:(NSDictionary *)dict fromTable:(NSString *)tableName
{
    [_lock lock];
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    
    BOOL isFirst = YES;
    for (NSString * key in dict) {
        if (isFirst) {
            sql = [sql stringByAppendingString:@" WHERE "];
            isFirst = NO;
        } else {
            sql = [sql stringByAppendingString:@" AND "];
        }
        sql = [sql stringByAppendingFormat:@"%@ = ?", key];
    }
    
    sql = [sql stringByAppendingString:@";"];
    
    BOOL ret = [_dataBase executeUpdate:sql withArgumentsInArray:dict.allValues];
    if (!ret) {
        perror("删除错误");
    }
    [_lock unlock];
}


/**查找记录*/
- (FMResultSet *)findColumnNames:(NSArray *)names recordsWithColumns:(NSDictionary *)dict fromTable:(NSString *)tableName
{
    [_lock lock];
    NSString * colNames = nil;
    if (names == nil) {
        colNames = @"*";
    } else {
        colNames = [names componentsJoinedByString:@", "];
    }
    NSString * sql = [NSString stringWithFormat:@"SELECT  %@ FROM %@", colNames, tableName];
    
    BOOL isFirst = YES;
    for (NSString * key in dict) {
        if (isFirst) {
            sql = [sql stringByAppendingString:@" WHERE "];
            isFirst = NO;
        } else {
            sql = [sql stringByAppendingString:@" AND "];
        }
        sql = [sql stringByAppendingFormat:@"%@ = ?", key];
    }
    
    sql = [sql stringByAppendingString:@";"];
    
    FMResultSet * set = [_dataBase executeQuery:sql withArgumentsInArray:dict.allValues];
    
    [_lock unlock];
    
    return set;
}

/**查找某个记录存储时间，返回这时间距离现在多久*/
- (NSTimeInterval)timeIntervalForColumns:(NSDictionary *)dict fromTable:(NSString *)tableName
{
    FMResultSet * set = [self findColumnNames:@[__INSERT_DATE_TIME] recordsWithColumns:dict fromTable:tableName];
    
    NSDate * date = nil;
    if ([set next]) {
        date = [set dateForColumn:__INSERT_DATE_TIME];
    } else {
        date = [NSDate distantPast];
    }
    
    return -[date timeIntervalSinceNow];
}


@end
