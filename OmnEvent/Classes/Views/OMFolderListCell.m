//
//  OMFolderListCell.m
//  ICYMI
//
//  Created by Kevin on 8/15/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

#import "OMFolderListCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation OMFolderListCell
@synthesize delegate,object, folderType;

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
        [m_FolderThumbImage setImageWithURL:[NSURL URLWithString:postImgFile.url] placeholderImage:[UIImage imageNamed:@"folder_icon.png"]];
    }
    
    m_lblFolderName.text = object[@"Name"];
    [[m_FolderThumbImage layer] setBorderWidth:2.0f];
    //[[self layer] setBorderWidth:2.0];
    if(folderType == kTypeOwner)
    {
        [[m_FolderThumbImage layer] setBorderColor:[UIColor yellowColor].CGColor];
        //[[self layer] setBorderColor:[UIColor yellowColor].CGColor];
        
        
    }
    else if (folderType == kTypeCoporate)
    {
        [[m_FolderThumbImage layer] setBorderColor:[UIColor blueColor].CGColor];
    }

}
@end