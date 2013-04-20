//
//  ViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_vkInstance = [Vkontakte sharedInstance];
    _vkInstance.delegate = self;
    
    [self refreshButtonState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loginButtonPressed:(id)sender
{
    if ((BOOL)[_vkInstance isAuthorized] == FALSE)
    {
        [_vkInstance authenticate];
    }
    else
    {
        [_vkInstance logout];
    }
}

- (void)refreshButtonState
{
    if (![_vkInstance isAuthorized])
    {
        [_loginButton setTitle:@"Войти"
                 forState:UIControlStateNormal];
    }
    else
    {
        [_loginButton setTitle:@"Выйти"
                 forState:UIControlStateNormal];
        [_vkInstance getUserInfo];
    }
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [self refreshButtonState];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    [self refreshButtonState];
}

@end
