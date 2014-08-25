//
//  AKSession.m
//  Pods
//
//  Created by Arash  Sanieyan on 2013-08-07.
//
//

#import "AKAnahitaAPI.h"
#import "FXKeychain.h"


NSString *const kAKSessionDidLogin = @"kAKSessionDidLogin";
NSString *const kAKSessionNewUserDidLogin = @"kAKSessionNewUserDidLogin";
NSString *const kAKSessionDidFailLogin = @"kAKSessionDidFailLogin";
NSString *const kAKSessionDidLogout = @"kAKSessionDidLogout";
NSString *const kAKSessionViewerNotificationKey = @"kAKSessionViewerNotificationKey";
NSString *const kAKSessionCredentialDidUpdate = @"kAKSessionCredentialDidUpdate";

NSString *const kAKSessionKeyChainKey = @"kAKSessionKeyChainKey";

@implementation NSDictionary(AKSessionCredential)

- (NSDictionary*)toParameters
{
    return self;
}

@end

@interface AKSessionBasicAuthCredential()

@property(nonatomic,copy) NSString *username, *password;

@end

@implementation AKSessionBasicAuthCredential

- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password
{
    if ( self = [super init] ) {
        self.password = password;
        self.username = username;
    }    
    return self;
}

- (NSDictionary*)toParameters
{
    return @{@"username":self.username,@"password":self.password};
}

@end

@interface AKSession()

@property(nonatomic,readwrite,strong) id<AKSessionCredential> credential;
@property(nonatomic,readwrite,strong) AKPerson * viewer;

@end

@implementation AKSession
{
    AKPerson *_viewer;
}

/**
 @method 
 
 @abstract
 Return a singleton session object. Tries to login the user using the
 existing username and pasword
*/
+ (instancetype)sessionWithCredential:(id<AKSessionCredential>)credential
{
    return [AKSession sessionWithCredential:credential forNewUser:NO];
}

+ (instancetype)sessionWithCredential:(id<AKSessionCredential>)credential forNewUser:(BOOL)isNewUser
{
    AKSession *session = [self sharedSession];
    session.credential = credential;
    session.isNewUser = isNewUser;
    return session;
}

+ (instancetype)sharedSession
{
    static AKSession *sharedSession;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       sharedSession = [[AKSession alloc] init];
       sharedSession.credential = [[FXKeychain defaultKeychain] objectForKey:kAKSessionKeyChainKey];
    });
    return sharedSession;
}

- (id)init
{
    if ( self = [super init] ) {
        
;    }
    return self;
}

- (void)login:(void(^)(AKPerson *viewer))success failure:(void(^)(NSError *error))failure
{
    void (^httpSuccess)(RKObjectRequestOperation*, RKMappingResult *)  = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NIDINFO(@"Welcome %@", self.viewer.name);
        //store the credential in they keychain to be used later
        [[FXKeychain defaultKeychain] setObject:[self.credential toParameters] forKey:kAKSessionKeyChainKey];
        if (self.isNewUser) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAKSessionNewUserDidLogin object:self userInfo:@{kAKSessionViewerNotificationKey:self.viewer}];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAKSessionDidLogin object:self userInfo:@{kAKSessionViewerNotificationKey:self.viewer}];
        }
        if ( success ) {
            success(self.viewer);
        }
    };
    void (^httpFailure)(RKObjectRequestOperation*, NSError *)  = ^(RKObjectRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAKSessionDidFailLogin object:self userInfo:nil];
        if ( failure ) failure(error);
    };
    if ( nil == self.credential ) {
        [[RKObjectManager sharedManager] getObject:self.viewer path:@"people/session" parameters:nil
            success:httpSuccess failure:httpFailure];    
    } else {
        // TODO: Handle social login
//        [[RKObjectManager sharedManager] postObject:viewer path:@"connect/login" parameters:[credential toParameters]
//                                            success:httpSuccess failure:httpFailure];
        
        [[RKObjectManager sharedManager] postObject:self.viewer path:@"people/session" parameters:[self.credential toParameters]
            success:httpSuccess failure:httpFailure];
    }

}

- (void)setViewer:(AKPerson *)viewer
{    
    [_viewer removeObserver:self forKeyPath:@"password" context:nil];
    _viewer = viewer;
    [_viewer addObserver:self forKeyPath:@"password" options:NSKeyValueObservingOptionNew context:nil];
}

- (AKPerson*)viewer
{
    if ( _viewer == nil ) {
        [self setViewer:[AKPerson new]];
    }
    return _viewer;
}

- (void)login
{
    [self login:nil failure:nil];
}

- (void)logout
{
    [[RKObjectManager sharedManager] postObject:self.viewer path:@"people/session" parameters:@{@"action" : @"delete"}
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NIDINFO(@"%@ is logged out successfully.", _viewer.name);
                                            [_viewer removeObserver:self forKeyPath:@"password" context:nil];
                                            _viewer = nil;
                                            _credential = nil;
                                            [[FXKeychain defaultKeychain] removeObjectForKey:kAKSessionKeyChainKey];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kAKSessionDidLogout object:self userInfo:nil];
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            NIDINFO(@"Failed to log %@ out.", _viewer.name);
                                            [_viewer removeObserver:self forKeyPath:@"password" context:nil];
                                            _viewer = nil;
                                            _credential = nil;
                                            [[FXKeychain defaultKeychain] removeObjectForKey:kAKSessionKeyChainKey];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kAKSessionDidLogout object:self userInfo:nil];
                                        }];
}

#pragma mark - Observing viewer attributes

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(AKPerson*)object change:(NSDictionary *)change context:(void *)context
{
    NSString *newPassword = [change valueForKey:NSKeyValueChangeNewKey];
    if ([keyPath isEqualToString:@"password"] && self.viewer.nodeID != nil && newPassword.length > 0)
    {
        [[FXKeychain defaultKeychain] setObject:
            [[[AKSessionBasicAuthCredential alloc] initWithUsername:self.viewer.username andPassword:newPassword] toParameters]
          forKey:kAKSessionKeyChainKey];
    }
}

@end