//
//  RWFMDB.m
//  LearnFMDB
//
//  Created by Roy on 2018/3/23.
//  Copyright © 2018年 Roy. All rights reserved.
//

#import "RWFMDB.h"
#import "FMDB.h"
#import <objc/runtime.h>

// 数据库中常见的几种类型
#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data

static RWFMDB *rwdb = nil;

@interface RWFMDB ()

@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) FMDatabase *db;

@end


@implementation RWFMDB

- (FMDatabaseQueue *)dbQueue
{
    if (!_dbQueue) {
        FMDatabaseQueue *fmdb = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
        self.dbQueue = fmdb;
        [_db close];
        self.db = [fmdb valueForKey:@"_db"];
    }
    return _dbQueue;
}

+ (instancetype)shareDatabase {
    return [RWFMDB shareDatabase:nil];
}

+ (instancetype)shareDatabase:(NSString *)dbName {
    return [RWFMDB shareDatabase:dbName path:nil];
}

+ (instancetype)shareDatabase:(NSString *)dbName path:(NSString *)dbPath {
    if (!rwdb) {
        NSString *path;
        if (!dbName) {
            dbName = @"RWFMDB.sqlite";
        }
        if (!dbPath) {
            path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
        } else {
            path = [dbPath stringByAppendingPathComponent:dbPath];
        }
        FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
        if ([fmdb open]) {
            rwdb = RWFMDB.new;
            rwdb.db = fmdb;
            rwdb.dbPath = path;
        }
    }
    if (![rwdb.db open]) {
        NSLog(@"database can not open !");
        return nil;
    }
    return rwdb;
}

- (instancetype)initWithDBName:(NSString *)dbName {
    return [self initWithDBName:dbName path:nil];
}

- (instancetype)initWithDBName:(NSString *)dbName path:(NSString *)dbPath {
    if (!dbName) {
        dbName = @"RWFMDB.sqlite";
    }
    NSString *path;
    if (!dbPath) {
        path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
    } else {
        path = [dbPath stringByAppendingPathComponent:dbName];
    }
    FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
    if ([fmdb open]) {
        self = [super init];
        if (self) {
            self.db = fmdb;
            self.dbPath = path;
            return self;
        }
    }
    return nil;
}

- (BOOL)jq_createTable:(NSString *)tableName dicOrModel:(id)parameters {
    return [self jq_createTable:tableName dicOrModel:parameters excludeName:nil];
}

- (BOOL)jq_createTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr {
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    } else {
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        dic = [self modelToDictionary:CLS excludePropertyName:nameArr];
    }
    
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@ (pkid  INTEGER PRIMARY KEY,", tableName];
    
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        if ((nameArr && [nameArr containsObject:key]) || [key isEqualToString:@"pkid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    BOOL creatFlag;
    creatFlag = [_db executeUpdate:fieldStr];
    
    return creatFlag;
}


- (NSString *)createTable:(NSString *)tableName dictionary:(NSDictionary *)dic excludeName:(NSArray *)nameArr
{
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@ (pkid  INTEGER PRIMARY KEY,", tableName];
    
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        if ((nameArr && [nameArr containsObject:key]) || [key isEqualToString:@"pkid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    return fieldStr;
}

- (NSArray *)jq_lookupTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *where = format ? [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args] : format;
    va_end(args);
    
    NSMutableArray *resultArr = [NSMutableArray array];
    NSDictionary *dic;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"select * from %@ %@",tableName, where ? where : @""];
    NSArray *columnArr = [self getColumnArr:tableName db:_db];
    
    FMResultSet *res = [_db executeQuery:finalStr];
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
        while ([res next]) {
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            for (NSString *key in dic) {
                if ([dic[key] isEqualToString:SQL_TEXT]) {
                    id value = [res stringForColumn:key];
                    if (value){
                        [resultDic setObject:value forKey:key];
                    }
                } else if ([dic[key] isEqualToString:SQL_INTEGER]) {
                    [resultDic setObject:@([res longLongIntForColumn:key]) forKey:key];
                } else if ([dic[key] isEqualToString:SQL_REAL]) {
                    [resultDic setObject:[NSNumber numberWithDouble:[res doubleForColumn:key]] forKey:key];
                } else if ([dic[key] isEqualToString:SQL_BLOB]) {
                    id value = [res dataForColumn:key];
                    if (value){
                        [resultDic setObject:value forKey:key];
                    }
                }
            }
            if (resultDic) {
                [resultArr addObject:resultDic];
            }
        }
    } else {
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        
        if (CLS) {
            NSDictionary *propertyType = [self modelToDictionary:CLS excludePropertyName:nil];
            while ([res next]) {
                
                id model = CLS.new;
                for (NSString *name in columnArr) {
                    if ([propertyType[name] isEqualToString:SQL_TEXT]) {
                        id value = [res stringForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_INTEGER]) {
                        [model setValue:@([res longLongIntForColumn:name]) forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_REAL]) {
                        [model setValue:[NSNumber numberWithDouble:[res doubleForColumn:name]] forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_BLOB]) {
                        id value = [res dataForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    }
                }
                [resultArr addObject:model];
            }
        }
    }
    return resultArr;
}

/// 得到表里的字段名称
- (NSArray *)getColumnArr:(NSString *)tableName db:(FMDatabase *)db {
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    FMResultSet *res = [db getTableSchema:tableName];
    while ([res next]) {
        [mArr addObject:[res stringForColumn:@"name"]];
    }
    return mArr;
}

- (BOOL)jq_isExistTable:(NSString *)tableName
{
    FMResultSet *set = [_db executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
    while ([set next])
    {
        NSInteger count = [set intForColumn:@"count"];
        if (count == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)jq_columnNameArray:(NSString *)tableName
{
    return [self getColumnArr:tableName db:_db];
}


#pragma mark - *************** runtime
- (NSDictionary *)modelToDictionary:(Class)cls excludePropertyName:(NSArray *)nameArr {
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if ([nameArr containsObject:name]) {
            continue;
        }
        NSString *type = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
        id value = [self propertTypeConvert:type];
        if (value) {
            [mDic setObject:value forKey:name];
        }
    }
    free(properties);
    return mDic;
}

- (NSString *)propertTypeConvert:(NSString *)typeStr {
    NSString *resultStr = nil;
    if ([typeStr hasPrefix:@"T@\"NSString\""]) {
        resultStr = SQL_TEXT;
    } else if ([typeStr hasPrefix:@"T@\"NSData\""]) {
        resultStr = SQL_BLOB;
    } else if ([typeStr hasPrefix:@"Ti"]||[typeStr hasPrefix:@"TI"]||[typeStr hasPrefix:@"Ts"]||[typeStr hasPrefix:@"TS"]||[typeStr hasPrefix:@"T@\"NSNumber\""]||[typeStr hasPrefix:@"TB"]||[typeStr hasPrefix:@"Tq"]||[typeStr hasPrefix:@"TQ"]) {
        resultStr = SQL_INTEGER;
    } else if ([typeStr hasPrefix:@"Tf"] || [typeStr hasPrefix:@"Td"]){
        resultStr= SQL_REAL;
    }
    
    return resultStr;
}

// 获取model的key和value
- (NSDictionary *)getModelPropertyKeyValue:(id)model tableName:(NSString *)tableName clomnArr:(NSArray *)clomnArr
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if (![clomnArr containsObject:name]) {
            continue;
        }
        
        id value = [model valueForKey:name];
        if (value) {
            [mDic setObject:value forKey:name];
        }
    }
    free(properties);
    
    return mDic;
}

#pragma mark - *************** 增删改查
- (BOOL)jq_insertTable:(NSString *)tableName dicOrModel:(id)parameters {
    NSArray *columnArr = [self getColumnArr:tableName db:_db];
    return [self insertTable:tableName dicOrModel:parameters columnArr:columnArr];
}

- (BOOL)insertTable:(NSString *)tableName dicOrModel:(id)parameters columnArr:(NSArray *)columnArr {
    BOOL flag;
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else {
        dic = [self getModelPropertyKeyValue:parameters tableName:tableName clomnArr:columnArr];
    }
    
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ (", tableName];
    NSMutableString *tempStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in dic) {
        
        if (![columnArr containsObject:key] || [key isEqualToString:@"pkid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@,", key];
        [tempStr appendString:@"?,"];
        
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (tempStr.length)
        [tempStr deleteCharactersInRange:NSMakeRange(tempStr.length-1, 1)];
    
    [finalStr appendFormat:@") values (%@)", tempStr];
    
    flag = [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    return flag;
}

// 直接传一个array插入
- (NSArray *)jq_insertTable:(NSString *)tableName dicOrModelArray:(NSArray *)dicOrModelArray
{
    
    int errorIndex = 0;
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *columnArr = [self getColumnArr:tableName db:_db];
    for (id parameters in dicOrModelArray) {
        
        BOOL flag = [self insertTable:tableName dicOrModel:parameters columnArr:columnArr];
        if (!flag) {
            [resultMArr addObject:@(errorIndex)];
        }
        errorIndex++;
    }
    
    return resultMArr;
}

- (BOOL)jq_deleteTable:(NSString *)tableName whereFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    BOOL flag;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"delete from %@  %@", tableName, where];
    flag = [_db executeUpdate:finalStr];
    return flag;
}

- (BOOL)jq_deleteAllDataFromTable:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    return YES;
}

- (BOOL)jq_deleteTable:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    return YES;
}

- (NSInteger)lastInsertPrimaryKeyId:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT * FROM %@ where pkid = (SELECT max(pkid) FROM %@)", tableName, tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        return [set longLongIntForColumn:@"pkid"];
    }
    return 0;
}

- (BOOL)jq_alterTable:(NSString *)tableName dicOrModel:(id)parameters
{
    return [self jq_alterTable:tableName dicOrModel:parameters excludeName:nil];
}

- (BOOL)jq_alterTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr
{
    __block BOOL flag;
    [self jq_inTransaction:^(BOOL *rollback) {
        if ([parameters isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in parameters) {
                if ([nameArr containsObject:key]) {
                    continue;
                }
                flag = [_db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, parameters[key]]];
                if (!flag) {
                    *rollback = YES;
                    return;
                }
            }
            
        } else {
            Class CLS;
            if ([parameters isKindOfClass:[NSString class]]) {
                if (!NSClassFromString(parameters)) {
                    CLS = nil;
                } else {
                    CLS = NSClassFromString(parameters);
                }
            } else if ([parameters isKindOfClass:[NSObject class]]) {
                CLS = [parameters class];
            } else {
                CLS = parameters;
            }
            NSDictionary *modelDic = [self modelToDictionary:CLS excludePropertyName:nameArr];
            NSArray *columnArr = [self getColumnArr:tableName db:_db];
            for (NSString *key in modelDic) {
                if (![columnArr containsObject:key] && ![nameArr containsObject:key]) {
                    flag = [_db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, modelDic[key]]];
                    if (!flag) {
                        *rollback = YES;
                        return;
                    }
                }
            }
        }
    }];
    
    return flag;
}

- (BOOL)jq_updateTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSDictionary *dic;
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else {
        dic = [self getModelPropertyKeyValue:parameters tableName:tableName clomnArr:clomnArr];
    }
    
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"update %@ set ", tableName];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in dic) {
        
        if (![clomnArr containsObject:key] || [key isEqualToString:@"pkid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@ = %@,", key, @"?"];
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (where.length) [finalStr appendFormat:@" %@", where];
    
    
    flag =  [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    
    return flag;
}

- (int)jq_tableItemCount:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        return [set intForColumn:@"count"];
    }
    return 0;
}

- (void)close
{
    [_db close];
}

- (void)open
{
    [_db open];
}

// =============================   线程安全操作    ===============================
- (void)jq_inDatabase:(void (^)(void))block {
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        block();
    }];
}

- (void)jq_inTransaction:(void (^)(BOOL *))block {
    [[self dbQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(rollback);
    }];
}

@end
