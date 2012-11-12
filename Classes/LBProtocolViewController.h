//
//  LBProtocolViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer, OSLoadBalancerEndpoint;

@interface LBProtocolViewController : UITableViewController <UITextFieldDelegate> {
    @private
    UITextField *textField;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) OSLoadBalancerEndpoint *endpoint;

- (id)initWithAccount:(OpenStackAccount *)account endpoint:(OSLoadBalancerEndpoint *)endpoint loadBalancer:(LoadBalancer *)loadBalancer;

@end
