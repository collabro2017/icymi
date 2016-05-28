//
//  OMFeedHeaderCell.m
//  Collabro
//
//  Created by Ellisa on 22/03/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMFeedHeaderCell.h"

@implementation OMFeedHeaderCell
@synthesize user,delegate;
- (void)awakeFromNib {
    // Initialization code
    
    [OMGlobal setCircleView:_imageViewForProfile borderColor:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showDetailPage:(UITapGestureRecognizer *)_gesture
{
    if ([delegate respondsToSelector:@selector(showProfile:)]) {
        [delegate performSelector:@selector(showProfile:) withObject:user];
    }

}

- (void)setCurrentObj:(PFObject *)obj
{
    _currentObj = obj;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailPage:)];
    gesture.numberOfTapsRequired = 1;
    
    [_imageViewForProfile addGestureRecognizer:gesture];
    
    user = _currentObj[@"user"];
    
    //Display avatar image
    if (_imageViewForProfile.image) {
        _imageViewForProfile.image = nil;
    }

    if ([user[@"loginType"] isEqualToString:@"email"] || [user[@"loginType"] isEqualToString:@"gmail"]) {
        
        
        PFFile *avatarFile = (PFFile *)user[@"ProfileImage"];
        
        if (avatarFile) {
            
            [OMGlobal setImageURLWithAsync:avatarFile.url positionView:self displayImgView:_imageViewForProfile];
        }
        

    }
    else if ([user[@"loginType"] isEqualToString:@"facebook"])
    {
        [OMGlobal setImageURLWithAsync:user[@"profileURL"] positionView:self displayImgView:_imageViewForProfile];
    }

    //display Username
    
    [_lblForUsername setText:user.username];
    
    [_lblForTime setText:[OMGlobal showTime:_currentObj.createdAt]];
    _constraintForHeight.constant = [OMGlobal heightForCellWithPost:_currentObj[@"description"]];
    [_lblForDes setText:_currentObj[@"description"]];
    
    if (_currentObj[@"country"]) {
        
        [_lblForLocation setText:_currentObj[@"country"]];
    }
    else
        [_lblForLocation setText:@"Unknown"];
    
}

@end
