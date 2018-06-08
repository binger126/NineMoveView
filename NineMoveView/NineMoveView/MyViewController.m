//
//  MyViewController.m
//  NineMoveView
//
//  Created by Mac on 2018/6/7.
//  Copyright © 2018年 xgkj. All rights reserved.
//

#import "MyViewController.h"
#import "SplitScreenSwitch.h"

@interface MyViewController ()




@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SplitScreenSwitch *scrollView = [[SplitScreenSwitch alloc] initWithFrame:self.view.frame];
    self.view = scrollView;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationMyViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
