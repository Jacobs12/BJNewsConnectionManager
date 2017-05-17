//
//  FTDataBaseManager.h
//  FTDataBase缓存管理
//
//  Created by Wolffy on 15-1-3.
//  Copyright (c) 2015年 Wolffy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
//前置声明，告诉编译器这个类是存在的
@class FMResultSet;
@interface FTDataBaseManager : NSObject

- (instancetype)initWithPath:(NSString *)path;

/**
 建表

 @param name table name -> string
 @param key key -> string
 @param type table type -> string
 @param dict other cloumn
 */
- (void)createTableWithName:(NSString *)name primaryKey:(NSString *)key type:(NSString *)type otherColumn:(NSDictionary *)dict;

/**
 插入记录

 @param dict insertRecordWithColumns
 @param tableName table name which insert record with columns
 */
- (void)insertRecordWithColumns:(NSDictionary *)dict toTable:(NSString *)tableName;

/**
 删除记录

 @param dict the dict includes records with columns which will remove
 @param tableName table name which will remove records with columns
 */
- (void)removeRecordWithColumns:(NSDictionary *)dict fromTable:(NSString *)tableName;

/**
 查找记录

 @param name column name -> array
 @param dict records with columns
 @param tableName table name
 @return FMResultSet
 */
- (FMResultSet *)findColumnNames:(NSArray *)name recordsWithColumns:(NSDictionary *)dict fromTable:(NSString *)tableName;

/**
 查找某个记录存储时间，返回这时间距离现在多久

 @param dict time interval for columns
 @param tableName table name
 @return 返回这时间距离现在多久
 */
- (NSTimeInterval)timeIntervalForColumns:(NSDictionary *)dict fromTable:(NSString *)tableName;

@end
