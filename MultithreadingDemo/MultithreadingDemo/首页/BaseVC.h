//
//  BaseVC.h
//  MultithreadingDemo
//
//  Created by TING on 30/12/2019.
//  Copyright © 2019 SHENZHEN TITA INTERACTIVE TECHNOLOGY CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

// 屏幕宽高
#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)

NS_ASSUME_NONNULL_BEGIN

@interface BaseVC : UIViewController

@property (nonatomic , strong) NSArray *btnTitleArr; // 按钮标题
@property (nonatomic , strong) NSArray *btnFunArr; // 按钮方法

- (void)setUI;

@end

NS_ASSUME_NONNULL_END
