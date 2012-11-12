//
//  OSLoadBalancerEndpoint.h
//  OpenStack
//
//  Created by Mike Mayo on 8/5/12.
//
//

#import <Foundation/Foundation.h>

@interface OSLoadBalancerEndpoint : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSString *region;
@property (nonatomic, retain) NSString *tenantId;
@property (nonatomic, retain) NSString *publicURL;

- (id)initWithJSONDict:(NSDictionary *)dict;
- (void)populateWithJSON:(NSDictionary *)dict;
+ (OSLoadBalancerEndpoint *)fromJSON:(NSDictionary *)dict;

@end
