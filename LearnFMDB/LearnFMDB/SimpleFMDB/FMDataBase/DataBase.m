//
//  DataBase.m
//  LearnFMDB
//
//  Created by Roy on 2018/3/16.
//  Copyright © 2018年 Roy. All rights reserved.
//

#import "DataBase.h"
#import "FMDB.h"
#import "Person.h"
#import "Car.h"

static DataBase *_dataBase = nil;

@interface DataBase() {
    FMDatabase *_db;
}

@end

@implementation DataBase

+ (instancetype)shareDataBase {
    if (_dataBase == nil) {
        _dataBase = [[DataBase alloc] init];
        [_dataBase initDataBase];
    }
    return _dataBase;
}

- (void)initDataBase {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    ///文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"learnSqlite.sqlite"];
    
    _db = [FMDatabase databaseWithPath:filePath];
    [_db open];
    
    /// 初始化数据表
    NSString *personSql = @"CREATE TABLE 'person' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'person_id' VARCHAR(255), 'person_name' VARCHAR(255), 'person_age' VARCHAR(255),'person_number' VARCHAR(255))";
    
    NSString *carSql = @"CREATE TABLE 'car' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'own_id' VARCHAR(255), 'car_id' VARCHAR(255),'car_brand' VARCHAR(255), 'car_price' VARCHAR(255))";
    
    [_db executeUpdate:personSql];
    [_db executeUpdate:carSql];
    
    [_db close];
}

/// 增
- (void)addPerson:(Person *)person {
    [_db open];
    NSNumber *maxID = @(0);
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM person"];
    
    /// 获取数据库中最大的id
    while ([res next]) {
        if (maxID.integerValue < [res stringForColumn:@"person_id"].integerValue) {
            maxID = @([res stringForColumn:@"person_id"].integerValue);
        }
    }
    
    maxID = @(maxID.integerValue + 1);
    [_db executeUpdate:@"INSERT INTO person(person_id,person_name,person_age,person_number)VALUES(?,?,?,?)", maxID, person.name, @(person.age), @(person.number)];
    [_db close];
}

/// 删
- (void)deletePerson:(Person *)person {
    [_db open];
    [_db executeUpdate:@"DELETE FROM person WHERE person_id = ?", person.ID];
    [_db close];
}

/// 改
- (void)updatePerson:(Person *)person {
    [_db open];
    [_db executeUpdate:@"UPDATE 'person' SET person_name = ? WHERE person_id = ?", person.name, person.ID];
    [_db executeUpdate:@"UPDATE 'person' SET person_age = ? WHERE person_id = ?", @(person.age), person.ID];
    [_db executeUpdate:@"UPDATE 'person' SET person_number = ? WHERE person_id = ?", @(person.number + 1), person.ID];
    [_db close];
}

- (NSMutableArray *)getAllPerson {
    [_db open];
    NSMutableArray *dataArrary = [[NSMutableArray alloc] init];
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM person"];
    
    while ([res next]) {
        Person *person = [[Person alloc] init];
        person.ID = @([[res stringForColumn:@"person_id"] integerValue]);
        person.name = [res stringForColumn:@"person_name"];
        person.age = [[res stringForColumn:@"person_age"] integerValue];
        person.number = [[res stringForColumn:@"person_number"] integerValue];
        [dataArrary addObject:person];
    }
    [_db close];
    return dataArrary;
}

#pragma mark - car (person)

- (void)addCar:(Car *)car toPerson:(Person *)person {
    [_db open];

    NSNumber *maxID = @(0);
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM car where own_id = ?", person.ID];
    while ([res next]) {
        if (maxID.integerValue < [[res stringForColumn:@"car_id"] integerValue]) {
            maxID = @([[res stringForColumn:@"car_id"] integerValue]);
        }
    }
    maxID = @(maxID.integerValue + 1);
    [_db executeUpdate:@"INSERT INTO car (own_id,car_id,car_brand,car_price)VALUES(?,?,?,?)", person.ID, maxID, car.brand, @(car.price)];
    [_db close];
}

- (void)deleteCar:(Car *)car fromPerson:(Person *)person {
    [_db open];
    [_db executeUpdate:@"DELETE FROM car where own_id = ? and car_id = ?", person.ID, car.car_id];
    [_db close];
}

- (void)deleteAllCarsFromPerson:(Person *)person {
    [_db open];
    [_db executeUpdate:@"DELETE FROM car where own_id = ?", person.ID];
    [_db close];
}

- (void)updateCar:(Car *)car fromPerson:(Person *)person {
    [_db open];
    [_db executeUpdate:@"UPDATE 'car' SET car_brand = ? WHERE own_id = ? AND car_id = ?", @"WW2W", person.ID, car.car_id];
    [_db executeUpdate:@"UPDATE 'car' SET car_price = ? WHERE own_id = ? AND car_id = ?", @(100), person.ID, car.car_id];
    [_db close];
}

- (NSMutableArray *)getAllCarsFromPerson:(Person *)person {
    [_db open];
    NSMutableArray *carArray = [[NSMutableArray alloc] init];
    //    FMResultSet *res = [_db executeQuery:[NSString stringWithFormat:@"SELECT * FROM car where own_id = %@", person.ID]];
    //    FMResultSet *res = [_db executeQuery:@"SELECT * FROM car where own_id = %@", person.ID];
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM car where own_id = ?", person.ID];
    while ([res next]) {
        Car *car = [[Car alloc] init];
        car.own_id = person.ID;
        car.car_id = @([[res stringForColumn:@"car_id"] integerValue]);
        car.brand = [res stringForColumn:@"car_brand"];
        car.price = [[res stringForColumn:@"car_price"] integerValue];
        [carArray addObject:car];
    }
    [_db close];
    return carArray;
}

@end
