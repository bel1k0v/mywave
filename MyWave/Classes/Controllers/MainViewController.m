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

@interface MainViewController () {
@private
    IBOutlet UIButton *_buttonMyMusic;
    IBOutlet UIButton *_buttonVkMusic;
    IBOutlet UIButton *_buttonVkLogin;
}
@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _vk = [Vkontakte sharedInstance];
    _vk.delegate = self;
    _db = [DBManager getSharedInstance];
    [self refreshButtonState];
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    _buttonMyMusic = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonMyMusic setFrame:CGRectMake(20.0, 85.0, 80.0, 20.0)];
    [_buttonMyMusic setTitle:@"My music" forState:UIControlStateNormal];
    //[_buttonMyMusic setBackgroundImage:[UIImage imageNamed:@"music-icon"] forState:UIControlStateNormal];
    _buttonMyMusic.titleLabel.font = [UIFont fontWithName:BaseFont size:14.0];
    [_buttonMyMusic addTarget:self action:@selector(_myMusicButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonMyMusic];
    
    _buttonVkMusic = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonVkMusic setFrame:CGRectMake(20.0, 155.0, 80.0, 20.0)];
    //[_buttonVkMusic setBackgroundImage:[UIImage imageNamed:@"vk-icon2"] forState:UIControlStateNormal];
    [_buttonVkMusic setTitle:@"Vk music" forState:UIControlStateNormal];
    _buttonVkMusic.titleLabel.font = [UIFont fontWithName:BaseFont size:14.0];
    [_buttonVkMusic addTarget:self action:@selector(_vkMusicButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonVkMusic];
    
    _buttonVkLogin = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonVkLogin setFrame:CGRectMake(110.0, 155.0, 80.0, 20.0)];
    _buttonVkLogin.titleLabel.font = [UIFont fontWithName:BaseFont size:14.0];
    [_buttonVkLogin addTarget:self action:@selector(_vkLoginButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonVkLogin];
    
    [self refreshButtonState];
    
    [self setView:view];
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

- (void)_vkLoginButtonPressed:(id)sender {
    if (![_vk isAuthorized])
        [_vk authenticate];
    else
        [_vk logout];
}

- (void)refreshButtonState {
    if (![_vk isAuthorized])
        [_buttonVkLogin setTitle:@"Login" forState:UIControlStateNormal];
    else
        [_buttonVkLogin setTitle:@"Logout" forState:UIControlStateNormal];
}

- (void)_vkMusicButtonPressed:(id)sender
{
    VkMusicViewController* musicViewController = [VkMusicViewController new];
    [musicViewController setVk:_vk];
    
    [self _changeViewController:musicViewController];

}

- (void)_myMusicButtonPressed:(id)sender
{
    MyMusicViewController* musicViewController = [MyMusicViewController new];
    
    [self _changeViewController:musicViewController];
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fail!"
                                                    message:@"VK Error"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

- (void)showVkontakteAuthController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkontakteAuthControllerDidCancelled {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte {
    [self vkontakteAuthControllerDidCancelled];
    [self refreshButtonState];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte {
    [self refreshButtonState];
}

@end
