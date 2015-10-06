//
//  CartCell.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/5/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productDescription;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;

@end
