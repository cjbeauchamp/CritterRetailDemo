//
//  CheckoutViewController.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/5/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CheckoutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *cardName;
@property (weak, nonatomic) IBOutlet UITextField *cardNumber;

@property (weak, nonatomic) IBOutlet UILabel *cartTotal;
@property (weak, nonatomic) IBOutlet UILabel *shippingTotal;
@property (weak, nonatomic) IBOutlet UILabel *taxTotal;
@property (weak, nonatomic) IBOutlet UILabel *checkoutTotal;

- (IBAction)completePurchase:(id)sender;
- (IBAction)triggerCrash:(id)sender;

@end
