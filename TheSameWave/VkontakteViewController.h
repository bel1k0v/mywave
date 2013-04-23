//
//  VkontakteViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol VkontakteViewControllerDelegate;
@interface VkontakteViewController : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *_hud;
    UIWebView *_webView;
    NSURL *_authLink;
}

@property (nonatomic, weak) id <VkontakteViewControllerDelegate> delegate;

- (id)initWithAuthLink:(NSURL *)link;

@end

@protocol VkontakteViewControllerDelegate <NSObject>
@optional
- (void)authorizationDidSucceedWithToken:(NSString *)accessToken
                                 userId:(NSString *)userId
                                expDate:(NSDate *)expDate;
- (void)authorizationDidFailedWithError:(NSError *)error;
- (void)authorizationDidCanceled;
@end
