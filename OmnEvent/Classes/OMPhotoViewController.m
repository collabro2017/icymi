//
//  OMPhotoViewController.m
//  OmnEvent
//
//  Created by elance on 7/31/14.
//  Copyright (c) 2014 ellisa. All rights reserved.
//

#import "OMPhotoViewController.h"
#import "OMPhotoCell.h"

#import "OMNewPostViewController.h"
#import "OMPreviewPhotoViewController.h"
#import "OMCommentViewController.h"

#import "UIImageView+AFNetworking.h"

@interface OMPhotoViewController ()

@end

@implementation OMPhotoViewController
@synthesize arrForPhoto;

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
    arrForPhoto = [NSMutableArray array];
    is_grid = NO;
    
    [self loadPhotoData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhotoData) name:kLoadPhotoData object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPhotoData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *mainQuery = [PFQuery queryWithClassName:@"Post"];
    [mainQuery whereKey:@"PostType" equalTo:@"photo"];
    [mainQuery orderByDescending:@"createdAt"];
    [mainQuery includeKey:@"user"];
    
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!objects) {
            
            return;
        }
        if (!error) {
            [arrForPhoto removeAllObjects];
            
            [arrForPhoto addObjectsFromArray:objects];
            
            [tblForPhoto reloadData];
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

- (void)eventClick:(UIButton *)sender
{
    
}

#pragma mark UITableView Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    if (is_grid) {
        static NSString *CellIdentifier_ = @"PhotoCell";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_];
        for (int i= 0; i < 3; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.bounds = CGRectMake(0, 0, kImageWidth, kImageHeight);
            button.center = CGPointMake((kImageWidth * 0.5f + (1 + kImageWidth) * i), kImageHeight * 0.5f);
            button.tag = indexPath.row * 3 + i;
            
            [button addTarget:self action:@selector(eventClick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *replaceView = [UIImageView new];
            replaceView.layer.borderColor = [[UIColor whiteColor] CGColor];
            
            replaceView.layer.borderWidth = 1.0f;
            if (button.tag < [arrForPhoto count]) {
                
                PFObject *obj = [arrForPhoto objectAtIndex:button.tag];
                
                PFFile *postImgFile = (PFFile *)obj[@"image"];
                
                if (postImgFile) {
                    [replaceView setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
                    [replaceView setFrame:button.bounds];
                    [button addSubview:replaceView];
                    replaceView.userInteractionEnabled = NO;
                    
                    [cell addSubview:button];
                }
            }
        }
        
        return cell;
        
    }
    else
    {
        static NSString *CellIdentifier = @"OMPhotoCell";

        OMPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[OMPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        }
        
        PFObject *obj = [arrForPhoto objectAtIndex:indexPath.row];
        [cell setDelegate:self];
        [cell setObject:obj];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (is_grid) {
        return kImageHeight;
    }
    return 350;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (is_grid) {
        
        if ([arrForPhoto count] % 3 == 0) {
            return [arrForPhoto count] / 3;
        }
        else if ([arrForPhoto count] % 3 > 0)
        {
            return ([arrForPhoto count] / 3 + 1);
            
        }
        
    }
    else
    {
        return [arrForPhoto count];
    }
    
    return 0;

}

- (IBAction)showTableView:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 100:
        {
            is_grid = NO;
        }
            break;
        case 101:
        {
            is_grid = YES;
        }
            break;
        default:
            break;
    }
    [tblForPhoto reloadData];

}

- (IBAction)newPhotoPostAction:(id)sender {
    
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:@"Option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Choose from Album", nil];
    
    [photoSheet setTag:100];
    [photoSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
        {
            
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            
            
            break;
        }
        case 1:
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        }
        default:
            break;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark-UIImagePickerController  Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)_picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [_picker dismissViewControllerAnimated:YES completion:^{
        [self gotoPostView:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)_picker
{
    [_picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)gotoPostView:(UIImage *)tempImage
{
    OMPreviewPhotoViewController *newPhotoPostVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewPhotoVC"];
    newPhotoPostVC.imageForPreview = tempImage;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:newPhotoPostVC];
    
    [[SlideNavigationController sharedInstance] presentViewController:nav animated:YES completion:nil];

}

- (void)showComments:(PFObject *)_obj
{
    OMCommentViewController *commentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentVC"];
    [commentVC setCurrentObject:_obj];
    
    [self.navigationController pushViewController:commentVC animated:YES];
    
}

@end
