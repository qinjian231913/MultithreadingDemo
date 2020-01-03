//
//  MainVC.m
//  MultithreadingDemo
//
//  Created by TING on 30/12/2019.
//  Copyright © 2019 SHENZHEN TITA INTERACTIVE TECHNOLOGY CO.,LTD. All rights reserved.
//

#import "MainVC.h"
#import "GCDDemo.h"
#import "Interview.h"
#import "NSThreadDemo.h"
#import "NSOperationDemo.h"
#import "LockDemo.h"

@interface MainVC ()


@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"首页";
    
    [self setData];
    [self setUI];
}

- (void)setData{
    self.btnTitleArr = @[@"NSThread",@"GCD",@"NSOperationDemo",@"多线程面试题",@"多线程锁"];
    
    self.btnFunArr = @[@"toNSThread",@"toGCD",@"toNSOperationDemo",@"toInterview",@"toLock"];
    
}

#pragma mark - NSThread
- (void)toNSThread{
    NSThreadDemo *thread = [[NSThreadDemo alloc] init];
    [self.navigationController pushViewController:thread animated:YES];
}

#pragma mark - GCD
- (void)toGCD{
    GCDDemo *gcd = [[GCDDemo alloc] init];
    [self.navigationController pushViewController:gcd animated:YES];
}

#pragma mark - NSOperationDemo
- (void)toNSOperationDemo{
    NSOperationDemo *op = [[NSOperationDemo alloc] init];
    [self.navigationController pushViewController:op animated:YES];
}

#pragma mark - 面试
- (void)toInterview{
    Interview *interview = [[Interview alloc] init];
    [self.navigationController pushViewController:interview animated:YES];
}

#pragma mark - 多线程锁
- (void)toLock{
    LockDemo *lock = [[LockDemo alloc] init];
    [self.navigationController pushViewController:lock animated:YES];
}

@end
