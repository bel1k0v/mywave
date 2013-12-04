//
//  ViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//
#import "AppDelegate.h"
#import "MainViewController.h"
#import "VkMusicViewController.h"
#import "MyMusicViewController.h"

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Cвоя волна";
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (delegate.currentSong != nil)
        NSLog(@"%@", delegate.currentSong);
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