//
//  LockDemo.m
//  MultithreadingDemo
//
//  Created by TING on 31/12/2019.
//  Copyright © 2019 SHENZHEN TITA INTERACTIVE TECHNOLOGY CO.,LTD. All rights reserved.
//

#import "LockDemo.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>
#import <pthread.h>

@interface LockDemo ()
@property (nonatomic , assign) NSInteger ticketCount;
@property (nonatomic , assign) OSSpinLock spinLock;
@property (nonatomic , assign) os_unfair_lock unfairLock;
@property (nonatomic , assign) pthread_mutex_t pthreadMutexNormalLock; // 常规锁
@property (nonatomic , assign) pthread_mutex_t pthreadMutexRecursiveLock; // 递归锁

// pthread_mutex条件锁
@property (nonatomic , assign) pthread_mutex_t pthreadMutexConditionLock; // 条件锁锁
@property (nonatomic , assign) pthread_cond_t pthreadCondition; // 条件
@property (nonatomic , strong) NSMutableArray *enemyArr; // 测试条件锁的数组


@property (nonatomic , strong) NSLock *nsLock;

@property (nonatomic , strong) NSRecursiveLock *nsRecursiveLock; // 递归锁

@property (nonatomic , strong) NSCondition *nsCondition; // 条件锁

@property (nonatomic , strong) NSConditionLock *nsConditionLock; // 条件锁

@property (nonatomic , strong) dispatch_queue_t serialQueue; // 串行队列实现线程同步

@property (nonatomic , strong) dispatch_semaphore_t semaphore; // 信号量

@property (nonatomic , assign) pthread_rwlock_t pthreadRwlock; // 读写锁


@property (nonatomic , strong) dispatch_queue_t readWriteQueue; // 异步栅栏函数实现读写锁的队列

@end

@implementation LockDemo

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"多线程锁";
    
    [self setData];
    [self setUI];
    
}

- (void)setData{
    self.btnTitleArr = @[@"不加锁",@"OSSpinLock(自旋锁)",@"os_unfair_lock",
                         @"pthread_mutex(常规锁)",@"pthread_mutex(递归锁)",@"pthread_mutex(条件锁)",
                         @"NSLock",@"NSRecursiveLock",@"NSCondition",
                         @"NSConditionLock",@"串行队列",@"信号量",
                         @"@synchronized",@"pthread_rwlock_t",@"异步栅栏读写锁"];
    
    self.btnFunArr = @[@"noLock",@"OSSpinLockTest",@"osUnfairLockTest",
                       @"pthreadMutexNormalLockTest",@"pthreadMutexRecursiveLockTest",@"pthreadMutexConditionLockTest",
                       @"nsLockTest",@"nsRecursiveLockTest",@"nsConditionTest",
                       @"nsConditionLockTest",@"serialQueueTest",@"dispatchSemaphoreTest",
                       @"synchronizedTest",@"pthreadRwlockTest",@"dispatchBarrierAsync"];
}


- (void)saleTicketWithSel:(SEL)selector{
    self.ticketCount = 10;
    
    // 线程1(窗口1)
    NSThread *thread1 = [[NSThread alloc] initWithBlock:^{
        for (NSInteger i = 0; i < 5; i++) {
            [self performSelector:selector];
        }
    }];
    thread1.name = @"窗口1";
    [thread1 start];

    // 线程2(窗口2)
    NSThread *thread2 = [[NSThread alloc] initWithBlock:^{
        for (NSInteger i = 0; i < 5; i++) {
            [self performSelector:selector];
        }
    }];
    thread2.name = @"窗口2";
    [thread2 start];
 
}

#pragma mark - 不加锁
- (void)noLock{
    [self saleTicketWithSel:@selector(noLockSaleTicket)];
}

// 不加锁时售票过程
- (void)noLockSaleTicket{
    NSInteger oldCount = self.ticketCount; // 取出余票数量
    if (oldCount > 0) {
        [NSThread sleepForTimeInterval:1.0f]; // 模拟售票耗时1秒
        self.ticketCount = --oldCount; // 售出一张票后更新剩余票数
    }
    NSLog(@"剩余票数：%ld--%@",self.ticketCount,[NSThread currentThread]);
}


#pragma mark - OSSpinLock(自旋锁)
- (void)OSSpinLockTest{
    NSLog(@"OSSpinLock<##>");
    [self saleTicketWithSel:@selector(OSSpinLockSaleTicket)];
}

- (void)OSSpinLockSaleTicket{
    if (!_spinLock) { // 初始化锁
        _spinLock = OS_SPINLOCK_INIT;
    }
    
    // 加锁
    OSSpinLockLock(&_spinLock);
    
    NSInteger oldCount = self.ticketCount;
    if (oldCount > 0) {
        [NSThread sleepForTimeInterval:1.0f];
        self.ticketCount = --oldCount;
    }
    NSLog(@"剩余票数：%ld--%@",self.ticketCount,[NSThread currentThread]);
    
    // 解锁
    OSSpinLockUnlock(&_spinLock);
}


#pragma mark - os_unfair_lock
- (void)osUnfairLockTest{
    NSLog(@"os_unfair_lock<##>");
    [self saleTicketWithSel:@selector(osUnfairLockSaleTicket)];
}

- (void)osUnfairLockSaleTicket{
    // 初始化锁(使用dispatch_once只是为了保证锁只被初始化一次)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _unfairLock = OS_UNFAIR_LOCK_INIT;
    });
    
    // 加锁
    os_unfair_lock_lock(&_unfairLock);
    
    NSInteger oldCount = self.ticketCount;
    if (oldCount > 0) {
        [NSThread sleepForTimeInterval:1.0f];
        self.ticketCount = --oldCount;
    }
    NSLog(@"os_unfair_lock剩余票数：%ld--%@",self.ticketCount,[NSThread currentThread]);
    
    // 解锁
    os_unfair_lock_unlock(&_unfairLock);
}


#pragma mark - pthread_mutex（互斥锁）
#pragma mark pthread_mutex常规锁
- (void)pthreadMutexNormalLockTest{
    NSLog(@"pthread_mutex<##> 常规锁");
    [self saleTicketWithSel:@selector(pthreadMutexNormalLockSaleTicket)];
}

/**
 // pthread_mutex互斥锁属性的类型
 #define PTHREAD_MUTEX_NORMAL        0 // 常规的锁(默认类型)
 #define PTHREAD_MUTEX_ERRORCHECK    1 // 检查错误类型的锁(一般用不上)
 #define PTHREAD_MUTEX_RECURSIVE        2 // 递归类型的锁
 #define PTHREAD_MUTEX_DEFAULT        PTHREAD_MUTEX_NORMAL  // 默认类型为常规类型
 */
- (void)pthreadMutexNormalLockSaleTicket{
    // 保证锁只被初始化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化锁的属性
        pthread_mutexattr_t attr; // 创建锁的属性
        pthread_mutexattr_init(&attr); // 初始化锁的属性
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL); // 设置锁属性的类型为常规锁
        
        // 根据锁的属性来初始化锁
        pthread_mutex_init(&_pthreadMutexNormalLock, &attr);
    });
    
    // 加锁
     pthread_mutex_lock(&_pthreadMutexNormalLock);
     
     NSInteger oldCount = self.ticketCount;
     if (oldCount > 0) {
         [NSThread sleepForTimeInterval:1.0f];
         self.ticketCount = --oldCount;
     }
     NSLog(@"pthread_mutex常规锁剩余票数：%ld--%@",self.ticketCount,[NSThread currentThread]);
     
     // 解锁
     pthread_mutex_unlock(&_pthreadMutexNormalLock);
}

#pragma mark pthread_mutex递归锁
- (void)pthreadMutexRecursiveLockTest{
    
    // 保证锁只被初始化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化锁的属性
        pthread_mutexattr_t attr; // 创建锁的属性
        pthread_mutexattr_init(&attr); // 初始化锁的属性
//        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL); // 设置锁属性的类型为常规锁的话就会造成死锁
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); // 设置锁属性的类型为递归锁
        
        // 根据锁的属性来初始化锁
        pthread_mutex_init(&_pthreadMutexRecursiveLock, &attr);
    });
    
    // 加锁
     pthread_mutex_lock(&_pthreadMutexRecursiveLock);
     
     // 加锁代码为递归调用
    static NSInteger i = 5;
    NSInteger temp = i--;
    if (temp > 0) {
        [self pthreadMutexRecursiveLockTest];
    }
    NSLog(@"pthread_mutex递归锁---%ld",temp);
     
     // 解锁
     pthread_mutex_unlock(&_pthreadMutexRecursiveLock);
}

#pragma mark pthread_mutex条件锁
/**
 需求：游戏中有产生敌人和杀死敌人2个方法是用同一把锁进行加锁的，杀死敌人有个前提条件就是必须有敌人存，
 如果在杀死敌人的线程获取到锁后发现敌人不存在，那这个线程就要等待，等有新的敌人产生了再进行杀死操作。
 */
- (void)pthreadMutexConditionLockTest{
    [self initPthreadConditionLock]; // 初始化锁、条件和一些相关数据
    
    // 创建一个线程调用killEnemy方法(此时还没有敌人，所以会进入等待状态)
    dispatch_queue_t queue = dispatch_queue_create("lock", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"killEnemy开始--%@<##>",[NSThread currentThread]);
        [self killEnemy];
        NSLog(@"killEnemy结束--%@<##>",[NSThread currentThread]);
    });
    
    // 2秒后再创建一个线程调用createEnemy方法来产生敌人
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), queue, ^{
        NSLog(@"createEnemy开始--%@<##>",[NSThread currentThread]);
        [self createEnemy];
        NSLog(@"createEnemy结束--%@<##>",[NSThread currentThread]);
    });
}

// 初始化锁、条件和一些相关数据（确保只初始化一次）
- (void)initPthreadConditionLock{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_pthreadMutexConditionLock, NULL); // 第二个参数传NULL时是一个常规锁
        pthread_cond_init(&_pthreadCondition, NULL); // 初始化条件，第二个参数一般就传NULL
    });
    
    if (!_enemyArr) {
        _enemyArr = [NSMutableArray array];
    }else{
        [_enemyArr removeAllObjects];
    }
}

// 杀死敌人
- (void)killEnemy{
    // 加锁
    pthread_mutex_lock(&_pthreadMutexConditionLock);
    
    if (_enemyArr.count == 0) {
        NSLog(@"还没有敌人，进入等待状态");
        pthread_cond_wait(&_pthreadCondition, &_pthreadMutexConditionLock); // 等待将锁和条件传进去
    }
    
    [_enemyArr removeLastObject];
    NSLog(@"杀死了敌人");
    
    // 解锁
    pthread_mutex_unlock(&_pthreadMutexConditionLock);
}

// 产生敌人
- (void)createEnemy{
    // 加锁
    pthread_mutex_lock(&_pthreadMutexConditionLock);
    
    NSObject *enemyObj = [NSObject new];
    [_enemyArr addObject:enemyObj];
    
    // 发送信号唤醒一条等待条件的线程
    pthread_cond_signal(&_pthreadCondition);
//    pthread_cond_broadcast(&_pthreadCondition); // 发送广播唤醒所有等待条件的线程
    
    if(_enemyArr.count == 1) NSLog(@"敌人数从0变为1，唤醒等待中的线程。");
    
    // 解锁
    pthread_mutex_unlock(&_pthreadMutexConditionLock);
}

#pragma mark - NSLock
- (void)nsLockTest{
    [self saleTicketWithSel:@selector(nsLockSaleTicket)];
}

- (void)nsLockSaleTicket{
    // 初始化锁
    if (!_nsLock) {
        _nsLock = [[NSLock alloc] init];
    }
    
    // 加锁
    [_nsLock lock];
    
    NSInteger oldCount = self.ticketCount;
    if (oldCount > 0) {
        [NSThread sleepForTimeInterval:1.0f];
        self.ticketCount = --oldCount;
    }
    NSLog(@"NSLock剩余票数：%ld--%@",self.ticketCount,[NSThread currentThread]);
    
    // 解锁
    [_nsLock unlock];
}

#pragma mark NSRecursiveLock 递归锁
- (void)nsRecursiveLockTest{
    if (!_nsRecursiveLock) { // 初始化锁
        _nsRecursiveLock = [[NSRecursiveLock alloc] init];
    }
    
    // 加锁
    [_nsRecursiveLock lock];
    
     // 加锁代码为递归调用
    static NSInteger i = 5;
    NSInteger temp = i--;
    if (temp > 0) {
        [self nsRecursiveLockTest];
    }
    NSLog(@"NSRecursiveLock 递归锁---%ld",temp);
     
     // 解锁
     [_nsRecursiveLock unlock];
}


#pragma mark - NSCondition 条件锁
- (void)nsConditionTest{
    // 初始化锁
    if (!_nsCondition) {
        _nsCondition = [[NSCondition alloc] init];
        _enemyArr = [NSMutableArray array];
    }
    
    // 创建一个线程调用killEnemy1方法(此时还没有敌人，所以会进入等待状态)
    dispatch_queue_t queue = dispatch_queue_create("NSCondition", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"killEnemy1开始--%@<##>",[NSThread currentThread]);
        [self killEnemy1];
        NSLog(@"killEnemy1结束--%@<##>",[NSThread currentThread]);
    });
    
    // 2秒后再创建一个线程调用createEnemy1方法来产生敌人
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), queue, ^{
        NSLog(@"createEnemy1开始--%@<##>",[NSThread currentThread]);
        [self createEnemy1];
        NSLog(@"createEnemy1结束--%@<##>",[NSThread currentThread]);
    });
}

// 杀死敌人
- (void)killEnemy1{
    // 加锁
    [_nsCondition lock];
    
    if (_enemyArr.count == 0) {
        NSLog(@"还没有敌人，进入等待状态");
        [_nsCondition wait]; // 等待
    }
    
    [_enemyArr removeLastObject];
    NSLog(@"杀死了敌人");
    
    // 解锁
    [_nsCondition unlock];
}

// 产生敌人
- (void)createEnemy1{
    // 加锁
    [_nsCondition lock];
    
    NSObject *enemyObj = [NSObject new];
    [_enemyArr addObject:enemyObj];
    
    // 发送信号唤醒一条等待条件的线程
    [_nsCondition signal];
//    [_nsCondition broadcast]; // 发送广播唤醒所有等待条件的线程
    
    if(_enemyArr.count == 1) NSLog(@"敌人数从0变为1，唤醒等待中的线程。");
    
    // 解锁
    [_nsCondition unlock];
}



#pragma mark - NSConditionLock 条件锁
// NSConditionLock是对NSCondition的进一步封装
- (void)nsConditionLockTest{
    // 用条件值初始化锁(也可以直接[[NSConditionLock alloc] init]来初始化，这样初始化的条件值是0)
    if(!_nsConditionLock){
        _nsConditionLock = [[NSConditionLock alloc] initWithCondition:1];
    }

    // 开启一个线程执行获取用户信息操作
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"开始获取用户信息");
        [self getUserInfoTest];
        NSLog(@"获取用户信息结束");
    });
    
    // 1秒钟后开启另一个线程执行登陆操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), queue, ^{
        NSLog(@"开始登陆");
        [self loginTest];
        NSLog(@"结束登陆");
    });
}

// 模拟登陆
- (void)loginTest{
    [_nsConditionLock lockWhenCondition:1];
    
    [NSThread sleepForTimeInterval:1.0f];
    NSLog(@"登陆成功");
    
    [_nsConditionLock unlockWithCondition:2];
}

// 模拟获取用户信息
- (void)getUserInfoTest{
    [_nsConditionLock lockWhenCondition:2];
    
    [NSThread sleepForTimeInterval:1.0f];
    NSLog(@"获取用户信息成功");
    
    [_nsConditionLock unlock];
}


#pragma mark - 串行队列配合同步函数实现线程同步
- (void)serialQueueTest{
    [self saleTicketWithSel:@selector(serialQueueSaleTicket)];
}

- (void)serialQueueSaleTicket{
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    dispatch_sync(_serialQueue, ^{ // 要加锁的代码块当成任务同步添加到队列中
        NSInteger oldCount = self.ticketCount;
        if (oldCount > 0) {
            [NSThread sleepForTimeInterval:1.0f];
            self.ticketCount = --oldCount;
        }
        NSLog(@"串行队列--剩余票数：%ld--%@",self.ticketCount,[NSThread currentThread]);
    });
}


#pragma mark - dispatch_semaphore_t 信号量
- (void)dispatchSemaphoreTest{
    [self saleTicketWithSel:@selector(dispatchSemaphoreSaleTicket)];
}

// dispatch_semaphore_wait()和dispatch_semaphore_signal()之间的代码就是要加锁的代码
- (void)dispatchSemaphoreSaleTicket{
    if (!_semaphore) { // 初始化信号量为1
        _semaphore = dispatch_semaphore_create(1);
    }
    
    // 如果信号量>0，则信号量-1并执行后面代码
    // 如果信号量<=0，则线程进入等待状态，第二个参数是等待时间，等信号量大于0或者等待超时时开始执行后续代码(DISPATCH_TIME_FOREVER表示永不超时)
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    NSInteger oldCount = self.ticketCount;
    if (oldCount > 0) {
        [NSThread sleepForTimeInterval:1.0f];
        self.ticketCount = --oldCount;
    }
    NSLog(@"信号量--剩余票数：%ld--%@",self.ticketCount,[NSThread currentThread]);
    
    // 执行dispatch_semaphore_signal()函数信号量+1
    dispatch_semaphore_signal(_semaphore);
}


#pragma mark - synchronized
// @synchronized底层是对pthread_mutex递归锁的封装，其内部会根据小括号传入的对象生成对应的递归锁，然后进行加锁解锁操作
- (void)synchronizedTest{
    @synchronized (self) {
        // 加锁代码为递归调用
           static NSInteger i = 5;
           NSInteger temp = i--;
           if (temp > 0) {
               [self nsRecursiveLockTest];
           }
           NSLog(@"NSRecursiveLock 递归锁---%ld",temp);
    }
}

#pragma mark - 读写锁
#pragma mark pthreadRwlock
- (void)pthreadRwlockTest{

    // 初始化锁
    pthread_rwlock_init(&_pthreadRwlock, NULL);
    
    dispatch_queue_t queue = dispatch_queue_create("rwlock", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSInteger i = 0; i < 2; i++) {
        dispatch_async(queue, ^{
            [self read];
            [self read];
            [self write];
            [self write];
            [self read];
            [self read];
        });
    }
}

// 读操作
- (void)read{
    // 读加锁
    pthread_rwlock_rdlock(&_pthreadRwlock);
    
    [NSThread sleepForTimeInterval:1.0f];
    NSLog(@"读操作");
    
    // 解锁
    pthread_rwlock_unlock(&_pthreadRwlock);
}

// 写操作
- (void)write{
    // 写加锁
    pthread_rwlock_wrlock(&_pthreadRwlock);
    
    [NSThread sleepForTimeInterval:1.0f];
    NSLog(@"写操作");
    
    // 解锁
    pthread_rwlock_unlock(&_pthreadRwlock);
}

#pragma mark dispatch_barrier_async（异步栅栏函数)实现读写锁
- (void)dispatchBarrierAsync{
    _readWriteQueue = dispatch_queue_create("readWriteQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSInteger i = 0; i < 2; i++) {
        dispatch_async(_readWriteQueue, ^{
            [self read1];
            [self read1];
            [self write1];
            [self write1];
            [self read1];
            [self read1];
        });
    }
}

// 读操作
- (void)read1{
    dispatch_async(_readWriteQueue, ^{
        [NSThread sleepForTimeInterval:1.0f];
        NSLog(@"读操作");
    });
}

// 写操作
- (void)write1{
    dispatch_barrier_async(_readWriteQueue, ^{
        [NSThread sleepForTimeInterval:1.0f];
        NSLog(@"写操作");
    });
}

@end
