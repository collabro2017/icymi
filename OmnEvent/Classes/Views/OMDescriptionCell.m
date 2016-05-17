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
    // Initialization code
    
    lblForDescription.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurrentObj:(PFObject *)_obj
{
    _currentObj = _obj;
    
    _user = _currentObj[@"user"];
    
    PFUser *self_user = [PFUser currentUser];    
    
    if (![_user.objectId isEqualToString:self_user.objectId]){
        lblForDescription.enabled = NO;
    } else {
        lblForDescription.enabled = YES;
    }
    
    constraintForDescription.constant = [OMGlobal getBoundingOfString:_currentObj[@"description"] width:lblForDescription.frame.size.width].height;
    
    [lblForDescription setText:_currentObj[@"description"]];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == lblForDescription)
    {
        beforeDescription = lblForDescription.text;
    }
    
    if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
        //NSLog(@" UITableView---");
        
        CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];
        
        NSDictionary *userInfo = @{
                                   @"pointInTable_x": [[NSNumber numberWithFloat:pointInTable.x] stringValue],
                                   @"pointInTable_y": [[NSNumber numberWithFloat:pointInTable.y+30] stringValue],
                                   @"textFieldHeight": [[NSNumber numberWithFloat:textField.inputAccessoryView.frame.size.height] stringValue]
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardShow object:nil userInfo:userInfo];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == lblForDescription)
    {
        
        if (![beforeDescription isEqualToString:lblForDescription.text] && lblForDescription.text.length > 0){
            _currentObj[@"description"] = lblForDescription.text;
            [_currentObj saveEventually];
        }
        
        [lblForDescription resignFirstResponder];
    }
    
    if ([textField.superview.superview.superview.superview isKindOfClass:[UITableView class]]){
        CGPoint bottomPosition = [textField convertPoint:textField.frame.origin toView:textField.superview.superview.superview.superview];
        
        NSDictionary *userInfo = @{
                                   @"pointInTable_x": [[NSNumber numberWithFloat:bottomPosition.x] stringValue],
                                   @"pointInTable_y": [[NSNumber numberWithFloat:bottomPosition.y] stringValue]
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyboardHide object:nil userInfo:userInfo];
    }
    
    return YES;
}

@end
