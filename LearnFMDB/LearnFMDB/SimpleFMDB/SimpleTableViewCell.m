//
//  SimpleTableViewCell.m
//  LearnFMDB
//
//  Created by Roy on 2018/3/16.
//  Copyright © 2018年 Roy. All rights reserved.
//

#import "SimpleTableViewCell.h"

@interface SimpleTableViewCell()



@end

@implementation SimpleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.titleLable];
    [self.contentView addSubview:self.subTitle];
    self.titleLable.frame = CGRectMake(0, 0, 200, CGRectGetHeight(self.contentView.frame));
    self.subTitle.frame = CGRectMake(CGRectGetMaxX(self.titleLable.frame), 0, 200, CGRectGetHeight(self.contentView.frame));
}

- (UILabel *)subTitle {
    if (!_subTitle) {
        _subTitle = [[UILabel alloc] init];
        _subTitle.textAlignment = NSTextAlignmentRight;
    }
    return _subTitle;
}

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.font = [UIFont systemFontOfSize:15.f];
        _titleLable.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLable;
}

@end
