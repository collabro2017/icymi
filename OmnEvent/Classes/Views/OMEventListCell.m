//
//  OMEventListCell.m
//  Collabro
//
//  Created by XXX on 4/6/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMEventListCell.h"

@implementation OMEventListCell
@synthesize delegate,object,user;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setObject:(PFObject *)_object
{
    object = _object;
    
    user = object[@"user"];
    //display image
    PFFile *postImgFile = (PFFile *)object[@"thumbImage"];
    
    if (postImgFile) {
        [imageViewForThumb setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }
    lblForUsername.text = object[@"eventname"];
    
    
    lblForTime.text = [OMGlobal showTime:object.createdAt];
    
    
}
@end
