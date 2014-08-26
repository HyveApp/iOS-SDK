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
        addAttributeMappingsFromArray:@[@"objectType", @"address", @"phone", @"facebook", @"twitter", @"hours", @"isFollower", @"isLeader", @"leaderCount", @"followerCount", @"imageURL"]];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if ( self = [super initWithDictionary:dictionary] ) {
        [self setNodeID:[NSString stringWithFormat:@"%@", [dictionary objectForKey:@"nodeID"]]];
        self.name = [dictionary objectForKey:@"name"];
        self.body = [dictionary objectForKey:@"body"];
        self.objectType = [dictionary objectForKey:@"objectType"];
        self.address = [dictionary objectForKey:@"address"];
        self.phone = [dictionary objectForKey:@"phone"];
        self.facebook = [dictionary objectForKey:@"facebook"];
        self.twitter = [dictionary objectForKey:@"twitter"];
        self.hours = [dictionary objectForKey:@"hours"];
        self.isFollower = [[dictionary objectForKey:@"isFollower"] boolValue];
        self.isLeader = [[dictionary objectForKey:@"isLeader"] boolValue];
        self.leaderCount = [[dictionary objectForKey:@"leaderCount"] integerValue];
        self.followerCount = [[dictionary objectForKey:@"followerCount"] integerValue];
        self.imageURL = [dictionary objectForKey:@"imageURL"];
    }
    return self;
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

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary objectForKey:@"nodeID"]) {
        [self setNodeID:[NSString stringWithFormat:@"%@", [dictionary objectForKey:@"nodeID"]]];
    }
    if ([dictionary objectForKey:@"name"]) {
        self.name = [dictionary objectForKey:@"name"];
    }
    if ([dictionary objectForKey:@"body"]) {
        self.body = [dictionary objectForKey:@"body"];
    }
    if ([dictionary objectForKey:@"objectType"]) {
        self.objectType = [dictionary objectForKey:@"objectType"];
    }
    if ([dictionary objectForKey:@"address"]) {
        self.address = [dictionary objectForKey:@"address"];
    }
    if ([dictionary objectForKey:@"phone"]) {
        self.phone = [dictionary objectForKey:@"phone"];
    }
    if ([dictionary objectForKey:@"facebook"]) {
        self.facebook = [dictionary objectForKey:@"facebook"];
    }
    if ([dictionary objectForKey:@"twitter"]) {
        self.twitter = [dictionary objectForKey:@"twitter"];
    }
    if ([dictionary objectForKey:@"hours"]) {
        self.hours = [dictionary objectForKey:@"hours"];
    }
    if ([dictionary objectForKey:@"isFollower"]) {
        self.isFollower = [[dictionary objectForKey:@"isFollower"] boolValue];
    }
    if ([dictionary objectForKey:@"isLeader"]) {
        self.isLeader = [[dictionary objectForKey:@"isLeader"] boolValue];
    }
    if ([dictionary objectForKey:@"leaderCount"]) {
        self.leaderCount = [[dictionary objectForKey:@"leaderCount"] integerValue];
    }
    if ([dictionary objectForKey:@"followerCount"]) {
        self.followerCount = [[dictionary objectForKey:@"followerCount"] integerValue];
    }
    if ([dictionary objectForKey:@"imageURL"]) {
        self.imageURL = [dictionary objectForKey:@"imageURL"];
    }
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

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:self.nodeID forKeyPath:@"nodeID"];
    [dictionary setValue:self.name forKeyPath:@"name"];
    [dictionary setValue:self.body forKeyPath:@"body"];
    [dictionary setValue:self.objectType forKeyPath:@"objectType"];
    [dictionary setValue:self.address forKeyPath:@"address"];
    [dictionary setValue:self.phone forKeyPath:@"phone"];
    [dictionary setValue:self.facebook forKeyPath:@"facebook"];
    [dictionary setValue:self.twitter forKeyPath:@"twitter"];
    [dictionary setValue:self.hours forKeyPath:@"hours"];
    [dictionary setValue:[NSNumber numberWithBool:self.isFollower] forKeyPath:@"isFollower"];
    [dictionary setValue:[NSNumber numberWithBool:self.isLeader] forKeyPath:@"isLeader"];
    [dictionary setValue:[NSNumber numberWithInteger:self.leaderCount] forKeyPath:@"leaderCount"];
    [dictionary setValue:[NSNumber numberWithInteger:self.followerCount] forKeyPath:@"followerCount"];
    [dictionary setValue:self.imageURL forKeyPath:@"imageURL"];
    return dictionary;
}

- (NSAttributedString *)hoursString
{
    if (!_hoursString) {
        NSMutableAttributedString *hours = [[NSMutableAttributedString alloc] initWithString:@"Hours:"
                                                                                  attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:14]}];
        if (self.hours.count > 0) {
            for (NSDictionary *hour in self.hours) {
                NSString *hourString = [hour objectForKey:@"weekday"];
                hourString = [NSString stringWithFormat:@"\n%-10s%@~%@", [hourString UTF8String], [hour objectForKey:@"start"], [hour objectForKey:@"end"]];
                [hours appendAttributedString:[[NSMutableAttributedString alloc] initWithString:hourString
                                                                                     attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:14]}]];
            }
            _hoursString = hours;
        }
        else {
            [hours appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\nPlease check back later."
                                                                                 attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:14]}]];
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

