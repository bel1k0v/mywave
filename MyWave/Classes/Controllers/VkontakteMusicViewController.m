//
//  MusicViewController.m
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "VkontakteMusicViewController.h"
#import "NSString+Gender.h"
#import "Track+Provider.h"
#import "Track+Search.h"
#import "AppHelper.h"

#define MinSearchLength 2
#define MaxSearchLength 25

static NSArray  * SCOPE = nil;

@implementation VkontakteMusicViewController {
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        [VKSdk initializeWithDelegate:self andAppId:@"3585088"];
        if ([VKSdk wakeUpSession])
        {
            //Start working
        } else {
            SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES];
            [VKSdk authorize:SCOPE];
        }
        
        [Track vkontakteTracks:self];
    }
    
    return self;
}

- (void) reloadTableView {
    [self.tableView reloadData];
}

- (void) renderTracks:(NSArray *)tracks {
    self->tracks = [NSMutableArray arrayWithArray:tracks];
    [self reloadTableView];
}

- (void) renderSearchTracks:(NSArray *)tracks {
    self->searchData = [NSMutableArray arrayWithArray:tracks];
    [self reloadTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL) isTracksRemote {
    return YES;
}

#pragma mark - Search display delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *) searchString {
    if (searchString.length > MinSearchLength && searchString.length < MaxSearchLength) {
        [Track vkontakteTracksForSearchString:[NSString stringWithFormat:@"%@", searchString] andCaller:self];
        return YES;
    }
    return NO;
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [VKSdk authorize:SCOPE revokeAccess:YES];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self reloadTableView];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    [self reloadTableView];
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
