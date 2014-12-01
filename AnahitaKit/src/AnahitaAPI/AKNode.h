//
//  AKNode.h
//  Pods
//
//  Created by Arash  Sanieyan on 2013-01-12.
//
//

#import "AKEntity.h"
#import <Foundation/Foundation.h>

@interface AKNode : AKEntity

+ (instancetype)withID:(int)nodeID;

@property (nonatomic, copy) NSString *nodeID;

@end

@interface AKActor : AKNode

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *objectType;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSString *facebook;
@property (nonatomic, strong) NSString *twitter;
@property (nonatomic, strong) NSString *instagram;
@property (nonatomic, strong) NSArray *hours;
@property (nonatomic, strong) NSAttributedString *hoursString;

@property (nonatomic, assign) BOOL isFollower;
@property (nonatomic, assign) BOOL isLeader;
@property (nonatomic, assign) NSUInteger followerCount;
@property (nonatomic, assign) NSUInteger leaderCount;


- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)follow:(AKActor*)actor success:(void (^)(id actor))successBlock failure:(void (^)(NSError* error))failureBlock;

- (void)unfollow:(AKActor*)actor success:(void (^)(id actor))successBlock failure:(void (^)(NSError* error))failureBlock;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, readonly) NSURL *largeImageURL;
@property (nonatomic, readonly) NSURL *mediumImageURL;
@property (nonatomic, readonly) NSURL *smallImageURL;
@property (nonatomic, readonly) NSURL *squareImageURL;
@property (nonatomic, readonly) NSDictionary *toDictionary;

@end

@interface AKPerson : AKActor

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end

