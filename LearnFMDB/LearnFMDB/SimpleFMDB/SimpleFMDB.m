//
//  SimpleFMDB.m
//  LearnFMDB
//
//  Created by Roy on 2018/3/15.
//  Copyright © 2018年 Roy. All rights reserved.
//

#import "SimpleFMDB.h"
#import "DataBase.h"
#import "SimpleTableViewCell.h"
#import "Person.h"
#import "Car.h"
#import "CarViewController.h"
#import "PersonCarViewController.h"

@interface SimpleFMDB ()<UITableViewDelegate, UITableViewDataSource>

/**
 *  数据源
 */
@property(nonatomic, strong) NSMutableArray *dataArray;

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation SimpleFMDB

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.dataArray = [[DataBase shareDataBase] getAllPerson];
    [self.tableView reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addData)];
    UIBarButtonItem *watchItem = [[UIBarButtonItem alloc] initWithTitle:@"车库" style:UIBarButtonItemStylePlain target:self action:@selector(watchCars)];
    
    self.navigationItem.rightBarButtonItems = @[addItem, watchItem];
    
    [self.view addSubview:self.tableView];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SimpleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultcell"];

    Person *person = self.dataArray[indexPath.row];
    if (person.number == 0) {
        cell.titleLable.text = person.name;
    }else{
        cell.titleLable.text = [NSString stringWithFormat:@"%@(第%ld次更新)", person.name, person.number];
    }
    cell.subTitle.text = [NSString stringWithFormat:@"age: %ld",person.age];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PersonCarViewController *pcvc = [[PersonCarViewController alloc] init];
    pcvc.person = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:pcvc animated:YES];
}

/// 删除数据
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Person *person = self.dataArray[indexPath.row];
        [[DataBase shareDataBase] deletePerson:person];
        person.name = @"张三";
        [[DataBase shareDataBase] updatePerson:person];
        self.dataArray = [[DataBase shareDataBase] getAllPerson];
        [self.tableView reloadData];
        
    }
    
}


#pragma mark - Action
/**
 *  添加数据到数据库
 */
- (void)addData{
    int nameRandom = arc4random_uniform(1000);
    NSInteger ageRandom = arc4random_uniform(100) + 1;
    NSString  *name = [NSString stringWithFormat:@"person_%d号",nameRandom];
    NSInteger age = ageRandom;
    
    Person *person = [[Person alloc] init];
    person.name = name;
    person.age = age;
    
    [[DataBase shareDataBase] addPerson:person];
    
    self.dataArray = [[DataBase shareDataBase] getAllPerson];
    
    [self.tableView reloadData];
}

- (void)watchCars{
    CarViewController *carVc = [[CarViewController alloc] init];
    [self.navigationController pushViewController:carVc animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[SimpleTableViewCell class] forCellReuseIdentifier:@"defaultcell"];
    }
    return _tableView;
}

@end
