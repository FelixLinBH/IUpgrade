//
//  IUpgradeViewController.m
//  IUpgrade
//
//  Created by felix.lin on 07/31/2016.
//  Copyright (c) 2016 felix.lin. All rights reserved.
//

#import "IUpgradeViewController.h"

@interface IUpgradeViewController ()

@end

@implementation IUpgradeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=https://s3-ap-northeast-1.amazonaws.com/internal.indexbricks.com/ios/coplates.plist"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
