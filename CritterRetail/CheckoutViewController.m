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

    self.title = @"Confirmation";

    // clear our cart
    NSFetchRequest *itemRequest = [[NSFetchRequest alloc] init];
    [itemRequest setEntity:[NSEntityDescription entityForName:@"CartItem"
                                       inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext]];
    
    NSError *error = nil;
    NSArray *items = [[AppDelegate sharedDelegate].managedObjectContext
                      executeFetchRequest:itemRequest error:&error];
    
    NSDecimalNumber *cartValue = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    //error handling goes here
    for (CartItem *item in items) {
        cartValue = [cartValue decimalNumberByAdding:item.productPrice];
    }
    
    NSDecimalNumber *tax = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lf", cartValue.doubleValue*0.075]];
    NSDecimalNumber *shipping = [NSDecimalNumber decimalNumberWithString:@"7.99"];
    NSDecimalNumber *totalValue = [cartValue decimalNumberByAdding:tax];
    totalValue = [totalValue decimalNumberByAdding:shipping];
    
    self.taxTotal.text = [NSString stringWithFormat:@"$%.2lf", tax.doubleValue];
    self.shippingTotal.text = [NSString stringWithFormat:@"$%.2lf", shipping.doubleValue];
    self.cartTotal.text = [NSString stringWithFormat:@"$%.2lf", cartValue.doubleValue];
    self.checkoutTotal.text = [NSString stringWithFormat:@"$%.2lf", totalValue.doubleValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)completePurchase:(id)sender
{    
    [Crittercism setValue:self.cardName.text forKey:@"PayerName"];

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
                                       } else if([httpResponse statusCode] == 300) {
                                           // trigger a crash
                                           @throw [NSException exceptionWithName:@"NSJSONException"
                                                                          reason:@"Uncaught exception - unable to parse JSON."
                                                                        userInfo:nil];

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

@end
