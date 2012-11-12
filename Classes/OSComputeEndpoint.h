//
//  OSComputeEndpoint.h
//  OpenStack
//
//  Created by Mike Mayo on 7/26/12.
//
//

#import <Foundation/Foundation.h>
#import "Server.h"
#import "Image.h"
#import "Flavor.h"

@interface OSComputeEndpoint : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSString *region;
@property (nonatomic, retain) NSString *tenantId;
@property (nonatomic, retain) NSURL *publicURL;
@property (nonatomic, retain) NSString *versionId;

// non-API field.  storing servers associated with this endpoint here
@property (nonatomic, retain) NSMutableDictionary *servers;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) NSMutableDictionary *flavors;

- (id)initWithJSONDict:(NSDictionary *)dict;
- (void)populateWithJSON:(NSDictionary *)dict;
+ (OSComputeEndpoint *)fromJSON:(NSDictionary *)dict;

#pragma mark - KVO
- (void)addServersObject:(Server *)object;
- (void)removeServersObject:(Server *)object;
- (void)addImagesObject:(Image *)object;
- (void)removeImagesObject:(Image *)object;
- (void)addFlavorsObject:(Flavor *)object;
- (void)removeFlavorsObject:(Flavor *)object;

@end
