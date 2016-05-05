//
//  OMFolderListCell.m
//  ICYMI
//
//  Created by Kevin on 8/15/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMFolderListCell.h"

@implementation OMFolderListCell
@synthesize delegate,object;

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

    PFFile *postImgFile = (PFFile *)object[@"Image"];
    
    if (postImgFile) {
        [m_FolderThumbImage setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:nil];
    }
    
    m_lblFolderName.text = object[@"Name"];

}
@end