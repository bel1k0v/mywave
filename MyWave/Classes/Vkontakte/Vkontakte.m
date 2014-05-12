#import "Vkontakte.h"
#import "NSString+URLEncoding.h"

@interface Vkontakte (Private)

- (void)storeSession;
- (BOOL)isSessionValid;
- (void)getCaptcha;
- (NSDictionary *)sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha;
- (NSDictionary *)sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData;
- (NSString *)URLEncodedString:(NSString *)str;
@end

@implementation Vkontakte (Private)

- (void)storeSession
{
    // Save authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"VKAccessTokenKey"];
    [defaults setObject:expirationDate forKey:@"VKExpirationDateKey"];
    [defaults setObject:userId forKey:@"VKUserID"];
    [defaults synchronize];
}

- (BOOL)isSessionValid
{
    return (accessToken != nil && expirationDate != nil && userId != nil
            && NSOrderedDescending == [expirationDate compare:[NSDate date]]);
}

- (void)getCaptcha
{
    NSString *captcha_img = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_img"];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Введите код:\n\n\n\n\n"
                                                          message:@"\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 45.0, 130.0, 50.0)];
    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:captcha_img]]];
    [myAlertView addSubview:imageView];
    
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 110.0, 260.0, 25.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    myTextField.tag = 33;
    
    [myAlertView addSubview:myTextField];
    [myAlertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_isCaptcha && buttonIndex == 1)
    {
        _isCaptcha = NO;
        
        UITextField *myTextField = (UITextField *)[actionSheet viewWithTag:33];
        [[NSUserDefaults standardUserDefaults] setObject:myTextField.text forKey:@"captcha_user"];
        NSLog(@"Captcha entered: %@", myTextField.text);
        
        NSString *request = [[NSUserDefaults standardUserDefaults] objectForKey:@"request"];
        
        NSDictionary *newRequestDict =[self sendRequest:request withCaptcha:YES];
        NSString *errorMsg = [[newRequestDict  objectForKey:@"error"] objectForKey:@"error_msg"];
        if(errorMsg)
        {
            NSError *error = [NSError errorWithDomain:@"vk.com"
                                                 code:[[[newRequestDict  objectForKey:@"error"] objectForKey:@"error_code"] intValue]
                                             userInfo:[newRequestDict  objectForKey:@"error"]];
            if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
            {
                [self.delegate vkontakteDidFailedWithError:error];
            }
            
        }
        else
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishPostingToWall:)])
            {
                [self.delegate vkontakteDidFinishPostingToWall:newRequestDict];
            }
            
        }
    }
    else if(_isCaptcha && buttonIndex == 0)
    {
        [self logout];
    }
}

- (NSDictionary *)sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha
{
    if(captcha == YES)
    {
        NSString *captcha_sid = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_sid"];
        NSString *captcha_user = [[NSUserDefaults standardUserDefaults] objectForKey:@"captcha_user"];
        reqURl = [reqURl stringByAppendingFormat:@"&captcha_sid=%@&captcha_key=%@", captcha_sid, [self URLEncodedString: captcha_user]];
    }
    //NSLog(@"Sending request: %@", reqURl);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(responseData)
    {
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        NSString *errorMsg = [[dict objectForKey:@"error"] objectForKey:@"error_msg"];
        
        //NSLog(@"Server response: %@ \nError: %@", dict, errorMsg);
        
        if([errorMsg isEqualToString:@"Captcha needed"])
        {
            _isCaptcha = YES;
            NSString *captcha_sid = [[dict objectForKey:@"error"] objectForKey:@"captcha_sid"];
            NSString *captcha_img = [[dict objectForKey:@"error"] objectForKey:@"captcha_img"];
            [[NSUserDefaults standardUserDefaults] setObject:captcha_img forKey:@"captcha_img"];
            [[NSUserDefaults standardUserDefaults] setObject:captcha_sid forKey:@"captcha_sid"];
            [[NSUserDefaults standardUserDefaults] setObject:reqURl forKey:@"request"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self getCaptcha];
        }
        
        return dict;
    }
    return nil;
}

- (NSDictionary *)sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData
{
    //NSLog(@"Sending request: %@", reqURl);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;  boundary=%@", stringBoundary];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(responseData)
    {
        NSError* error;
        NSDictionary* dict = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        NSString *errorMsg = [[dict objectForKey:@"error"] objectForKey:@"error_msg"];
        NSLog(@"Server response: %@ \nError: %@", dict, errorMsg);
        
        return dict;
    }
    return nil;
}

- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (__bridge CFStringRef)str,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8);
	return result;
}

@end

@implementation Vkontakte

//#warning Provide your vkontakte app id
NSString * const vkAppId = @"3585088";
NSString * const vkPermissions = @"wall,photos,offline,audio";
NSString * const vkRedirectUrl = @"http://oauth.vk.com/blank.html";

@synthesize delegate;

#pragma mark - Initialize

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"VKAccessTokenKey"]
            && [defaults objectForKey:@"VKExpirationDateKey"]
            && [defaults objectForKey:@"VKUserID"])
        {
            accessToken = [defaults objectForKey:@"VKAccessTokenKey"];
            expirationDate = [defaults objectForKey:@"VKExpirationDateKey"];
            userId = [defaults objectForKey:@"VKUserID"];
        }
    }
    return self;
}

- (BOOL)isAuthorized
{
    if (![self isSessionValid])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)authenticate
{
    NSString *authLink = [NSString stringWithFormat:@"http://api.vkontakte.ru/oauth/authorize?client_id=%@&scope=%@&redirect_uri=%@&display=touch&response_type=token", vkAppId, vkPermissions, vkRedirectUrl];
    NSURL *url = [NSURL URLWithString:authLink];
    
    VkontakteViewController *vkontakteViewController = [[VkontakteViewController alloc] initWithAuthLink:url];
    vkontakteViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vkontakteViewController];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(showVkontakteAuthController:)])
    {
        [self.delegate showVkontakteAuthController:navController];
    }
}

- (void)logout
{
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* vkCookies1 = [cookies cookiesForURL:
                           [NSURL URLWithString:@"http://api.vk.com"]];
    NSArray* vkCookies2 = [cookies cookiesForURL:
                           [NSURL URLWithString:@"http://vk.com"]];
    NSArray* vkCookies3 = [cookies cookiesForURL:
                           [NSURL URLWithString:@"http://login.vk.com"]];
    NSArray* vkCookies4 = [cookies cookiesForURL:
                           [NSURL URLWithString:@"http://oauth.vk.com"]];
    
    for (NSHTTPCookie* cookie in vkCookies1)
    {
        [cookies deleteCookie:cookie];
    }
    for (NSHTTPCookie* cookie in vkCookies2)
    {
        [cookies deleteCookie:cookie];
    }
    for (NSHTTPCookie* cookie in vkCookies3)
    {
        [cookies deleteCookie:cookie];
    }
    for (NSHTTPCookie* cookie in vkCookies4)
    {
        [cookies deleteCookie:cookie];
    }
    
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"VKAccessTokenKey"])
    {
        [defaults removeObjectForKey:@"VKAccessTokenKey"];
        [defaults removeObjectForKey:@"VKExpirationDateKey"];
        [defaults removeObjectForKey:@"VKUserID"];
        [defaults synchronize];
        
        // Nil out the session variables to prevent
        // the app from thinking there is a valid session
        if (accessToken)
        {
            accessToken = nil;
        }
        if (expirationDate)
        {
            expirationDate = nil;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishLogOut:)])
    {
        [self.delegate vkontakteDidFinishLogOut:self];
    }
}

- (void)getUserInfo
{
    if (![self isAuthorized]) return;
    
    NSMutableString *requestString = [[NSMutableString alloc] init];
	[requestString appendFormat:@"%@/", @"https://api.vk.com/method"];
    [requestString appendFormat:@"%@?", @"getProfiles"];
    [requestString appendFormat:@"uid=%@&", userId];
    NSMutableString *fields = [[NSMutableString alloc] init];
    [fields appendString:@"sex,bdate,photo,photo_big"];
    [requestString appendFormat:@"fields=%@&", fields];
    [requestString appendFormat:@"access_token=%@", accessToken];
    
	NSURL *url = [NSURL URLWithString:requestString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSData *response = [NSURLConnection sendSynchronousRequest:request
											 returningResponse:nil
														 error:nil];
	NSString *responseString = [[NSString alloc] initWithData:response
                                                     encoding:NSUTF8StringEncoding];
	NSLog(@"%@",responseString);
    
    NSError* error;
    NSDictionary* parsedDictionary = [NSJSONSerialization
                                      JSONObjectWithData:response
                                      options:kNilOptions
                                      error:&error];
    
    NSArray *array = [parsedDictionary objectForKey:@"response"];
    
    if ([parsedDictionary objectForKey:@"response"])
    {
        parsedDictionary = [array objectAtIndex:0];
        parsedDictionary = [NSMutableDictionary dictionaryWithDictionary:parsedDictionary];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFinishGettinUserInfo:)])
        {
            [self.delegate vkontakteDidFinishGettinUserInfo:parsedDictionary];
        }
    }
    else
    {
        NSDictionary *errorDict = [parsedDictionary objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method"
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5)
            {
                [self logout];
            }
            
            [self.delegate vkontakteDidFailedWithError:error];
        }
    }
}

- (NSArray *) getUserAudio {
    if (![self isAuthorized]) return NULL;
    
    NSString *url = [NSString stringWithFormat:@"https://api.vk.com/method/audio.get?oid=%@&access_token=%@", userId, accessToken];

    NSDictionary *parsedDictionary = [self sendRequest:url withCaptcha:NO];
    NSArray *array = [parsedDictionary objectForKey:@"response"];

    if ([parsedDictionary objectForKey:@"response"])
    {
        NSRange range;
        range.location = 0;
        range.length = [array count] - 1;
        NSArray *music = [array subarrayWithRange:range];
        return music;
    }
    else
    {
        NSDictionary *errorDict = [parsedDictionary objectForKey:@"error"];
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method"
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            if (error.code == 5)
            {
                [self logout];
            }
            
            return NULL;
        }
    }
    
    return NULL;
}

- (NSArray *) searchAudio:(NSString *)q {
    if (![self isAuthorized]) return NULL;
    q = [q urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"https://api.vk.com/method/audio.search?q=%@&access_token=%@", q, accessToken];
    NSLog(@"action URL: %@", url);
    
    NSDictionary *parsedDictionary = [self sendRequest:url withCaptcha:NO];
    
    NSArray *array = [parsedDictionary objectForKey:@"response"];
    
    if ([parsedDictionary objectForKey:@"response"])
    {
        NSRange range;
        range.location = 1;
        range.length = [array count] - 1;
        NSArray *music = [array subarrayWithRange:range];
        return music;
    }
    else
    {
        NSDictionary *errorDict = [parsedDictionary objectForKey:@"error"];
        
        if ([self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
        {
            NSError *error = [NSError errorWithDomain:@"http://api.vk.com/method"
                                                 code:[[errorDict objectForKey:@"error_code"] intValue]
                                             userInfo:errorDict];
            
            if (error.code == 5)
            {
                [self logout];
            }
            
            return NULL;
        }
    }
    
    return NULL;
}

#pragma mark - VkontakteViewControllerDelegate

- (void)authorizationDidSucceedWithToken:(NSString *)_accessToken
                                 userId:(NSString *)_userId
                                expDate:(NSDate *)_expDate

{
    accessToken = _accessToken;
    userId = _userId;
    expirationDate = _expDate;
    
    [self storeSession];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFinishLogin:)])
    {
        [self.delegate vkontakteDidFinishLogin:self];
    }
}

- (void)authorizationDidFailedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteDidFailedWithError:)])
    {
        [self.delegate vkontakteDidFailedWithError:error];
    }
}

- (void)authorizationDidCanceled
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(vkontakteAuthControllerDidCancelled)])
    {
        [self.delegate vkontakteAuthControllerDidCancelled];
    }
}

@end
