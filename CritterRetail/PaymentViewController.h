//
//  PaymentViewController.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/5/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *cardNumber;
- (IBAction)confirmOrder:(id)sender;

@end
