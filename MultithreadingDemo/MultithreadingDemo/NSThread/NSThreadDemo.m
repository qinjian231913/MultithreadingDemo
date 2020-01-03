//
//  NSThreadDemo.m
//  MultithreadingDemo
//
//  Created by TING on 31/12/2019.
//  Copyright © 2019 SHENZHEN TITA INTERACTIVE TECHNOLOGY CO.,LTD. All rights reserved.
//

#import "NSThreadDemo.h"

@interface NSThreadDemo ()

@end

@implementation NSThreadDemo

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"NSThread";
    [self setData];
    [self setUI];
}

- (void)setData{
    self.btnTitleArr = @[@"实例化1",@"实例化2",@"隐式创建1",@"隐式创建2"];
    self.btnFunArr = @[@"threadInitTarget",@"threadInitBlock",@"implicitThreadTarget",@"implicitThreadBlock"];
}

#pragma mark - 通过target方式实例化
- (void)threadInitTarget{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(task1) object:nil];
    thread.name = @"thread1"; // 给线程取名
    thread.threadPriority = 0.3; // 设置线程优先级
    [thread start]; // 启动线程
}

- (void)task1{
    NSLog(@"task1--%@",[NSThread currentThread]);
}

#pragma mark - 通过block方式实例化
- (void)threadInitBlock{
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
       NSLog(@"task2--%@",[NSThread currentThread]);
    }];
    thread.name = @"thread2";
    [thread start];
}

#pragma mark - 通过target隐式创建线程
- (void)implicitThreadTarget{
    [NSThread detachNewThreadSelector:@selector(task3) toTarget:self withObject:nil];
}

- (void)task3{
    NSLog(@"task3--%@",[NSThread currentThread]);
}

#pragma mark - 通过block隐式创建线程
- (void)implicitThreadBlock{
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"task4--%@",[NSThread currentThread]);
    }];
}
@end
