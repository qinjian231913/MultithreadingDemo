//
//  NSOperationDemo.m
//  MultithreadingDemo
//
//  Created by TING on 31/12/2019.
//  Copyright © 2019 SHENZHEN TITA INTERACTIVE TECHNOLOGY CO.,LTD. All rights reserved.
//

#import "NSOperationDemo.h"

@interface NSOperationDemo ()

@end

@implementation NSOperationDemo

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"NSOperationDemo";
    
    [self setData];
    [self setUI];
}

- (void)setData{
    self.btnTitleArr = @[@"NSInvocationOperation",@"NSBlockOperation1",@"NSBlockOperation2",
                         @"主队列",@"自定义队列",@"线程通信",
                         @"操作的依赖关系"];
    
    self.btnFunArr = @[@"NSInvocationOperationTest",@"NSBlockOperation1",@"NSBlockOperation2",
                       @"mainQueueTest",@"customQueueTest",@"threadCommunication",
                       @"operationDependency"];
}

#pragma mark - NSInvocationOperation的使用
// NSInvocationOperation执行的任务默认是在当前线程执行
- (void)NSInvocationOperationTest{
    NSInvocationOperation *io = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task) object:nil];
    
    [io start];
}

- (void)task1{
    NSLog(@"task1-->%@",[NSThread currentThread]);
}

#pragma mark - NSBlockOperation的使用
#pragma mark NSBlockOperation单任务
// 如果任务只有一个，那么任务是在当前线程执行
- (void)NSBlockOperation1{
    NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1-->%@",[NSThread currentThread]);
    }];

    [bo start];
}

#pragma mark NSBlockOperation多任务
// 当任务数量大于1时会开启新的线程去执行
- (void)NSBlockOperation2{
    NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
          NSLog(@"1-->%@",[NSThread currentThread]);
      }];
      
    // 添加任务块
   [bo addExecutionBlock:^{
          NSLog(@"2-->%@",[NSThread currentThread]);
      }];
      
      [bo addExecutionBlock:^{
          [NSThread sleepForTimeInterval:2.0f];
          NSLog(@"3-->%@",[NSThread currentThread]);
      }];
      
      [bo addExecutionBlock:^{
          NSLog(@"4-->%@",[NSThread currentThread]);
      }];
      
      // 所有任务都执行完后执行completionBlock中的代码
      bo.completionBlock = ^{
          NSLog(@"完成");
      };

      [bo start];
}

#pragma mark - NSOperationQueue（队列）
#pragma mark 主队列
// 一般添加到主队列中的任务是在主线程中执行，但是通过NSBlockOperation添加的任务数如果大于1，那么是会开启新的线程去执行任务的
- (void)mainQueueTest{
    // 获取主队列
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    NSInvocationOperation *io = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
        
    NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"2-->%@",[NSThread currentThread]);
        }];
            
    [bo addExecutionBlock:^{
            NSLog(@"3-->%@",[NSThread currentThread]);
        }];
    
    // 先队列中添加NSOperation对象
    [queue addOperation:io];
    [queue addOperation:bo];
}

- (void)task2{
    NSLog(@"1-->%@",[NSThread currentThread]);
}

#pragma mark  自定义队列
// 添加到自定义队列中的任务会自动开启子线程去执行(子线程的创建由系统控制，添加的多个任务可能在同一个子线程中执行也可能在不同子线程中执行)
- (void)customQueueTest{
    // 创建自定义队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 设置最大并发数为2
    queue.maxConcurrentOperationCount = 2;
    
    NSMutableArray *temArr = [NSMutableArray array];
    for (NSInteger i = 0; i < 5; i++) {
        NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1.0f];
            NSLog(@"%ld-->%@",i,[NSThread currentThread]);
        }];
        [temArr addObject:bo];
    }
    
    // 向队列中添加多个NSOperation，第二个参数为YES表名会阻塞当前线程，等所有任务都完成了才会继续后面的代码
    [queue addOperations:temArr waitUntilFinished:YES];
    
    NSLog(@"----end----");
}

#pragma mark - 线程通信
- (void)threadCommunication{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"开始子线程任务--%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1]; // 模拟耗时操作
        NSLog(@"结束子线程任务--%@",[NSThread currentThread]);
        
        // 回到主线程刷新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           NSLog(@"回到主线程刷新UI--%@",[NSThread currentThread]);
        }];
    }];
    [queue addOperation:bo];
}

#pragma mark - 操作的依赖关系
- (void)operationDependency{

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"任务1-->%@",[NSThread currentThread]);
    }];
    // 设置任务优先级
    bo1.queuePriority = NSOperationQueuePriorityVeryHigh;
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"任务2-->%@",[NSThread currentThread]);
    }];
    
    bo2.queuePriority = NSOperationQueuePriorityNormal;
    
    NSBlockOperation *bo3 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"任务3-->%@",[NSThread currentThread]);
    }];
    
    bo3.queuePriority = NSOperationQueuePriorityVeryLow;
    
    // 添加依赖
    [bo1 addDependency:bo2]; // bo1依赖bo2，也就是bo2执行完了才会执行bo1
    [bo2 addDependency:bo3]; // bo2依赖bo3，也就是bo3执行完了才会执行bo2
    
    [queue addOperations:@[bo1,bo2,bo3] waitUntilFinished:NO];
    
    // 回到主线程刷新UI
    NSBlockOperation *bo4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"回到主线程刷新UI-->%@",[NSThread currentThread]);
    }];
    // 有依赖关系的2个任务可以不在一个队列中
    [bo4 addDependency:bo1];
    [[NSOperationQueue mainQueue] addOperation:bo4];
}

@end
