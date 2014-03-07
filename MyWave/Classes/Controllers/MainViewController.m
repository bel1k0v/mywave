//
//  ViewController.m
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "MainViewController.h"
#import "VkMusicViewController.h"
#import "MyMusicViewController.h"

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"My Wave" ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)vkMusicButtonPressed:(id)sender
{
    VkMusicViewController* musicViewController = [VkMusicViewController new];
    [self.navigationController pushViewController:musicViewController animated:YES];
}

- (void)myMusicButtonPressed:(id)sender
{
    MyMusicViewController* downloadedViewController = [MyMusicViewController new];
    [self.navigationController pushViewController:downloadedViewController animated:YES];
}

@end
