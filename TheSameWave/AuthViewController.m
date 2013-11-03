//
//  ViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "AuthViewController.h"
#import "MusicViewController.h"

@implementation AuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_vkInstance = [Vkontakte sharedInstance];
    _vkInstance.delegate = self;
    self.navigationItem.title = @"The Same Wave";
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

- (void)musicButtonPressed:(id)sender
{
    if([_vkInstance isAuthorized])
    {
        [self vkontakteDidFinishLogin:_vkInstance];
    }
    else
    {
        NSLog(@"Authorize please");
    }
}

- (void)refreshButtonState
{
    if (![_vkInstance isAuthorized])
    {
        [_loginButton setTitle:@"Login"
                 forState:UIControlStateNormal];
    }
    else
    {
        [_loginButton setTitle:@"Logout"
                 forState:UIControlStateNormal];
        [_vkInstance getUserInfo];
    }
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    NSLog(@"Error");
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self refreshButtonState];
    MusicViewController* musicViewController = [MusicViewController new];
    musicViewController.data = [vkontakte getUserAudio];
    
    [self.navigationController pushViewController:musicViewController animated:YES];
}


- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    [self refreshButtonState];
}

@end
