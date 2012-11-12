//
//  LoadBalancersViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackViewController.h"

@class OpenStackAccount, OSLoadBalancerEndpoint;

@interface LoadBalancersViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource> {
    @private
    BOOL lbsLoaded;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSDictionary *algorithmNames;

- (IBAction)refreshButtonPressed:(id)sender;

@end
