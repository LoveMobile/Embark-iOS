//
//  RecipientCell.h
//  Embark
//
//  Created by Irvin Liao on 6/14/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipientCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarIV;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *avatarActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
