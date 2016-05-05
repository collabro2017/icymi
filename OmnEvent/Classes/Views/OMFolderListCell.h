//
//  OMFolderListCell.h
//  ICYMI
//
//  Created by Kevin on 8/15/15.
//  Copyright (c) 2015 ellisa. All rights reserved.
//

@interface OMFolderListCell : UITableViewCell
{

    __weak IBOutlet UIImageView *m_FolderThumbImage;
    __weak IBOutlet UILabel *m_lblFolderName;
    
    
}
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) PFObject *object;

@end
