//
//  ReviewViewController.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/7/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewViewController : UIViewController
<UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextView *reviewField;
@property (nonatomic, assign) NSUInteger productID;

- (IBAction)cancel:(id)sender;
- (IBAction)submit:(id)sender;

@end
