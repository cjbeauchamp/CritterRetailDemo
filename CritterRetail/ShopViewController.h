//
//  ShopViewController.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/1/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopViewController : UIViewController
<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)goBrowse:(id)sender;

@end
