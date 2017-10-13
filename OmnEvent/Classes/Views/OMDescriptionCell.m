//
//  OMDescriptionCell.m
//  Collabro
//
//  Created by XXX on 4/21/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMDescriptionCell.h"

@implementation OMDescriptionCell
@synthesize beforeDescription;

- (void)awakeFromNib {
    [super awakeFromNib];
    txtViewForDescription.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCurrentObj:(PFObject *)_obj
{
    _currentObj = _obj;
    
    _user = _currentObj[@"user"];
    
    PFUser *self_user = [PFUser currentUser];    
    
    if (![_user.objectId isEqualToString:self_user.objectId]) {
        txtViewForDescription.editable = NO;
    } else {
        txtViewForDescription.editable = YES;
    }
    
    txtViewForDescription.text = _currentObj[@"description"];
    txtViewForDescription.scrollEnabled = NO;
    txtViewForDescription.showsHorizontalScrollIndicator = NO;
    txtViewForDescription.showsVerticalScrollIndicator = NO;
    
    CGRect txtViewTitleFrame = txtViewForDescription.frame;
    CGSize txtViewTitleNewSize = [OMGlobal getBoundingOfString:_currentObj[@"description"] width:txtViewTitleFrame.size.width];
    if (txtViewTitleNewSize.height > 44) {
        txtViewTitleFrame.size.height = txtViewTitleNewSize.height;
    }
    txtViewForDescription.frame = txtViewTitleFrame;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == txtViewForDescription)
    {
        beforeDescription = txtViewForDescription.text;
    }
    
    textView.scrollEnabled = YES;
    
    if ([textView.superview.superview.superview.superview isKindOfClass:[UITableView class]]) {
        CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin
                                                         toView:textView.superview.superview.superview.superview];
        NSDictionary *userInfo = @{
                                   @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
                                   @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y+30] stringValue],
                                   @"textFieldHeight": [[NSNumber numberWithFloat:textView.frame.size.height] stringValue]
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
    }
    else if ([textView.superview.superview.superview isKindOfClass:[UITableView class]]) { //for iOS 11
        CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin
                                                         toView:textView.superview.superview.superview];
        NSDictionary *userInfo = @{
                                   @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
                                   @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y+30] stringValue],
                                   @"textFieldHeight": [[NSNumber numberWithFloat:textView.frame.size.height] stringValue]
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([textView isEqual:txtViewForDescription]) {
        if ([text isEqualToString:@"\n"]) {
            if (![beforeDescription isEqualToString:txtViewForDescription.text] && txtViewForDescription.text.length > 0)
            {
                _currentObj[@"description"] = txtViewForDescription.text;
                // for badge processing in here
                
                //for badge
                NSMutableArray * arrPostLookedFlags = [NSMutableArray array];
                arrPostLookedFlags = [_currentObj[@"TagFriends"] mutableCopy];
                PFUser *eventUser = _currentObj[@"user"];
                
                if(![eventUser.objectId isEqualToString:USER.objectId])
                {
                    [arrPostLookedFlags addObject:eventUser.objectId];
                    if ([arrPostLookedFlags containsObject:USER.objectId]) {
                        [arrPostLookedFlags removeObject:USER.objectId];
                    }
                }
                OMAppDelegate* appDel = (OMAppDelegate* )[UIApplication sharedApplication].delegate;
                if(appDel.network_state)
                {
                    NSLog(@"Badge for event desription of Post Added");
                    [_currentObj saveInBackground];
                }
                
            }
            [txtViewForDescription resignFirstResponder];
            
            if ([textView.superview.superview.superview.superview isKindOfClass:[UITableView class]]) {
                CGPoint bottomPosition = [textView convertPoint:textView.frame.origin
                                                         toView:textView.superview.superview.superview.superview];
                NSDictionary *userInfo = @{
                                           @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                           @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
            }
            else if ([textView.superview.superview.superview isKindOfClass:[UITableView class]]){ //for iOS 11
                CGPoint bottomPosition = [textView convertPoint:textView.frame.origin
                                                         toView:textView.superview.superview.superview];
                NSDictionary *userInfo = @{
                                           @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                           @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                           };
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
            }
            
            return NO;
        }
        else if (textView.text.length < MAX_DESCRIPTION_LIMIT || [text isEqualToString:@""]) {
            return YES;
        }
    }
    
    return NO;
}

@end
