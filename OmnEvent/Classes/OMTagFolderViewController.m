//
//  OMTagFolderViewController.m
//  ICYMI
//
//  Created by Kevin on 8/18/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMTagFolderViewController.h"
#import "OMTagFolderCell.h"

@interface OMTagFolderViewController ()
{
    NSMutableArray *cellSelected;
    NSMutableArray *arrForSelectedFolder;
}

@end

@implementation OMTagFolderViewController

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
    arrForFolder = [NSMutableArray array];
    cellSelected = [NSMutableArray array];
    arrForSelectedFolder = [NSMutableArray array];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(done:)];
    
    
    self.title = @"Add to Folders";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadFolders];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(selectedCells:didFinished:)]) {
        [self.delegate selectedFolders:self didFinished:arrForSelectedFolder];
    }
}


- (void)loadFolders
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *mainQ = [PFQuery queryWithClassName:kClassFolder];
    [mainQ whereKey:@"Owner" equalTo:USER];;
    [mainQ orderByDescending:@"createdAt"];
    
    [mainQ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (objects == nil || [objects count] == 0) {
            return ;
        }
        if (!error) {
            [arrForFolder removeAllObjects];
            
            for (PFObject *obj in objects) {
                
                [arrForFolder addObject:obj];
                
            }
            
            [tblForFolderList reloadData];
        }
        
    }];    
    
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
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TagFolderCell";
    OMTagFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[OMTagFolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    [cell setObject:[arrForFolder objectAtIndex:indexPath.row]];
    
    if ([cellSelected containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([cellSelected containsObject:indexPath]) {
        [cellSelected removeObject:indexPath];
        PFObject *folder = (PFObject *)[arrForFolder objectAtIndex:indexPath.row];
        [arrForSelectedFolder removeObject:folder];
        
    }
    else
    {
        [cellSelected addObject:indexPath];
        PFObject *folder = (PFObject *)[arrForFolder objectAtIndex:indexPath.row];
        
        [arrForSelectedFolder addObject:folder];
        
    }
    [tableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrForFolder count];
}

@end
