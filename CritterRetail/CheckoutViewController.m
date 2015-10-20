//
//  CheckoutViewController.m
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/5/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import "CheckoutViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <Crittercism/Crittercism.h>

@interface CheckoutViewController ()

@end

@implementation CheckoutViewController

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Crittercism leaveBreadcrumb:@"CheckoutViewDisplayed"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // clear our cart
    NSFetchRequest *itemRequest = [[NSFetchRequest alloc] init];
    [itemRequest setEntity:[NSEntityDescription entityForName:@"CartItem"
                                       inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext]];
    
    NSError *error = nil;
    NSArray *items = [[AppDelegate sharedDelegate].managedObjectContext
                      executeFetchRequest:itemRequest error:&error];
    
    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    //error handling goes here
    for (CartItem *item in items) {
        total = [total decimalNumberByAdding:item.productPrice];
    }
    
    self.checkoutTotal.text = [NSString stringWithFormat:@"$%@", total.stringValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)completePurchase:(id)sender
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/completePurchase", BASE_URL]];
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
                                           
                                           // clear our cart
                                           NSFetchRequest *itemRequest = [[NSFetchRequest alloc] init];
                                           [itemRequest setEntity:[NSEntityDescription entityForName:@"CartItem"
                                                                          inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext]];
                                           
                                           NSError *error = nil;
                                           NSArray *items = [[AppDelegate sharedDelegate].managedObjectContext
                                                            executeFetchRequest:itemRequest error:&error];
                                           //error handling goes here
                                           for (NSManagedObject *item in items) {
                                               [[AppDelegate sharedDelegate].managedObjectContext deleteObject:item];
                                           }
                                           [[AppDelegate sharedDelegate] saveContext];

                                           
                                           [Crittercism endTransaction:@"checkout"];
                                           
                                           
                                           [self.navigationController popToRootViewControllerAnimated:TRUE];
                                       } else {
                                           [[[UIAlertView alloc] initWithTitle:@"Transaction Failed"
                                                                       message:@"A bad thing happened on the server! Oh no!"
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

- (IBAction)triggerCrash:(id)sender {
    @throw [NSException exceptionWithName:@"UIException"
                                   reason:@"The outlet was not properly connected to the button."
                                 userInfo:nil];
}

@end
