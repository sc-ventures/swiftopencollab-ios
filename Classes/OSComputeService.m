//
//  OSComputeService.m
//  OpenStack
//
//  Created by Mike Mayo on 7/26/12.
//
//

#import "OSComputeService.h"
#import "OSComputeEndpoint.h"

@implementation OSComputeService

#pragma mark - Memory Management

- (void)dealloc {
    [_name release];
    [_displayName release];
    [_endpoints release];
    [super dealloc];
}

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.displayName forKey:@"displayName"];
//    [coder encodeObject:self.endpoints forKey:@"endpoints"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [[coder decodeObjectForKey:@"name"] retain];
        self.displayName = [[coder decodeObjectForKey:@"displayName"] retain];
        self.endpoints = [[coder decodeObjectForKey:@"endpoints"] retain];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OSComputeService *copy = [[OSComputeService allocWithZone:zone] init];
    copy.name = self.name;
    copy.displayName = self.displayName;
    copy.endpoints = self.endpoints;
    return copy;
}

#pragma mark - JSON

- (void)populateWithJSON:(NSDictionary *)dict {
    self.name = [dict objectForKey:@"name"];
    
    NSArray *jsonEndpoints = [dict objectForKey:@"endpoints"];
    self.endpoints = [[[NSMutableArray alloc] initWithCapacity:[jsonEndpoints count]] autorelease];
    for (NSDictionary *endpointJSON in jsonEndpoints) {
        
        OSComputeEndpoint *endpoint = [OSComputeEndpoint fromJSON:endpointJSON];
        [self.endpoints addObject:endpoint];
        
    }
    
    // there is no display name in the API, and the values returned aren't suitable for human
    // consumption.  here we'll attempt to give the service a proper name
    if ([self.name isEqualToString:@"cloudServers"]) {
        self.displayName = @"First Gen Cloud Servers";
    } else if ([self.name isEqualToString:@"cloudServersOpenStack"]) {
        self.displayName = @"OpenStack Cloud Servers";
    }
    
}

- (id)initWithJSONDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self populateWithJSON:dict];
    }
    return self;
}

+ (OSComputeService *)fromJSON:(NSDictionary *)dict {
    OSComputeService *service = [[OSComputeService alloc] initWithJSONDict:dict];
    return [service autorelease];
}

@end
