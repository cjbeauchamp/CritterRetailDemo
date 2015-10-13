//
//  ReviewViewController.m
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/7/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import "ReviewViewController.h"

#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "ShopViewController.h"

#import <Crittercism/Crittercism.h>

@interface ReviewViewController ()

@end

@implementation ReviewViewController

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)submit:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // do some API request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/product/%ld/review", BASE_URL, self.productID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *postDict = @{
                               @"author": self.nameField.text,
                               @"content": self.reviewField.text
                               };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDict
                                                       options:0
                                                         error:&error];
    
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                   
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if(error == nil) {
                                       if ([httpResponse statusCode] == 200) {
                                           
                                           MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:[AppDelegate sharedDelegate].shopVC.view];
                                           hud.labelText = @"Review Posted!";
                                           hud.mode = MBProgressHUDModeCustomView;
                                           [[AppDelegate sharedDelegate].shopVC.view addSubview:hud];
                                           [hud show:YES];
                                           [hud hide:YES afterDelay:3];
                                           
                                           // reload the shopping webview
                                           [[AppDelegate sharedDelegate].shopVC.webView reload];
                                           
                                           [self dismissViewControllerAnimated:TRUE completion:nil];
                                           
                                       } else {
                                           [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                       message:@"Something unexpected happened. Uh oh!"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"Ok"
                                                             otherButtonTitles:nil] show];
                                       }
                                   } else {
                                       [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                   message:@"Something unexpected happened. Uh oh!"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil] show];
                                   }
                               });
                           }];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.nameField becomeFirstResponder];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL) textView:(UITextView*)textView
shouldChangeTextInRange:(NSRange)range
  replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
