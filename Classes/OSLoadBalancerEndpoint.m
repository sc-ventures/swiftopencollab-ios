//
//  OSLoadBalancerEndpoint.m
//  OpenStack
//
//  Created by Mike Mayo on 8/5/12.
//
//

#import "OSLoadBalancerEndpoint.h"

@implementation OSLoadBalancerEndpoint

#pragma mark - Memory Management

- (void)dealloc {
    [_region release];
    [_tenantId release];
    [_publicURL release];
    [super dealloc];
}

#pragma mark - Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.region forKey:@"region"];
    [coder encodeObject:self.tenantId forKey:@"tenantId"];
    [coder encodeObject:self.publicURL forKey:@"publicURL"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.region = [[coder decodeObjectForKey:@"region"] retain];
        self.tenantId = [[coder decodeObjectForKey:@"tenantId"] retain];
        self.publicURL = [[coder decodeObjectForKey:@"publicURL"] retain];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OSLoadBalancerEndpoint *copy = [[OSLoadBalancerEndpoint allocWithZone:zone] init];
    copy.region = self.region;
    copy.tenantId = self.tenantId;
    copy.publicURL = self.publicURL;
    return copy;
}

#pragma mark - JSON

- (void)populateWithJSON:(NSDictionary *)dict {
    self.region = [dict objectForKey:@"region"];
    self.tenantId = [dict objectForKey:@"tenantId"];
    self.publicURL = [dict objectForKey:@"publicURL"];
}

- (id)initWithJSONDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self populateWithJSON:dict];
    }
    return self;
}

+ (OSLoadBalancerEndpoint *)fromJSON:(NSDictionary *)dict {
    OSLoadBalancerEndpoint *service = [[OSLoadBalancerEndpoint alloc] initWithJSONDict:dict];
    return [service autorelease];
}

@end
