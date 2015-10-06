//
//  PaymentViewController.m
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/5/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import "PaymentViewController.h"

#import "MBProgressHUD.h"
#import "Crittercism.h"

@interface PaymentViewController ()
<UITextFieldDelegate>

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
//    CGFloat newY = textField.frame.origin.y-150;
//    self.view.transform = CGAffineTransformMakeTranslation(0, newY > 0 ? 0 : newY);
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    self.view.transform = CGAffineTransformIdentity;
}

- (IBAction)confirmOrder:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // do some API request
    NSString *urlString = [NSString stringWithFormat:@"http://127.0.0.1:8000/api/confirmPayment/%@", self.cardNumber.text];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){

                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                   
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if(error == nil) {
                                       if ([httpResponse statusCode] == 200) {
                                           [self performSegueWithIdentifier:@"confirm_order" sender:nil];
                                       } else if ([httpResponse statusCode] == 300) {
                                           [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                       message:@"Invalid payment info. Please try again."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles:nil] show];
                                       } else if ([httpResponse statusCode] == 500) {
                                           [[[UIAlertView alloc] initWithTitle:@"Transaction Failed"
                                                                       message:@"A bad thing happened on the server! Oh no!"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles:nil] show];
                                           [self.navigationController popViewControllerAnimated:TRUE];
                                       } else {
                                           [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                       message:@"Something *actually* unexpected happened. Uh oh!"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles:nil] show];
                                           [self.navigationController popViewControllerAnimated:TRUE];
                                       }
                                   } else {
                                       NSString *message = [NSString stringWithFormat:@"Error processing payment info: %@", error.localizedDescription];
                                       [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                   message:message
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil] show];
                                       [Crittercism failTransaction:@"checkout"];
                                       [self.navigationController popViewControllerAnimated:TRUE];
                                   }
                               });
                           }];
    
    
}
@end
