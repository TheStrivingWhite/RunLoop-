//
//  ViewController.m
//  RunLoop刷新图片
//
//  Created by yy on 2018/8/6.
//  Copyright © 2018年 1. All rights reserved.
//

#import "ViewController.h"
#import "ImageVC.h"

@interface ViewController ()


@end

@implementation ViewController

- (IBAction)pushvc:(id)sender {
    ImageVC * vc = [[ImageVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
