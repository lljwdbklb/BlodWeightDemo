//
//  HistoryController.m
//  BlodWeightDemo
//
//  Created by apple on 16/4/6.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

#import "HistoryController.h"
#import "HistoryPersonData.h"

@interface HistoryController ()
@property (strong, nonatomic) RLMResults *array;
@end

@implementation HistoryController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.array  = [HistoryPersonData allObjects];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    HistoryPersonData *data = [self.array objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %ld %ld",data.sex?@"男":@"女",data.age,data.height];
    cell.detailTextLabel.text = data.data.subtime;
    return cell;
}

@end
