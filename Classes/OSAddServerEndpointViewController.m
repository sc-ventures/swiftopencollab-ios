//
//  OSAddServerEndpointViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 7/31/12.
//
//

#import "OSAddServerEndpointViewController.h"
#import "UIViewController+Conveniences.h"
#import "OSComputeService.h"
#import "OSComputeEndpoint.h"
#import "AddServerViewController.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"

@implementation OSAddServerEndpointViewController

- (id)initWithAccount:(OpenStackAccount *)account {
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.account = account;
    }
    return self;
}

- (void)dealloc {
    [_account release];
    [_endpoints release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // configure appearance
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 70;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1];
    [self addCancelButton];
    self.navigationItem.title = @"Select a Region";
    
    // load data
    self.endpoints = [[[NSMutableArray alloc] init] autorelease];
    
    for (OSComputeService *service in self.account.computeServices) {
        
        for (OSComputeEndpoint *endpoint in service.endpoints) {
            
            [self.endpoints addObject:endpoint];
            
        }
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.endpoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    OSComputeEndpoint *endpoint = [self.endpoints objectAtIndex:indexPath.row];
    
    if ([endpoint.versionId isEqualToString:@"1.0"]) {
        cell.textLabel.text = @"First Generation";
        cell.detailTextLabel.text = @"First Gen Rackspace Cloud";
        cell.imageView.image = [UIImage imageNamed:@"rackspacecloud_icon.png"];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - OpenStack", endpoint.region];
        cell.detailTextLabel.text = @"Next Generation Open Cloud";
        cell.imageView.image = [UIImage imageNamed:@"openstack-icon.png"];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OSComputeEndpoint *endpoint = [self.endpoints objectAtIndex:indexPath.row];

    AddServerViewController *vc = [[AddServerViewController alloc] initWithNibName:@"AddServerViewController" bundle:nil];
    vc.account = self.account;
    vc.endpoint = endpoint;
//    vc.serversViewController = self;
//    vc.accountHomeViewController = self.accountHomeViewController;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];

}

@end
