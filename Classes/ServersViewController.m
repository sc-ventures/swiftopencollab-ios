//
//  ServersViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ServersViewController.h"
#import "OpenStackAccount.h"
#import "AddServerViewController.h"
#import "UIViewController+Conveniences.h"
#import "Server.h"
#import "Image.h"
#import "Flavor.h"
#import "ServerViewController.h"
#import "OpenStackRequest.h"
#import "RateLimit.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"
#import "AccountHomeViewController.h"
#import "AccountManager.h"
#import "Provider.h"
#import "APICallback.h"
#import "OSComputeService.h"
#import "OSComputeEndpoint.h"
#import "OSAddServerEndpointViewController.h"


@implementation ServersViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSArray *)sortedRegions {
    NSArray *endpoints = [self.servers allKeys];
    return [endpoints sortedArrayUsingSelector:@selector(compare:)];
}

- (OSComputeEndpoint *)endpointAtIndex:(NSInteger)index {
    if ([[self sortedRegions] count] > 0) {
        return [[self sortedRegions] objectAtIndex:index];
    } else {
        return nil;
    }
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

#pragma mark - Button Handlers

- (void)addButtonPressed:(id)sender {
    
    OSAddServerEndpointViewController *vc = [[OSAddServerEndpointViewController alloc] initWithAccount:self.account];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
        if (app.rootViewController.popoverController) {
            [app.rootViewController.popoverController dismissPopoverAnimated:YES];
        }
    }
    [self presentModalViewControllerWithNavigation:vc];
    [vc release];
    
    /*
    AddServerViewController *vc = [[AddServerViewController alloc] initWithNibName:@"AddServerViewController" bundle:nil];
    vc.account = self.account;
    vc.serversViewController = self;
    vc.accountHomeViewController = self.accountHomeViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
        if (app.rootViewController.popoverController) {
            [app.rootViewController.popoverController dismissPopoverAnimated:YES];
        }
    }
    [self presentModalViewControllerWithNavigation:vc];
    [vc release];
    */
}

- (void)selectFirstServer {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)enableRefreshButton {
    serversLoaded = YES;
    refreshButton.enabled = YES;
    [self hideToolbarActivityMessage];
}

- (void)refreshButtonPressed:(id)sender {

    refreshButton.enabled = NO;
    [self showToolbarActivityMessage:@"Refreshing servers..."];
    
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
                    [self enableRefreshButton];
                    
                } failure:^(OpenStackRequest *request) {

                    [self alert:@"There was a problem loading some of your servers." request:request];
                    
                }];
                
            }
            
        }
        
    } else {
        
        // old school way to get servers
        [[self.account.manager getServers] success:^(OpenStackRequest *request) {
            
            NSLog(@"get servers response: %@", [request responseString]);
            
            [self enableRefreshButton];
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
            [self enableRefreshButton];
            if (request.responseStatusCode != 0) {
                [self alert:@"There was a problem loading your servers." request:request];
            }
        }];
        
    }
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
    self.tableView.rowHeight = 50;
    self.navigationItem.title = [self.account.provider isRackspace] ? @"Cloud Servers" : @"Compute";
    [self addAddButton];
    [self configureServersCollection];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        loaded = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // let's loop through the servers and see if there are any where we don't have an image
    for (OSComputeEndpoint *endpoint in self.servers) {
        
        for (NSString *serverId in endpoint.servers) {
            
            Server *server = [endpoint.servers objectForKey:serverId];
            
            if (!server.image && server.imageId) {
                
                [[self.account.manager getImage:server endpoint:endpoint] success:^(OpenStackRequest *request) {
                    
                    Image *image = [request image];
                    server.image = image;
                    [self.tableView reloadData];
                    
                } failure:^(OpenStackRequest *request) {
                    
                    NSLog(@"loading image for server %@ failed", server.name);
                    
                }];
                
            }
            
        }
        
    }
    
    if (!serversLoaded && [self.account.servers count] == 0) {
        [self refreshButtonPressed:nil];
    } else if (self.comingFromAccountHome) {
        [self refreshButtonPressed:nil];
    }
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.account.servers count] == 0 && serversLoaded) {
//        return [self tableView:self.tableView emptyCellWithImage:[UIImage imageNamed:@"empty-servers.png"] title:@"No Servers" subtitle:@"Tap the + button to create a new Cloud Server"];
//    } else if ([self.account.servers count] == 0) {
//        return nil; // there will be no cells present while loading
//    } else {
        static NSString *CellIdentifier = @"Cell";

        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        // Configure the cell...
        
        Server *server = [self serverAtIndexPath:indexPath];
        
        cell.textLabel.text = server.name;
        cell.detailTextLabel.text = server.flavor.name;
//        cell.detailTextLabel.text = [server image].name;
//        if ([server.addresses objectForKey:@"public"]) {
//            cell.detailTextLabel.text = [[server.addresses objectForKey:@"public"] objectAtIndex:0];
//        } else {
//            cell.detailTextLabel.text = @"";
//        }
        
        server.image = [server.endpoint.images objectForKey:server.imageId];
        
        if ([server.image respondsToSelector:@selector(logoPrefix)]) {
            if ([[server.image logoPrefix] isEqualToString:kCustomImage]) {
                cell.imageView.image = [UIImage imageNamed:kCloudServersIcon];
            } else {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
            }
        }
        
        return cell;
//    }    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Server *server = [self serverAtIndexPath:indexPath];    
    ServerViewController *vc = [[ServerViewController alloc] initWithNibName:@"ServerViewController" bundle:nil];
    vc.server = server;
    vc.account = self.account;
    vc.serversViewController = self;
    vc.selectedServerIndexPath = indexPath;
    vc.accountHomeViewController = self.accountHomeViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self presentPrimaryViewController:vc];
        if (loaded) {
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            if (app.rootViewController.popoverController != nil) {
                [app.rootViewController.popoverController dismissPopoverAnimated:YES];
            }
        }
    } else {
        [self.navigationController pushViewController:vc animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [vc release];
}


#pragma mark - Memory management

- (void)dealloc {
    [_tableView release];
    [_account release];
    [_accountHomeViewController release];
    [_servers release];
    [super dealloc];
}


@end

