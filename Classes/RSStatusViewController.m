//
//  RSStatusViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 8/13/12.
//
//

#import "RSStatusViewController.h"

@implementation RSStatusViewController

- (void)dealloc {
    [_webView release];
    [_activityIndicatorView release];
    [super dealloc];
}

- (id)init {
    return [self initWithNibName:@"RSStatusViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"System Status";
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];

    [self refreshButtonPressed:nil];
    
    self.navigationItem.leftBarButtonItem = nil;
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[request.URL host] isEqualToString:@"status.rackspace.com"]) {
        
        return YES;
        
    } else {
        
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
        
    }
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSString *activityMessage = @"Loading...";
    self.activityIndicatorView = [[[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage] autorelease];
    [self.activityIndicatorView addToView:self.webView scrollOffset:0];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.activityIndicatorView removeFromSuperview];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self.activityIndicatorView removeFromSuperview];
    self.navigationItem.rightBarButtonItem.enabled = YES;

}

- (void)refreshButtonPressed:(id)sender {
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://status.rackspace.com/"]]];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
