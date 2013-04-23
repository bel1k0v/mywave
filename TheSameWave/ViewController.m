//
//  ViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "ViewController.h"
#import "MusicViewController.h";

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_vkInstance = [Vkontakte sharedInstance];
    _vkInstance.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
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
    NSLog(@"Error");
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [self dismissModalViewControllerAnimated:YES];
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
