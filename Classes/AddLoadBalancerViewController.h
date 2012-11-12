//
//  AddLoadBalancerNameViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface AddLoadBalancerViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) NSDictionary *algorithmNames;
@property (nonatomic, retain) UITextField *nameTextField;

- (id)initWithAccount:(OpenStackAccount *)account;

@end
