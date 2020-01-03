//
//  ViewController.m
//  MultithreadingDemo
//
//  Created by TING on 27/12/2019.
//  Copyright © 2019 SHENZHEN TITA INTERACTIVE TECHNOLOGY CO.,LTD. All rights reserved.
//

#import "GCDDemo.h"



@interface GCDDemo ()


@property (nonatomic , strong) dispatch_source_t timer; 

@end

@implementation GCDDemo


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"GCD";
    
    [self setData];
    [self setUI];
    
}

- (void)setData{
    self.btnTitleArr = @[@"主队列同步",@"主队列异步",@"全局队列同步",
                         @"全局队列异步",@"串行队列同步",@"串行队列异步",
                         @"并发队列同步",@"并发队列异步",@"block任务",
                         @"函数任务",@"同步栅栏函数",@"异步栅栏函数",
                         @"dispatch_async + group",@"dispatch_group_async",@"dispatch_group_wait",
                         @"dispatchAfter",@"dispatchWallTime",@"dispatchApply",
                         @"dispatchOnce",@"信号量",@"计时器"];
    
    self.btnFunArr = @[@"mainQueueTest1",@"mainQueueTest2",@"globalQueueTest1",
                       @"globalQueueTest2",@"customQueueTest1",@"customQueueTest2",
                       @"customQueueTest3",@"customQueueTest4",@"blockTask",
                       @"functionTask",@"syncBarrier",@"asyncBarrier",
                       @"GCDGroup1",@"GCDGroup2",@"GCDGroup3",
                       @"dispatchAfter",@"dispatchWallTime",@"dispatchApply",
                       @"dispatchOnce",@"dispatchSemaphore",@"dispatchSource"];
}




#pragma mark - 任务
/**
 //同步执行
 void dispatch_sync(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block);
 void dispatch_sync_f(dispatch_queue_t queue, void *_Nullable context, dispatch_function_t work);
 void dispatch_barrier_sync(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block);
 void dispatch_barrier_sync_f(dispatch_queue_t queue, void *_Nullable context, dispatch_function_t work);
 
 //异步执行
 void dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
 void dispatch_async_f(dispatch_queue_t queue, void *_Nullable context, dispatch_function_t work);
 void dispatch_group_async(dispatch_group_t group, dispatch_queue_t queue, dispatch_block_t block);
 void dispatch_group_async_f(dispatch_group_t group, dispatch_queue_t queue, void *_Nullable context, dispatch_function_t work);
 void dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
 void dispatch_barrier_async_f(dispatch_queue_t queue, void *_Nullable context, dispatch_function_t work);
 */


#pragma mark block任务
/**
 void dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
参数一(queue)：派发队列，将任务添加到这个队列中。
 参数二(block)：执行任务的block。
 */
- (void)blockTask{
    NSLog(@"%@",[NSThread currentThread]);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ // blcok任务
        [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时任务
        NSLog(@"block任务--%@",[NSThread currentThread]);
    });
    
}

#pragma mark 函数任务
/**
  void dispatch_async_f(dispatch_queue_t queue, void *_Nullable context, dispatch_function_t work);
    参数一(queue)：派发队列，将任务添加到这个队列中
    参数三(work)：执行任务的函数，dispatch_function_t是一个函数指针(其定义为：typedef void (*dispatch_function_t)(void *_Nullable);)，指向耗时任务所在的的函数。
    参数二(context)：是给耗时任务的函数传的参数，参数类型是任意类型
 */
- (void)functionTask{
    NSLog(@"%@",[NSThread currentThread]);
    dispatch_async_f(dispatch_get_global_queue(0, 0), @"abc124", testFunction);
}

// 任务所在的函数
void testFunction(void *para){
    [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时任务
    NSLog(@"函数任务参数：%@----线程：%@",para,[NSThread currentThread]);
}

#pragma mark - 队列
#pragma mark  主队列测试
// 主队列同步函数
- (void)mainQueueTest1{
    [self aaa]; return;
    
    NSLog(@"\n");
    NSLog(@"主队列同步函数");
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_sync(mainQueue, ^{
            [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时操作
            NSLog(@"%ld--%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"----end----");
}

- (void)aaa{
    
    dispatch_queue_t queue1 = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue2 = dispatch_get_global_queue(0, 0);
    NSLog(@"%p,%p",queue1,queue2);
    
    dispatch_queue_t queue3 = dispatch_queue_create("abc", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue4 = dispatch_queue_create("abc", DISPATCH_QUEUE_SERIAL);
    NSLog(@"%p,%p",queue3,queue4);
}

// 主队列异步函数
- (void)mainQueueTest2{
    NSLog(@"\n");
    NSLog(@"主队列异步函数");
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_async(mainQueue, ^{
            [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时操作
            NSLog(@"%ld--%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"----end----");
}

#pragma mark  全局队列测试
// 全局队列同步函数
- (void)globalQueueTest1{
    NSLog(@"\n");
    NSLog(@"全局队列同步");
    // 全局队列(第一个参数是队列的优先级，第二个参数是保留参数)
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_sync(globalQueue, ^{
            [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时操作
            NSLog(@"%ld--%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"----end----");
}

// 全局队列异步函数
- (void)globalQueueTest2{
    NSLog(@"\n");
    NSLog(@"全局队列异步");
    // 全局队列(第一个参数是队列的优先级，第二个参数是保留参数)
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_async(globalQueue, ^{
            [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时操作
            NSLog(@"%ld--%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"----end----");
}

#pragma mark 自己创建队列
// 自建并串行列同步函数
- (void)customQueueTest1{
    NSLog(@"\n");
    NSLog(@"自建串行队列同步函数");
    dispatch_queue_t serialQueue = dispatch_queue_create("com.test.myQueue", DISPATCH_QUEUE_SERIAL);
    
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_sync(serialQueue, ^{
            [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时操作
            NSLog(@"%ld--%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"----end----");
}

// 自建串行队列异步函数
- (void)customQueueTest2{
    NSLog(@"\n");
    NSLog(@"自建串行队列异步函数<##>");
    dispatch_queue_t serialQueue = dispatch_queue_create("com.test.myQueue", DISPATCH_QUEUE_SERIAL);
    
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_async(serialQueue, ^{
            [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时操作
            NSLog(@"%ld--%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"----end----");
}

// 自建并发队列同步函数
- (void)customQueueTest3{
    NSLog(@"\n");
    NSLog(@"自建并发队列同步函数<##>");
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.test.myQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_sync(concurrentQueue, ^{
            [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时操作
            NSLog(@"%ld--%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"----end----");
}

// 自建并发队列异步函数
- (void)customQueueTest4{
    NSLog(@"\n");
    NSLog(@"自建并发队列异步函数<##>");
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.test.myQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSInteger i = 0; i < 5; i++) {
        dispatch_async(concurrentQueue, ^{
            [NSThread sleepForTimeInterval:1.0f]; // 模拟耗时操作
            NSLog(@"%ld--%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"----end----");
}


#pragma mark - 栅栏函数
/**
 需求：
 一个大文件被分成part1和part2两部分存在服务器上，现在要将part1和part2都下载下来后然后合并并写入磁盘。
 这里其实有4个任务，下载part1是task1，下载part2是task2，合并part1和part2是task3，将合并后的文件写入磁盘是task4。
 这4个任务执行顺序是task1和task2并发异步执行，这两个任务都执行完了后再执行task3，task3执行完了再执行task4。
 */
// 同步栅栏函数
- (void)syncBarrier{
    NSLog(@"当前线程1");
    dispatch_queue_t queue = dispatch_queue_create("com.demo.tsk", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
       NSLog(@"开始下载part1---%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0f]; // 模拟下载耗时2s
        NSLog(@"完成下载part1---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程2");
    
    dispatch_async(queue, ^{
       NSLog(@"开始下载part2---%@",[NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
       NSLog(@"完成下载part2---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程3");
    
    dispatch_barrier_sync(queue, ^{
       NSLog(@"开始合并part1和part2---%@",[NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
       NSLog(@"完成合并part1和part2---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程4");
        
    dispatch_async(queue, ^{
       NSLog(@"开始写入磁盘---%@",[NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
       NSLog(@"完成写入磁盘---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程5");
}

// 异步栅栏函数
- (void)asyncBarrier{
    NSLog(@"当前线程1");
    dispatch_queue_t queue = dispatch_queue_create("com.demo.tsk", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
       NSLog(@"开始下载part1---%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0f]; // 模拟下载耗时2s
        NSLog(@"完成下载part1---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程2");
    
    dispatch_async(queue, ^{
       NSLog(@"开始下载part2---%@",[NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
       NSLog(@"完成下载part2---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程3");
    
    dispatch_barrier_async(queue, ^{
       NSLog(@"开始合并part1和part2---%@",[NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
       NSLog(@"完成合并part1和part2---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程4");
        
    dispatch_async(queue, ^{
       NSLog(@"开始写入磁盘---%@",[NSThread currentThread]);
       [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
       NSLog(@"完成写入磁盘---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程5");
}


#pragma mark - 任务组
/**
 需求：某个界面需要请求banner信息和产品列表信息，等这两个接口的数据都返回后再回到主线程刷新UI
 */
// dispatch_group_enter()、dispatch_group_leave()和dispatch_async()配合使用
- (void)GCDGroup1{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.demo.tsk", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"当前线程1");
    dispatch_group_enter(group); // 开始任务前将任务交给任务组管理，任务组中任务数+1
    dispatch_async(queue, ^{
        NSLog(@"开始请求banner数据---%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
        NSLog(@"收到banner数据---%@",[NSThread currentThread]);
        dispatch_group_leave(group); // 任务结束后将任务从任务组中移除，任务组中任务数-1
    });
    
    NSLog(@"当前线程2");
    dispatch_group_enter(group); // 任务组中任务数+1
    dispatch_async(queue, ^{
        NSLog(@"开始请求产品列表数据---%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:3.0f]; // 模拟下载耗时1s
        NSLog(@"收到产品列表数据---%@",[NSThread currentThread]);
        dispatch_group_leave(group); // 任务组中任务数-1
    });
    
    NSLog(@"当前线程3");
    
    // 监听任务组中的任务的完成情况，当任务组中所有任务都完成时指定队列安排执行block中的代码
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"回到主线程刷新UI---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程4");
}

// dispatch_group_async的使用
- (void)GCDGroup2{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.demo.tsk", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"当前线程1");
    dispatch_group_async(group, queue, ^{
        NSLog(@"开始请求banner数据---%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
        NSLog(@"收到banner数据---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程2");
    dispatch_group_async(group, queue, ^{
        NSLog(@"开始请求产品列表数据---%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:3.0f]; // 模拟下载耗时1s
        NSLog(@"收到产品列表数据---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程3");
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"回到主线程刷新UI---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程4");
}

// dispatch_group_wait的使用
- (void)GCDGroup3{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.demo.tsk", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"当前线程1");
    dispatch_group_async(group, queue, ^{
        NSLog(@"开始请求banner数据---%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0f]; // 模拟下载耗时1s
        NSLog(@"收到banner数据---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程2");
    dispatch_group_async(group, queue, ^{
        NSLog(@"开始请求产品列表数据---%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:3.0f]; // 模拟下载耗时1s
        NSLog(@"收到产品列表数据---%@",[NSThread currentThread]);
    });
    
    NSLog(@"当前线程3");
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"回到主线程刷新UI---%@",[NSThread currentThread]);
//    });
    
    // 将等待时间设置为DISPATCH_TIME_FOREVER，表示永不超时，等任务组中任务全部都完成后才会执行其后面的代码
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)));
    
    NSLog(@"任务组中的任务全部完成，刷新UI");
    
    NSLog(@"当前线程4");
}

#pragma mark - dispatch_after和dispatch_time_t
// dispatch_after
// 需求：从现在开始，延迟3秒后在主线程刷新UI。
- (void)dispatchAfter{
    NSLog(@"现在时间--%@",[NSDate date]);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"到主线程刷新UI--%@",[NSDate date]);
    });
}

// dispatch_walltime
// 需求：从一个具体时间点开始，再晚10秒执行任务
- (void)dispatchWallTime{
    NSString *dateStr = @"2019-12-30 11:09:00";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    NSDate *date = [formatter dateFromString:dateStr];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    
    // dispatch_walltime第一个参数的结构体
    struct timespec timeStruct;
    timeStruct.tv_sec = (NSInteger)timeInterval;
    
    NSLog(@"设置的时间点--%@",[formatter stringFromDate:date]);
    
    // 比时间点再晚10秒
    dispatch_time_t time = dispatch_walltime(&timeStruct, (int64_t)(10 * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"到主线程刷新UI--%@",[formatter stringFromDate:[NSDate date]]);
    });
}

#pragma mark - dispatch_apply
- (void)dispatchApply{
    NSLog(@"开始");
    dispatch_queue_t queue = dispatch_queue_create("com.demo.tsk", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"第%ld次开始执行--%@",index,[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0f];
        NSLog(@"第%ld次结束执行--%@",index,[NSThread currentThread]);
    });
    NSLog(@"结束");
}

#pragma mark - dispatch_once
- (void)dispatchOnce{
    static GCDDemo *vc = nil;
    static dispatch_once_t onceToken;
    dispatch_apply(3, dispatch_get_global_queue(0, 0), ^(size_t idx) {
        NSLog(@"第%ld次开始执行--%@",idx,[NSThread currentThread]);
        dispatch_once(&onceToken, ^{
            vc = [[GCDDemo alloc] init];
            NSLog(@"是否只执行了一次--%@",[NSThread currentThread]);
        });
        NSLog(@"第%ld次结束执行--%@",idx,[NSThread currentThread]);
    });
}

#pragma mark - dispatch_semaphore(信号量)
// 信号量
- (void)dispatchSemaphore{
    
    dispatch_queue_t queue = dispatch_queue_create("com.demo.tsk", DISPATCH_QUEUE_CONCURRENT);
    
    // 创建信号量并设置信号值(最大并发数)为2
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    
    for (NSInteger i = 0; i < 5; i++) {
        // 如果信号值大于0，信号值减1并执行后续代码
        // 如果信号值等于0，当前线程将被阻塞处于等待状态，直到信号值大于0或者等待超时为止
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(queue, ^{
            NSLog(@"第%ld次开始执行--%@",i,[NSThread currentThread]);
            [NSThread sleepForTimeInterval:1.0f];
            NSLog(@"第%ld次结束执行--%@",i,[NSThread currentThread]);
            // 任务执行完后发送信号使信号值+1
            dispatch_semaphore_signal(semaphore);
        });
    }
    
    NSLog(@"******当前线程******");
}

#pragma mark - dispatch_source(实现定时器)
- (void)dispatchSource{
    
    __block NSInteger timeout = 10; // 倒计时时间
    dispatch_queue_t queue = dispatch_queue_create("my.queue", DISPATCH_QUEUE_CONCURRENT);
    
    /*
     创建一个dispatch_source_t对象(其本质是一个OC对象)
     第一个参数是要监听的事件的类型
     第4个参数是回调函数所在的队列
     第2和第3个参数是和监听事件类型(第一个参数)有关的，监听事件类型是DISPATCH_SOURCE_TYPE_TIMER时这两个参数都设置为0就可以了。
     具体的可以参考博客 https://www.cnblogs.com/wjw-blog/p/5903441.html
     */
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    /*
     设置计时器的一些参数
     第一个参数是前面创建的dispatch_source_t对象
     第二个参数是计时器开始的时间
     第三个参数是计时器间隔时间
     第四个参数是是一个微小的时间量，单位是纳秒，系统为了改进性能，会根据这个时间来推迟timer的执行以与其它系统活动同步。也就是设置timer允许的误差。
     */
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC, 0);
    
    // 设置回调事件
    dispatch_source_set_event_handler(self.timer, ^{
        timeout--;
        NSLog(@"%ld",timeout);
        if (timeout <= 0) {
            // 结束倒计时
            dispatch_source_cancel(self.timer);
        }
    });
    dispatch_resume(self.timer);
}

@end
