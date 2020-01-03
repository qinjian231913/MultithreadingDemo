//
//  BaseVC.m
//  MultithreadingDemo
//
//  Created by TING on 30/12/2019.
//  Copyright © 2019 SHENZHEN TITA INTERACTIVE TECHNOLOGY CO.,LTD. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)setUI{
    
    CGFloat btnW = 170;
    CGFloat btnH = 45;
    CGFloat btnSpace = (WIDTH - btnW * 2)/3;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 88, WIDTH, HEIGHT-88)];
    scrollView.contentSize = CGSizeMake(WIDTH, (self.btnFunArr.count/2)*(btnH+30)+100);
    [self.view addSubview:scrollView];
    
    for (NSInteger i = 0; i < self.btnTitleArr.count; i++) {
        NSString *title = self.btnTitleArr[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnSpace+(btnW+btnSpace)*(i%2), 30+(btnH+30)*(i/2), btnW, btnH);
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        btn.layer.borderColor = UIColor.blackColor.CGColor;
        btn.layer.borderWidth = 1;
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:title.length>8?15:17];
        [scrollView addSubview:btn];
        [btn addTarget:self action:NSSelectorFromString(self.btnFunArr[i]) forControlEvents:UIControlEventTouchUpInside];
    }
}

@end
