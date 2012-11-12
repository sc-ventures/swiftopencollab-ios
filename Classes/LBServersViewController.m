//
//  LBServersViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBServersViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "LoadBalancer.h"
#import "Server.h"
#import "Flavor.h"
#import "Image.h"
#import "UIViewController+Conveniences.h"
#import "ActivityIndicatorView.h"
#import "APICallback.h"
#import "LoadBalancerNode.h"
#import "LoadBalancerProtocol.h"
#import "OSComputeService.h"
#import "OSComputeEndpoint.h"


@implementation LBServersViewController

- (NSArray *)sortedRegions {
    NSArray *endpoints = [self.servers allKeys];
    return [endpoints sortedArrayUsingSelector:@selector(region)];
}

- (OSComputeEndpoint *)endpointAtIndex:(NSInteger)index {
    return [[self sortedRegions] objectAtIndex:index];
}

- (Server *)serverForEndpoint:(OSComputeEndpoint *)endpoint atIndex:(NSInteger)index {
    NSArray *servers = [endpoint.servers allValues];
    if ([servers count] > index) {
        return [servers objectAtIndex:index];
    } else {
        return nil;
    }
}

- (Server *)serverAtIndexPath:(NSIndexPath *)indexPath {
    OSComputeEndpoint *endpoint = [self endpointAtIndex:indexPath.section];
    return [self serverForEndpoint:endpoint atIndex:indexPath.row];
}


- (id)initWithAccount:(OpenStackAccount *)a loadBalancer:(LoadBalancer *)lb serverNodes:(NSMutableArray *)sn {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self = [super initWithStyle:UITableViewStyleGrouped];
    } else {
        self = [super initWithStyle:UITableViewStylePlain];
    }
    if (self) {
        self.account = a;
        self.loadBalancer = lb;
        self.serverNodes = sn;
        self.originalServerNodes = [[sn copy] autorelease];
    }
    return self;
}

- (void)dealloc {
    [_account release];
    [_loadBalancer release];
    [_serverNodes release];
    [_originalServerNodes release];
    [_servers release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)configureServersCollection {
    
    self.servers = [[[NSMutableDictionary alloc] init] autorelease];
    
    // We need to figure out where our list of servers is located.  there are two possibilities:
    // 1. self.account.servers:         1.0 style login
    // 2. self.account.computeServices: 2.0 style login
    // We will prefer 2.0, so we're checking it first.
    if (self.account.computeServices && [self.account.computeServices count] > 0) {
        
        for (OSComputeService *service in self.account.computeServices) {
            
            for (OSComputeEndpoint *endpoint in service.endpoints) {
                
                if (endpoint.servers) {
                    [self.servers setObject:endpoint.servers forKey:endpoint];
                }
                
            }
            
        }
        
    } else if (self.account.servers) {
        
        // we're going to make a fake compute service object to represent first gen cloud servers
        OSComputeService *service = [[OSComputeService alloc] init];
        service.name = @"Cloud Servers";
        service.endpoints = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
        
        OSComputeEndpoint *endpoint = [[OSComputeEndpoint alloc] init];
        endpoint.versionId = @"1.0";
        endpoint.publicURL = self.account.serversURL;
        [service.endpoints addObject:endpoint];
        
        [self.servers setObject:self.account.servers forKey:endpoint];
        
        [endpoint release];
        [service release];
        
    }
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Cloud Servers";
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self addDoneButton];
    }
    
        // we may not have loaded the servers yet, so load them now
        
        if (self.account.computeServices && [self.account.computeServices count] > 0) {
            
            // iterate through endpoints and get servers for each
            for (OSComputeService *service in self.account.computeServices) {
                
                for (OSComputeEndpoint *endpoint in service.endpoints) {
                    
                    [[self.account.manager getServersAtEndpoint:endpoint] success:^(OpenStackRequest *request) {
                        
                        NSDictionary *servers = [request servers];
                        
                        for (NSString *id in servers) {
                            Server *server = [servers objectForKey:id];
                            server.endpoint = [[endpoint copy] autorelease];
                            server.flavor = [server.endpoint.flavors objectForKey:server.flavorId];
                            [endpoint addServersObject:server];
                        }
                        
                        if (endpoint.servers) {
                            [self.servers setObject:endpoint.servers forKey:endpoint];
                        }
                        
                        [self configureServersCollection];
                        
                    } failure:^(OpenStackRequest *request) {
                        
                        [self alert:@"There was a problem loading some of your servers." request:request];
                        
                    }];
                    
                }
                
            }
            
        } else {
            
            // old school way to get servers
            [[self.account.manager getServers] success:^(OpenStackRequest *request) {
                
                NSLog(@"get servers response: %@", [request responseString]);
                
                self.account.servers = [NSMutableDictionary dictionaryWithDictionary:[request servers]];
                
                for (NSString *serverId in self.account.servers) {
                    Server *server = [self.account.servers objectForKey:serverId];
                    server.image = [self.account.images objectForKey:server.imageId];
                    server.flavor = [self.account.flavors objectForKey:server.flavorId];
                }
                
                [self configureServersCollection];
                
                [self.account persist];
                [self.tableView reloadData];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(selectFirstServer) userInfo:nil repeats:NO];
                }
            } failure:^(OpenStackRequest *request) {
                if (request.responseStatusCode != 0) {
                    [self alert:@"There was a problem loading your servers." request:request];
                }
            }];
            
        }
        
        
        /*
        [[self.account.manager getServers] success:^(OpenStackRequest *request) {
            [activityIndicatorView removeFromSuperviewAndRelease];
            [self.tableView reloadData];
        } failure:^(OpenStackRequest *request) {
            [activityIndicatorView removeFromSuperviewAndRelease];
            [self alert:@"There was a problem loading your servers." request:request];
        }];
        */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    OSComputeEndpoint *endpoint = [self endpointAtIndex:section];
    
    NSString *region = @"";
    if (endpoint.region) {
        region = [NSString stringWithFormat:@"%@ - ", endpoint.region];
    }
    
    NSString *name = nil;
    if ([endpoint.versionId isEqualToString:@"1.0"]) {
        name = @"First Generation";
    } else {
        name = @"OpenStack";
    }
    
    return [NSString stringWithFormat:@"%@%@", region, name];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.servers allKeys] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    OSComputeEndpoint *endpoint = [self endpointAtIndex:section];
    return [endpoint.servers count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Server *server = [self serverAtIndexPath:indexPath];
    cell.textLabel.text = server.name;
    cell.detailTextLabel.text = server.flavor.name;

    server.image = [server.endpoint.images objectForKey:server.imageId];
    if ([server.image respondsToSelector:@selector(logoPrefix)]) {
        if ([[server.image logoPrefix] isEqualToString:kCustomImage]) {
            cell.imageView.image = [UIImage imageNamed:kCloudServersIcon];
        } else {
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
        }
    }

    for (LoadBalancerNode *node in self.serverNodes) {
        if ([node.server isEqual:server]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Server *server = [self serverAtIndexPath:indexPath];
    LoadBalancerNode *nodeToRemove = nil;
    for (LoadBalancerNode *node in self.serverNodes) {
        if ([node.server isEqual:server]) {
            nodeToRemove = node;
        }
    }
    
    if (nodeToRemove) {
        [self.serverNodes removeObject:nodeToRemove];
    } else {
        LoadBalancerNode *node = [[LoadBalancerNode alloc] init];
        node.condition = @"ENABLED";
        node.server = server;
        node.address = [[server.addresses objectForKey:@"public"] objectAtIndex:0];
        node.port = [NSString stringWithFormat:@"%i", self.loadBalancer.protocol.port];
        [self.serverNodes addObject:node];
        [node release];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
}

#pragma mark - Button Handlers

- (void)doneButtonPressed:(id)sender {
    
    // compare original nodes to current nodes and alter the LB
    NSMutableArray *nodesToAdd = [[NSMutableArray alloc] init];
    NSMutableArray *nodesToDelete = [[NSMutableArray alloc] init];
    
    NSLog(@"original nodes: %@", self.originalServerNodes);
    NSLog(@"current nodes: %@", self.serverNodes);

    for (LoadBalancerNode *node in self.originalServerNodes) {
        if (![self.serverNodes containsObject:node]) {
            [nodesToDelete addObject:node];
            NSLog(@"going to delete: %@", node);
        }
    }
    
    for (LoadBalancerNode *node in self.serverNodes) {
        if (![self.originalServerNodes containsObject:node]) {
            [nodesToAdd addObject:node];
            NSLog(@"going to add: %@", node);
        }
    }
    
    for (LoadBalancerNode *node in nodesToAdd) {
        [self.loadBalancer.nodes addObject:node];
    }

    for (LoadBalancerNode *node in nodesToDelete) {
        [self.loadBalancer.nodes removeObject:node];
    }
    
    [nodesToDelete release];
    [nodesToAdd release];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
