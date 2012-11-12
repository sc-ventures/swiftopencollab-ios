//
//  OSComputeService.h
//  OpenStack
//
//  Created by Mike Mayo on 7/26/12.
//
//

#import <Foundation/Foundation.h>

@interface OSComputeService : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSMutableArray *endpoints;

- (id)initWithJSONDict:(NSDictionary *)dict;
- (void)populateWithJSON:(NSDictionary *)dict;
+ (OSComputeService *)fromJSON:(NSDictionary *)dict;

@end
