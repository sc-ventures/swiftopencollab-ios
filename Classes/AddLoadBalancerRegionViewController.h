//
//  AddLoadBalancerRegionViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer, OSLoadBalancerEndpoint;

@interface AddLoadBalancerRegionViewController : UITableViewController

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) OSLoadBalancerEndpoint *endpoint;

- (id)initWithAccount:(OpenStackAccount *)account;

@end
