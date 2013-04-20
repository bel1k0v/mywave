#import <Foundation/Foundation.h>
#import "VkontakteViewController.h"

extern NSString * const vkAppId;
extern NSString * const vkPermissions;
extern NSString * const vkRedirectUrl;

@protocol VkontakteDelegate;

@interface Vkontakte : NSObject <VkontakteViewControllerDelegate, UIAlertViewDelegate>
{
    
    NSString *accessToken;
    NSDate   *expirationDate;
    NSString *userId;
    
    BOOL _isCaptcha;
}

@property (nonatomic, weak) id <VkontakteDelegate> delegate;

+ (id)sharedInstance;
- (BOOL)isAuthorized;
- (void)authenticate;
- (void)logout;
- (void)getUserInfo;
- (void)getUserAudio;

@end

@protocol VkontakteDelegate <NSObject>
@required
- (void)vkontakteDidFailedWithError:(NSError *)error;
- (void)showVkontakteAuthController:(UIViewController *)controller;
- (void)vkontakteAuthControllerDidCancelled;
@optional
- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte;
- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte;

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info;
- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce;

@end
