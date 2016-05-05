//
//  OMFriendViewController.h
//  Collabro
//
//  Created by Ellisa on 24/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"

@interface OMFriendViewController : OMBaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    IBOutlet UITableView *tblForFriend;
    IBOutlet UITableView *tblForSearch;
    IBOutlet UISearchBar *searchBarForFriendSearch;

    BOOL isSearching;
    
    BOOL m_isSearchContent;
    BOOL m_isViewDidLoad;
    
    NSTimer* m_timer;
}

-(void)startTimer;
-(void)stopTimer;

@end
