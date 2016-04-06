//
//  ViewController.m
//  BlodWeightDemo
//
//  Created by apple on 16/3/31.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

#import "ViewController.h"
#import <BabyBluetooth/BabyBluetooth.h>
#import "BlueScalesData.h"
#import "LockScalesData.h"
#import "TemporaryScalesData.h"
#import "HistoryPersonData.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableArray *pers;
@property (weak, nonatomic) IBOutlet UILabel *connectLab;
@property (weak, nonatomic) IBOutlet UILabel *currWeight;
@property (weak, nonatomic) IBOutlet UILabel *doneWeight;
@property (weak, nonatomic) IBOutlet UILabel *fat;
@property (weak, nonatomic) IBOutlet UILabel *water;
@property (weak, nonatomic) IBOutlet UILabel *skeleton;
@property (weak, nonatomic) IBOutlet UILabel *muscle;
@property (weak, nonatomic) IBOutlet UILabel *metabolism;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *height;
@property (weak, nonatomic) IBOutlet UISwitch *sex;
@property (weak, nonatomic) IBOutlet UILabel *BMI;

@property (weak, nonatomic) IBOutlet UILabel *power;

@property (strong, nonatomic) NSMutableArray *temps;

@property (strong, nonatomic) CBCharacteristic *write;

@property (nonatomic, strong) HistoryPersonData *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.pers = [NSMutableArray array];
    self.temps = [NSMutableArray array];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(clickHistory)];
    
    [self installBlue];
}

- (void)clickHistory {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"history"] animated:YES];
}

- (void)installBlue {
    
    BabyBluetooth *blu = [BabyBluetooth shareBabyBluetooth];
    
    __weak typeof(self) weekSelf = self;
    [blu setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (![weekSelf.pers containsObject:peripheral]) {
            [weekSelf.pers addObject:peripheral];
            [weekSelf.tableView reloadData];
        }
    }];
    
    [blu setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (peripheralName.length > 0) {
            NSLog(@"%@",peripheralName);
            if ([peripheralName hasPrefix:@"B"]) {
                return YES;
            }
        }
        return NO;
    }];
    
    
    [blu setBlockOnDidUpdateName:^(CBPeripheral *peripheral) {
        if ([weekSelf.pers containsObject:peripheral]) {
            [weekSelf.pers replaceObjectAtIndex:[weekSelf.pers indexOfObject:peripheral] withObject:peripheral];
        }
    }];
    
    [blu setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [weekSelf.connectLab setText:@"连接设备成功（没准备好）"];
        NSArray *sers = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"FFF0"],[CBUUID UUIDWithString:@"FFD0"],[CBUUID UUIDWithString:@"180F"], nil];
        [peripheral discoverServices:sers];
    }];
    
    [blu setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [weekSelf.connectLab setText:@"设备断开连接"];
    }];
    
    [blu setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        [weekSelf.connectLab setText:@"查找特征值(已连接，准备中)"];
        for (CBService *service in peripheral.services) {
            if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {//读
                [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFF1"]] forService:service];
            } else if([service.UUID.UUIDString isEqualToString:@"FFD0"]) {//写
                [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFD1"]] forService:service];
            } else if([service.UUID.UUIDString isEqualToString:@"180F"]){
                [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A19"]] forService:service];
            }
        }
    }];
    
    [blu setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        [weekSelf.connectLab setText:@"设置特征值(准备好)"];
        if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {
            [peripheral setNotifyValue:YES forCharacteristic:[service.characteristics firstObject]];
        } else if([service.UUID.UUIDString isEqualToString:@"FFD0"]) {
            weekSelf.write = [service.characteristics firstObject];
        } else if([service.UUID.UUIDString isEqualToString:@"180F"]) {
            [peripheral setNotifyValue:YES forCharacteristic:[service.characteristics firstObject]];
            [peripheral readValueForCharacteristic:[service.characteristics firstObject]];
        }
    }];
    
    
    [blu setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
    }];
    
    
    [blu setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSData *data = characteristic.value;
        const uint8_t *bytes = data.bytes;
        NSInteger length = data.length;
        NSLog(@"read characteristic -- %@",characteristic.UUID.UUIDString);
        if ([characteristic.UUID.UUIDString isEqualToString:@"2A19"]) {
            weekSelf.power.text = [NSString stringWithFormat:@"%d%%",bytes[0]];
            return ;
        }
        if(length <= 1) {
            NSLog(@"end");
            [weekSelf.temps removeAllObjects];
        } else {
            BlueScalesData *data = [BlueScalesData scalesDataWithBytes:bytes length:length];
            if (data.cmd == 0x01) {//零时体重
                TemporaryScalesData *temp= [TemporaryScalesData dataWithDatas:data.data];
                
                weekSelf.currWeight.text = [NSString stringWithFormat:@"%.1f",temp.weight];
                [weekSelf.temps addObject:temp];
                if (weekSelf.temps.count == 1) {
                    
                    weekSelf.data = [[HistoryPersonData alloc] init];
                    weekSelf.data.sex = weekSelf.sex.on;
                    weekSelf.data.age = weekSelf.age.text.integerValue;
                    weekSelf.data.height = weekSelf.height.text.integerValue;
                    
                    
                    
                    unsigned char bs[8] = {0x00};
                    bs[0] = 0xFA;
                    bs[1] = 0x85;
                    bs[2] = 0x04;
                    bs[3] = 0x01;
                    bs[4] = (weekSelf.sex.on & 0xFF);
                    bs[5] = (weekSelf.age.text.integerValue & 0xFF);
                    bs[6] = (weekSelf.height.text.integerValue & 0xFF);
                    
                    bs[7] = calcFCS((bs + 1), 6);
                    NSData *data = [NSData dataWithBytes:bs length:8];
                    [peripheral writeValue:data forCharacteristic:weekSelf.write type:CBCharacteristicWriteWithResponse];
                }
                
            } else if(data.cmd == 0x02) { //锁定测量结果
                //                //需要向体重秤返回成功回调。。
                
                LockScalesData *lock = [LockScalesData dataWithDatas:data.data];
                weekSelf.data.data = lock;
                
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    [realm addObject:weekSelf.data];
                }];
                
                weekSelf.doneWeight.text = [NSString stringWithFormat:@"%.1fKG(%@)",lock.weight,[weekSelf weightSandard:lock.weight]];
                weekSelf.fat.text = [NSString stringWithFormat:@"%.1f%%(%@)",lock.fat,[weekSelf fatStandard:lock.fat]];
                weekSelf.water.text = [NSString stringWithFormat:@"%.1f%%(%@)",lock.whater,[weekSelf waterStandard:lock.whater]];
                weekSelf.muscle.text = [NSString stringWithFormat:@"%.1f%%(%@)",lock.muscle,[weekSelf muscleSandard:lock.muscle]];
                weekSelf.skeleton.text = [NSString stringWithFormat:@"%.1f%%(%@)",lock.skeleton,[weekSelf skeletonSandard:lock.skeleton]];
                weekSelf.metabolism.text = [NSString stringWithFormat:@"%.1f",lock.metabolism];
            }
        }
        
    }];
    
}

- (NSString *)weightSandard:(float)weight {
    NSString *str = @"";
    float bmi = weight / powf(self.height.text.floatValue / 100.0,2);
    self.BMI.text = [NSString stringWithFormat:@"%.1f%%(正常范围：18.5-23.9)",bmi];
    if (bmi < 18.5) {//体重过低
        str = @"体重过低";
    } else if(bmi >= 18.5 && bmi <= 23.9) {//适宜体重
        str = @"适宜体重";
    } else if(bmi >=24.0 && bmi <= 27.9) {//超重
        str = @"超重";
    } else {//肥胖
        str = @"肥胖";
    }
    
    return str;
}

- (NSString *)skeletonSandard:(float)muscle {//骨骼
    NSString *str = @"";
    if(self.sex.on) {//男
        if (self.age.text.integerValue <= 54) {
            str = @"标准：2.4%";
            
        } else if (self.age.text.integerValue >= 54 && self.age.text.integerValue <= 75) {
            str = @"标准：2.8%";
        } else {
            str = @"标准：3.1%";
        }
    } else {
        if (self.age.text.integerValue <= 39) {
            str = @"标准：1.7%";
        } else if (self.age.text.integerValue >= 40 && self.age.text.integerValue <= 60) {
            str = @"标准：2.1%";
        } else {
            str = @"标准：2.4%";
        }
    }
    return str;
}


- (NSString *)muscleSandard:(float)muscle {//肌肉
    NSString *str = @"";
    if(self.sex.on) {
        NSString *s = @"正常范围：31-34";
        if (muscle <= 30) {
            str = [NSString stringWithFormat:@"低  %@",s];
        } else if(muscle >= 31 && muscle <= 34) {
            str = [NSString stringWithFormat:@"标准  %@",s];
        } else if(muscle >= 35 && muscle <= 38) {
            str = [NSString stringWithFormat:@"偏高  %@",s];
        } else if(muscle >= 39){
            str = [NSString stringWithFormat:@"高  %@",s];
        }
    } else {
        
        NSString *s = @"正常范围：25-27";
        if (muscle <= 25) {
            str = [NSString stringWithFormat:@"低  %@",s];
        } else if(muscle >= 25 && muscle <= 27) {
            str = [NSString stringWithFormat:@"标准  %@",s];
        } else if(muscle >= 28 && muscle <= 29) {
            str = [NSString stringWithFormat:@"偏高  %@",s];
        } else if(muscle >= 30){
            str = [NSString stringWithFormat:@"高  %@",s];
        }
    }
    return str;
}

- (NSString *)waterStandard:(float)water {
    NSString *str = @"";
    if (self.age.text.integerValue>=6 && self.age.text.integerValue <= 15) {
        if(self.sex.on) {//男
            NSString *s = @"正常范围：58-72";
            if (water < 58) {//偏低
                str = [NSString stringWithFormat:@"偏低  %@",s];
            } else if(water >=58 && water <= 72) {//正常
                str = [NSString stringWithFormat:@"正常  %@",s];
            } else if(water > 72) {//偏高
                str = [NSString stringWithFormat:@"偏高  %@",s];
            }
        } else {
            NSString *s = @"正常标准：57-67";
            if (water < 57) {//偏瘦
                str = [NSString stringWithFormat:@"偏低  %@",s];
            } else if(water >=57 && water <=67) {//正常
                str = [NSString stringWithFormat:@"正常  %@",s];
            } else if(water > 67) {//偏高
                str = [NSString stringWithFormat:@"偏高  %@",s];
            }
        }
    } else if (self.age.text.integerValue >= 15 && self.age.text.integerValue <= 30)  {
        if(self.sex.on) {//男
            NSString *s = @"正常范围：53-67";
            if (water < 53) {//偏低
                str = [NSString stringWithFormat:@"偏低  %@",s];
            } else if(water >=53 && water <= 67) {//正常
                str = [NSString stringWithFormat:@"正常  %@",s];
            } else if(water > 67) {//偏高
                str = [NSString stringWithFormat:@"偏高  %@",s];
            }
        } else {
            NSString *s = @"正常范围：47-57";
            if (water < 47) {//偏低
                str = [NSString stringWithFormat:@"偏低  %@",s];
            } else if(water >=47 && water <= 57) {//正常
                str = [NSString stringWithFormat:@"正常  %@",s];
            } else if(water > 57) {//偏高
                str = [NSString stringWithFormat:@"偏高  %@",s];
            }
        }
    } else if (self.age.text.integerValue >= 31 && self.age.text.integerValue <= 60)  {
        if(self.sex.on) {//男
            NSString *s = @"正常范围：47-61";
            if (water < 47) {//偏低
                str = [NSString stringWithFormat:@"偏低  %@",s];
            } else if(water >=47 && water <= 61) {//正常
                str = [NSString stringWithFormat:@"正常  %@",s];
            } else if(water > 61) {//偏高
                str = [NSString stringWithFormat:@"偏高  %@",s];
            }
        } else {
            NSString *s = @"正常范围：42-52";
            if (water < 42) {//偏低
                str = [NSString stringWithFormat:@"偏低  %@",s];
            } else if(water >=42 && water <= 52) {//正常
                str = [NSString stringWithFormat:@"正常  %@",s];
            } else if(water > 52) {//偏高
                str = [NSString stringWithFormat:@"偏高  %@",s];
            }
        }
    } else if (self.age.text.integerValue > 60) {
        if(self.sex.on) {//男
            NSString *s = @"正常范围：42-56";
            if (water < 42) {//偏低
                str = [NSString stringWithFormat:@"偏低  %@",s];
            } else if(water >=42 && water <= 56) {//正常
                str = [NSString stringWithFormat:@"正常  %@",s];
            } else if(water > 56) {//偏高
                str = [NSString stringWithFormat:@"偏高  %@",s];
            }
        } else {
            NSString *s = @"正常范围：37-47";
            if (water < 37) {//偏低
                str = [NSString stringWithFormat:@"偏低  %@",s];
            } else if(water >=37 && water <= 47) {//正常
                str = [NSString stringWithFormat:@"正常  %@",s];
            } else if(water > 47) {//偏高
                str = [NSString stringWithFormat:@"偏高  %@",s];
            }
        }
    }
    return str;
}


- (NSString *)fatStandard:(float)fat {
    NSString *str = @"";
    if (self.age.text.integerValue>=6 && self.age.text.integerValue <= 39) {
        if(self.sex.on) {//男
            NSString *s = @"正常标准：8-19";
            if (fat < 8) {//偏瘦
                str = [NSString stringWithFormat:@"偏瘦  %@",s];
            } else if(fat >=8 && fat <= 19) {//标准
                str = [NSString stringWithFormat:@"标准  %@",s];
            } else if(fat >=19 && fat <= 25) {//偏胖
                str = [NSString stringWithFormat:@"偏胖  %@",s];
            } else if(fat > 25) {//胖
                str = [NSString stringWithFormat:@"胖  %@",s];
            }
        } else {
            NSString *s = @"正常标准：21-23";
            if (fat < 21) {//偏瘦
                str = [NSString stringWithFormat:@"偏瘦  %@",s];
            } else if(fat >=21 && fat <= 23) {//标准
                str = [NSString stringWithFormat:@"标准  %@",s];
            } else if(fat >=33 && fat <= 39) {//偏胖
                str = [NSString stringWithFormat:@"偏胖  %@",s];
            } else if(fat > 39) {//胖
                str = [NSString stringWithFormat:@"胖  %@",s];                
            }
        }
    } else if (self.age.text.integerValue >= 40 && self.age.text.integerValue <= 59)  {
        if(self.sex.on) {//男
            NSString *s = @"正常标准：11-22";
            if (fat < 11) {//偏瘦
                str = [NSString stringWithFormat:@"偏瘦  %@",s];
            } else if(fat >=11 && fat <= 22) {//标准
                str = [NSString stringWithFormat:@"标准  %@",s];
            } else if(fat >=22 && fat <= 28) {//偏胖
                str = [NSString stringWithFormat:@"偏胖  %@",s];
            } else if(fat > 28) {//胖
                str = [NSString stringWithFormat:@"胖  %@",s];
            }
        } else {
            NSString *s = @"正常标准：23-35";
            if (fat < 23) {//偏瘦
                str = [NSString stringWithFormat:@"偏瘦  %@",s];
            } else if(fat >=23 && fat <= 35) {//标准
                str = [NSString stringWithFormat:@"标准  %@",s];
            } else if(fat >=35 && fat <= 40) {//偏胖
                str = [NSString stringWithFormat:@"偏胖  %@",s];
            } else if(fat > 40) {//胖
                str = [NSString stringWithFormat:@"胖  %@",s];
            }
        }
    } else if (self.age.text.integerValue >= 60) {
        if(self.sex.on) {//男
            NSString *s = @"正常标准：13-25";
            if (fat < 13) {//偏瘦
                str = [NSString stringWithFormat:@"偏瘦  %@",s];
            } else if(fat >=13 && fat <= 25) {//标准
                str = [NSString stringWithFormat:@"标准  %@",s];
            } else if(fat >=25 && fat <= 30) {//偏胖
                str = [NSString stringWithFormat:@"偏胖  %@",s];
            } else if(fat > 30) {//胖
                str = [NSString stringWithFormat:@"胖  %@",s];
            }
        } else {
            NSString *s = @"正常标准：24-36";
            if (fat < 24) {//偏瘦
                str = [NSString stringWithFormat:@"偏瘦  %@",s];
            } else if(fat >=24 && fat <= 36) {//标准
                str = [NSString stringWithFormat:@"标准  %@",s];
            } else if(fat >=36 && fat <= 42) {//偏胖
                str = [NSString stringWithFormat:@"偏胖  %@",s];
            } else if(fat > 42) {//胖
                str = [NSString stringWithFormat:@"胖  %@",s];
            }
        }
    }
    return str;
}


- (IBAction)clickSearch:(id)sender {
    BabyBluetooth *blu = [BabyBluetooth shareBabyBluetooth];
    if(self.tableView.hidden) {
        self.tableView.hidden = NO;
        blu.scanForPeripherals().begin();
        
    } else {
        self.tableView.hidden = YES;
        [blu cancelScan];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    CBPeripheral *peripheral = self.pers[indexPath.row];
    cell.textLabel.text = peripheral.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *peripheral = self.pers[indexPath.row];
    [[BabyBluetooth shareBabyBluetooth].centralManager connectPeripheral:peripheral options:nil];
    [self.connectLab setText:@"尝试连接设备"];
}

unsigned char calcFCS(unsigned char*pMsg,unsigned char len) {
    
    unsigned char result = 0;
    while (len--)
    {
        result ^= *pMsg++;
    }
    return result;
}

- (IBAction)tap:(id)sender {
    [self.view endEditing:YES];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if ([touch.view isKindOfClass:[UIControl class]] ) {
        // we touched our control surface
        return NO; // ignore the touch
    }
    if ([NSStringFromClass([touch.view class]) hasPrefix:@"UITableView"]) {
        return NO;
    }
    return YES; // handle the touch
}

@end
