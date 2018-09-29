//
//  ViewController.m
//  ZQAutoReadBook
//
//  Created by zzq on 2018/9/29.
//  Copyright © 2018年 zzq. All rights reserved.
//

#import "ViewController.h"
#import "DemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClicked:(id)sender {
    DemoViewController *vc = [DemoViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
