//
//  ZTViewController.m
//  ZTCameraKit
//
//  Created by zttina on 04/05/2019.
//  Copyright (c) 2019 zttina. All rights reserved.
//

#import "ZTViewController.h"
#import "ZTCameraVC.h"
@interface ZTViewController ()

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation ZTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:self.imageView];
    self.imageView.center = self.view.center;
    self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.imageView addGestureRecognizer:tap];
}
- (void)tap:(UITapGestureRecognizer *)tap {
    
    ZTCameraVC *vc = [[ZTCameraVC alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
    
    //
    @weakify(self);
    vc.imageBlock = ^(UIImage *image) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
        self.imageView.image = image;
    };
    vc.imageDataBlock = ^(NSData *imageData) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
        self.imageView.image = [UIImage imageWithData:imageData];

    };
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
