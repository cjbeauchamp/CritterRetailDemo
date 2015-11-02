//
//  ShippingViewController.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/5/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShippingViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *zipCode;

- (IBAction)confirmShipping:(id)sender;

@end
