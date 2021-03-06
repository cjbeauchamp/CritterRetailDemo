//
//  ShippingViewController.m
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/5/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import "ShippingViewController.h"

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Crittercism/Crittercism.h>

@interface ShippingViewController ()
<UITextFieldDelegate>

@end

@implementation ShippingViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Shipping & Payment";
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Crittercism leaveBreadcrumb:@"ShippingViewDisplayed"];
}

- (IBAction)confirmShipping:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // do some API request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/confirmPayment/%@", BASE_URL, self.zipCode.text]];
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
                                           [Crittercism failTransaction:@"checkout"];
                                           [self.navigationController popViewControllerAnimated:TRUE];
                                       } else if ([httpResponse statusCode] == 600) {
                                           
                                           @throw [NSException exceptionWithName:@"InvalidResponse"
                                                                          reason:@"Unable to parse the server response"
                                                                        userInfo:nil];
                                           
                                       } else {
                                           [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                       message:@"Something *actually* unexpected happened. Uh oh!"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles:nil] show];
                                           [Crittercism failTransaction:@"checkout"];
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
