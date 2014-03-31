//
//  MusicViewController.m
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "VkMusicViewController.h"
#import "NSString+Gender.h"

@implementation VkMusicViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        searchCache = [[NSCache alloc] init];
        searchData = [[NSMutableArray alloc]initWithArray:[self getSongs]];
    }
    return self;
}

- (void)initSearch {
    searchData = [NSMutableArray arrayWithCapacity:[self->tracks count]];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    
    self.tableView.tableHeaderView = searchBar;
}
- (void)setupData {
    self->tracks = nil;
    self->tracks = [self getSongs];
}

-(NSArray *)getSongs {
    return ((BOOL)[_vkInstance isAuthorized] != FALSE) ? [_vkInstance getUserAudio] : [[NSArray alloc]init];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _vkInstance = [Vkontakte sharedInstance];
    _vkInstance.delegate = self;
    
    if ((BOOL)[_vkInstance isAuthorized] != FALSE) {
        [self setupData];
        [self.tableView reloadData];
    }
    
    self.navigationItem.title = @"VK";
    _loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(loginBarButtonItemPressed:)];
    self.navigationItem.rightBarButtonItem = _loginBarButtonItem;
    [self refreshButtonState];
    [self initSearch];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (IBAction)loginBarButtonItemPressed:(id)sender {
    if ((BOOL)[_vkInstance isAuthorized] == FALSE)
        [_vkInstance authenticate];
    else
        [_vkInstance logout];
}

- (BOOL)isTracksRemote {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchData count];
    } else {
        return [self->tracks count];
    }
}

- (void)refreshButtonState {
    if (![_vkInstance isAuthorized])
        _loginBarButtonItem.title = @"Login";
    else
        _loginBarButtonItem.title = @"Logout";
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
    [self refreshButtonState];
    [self setupData];
    [self.tableView reloadData];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte {
    [self refreshButtonState];
}

#pragma mark - Search display delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (searchString.length > 3 && searchString.length < 25) {
        NSArray *cachedData = [searchCache objectForKey:searchString];
        if (cachedData == NULL) {
            cachedData = [_vkInstance searchAudio:searchString];
            if (cachedData != NULL) [searchCache setObject:cachedData forKey:searchString];
            else cachedData = [NSArray new];
        }
        searchData = [[NSMutableArray alloc]initWithArray:cachedData];
        [self.tableView reloadData];
    }
    
    return YES;
}

@end
