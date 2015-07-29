//
//  NavigationController.m
//  MyWave
//
//  Created by Дмитрий on 15.04.14.
//
//

#import "NavigationController.h"
#import "AppHelper.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1f) {
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],
                                        NSForegroundColorAttributeName,
                                        [UIFont fontWithName:BaseFont size:BaseFontSizeHeader],
                                        NSFontAttributeName, nil];
        
        [[UINavigationBar appearance] setTitleTextAttributes: textAttributes];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0902f green:0.6941f blue:0.9647f alpha:1.0f]];
        //[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:33.0/255.0 green:33.0/255.0 blue:33.0/255.0 alpha:1.0]];
    }
    else
    { // 6.1, 6.0
        self.navigationBar.tintColor = [UIColor colorWithRed:0.0902f green:0.6941f blue:0.9647f alpha:1.0f];
        // Customize the title text for *all* UINavigationBars
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor whiteColor],
          UITextAttributeTextColor,
          [UIFont fontWithName:BaseFont size:BaseFontSizeHeader],
          UITextAttributeFont,
          nil]];
    }
    
    
    NSDictionary *barButtorTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIColor whiteColor],
                                             NSForegroundColorAttributeName,
                                             [UIFont fontWithName:BaseFont size:14.0],
                                             NSFontAttributeName, nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtorTextAttributes
                                                forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
