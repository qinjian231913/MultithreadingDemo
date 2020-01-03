//
//  Interview.m
//  MultithreadingDemo
//
//  Created by TING on 30/12/2019.
//  Copyright © 2019 SHENZHEN TITA INTERACTIVE TECHNOLOGY CO.,LTD. All rights reserved.
//

#import "Interview.h"

@interface Interview ()

@end

@implementation Interview

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"面试题";
    
    [self setData];
    [self setUI];
}

- (void)setData{
    self.btnTitleArr = @[@"面试题1",@"面试题2",@"面试题3",
                         @"面试题4",@"面试题5",@"面试题6",
                         @"面试题7"];
    
    self.btnFunArr = @[@"interview1",@"interview2",@"interview3",
                       @"interview4",@"interview5",@"interview6",
                       @"interview7"];
}


#pragma mark - 面试题1
- (void)interview1{
    NSLog(@"面试题1");
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        NSLog(@"1---%@",[NSThread currentThread]);
        [self performSelector:@selector(test1) withObject:nil afterDelay:.0f];
        NSLog(@"3---%@",[NSThread currentThread]);
//        [[NSRunLoop currentRunLoop] run];
    });
    
}

- (void)test1{
    NSLog(@"2---%@",[NSThread currentThread]);
}

#pragma mark - 面试题2
- (void)interview2{
    NSLog(@"面试题2");
    
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
       NSLog(@"1---%@",[NSThread currentThread]);
        
        // 线程保活
        // 先向当前runloop中添加一个source（如果runloop中一个source、NSTime或Obserer都没有的话就会退出）
        // 然后启动runloop
        [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }];
    [thread start];
    
    [self performSelector:@selector(test2) onThread:thread withObject:nil waitUntilDone:YES];
}

- (void)test2{
    NSLog(@"2---%@",[NSThread currentThread]);
}

#pragma mark - 面试题3
- (void)interview3{
    NSLog(@"面试题3");
    NSLog(@"执行任务1--%@",[NSThread currentThread]);
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        NSLog(@"执行任务2--%@",[NSThread currentThread]);
    });
    
    NSLog(@"执行任务3--%@",[NSThread currentThread]);
}

#pragma mark - 面试题4
- (void)interview4{
    NSLog(@"面试题4");
    
    NSLog(@"执行任务1--%@",[NSThread currentThread]);
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"执行任务2--%@",[NSThread currentThread]);
    });
    
    NSLog(@"执行任务3--%@",[NSThread currentThread]);
}

#pragma mark - 面试题5
- (void)interview5{
    NSLog(@"面试题5");
    
    NSLog(@"执行任务1--%@",[NSThread currentThread]);
    
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSLog(@"执行任务2--%@",[NSThread currentThread]);
        
        dispatch_sync(queue, ^{
            NSLog(@"执行任务3--%@",[NSThread currentThread]);
        });
    
        NSLog(@"执行任务4--%@",[NSThread currentThread]);
    });
    
    NSLog(@"执行任务5--%@",[NSThread currentThread]);
}

#pragma mark - 面试题6
- (void)interview6{
    NSLog(@"面试题6");
    
    NSLog(@"执行任务1--%@",[NSThread currentThread]);
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
//        dispatch_queue_t queue2 = dispatch_queue_create("myqueu2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue2 = dispatch_queue_create("myqueu2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"执行任务2--%@",[NSThread currentThread]);
        
        dispatch_sync(queue2, ^{
            NSLog(@"执行任务3--%@",[NSThread currentThread]);
        });
        
        NSLog(@"执行任务4--%@",[NSThread currentThread]);
    });
    
    NSLog(@"执行任务5--%@",[NSThread currentThread]);
}

#pragma mark - 面试题7
- (void)interview7{
    NSLog(@"面试题7");
    
    NSLog(@"执行任务1--%@",[NSThread currentThread]);
    
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{ // 0
        NSLog(@"执行任务2--%@",[NSThread currentThread]);
        
        dispatch_sync(queue, ^{ // 1
            NSLog(@"执行任务3--%@",[NSThread currentThread]);
        });
        
        NSLog(@"执行任务4--%@",[NSThread currentThread]);
    });
    
    NSLog(@"执行任务5--%@",[NSThread currentThread]);
}

@end
