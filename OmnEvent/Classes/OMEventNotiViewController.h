//
//  OMEventNotiViewController.h
//  ICYMI
//
//  Created by lion on 11/28/16.
//  Copyright © 2016 ellisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMSocialEvent.h"

@interface OMEventNotiViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *notiTable;
@property (strong, nonatomic) OMSocialEvent *event;
@property (nonatomic) NSInteger curEventIndex;

@end
