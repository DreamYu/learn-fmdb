//
//  Person.h
//  LearnFMDB
//
//  Created by Roy on 2018/3/15.
//  Copyright © 2018年 Roy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

/// simpleFMDB 使用
@property(nonatomic,strong) NSNumber *ID;

//@property(nonatomic,copy) NSString *name;

//@property(nonatomic,assign) NSInteger age;

@property(nonatomic,assign) NSInteger number;
/**
 *  一个人可以拥有多辆车
 */
@property(nonatomic,strong) NSMutableArray *carArray;


/// PackingFMDB 使用
/// 可省略, 默认的主键id, 如果需要获取主键id的值, 可在自己的model中添加下面这个属性
@property (nonatomic, assign)NSInteger pkid;

@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSNumber *phoneNum;
@property (nonatomic, strong)NSData *photoData;
@property (nonatomic, assign)NSInteger luckyNum;
@property (nonatomic, assign)BOOL sex;
@property (nonatomic, assign)int age;
@property (nonatomic, assign)float height;  //float类型存入172.12会变成172.19995,取值时%.2f等于原值172.12
@property (nonatomic, assign)double weight;
@property (nonatomic, strong)Person *testP;
@end
