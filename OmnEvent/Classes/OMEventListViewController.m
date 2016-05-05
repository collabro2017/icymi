//
//  OMEventListViewController.m
//  OmnEvent
//
//  Created by elance on 7/18/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMEventListViewController.h"
#import "OMEventListCell.h"
#import "OMNewEventPostViewController.h"
#import "OMCommentViewController.h"

#import "UIImageView+AFNetworking.h"
@interface OMEventListViewController ()

@end

@implementation OMEventListViewController
@synthesize arrForEvent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    is_mosaic = NO;
    arrForEvent = [NSMutableArray array];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadEvents
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    [mainQuery whereKey:@"PostType" equalTo:@"event"];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!objects) {
            
            return;
        }
        if (!error) {
            [arrForEvent removeAllObjects];
            
            [arrForEvent addObjectsFromArray:objects];
            
            [tblForEventList reloadData];
        }
    }];
}

#pragma mark UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (is_mosaic) {
        
    }
    else
    {
        
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *obj = [arrForEvent objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"EventListCell";
    
    OMEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[OMEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }
    
    [cell setObject:obj];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    
//    if (is_mosaic) {
//        
//        for (int i= 0; i < 3; i++) {
//            
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//            button.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
//            button.center = CGPointMake((kImageWidth * 0.5f + (1 + kImageWidth) * i), kImageHeight * 0.5f);
//            button.tag = indexPath.row * 3 + i;
//            
//            [button addTarget:self action:@selector(eventClick:) forControlEvents:UIControlEventTouchUpInside];
//            UIImageView *replaceView = [UIImageView new];
//            replaceView.layer.borderColor = [[UIColor whiteColor] CGColor];
//            
//            replaceView.layer.borderWidth = 1.0f;
//            if (button.tag < [arrForEvent count]) {
//                
//                PFObject *obj = [arrForEvent objectAtIndex:button.tag];
//                
//                PFFile *postImgFile = (PFFile *)obj[@"image"];
//                
//                if (postImgFile) {
//                    [replaceView setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
//                    [replaceView setFrame:button.bounds];
//                    [button addSubview:replaceView];
//                    replaceView.userInteractionEnabled = NO;
//                    
//                    [cell addSubview:button];
//                }
//            }
//        }
//        
//        return cell;
//        
//    }
//    else
//    {
//        PFObject *obj = [arrForEvent objectAtIndex:indexPath.row];
//        
////        cell.textLabel.text = obj[@"EventName"];
//        
//        PFFile *postImgFile = (PFFile *)obj[@"image"];
//        if (postImgFile) {
////            [cell.imageView setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
//            
//            UIImageView *imageViewForEventThumb = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
//            
//            [OMGlobal setImageURLWithAsync:postImgFile.url positionView:cell displayImgView:imageViewForEventThumb];
//            [cell.contentView addSubview:imageViewForEventThumb];
//            
//        }
//        
//        UILabel *lblForName = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 150, 20)];
//        
//        lblForName.text = obj[@"EventName"];
//        [lblForName setFont:[UIFont fontWithName:@"Arial" size:12]];
//        [cell.contentView addSubview:lblForName];
//        return cell;
//    }
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (is_mosaic) {
        return kImageHeight;
    }
    else
    {
        return 107;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (is_mosaic) {
        
        if ([arrForEvent count] % 3 == 0) {
            return [arrForEvent count] / 3;
        }
        else if ([arrForEvent count] % 3 > 0)
        {
            return ([arrForEvent count] / 3 + 1);
            
        }
        
    }
    else
    {
        return [arrForEvent count];
    }
    
    return 0;
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

- (IBAction)createNewEventAction:(id)sender {
    
    OMNewEventPostViewController *newEventPostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewEventPostVC"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newEventPostVC];
    
    [[SlideNavigationController sharedInstance] presentViewController:nav animated:YES completion:nil];
}

- (void)showComments:(PFObject *)_obj
{
    OMCommentViewController *commentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentVC"];
    [commentVC setCurrentObject:_obj];
    
    [self.navigationController pushViewController:commentVC animated:YES];
    
}

@end
