//
//  OMFindFriendViewController.h
//  Collabro
//
//  Created by elance on 8/13/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"
#import "INSSearchBar.h"

@interface OMFindFriendViewController : OMBaseViewController<INSSearchBarDelegate>
{
    
    
    
    IBOutlet UITableView *tblForSearchResult;
    NSMutableArray *arrForFriends;
    NSMutableArray *arrForUsername;
    
    INSSearchBar *searchBar;
    IBOutlet UIView *searchView;
    
}
@property (nonatomic, strong) NSArray *allData;
@property (nonatomic, strong) NSArray *searchResults;

@end
