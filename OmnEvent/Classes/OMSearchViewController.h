//
//  OMSearchViewController.h
//  Collabro
//
//  Created by Ellisa on 24/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMBaseViewController.h"

@interface OMSearchViewController : OMBaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
    
    IBOutlet UICollectionView *collectionViewForSearch;
}
@property (nonatomic,strong) UISearchBar        *searchBarForEvent;
@end
