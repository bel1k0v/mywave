//
//  MusicViewController.m
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "VkontakteMusicViewController.h"
#import "NSString+Gender.h"
#import "Track+VkSDK.h"
#import "Track+Db.h"
#import "AppHelper.h"

#define MinSearchLength 2
#define MaxSearchLength 25

//static NSString *const TOKEN_KEY = @"my_application_access_token";
static NSArray  * SCOPE = nil;


@implementation VkontakteMusicViewController {
}

- (void)_actionDownloadAll:(id)sender {

    NSMutableArray *dowloadedTracks = [NSMutableArray new];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 4;
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            for (Track* track in dowloadedTracks)
            {
                [track save];
            }
            NSLog(@"Complete dowloading");
        }];
    }];
    
    for (Track* track in tracks)
    {
        if ([track isSaved] == NO) {
            NSURL            *url = track.audioFileURL;
            NSString        *name = [NSString stringWithFormat:@"%@ - %@", track.artist, track.title];
            NSString    *filename = [[AppHelper filesDir] stringByAppendingPathComponent:[name stringByAppendingString:@".mp3"]];
            
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                NSData       *data = [NSData dataWithContentsOfURL:url];
                [data writeToFile:filename atomically:YES];
            }];
            [completionOperation addDependency:operation];
            [dowloadedTracks addObject:track];
        }
        
    }
    
    [queue addOperations:completionOperation.dependencies waitUntilFinished:NO];
    [queue addOperation:completionOperation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"All" style:UIBarButtonItemStylePlain target:self action:@selector(_actionDownloadAll:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}
- (void) authorize {
    [VKSdk authorize:SCOPE revokeAccess:YES];
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

- (void)viewDidAppear:(BOOL)animated {
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES];
    
    [VKSdk initializeWithDelegate:self andAppId:@"3585088"];
    
    if (![VKSdk wakeUpSession])
    {
        [self authorize];
    }
    
    [super viewDidAppear:animated];
    [Track vkontakteTracks:self];
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
    [self authorize];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self reloadTableView];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:NO completion:nil];
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
