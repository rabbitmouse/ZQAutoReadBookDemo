//
//  DemoViewController.m
//  ZQAutoReadBook
//
//  Created by zzq on 2018/9/29.
//  Copyright © 2018年 zzq. All rights reserved.
//

#import "DemoViewController.h"
#import "ZQAutoReadViewController.h"
#import "ReadContentViewController.h"

@interface DemoViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource, ZQAutoViewDelegate>

@property (nonatomic, strong) UIPageViewController *pageCtr;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) ZQAutoReadViewController *autoReadController;


@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.colors = @[[UIColor redColor],[UIColor yellowColor],[UIColor blueColor],[UIColor greenColor],[UIColor orangeColor],[UIColor purpleColor]];
    
    
    [self addPageViewController];
    
    //开始自动阅读
    [self beginAutoRead];
}

- (void)addPageViewController {
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageViewController.doubleSided = YES;
    pageViewController.delegate = self;
    pageViewController.dataSource = self;
    [self addChildViewController:pageViewController];
    [self.view addSubview:pageViewController.view];
    
    _pageCtr = pageViewController;
    _pageCtr.view.frame = self.view.bounds;
    
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = self.colors[arc4random() % 6];
    [_pageCtr setViewControllers:@[ vc ]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
}

- (void)beginAutoRead {
    ZQAutoReadViewController *autoReadController = [ZQAutoReadViewController new];
    autoReadController.delegate = self;
    //加载当前界面
    [autoReadController updateWithView:[self captureView:self.view]];
    [autoReadController startAuto];
    [self.view addSubview:autoReadController.view];
    [self addChildViewController:autoReadController];
    self.autoReadController = autoReadController;
    //加载下一章||翻页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createNewContentController];
    });
}

- (UIImage *)captureView:(UIView *)view {
    CGRect rect = view.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)createNewContentController {
    ReadContentViewController *vc = [ReadContentViewController new];
    [_pageCtr setViewControllers:@[ vc ]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
}

#pragma mark - autoReadDelegate

- (void)finishReadPage:(ZQAutoReadViewController *)controller {
    
    //重设自动阅读界面
    [self.autoReadController updateWithView:[self captureView:self.view]];
    [self.autoReadController startAuto];
    //加载下一章||翻页
    [self createNewContentController];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NSLog(@"向前翻");
    
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = self.colors[arc4random() % 6];
    
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NSLog(@"向后翻");
    
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = self.colors[arc4random() % 6];
    
    return vc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {

}


@end
