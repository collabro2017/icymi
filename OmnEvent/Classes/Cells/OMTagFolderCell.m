//
//  OMTagFolderCell.m
//  ICYMI
//
//  Created by Kevin on 8/18/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMTagFolderCell.h"

@implementation OMTagFolderCell

@synthesize user,object;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    //[OMGlobal setCircleView:imageViewForFolder borderColor:nil];
    
    [OMGlobal setCircleView:imageViewForFolder borderColor:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setObject:(PFObject *)_object
{
    
    object = _object;

    [lblForFolderName setText:object[@"Name"]];
    

    PFFile *postImgFile = (PFFile *)object[@"Image"];
    
    if (postImgFile) {
        [imageViewForFolder setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }    
}

@end

