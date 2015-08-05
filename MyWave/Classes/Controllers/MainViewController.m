//
//  MainViewController.m
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "MainViewController.h"
#import "DeviceMusicViewController.h"
#import "VkontakteMusicViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "AppHelper.h"

@interface MainViewController () {
    
@private
    NSArray *_providers;
    UIImageView *_imageViewLogo;
    UITableView *_tableViewProviders;
    UIButton *_buttonMyMusic;
    UIButton *_buttonVkMusic;
    UIButton *_buttonVkLogin;
}
@end

@implementation MainViewController

static NSString *selectorStringFormat = @"_%@MusicControlPressed:";

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _providers = [[NSArray alloc]initWithObjects:@"device", @"vkontakte", nil];
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //_imageViewLogo = [[UIImageView alloc]initWithFrame:CGRectMake(15.0f, 30.0f, 52.0f, 24.0f)];
    //_imageViewLogo.image = [UIImage imageNamed:@"logo_white"];
    //[view addSubview:_imageViewLogo];
    
    _tableViewProviders = [[UITableView alloc]initWithFrame:CGRectMake(0, 64.0f, view.frame.size.width, view.frame.size.height - 74.0f)
 style:UITableViewStylePlain];
    _tableViewProviders.backgroundColor = UIColorFromRGB(0xCCCCCC);
    _tableViewProviders.dataSource = self;
    _tableViewProviders.delegate = self;
    [_tableViewProviders setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [view addSubview:_tableViewProviders];
    
    view.backgroundColor = UIColorFromRGB(0x333333);
    [self setView:view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_providers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = UIColorFromRGB(0xCCCCCC);
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[_providers objectAtIndex:indexPath.row] capitalizedString]];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sel = [NSString stringWithFormat:selectorStringFormat, [_providers objectAtIndex:indexPath.row]];
    [self performSelector:NSSelectorFromString(sel) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)_changeViewController:(UIViewController *)controller {
    UINavigationController *navigationController = [UINavigationController new];
    [navigationController setViewControllers:@[controller]];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.sidePanelController.centerPanel = navigationController;
}

- (void)_vkontakteMusicControlPressed:(id)sender {
    if (AppHelper.isNetworkAvailable) {
        VkontakteMusicViewController* musicViewController = [VkontakteMusicViewController new];
        [self _changeViewController:musicViewController];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Connect your device to wi-fi or 3G/LTE network" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)_deviceMusicControlPressed:(id)sender {
    DeviceMusicViewController* musicViewController = [DeviceMusicViewController new];
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

@end
