//
//  MainViewController.m
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "NavigationController.h"
#import "MainViewController.h"
#import "RemoteMusicViewController.h"
#import "MyMusicViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "AppHelper.h"
#import "Track+Provider.h"

@interface MainViewController () {
    
@private
    NSArray *providers;
    IBOutlet UIImageView *_imageViewLogo;
    IBOutlet UITableView *_tableViewProviders;
    IBOutlet UIButton *_buttonMyMusic;
    IBOutlet UIButton *_buttonVkMusic;
    IBOutlet UIButton *_buttonVkLogin;
}
@end

@implementation MainViewController

static NSString *selectorStringFormat = @"_%@MusicControlPressed:";

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _vk = [Vkontakte sharedInstance];
    _vk.delegate = self;
    _db = [DBManager sharedInstance];
}

- (void)loadView {
    providers = [[NSArray alloc]initWithObjects:@"downloaded", @"vkontakte", nil];
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _imageViewLogo = [[UIImageView alloc]initWithFrame:CGRectMake(15.0f, 30.0f, 52.0f, 24.0f)];
    _imageViewLogo.image = [UIImage imageNamed:@"logo_white"];
    [view addSubview:_imageViewLogo];
    
    _tableViewProviders = [[UITableView alloc]initWithFrame:CGRectMake(0, 64.0f, view.frame.size.width, view.frame.size.height - 74.0f)
 style:UITableViewStylePlain];
    _tableViewProviders.backgroundColor = UIColorFromRGB(0x0f3743);
    _tableViewProviders.dataSource = self;
    _tableViewProviders.delegate = self;
    [_tableViewProviders setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [view addSubview:_tableViewProviders];
    
    view.backgroundColor = UIColorFromRGB(0x0f3743);
    [self setView:view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Music on a device";
    } else {
        return @"Social accounts";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = UIColorFromRGB(0x0f3743);
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[providers objectAtIndex:indexPath.row + indexPath.section] capitalizedString]];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sel = [NSString stringWithFormat:selectorStringFormat, [providers objectAtIndex:indexPath.row + indexPath.section]];
    [self performSelector:NSSelectorFromString(sel) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)_changeViewController:(UIViewController *)controller {
    NavigationController *navigationController = [NavigationController new];
    [navigationController setViewControllers:@[controller]];
    self.sidePanelController.centerPanel = navigationController;
}

- (void)_vkLoginButtonPressed:(id)sender {
    if (![_vk isAuthorized])
        [_vk authenticate];
    else
        [_vk logout];
}

- (void)_vkontakteMusicControlPressed:(id)sender
{
    if (![_vk isAuthorized]) {
        [_vk authenticate];
    } else {
        RemoteMusicViewController* musicViewController = [RemoteMusicViewController new];
        musicViewController->tracks = [[NSMutableArray alloc]initWithArray:[Track vkontakteTracks]];
        [musicViewController setVk:_vk];
        
        [self _changeViewController:musicViewController];
    }
}

- (void)_downloadedMusicControlPressed:(id)sender
{
    MyMusicViewController* musicViewController = [MyMusicViewController new];
    musicViewController->tracks = [[NSMutableArray alloc]initWithArray:[Track myTracks]];
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
    [self _vkontakteMusicControlPressed:self];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte {
    [self vkontakteAuthControllerDidCancelled];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte {
}

@end
