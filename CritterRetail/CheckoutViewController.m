//
//  CheckoutViewController.m
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/5/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import "CheckoutViewController.h"
#import "MBProgressHUD.h"

@interface CheckoutViewController ()

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)completePurchase:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:8000/api/completePurchase"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                   
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if(error == nil) {
                                       if ([httpResponse statusCode] == 200) {

                                           
                                           MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                                           hud.labelText = @"Purchase Complete!";
                                           hud.mode = MBProgressHUDModeCustomView;
                                           [self.navigationController.view addSubview:hud];
                                           [hud show:YES];
                                           [hud hide:YES afterDelay:3];

                                           [self.navigationController popToRootViewControllerAnimated:TRUE];
                                       } else {
                                           [[[UIAlertView alloc] initWithTitle:@"Transaction Failed"
                                                                       message:@"A bad thing happened on the server! Oh no!"
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
                                       [self.navigationController popViewControllerAnimated:TRUE];
                                   }
                               });
                           }];
}
@end
