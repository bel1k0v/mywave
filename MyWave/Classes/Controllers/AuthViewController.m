//
//  ViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "AuthViewController.h"
#import "MusicViewController.h"
#import "DownloadedViewController.h"

@implementation AuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_vkInstance = [Vkontakte sharedInstance];
    _vkInstance.delegate = self;
    self.navigationItem.title = @"";
    _loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Войти" style:UIBarButtonItemStylePlain target:self action:@selector(loginBarButtonItemPressed:)];
    self.navigationItem.rightBarButtonItem = _loginBarButtonItem;
    [self refreshButtonState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)loginBarButtonItemPressed:(id)sender
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fail!" message:@"Authorize please!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)downloaderButtonPressed:(id)sender
{
    DownloadedViewController* downloadedViewController = [DownloadedViewController new];
    [self.navigationController pushViewController:downloadedViewController animated:YES];
}

- (void)refreshButtonState
{
    if (![_vkInstance isAuthorized])
    {
        _loginBarButtonItem.title = @"Войти";
    }
    else
    {
        //[_vkInstance getUserInfo];
        _loginBarButtonItem.title = @"Выйти";
    }
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fail!" message:@"VK Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
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
