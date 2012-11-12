//
//  OSAddServerEndpointViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 7/31/12.
//
//

#import <UIKit/UIKit.h>
#import "OpenStackAccount.h"

@interface OSAddServerEndpointViewController : UITableViewController

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) NSMutableArray *endpoints;

- (id)initWithAccount:(OpenStackAccount *)account;

@end
