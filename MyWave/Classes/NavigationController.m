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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1f)
    {
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor whiteColor],
                                        NSForegroundColorAttributeName,
                                        [UIFont fontWithName:BaseFont size:BaseFontSizeHeader],
                                        NSFontAttributeName, nil];
        
        [[UINavigationBar appearance] setTitleTextAttributes: textAttributes];
        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x33a853)];
    }
    else
    { // Less than 6.1
        self.navigationBar.tintColor = UIColorFromRGB(0x33a853);
        // Customize the title text for *all* UINavigationBars
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor whiteColor],
          UITextAttributeTextColor,
          [UIFont fontWithName:BaseFont size:BaseFontSizeHeader],
          UITextAttributeFont,
          nil]];
    }
    
    // Navigation Bar
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    NSDictionary *barButtorTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIColor whiteColor],
                                             NSForegroundColorAttributeName,
                                             [UIFont fontWithName:BaseFont size:14.0],
                                             NSFontAttributeName, nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtorTextAttributes
                                                forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
