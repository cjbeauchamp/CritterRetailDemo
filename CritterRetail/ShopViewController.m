//
//  ShopViewController.m
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/1/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import "ShopViewController.h"

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "ReviewViewController.h"

#import <Crittercism/Crittercism.h>


@interface ShopViewController ()

@end

@implementation ShopViewController

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Crittercism leaveBreadcrumb:@"ShopViewDisplayed"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppDelegate sharedDelegate].shopVC = self;
    
    for(UIViewController *vc in self.tabBarController.viewControllers) {
        if([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController*)vc;
            [nvc.topViewController viewDidLoad];
        }
    }
    
    [self goBrowse:nil];
}

- (IBAction)goBrowse:(id)sender
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:BASE_URL]];
    [self.webView loadRequest:request];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
    [self.activityIndicator stopAnimating];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    
    NSLog(@"URL: %@", url);
    
    if([url.scheme isEqualToString:@"iosrequest"]) {

        NSString *method = url.host;
        
        NSString *params = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)url.fragment, CFSTR(""), kCFStringEncodingUTF8);
        
        params = [params stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        
        NSLog(@"Params: %@", params);

        NSError *jsonError;
        NSData *objectData = [params dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *paramDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                                  options:0
                                                                    error:&jsonError];
        
        NSLog(@"paramDict: %@", paramDict);
        
        if([method isEqualToString:@"review"]) {
            
            // show a dialog for a review to be written
            [self performSegueWithIdentifier:@"review" sender:paramDict];
            
        } else if([method isEqualToString:@"rating"]) {
            
            // show a dialog for a review to be written
            [self performSegueWithIdentifier:@"rating" sender:paramDict];
            
        } else if([method isEqualToString:@"addtocart"]) {
            
            // create a cart item
            CartItem *record = (CartItem*)[NSEntityDescription insertNewObjectForEntityForName:@"CartItem"
                                                                        inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
        
            record.productName = paramDict[@"name"];
            record.quantity = @1;
            record.productPrice = [NSDecimalNumber decimalNumberWithString:((NSNumber*)paramDict[@"price"]).stringValue];
            record.productID = paramDict[@"productID"];
            record.imageURL = paramDict[@"image"];
            record.productDescription = paramDict[@"description"];
            
            [[AppDelegate sharedDelegate] saveContext];

            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.labelText = @"Added to cart!";
            hud.mode = MBProgressHUDModeCustomView;
            [self.view addSubview:hud];
            [hud show:YES];
            
            [hud hide:YES afterDelay:3];
            
            NSString *msg = [NSString stringWithFormat:@"Product added to cart: %ld", ((NSNumber*)paramDict[@"productID"]).integerValue];
            [Crittercism leaveBreadcrumb:msg];
            
        }
        
        return NO;
    }
    
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"review"]) {
        NSDictionary *params = (NSDictionary*)sender;
        NSLog(@"Params: %@", params);
        ReviewViewController *vc = (ReviewViewController*)segue.destinationViewController;
        vc.productID = [(NSNumber*)params[@"productID"] integerValue];
    }
}

@end
