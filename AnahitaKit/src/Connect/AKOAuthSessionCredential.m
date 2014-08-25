//
//  AKOAuthSessionCredential.m
//  Pods
//
//  Created by Arash  Sanieyan on 2013-08-14.
//
//

#import "AKConnect.h"

@interface AKOAuthSessionCredential()

@property(nonatomic,readwrite) NSString* token;
@property(nonatomic,readwrite) NSString* secret;
@property(nonatomic,readwrite) NSString* profileId;
@property(nonatomic,readwrite,assign) AKConnectServiceType serviceType;

@end

@implementation AKOAuthSessionCredential

+ (id)credentialWithToken:(NSString *)token secret:(NSString *)secret serivce:(AKConnectServiceType)service
{
    return [AKOAuthSessionCredential credentialWithToken:token secret:secret profileId:@"" serivce:service];
}

+ (id)credentialWithToken:(NSString *)token secret:(NSString *)secret profileId:(NSString *)profileId serivce:(AKConnectServiceType)service
{ 
    AKOAuthSessionCredential *credt = [AKOAuthSessionCredential new];
    NSAssert(token, @"Token must be specified");
    credt.token  = token;
    credt.secret = secret;
    credt.profileId = profileId;
    credt.serviceType = service;
    return credt;
}

- (NSDictionary*)toParameters
{    
    return @{
        @"oauth_handler" : AKConnectStringFromServiceType(self.serviceType),
        @"oauth_token"   : self.token,
        @"oauth_secret"  : self.secret ? self.secret : @"",
        @"profile_id"    : self.profileId
    };
}

@end
