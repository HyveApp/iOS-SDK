//
//  AKNode.m
//  Pods
//
//  Created by Arash  Sanieyan on 2013-01-12.
//
//

#import "AKAnahitaAPI.h"

@implementation AKNode

+ (instancetype)withID:(int)nodeID
{
    id node = [self new];
    [node setNodeID:[NSString stringWithFormat:@"%d", nodeID]];
    return node;
}

+ (void)configureEntity:(AKEntityManager *)configuration
{
    [configuration.mappingForResponse addAttributeMappingsFromDictionary:@{@"id":@"nodeID"}];
    
    //use the collection path to guess the entity path
    if ( configuration.pathPatternForGettingCollection &&
            !configuration.pathPatternForGettingEntity) {
            configuration.pathPatternForGettingEntity = [NSString stringWithFormat:@"%@/:nodeID", configuration.pathPatternForGettingCollection];
    }
}

@end

@interface AKNode(SocPatternWorkAround)
@property(nonatomic,readonly) NSString* nodeid;
@end
@implementation AKNode(SocPatternWorkAround)
- (NSString*)nodeid {
    return self.nodeID;
}
@end

@interface AKActor()

@property(nonatomic,strong) NSDictionary *imageURL;

@end

@implementation AKActor

+ (void)configureEntity:(AKEntityManager *)configuration
{
    [super configureEntity:configuration];
    [configuration.mappingForResponse addAttributeMappingsFromArray:@[@"name",@"body"]];
    [configuration.mappingForRequest addAttributeMappingsFromArray:@[@"name",@"body"]];
    [configuration.mappingForResponse
        addAttributeMappingsFromArray:@[@"objectType",@"address", @"phone", @"facebook", @"twitter", @"hours", @"isFollower", @"isLeader", @"leaderCount", @"followerCount", @"imageURL"]];
    
//    RKAttributeMapping *imageMapping = [RKAttributeMapping attributeMappingForKey:@"imageURL" usingTransformerBlock:^id(id value, __unsafe_unretained Class destinationType) {
//        
//    }];    
}

- (void)follow:(AKActor*)actor success:(void (^)(id actor))successBlock failure:(void (^)(NSError *error))failureBlock
{
    //if viewer is following
    if ( self == [AKSession sharedSession].viewer ) {
        actor.isLeader = YES;
    }
    NSString *resourcePath = actor.resourcePath;
    NSArray *components = [actor.objectType componentsSeparatedByString:@"."];
    if (components.count > 1) {
        if ([resourcePath rangeOfString:[components objectAtIndex:1]].location == NSNotFound) {
            resourcePath = [NSString stringWithFormat:@"%@/%@", [components objectAtIndex:1], actor.nodeID];
        }
    }
    [[RKObjectManager sharedManager] postObject:nil path:resourcePath parameters:@{@"_action":@"follow"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        successBlock(actor);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failureBlock) failureBlock(error);
    }];
}

- (void)unfollow:(AKActor*)actor success:(void (^)(id actor))successBlock failure:(void (^)(NSError *error))failureBlock
{
    //if viewer is unfollowing
    if ( self == [AKSession sharedSession].viewer ) {
        actor.isLeader = NO;
    }
    NSString *resourcePath = actor.resourcePath;
    NSArray *components = [actor.objectType componentsSeparatedByString:@"."];
    if (components.count > 1) {
        if ([resourcePath rangeOfString:[components objectAtIndex:1]].location == NSNotFound) {
            resourcePath = [NSString stringWithFormat:@"%@/%@", [components objectAtIndex:1], actor.nodeID];
        }
    }
    [[RKObjectManager sharedManager] postObject:nil path:resourcePath parameters:@{@"_action":@"unfollow"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        successBlock(actor);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failureBlock) failureBlock(error);
    }];
}

- (NSURL*)largeImageURL
{
    NSString *path = [self.imageURL valueForKeyPath:@"large.url"];
    return [NSURL URLWithString:path];
}

- (NSURL*)mediumImageURL
{
    NSString *path = [self.imageURL valueForKeyPath:@"medium.url"];
    return [NSURL URLWithString:path];
}

- (NSURL*)smallImageURL
{
    NSString *path = [self.imageURL valueForKeyPath:@"small.url"];
    return [NSURL URLWithString:path];
}

- (NSURL*)squareImageURL
{
    NSString *path = [self.imageURL valueForKeyPath:@"square.url"];
    return [NSURL URLWithString:path];
}

- (NSAttributedString *)hoursString
{
    if (!_hoursString) {
        if (self.hours.count > 0) {
            NSMutableAttributedString *hours = [[NSMutableAttributedString alloc] initWithString:@"Hours:\n"
                                                                                      attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:15]}];
            for (NSDictionary *hour in self.hours) {
                NSString *hourString = [NSString stringWithFormat:@"%@    %@~%@\n", [hour objectForKey:@"weekday"], [hour objectForKey:@"start"], [hour objectForKey:@"end"]];
                [hours appendAttributedString:[[NSMutableAttributedString alloc] initWithString:hourString
                                                                                     attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:15]}]];
            }
            _hoursString = hours;
        }
        else {
            NSMutableAttributedString *hours = [[NSMutableAttributedString alloc] initWithString:@"Hours:\n"
                                                                                      attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:15]}];
            [hours appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"Please check back later."
                                                                                 attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:15]}]];
            _hoursString = hours;
        }
    }
    
    return _hoursString;
}

@end

@implementation AKPerson

+ (void)configureEntity:(AKEntityManager *)configuration
{
    [super configureEntity:configuration];
    configuration.pathPatternForGettingCollection = @"people";
    configuration.pathPatternForGettingEntity = @"people/:nodeID";
    [configuration.mappingForResponse addAttributeMappingsFromArray:@[@"email",@"username"]];
    [configuration.mappingForRequest addAttributeMappingsFromArray:@[@"email",@"username",@"password"]];
    [RKResponseDescriptor responseDescriptorWithMapping:configuration.mappingForResponse
     method:RKRequestMethodPOST | RKRequestMethodGET pathPattern:@"people/session" keyPath:nil statusCodes:
        RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)
     ];       
}

@end

