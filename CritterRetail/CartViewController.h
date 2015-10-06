//
//  CartViewController.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/1/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

- (IBAction)toggleEdit:(id)sender;

@end
