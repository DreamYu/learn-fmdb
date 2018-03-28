//
//  DBCell.h
//  LearnFMDB
//
//  Created by Roy on 2018/3/23.
//  Copyright © 2018年 Roy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"

@interface DBCell : UITableViewCell

@property (nonatomic, strong)UILabel *pkid;
@property (nonatomic, strong)UILabel *name;
@property (nonatomic, strong)UILabel *phoneNum;
@property (nonatomic, strong)UILabel *photoData;
@property (nonatomic, strong)UILabel *luckyNum;
@property (nonatomic, strong)UILabel *sex;
@property (nonatomic, strong)UILabel *age;
@property (nonatomic, strong)UILabel *height;
@property (nonatomic, strong)UILabel *weight;

@property (nonatomic, strong)UILabel *height1;
@property (nonatomic, strong)UILabel *weight2;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier columnArr:(NSArray *)array;
- (void)setData:(Person *)model;

@end
