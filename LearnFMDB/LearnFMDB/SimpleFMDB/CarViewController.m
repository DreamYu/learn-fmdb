//
//  CarViewController.m
//  LearnFMDB
//
//  Created by Roy on 2018/3/22.
//  Copyright © 2018年 Roy. All rights reserved.
//

#import "CarViewController.h"
#import "DataBase.h"
#import "Person.h"
#import "Car.h"

@interface CarViewController ()

@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,strong) NSMutableArray *carArray;

@end

@implementation CarViewController

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"车库";
    
    self.dataArray = [[DataBase shareDataBase] getAllPerson];
    
    for (int i = 0 ; i < self.dataArray.count; i++) {
        Person *person = self.dataArray[i];
        NSMutableArray *carArray =  [[DataBase shareDataBase] getAllCarsFromPerson:person];
        [self.carArray addObject:carArray];
    }
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *carArray = self.carArray[section];
    return carArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"carcell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"carcell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSMutableArray *carArray = self.carArray[indexPath.section];
    Car *car = carArray[indexPath.row];
    cell.textLabel.text = car.brand;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"price: $% ld",car.price];
    return cell;
}

#pragma mark - Getter
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
    
}

- (NSMutableArray *)carArray{
    if (!_carArray) {
        _carArray = [[NSMutableArray alloc ] init];
    }
    return _carArray;
    
}



@end
