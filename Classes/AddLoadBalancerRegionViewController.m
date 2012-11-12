//
//  AddLoadBalancerRegionViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddLoadBalancerRegionViewController.h"
#import "OpenStackAccount.h"
#import "UIViewController+Conveniences.h"
#import "AddLoadBalancerViewController.h"
#import "LoadBalancer.h"
#import "OSLoadBalancerEndpoint.h"

@implementation AddLoadBalancerRegionViewController

- (id)initWithAccount:(OpenStackAccount *)a {
    self = [super initWithNibName:@"AddLoadBalancerRegionViewController" bundle:nil];
    if (self) {
        self.account = a;
    }
    return self;
}

- (void)dealloc {
    [_account release];
    [_loadBalancer release];
    [_endpoint release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Region";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.account.loadBalancerEndpoints count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"For optimal performance, choose the location that is closest to the servers you want to load balance.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    OSLoadBalancerEndpoint *endpoint = [self.account.loadBalancerEndpoints objectAtIndex:indexPath.row];
    NSString *region = endpoint.region;
    cell.textLabel.text = region;
    cell.accessoryType = [self.loadBalancer.region isEqualToString:region] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OSLoadBalancerEndpoint *endpoint = [self.account.loadBalancerEndpoints objectAtIndex:indexPath.row];
    self.loadBalancer.region = endpoint.region;
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
}

@end
