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
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "AppHelper.h"

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

- (void)_changeViewController:(UIViewController *)controller {
    UINavigationController *navigationController = [UINavigationController new];
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1f) {
        [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    } else {
        navigationController.navigationBar.tintColor = UIColorFromRGB(0x18AAD6);
    }

    [navigationController setViewControllers:@[controller]];
    self.sidePanelController.centerPanel = navigationController;
}

- (void)vkMusicButtonPressed:(id)sender
{
    VkMusicViewController* musicViewController = [VkMusicViewController new];
    [self _changeViewController:musicViewController];

}

- (void)myMusicButtonPressed:(id)sender
{
    MyMusicViewController* musicViewController = [MyMusicViewController new];
    [self _changeViewController:musicViewController];
}

@end
