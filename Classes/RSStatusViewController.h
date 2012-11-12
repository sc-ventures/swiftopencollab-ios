//
//  RSStatusViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 8/13/12.
//
//

#import <UIKit/UIKit.h>
#import "ActivityIndicatorView.h"

@interface RSStatusViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) ActivityIndicatorView *activityIndicatorView;

@end
