//
//  NFBeeminderHelper.m
//  HolyRosary
//
//  Created by Pedro Paulo Oliveira Junior on 11/11/14.
//  Copyright (c) 2014 NetFilter. All rights reserved.
//

// It uses AFNetworking 1.x series

#import "NFBeeminderHelper.h"
#import "AFNetworking.h"

static NSString * BackendBaseURL =
        @"https://www.beeminder.com/";
static NSString * OAuth2Path =
        @"apps/authorize";
static NSString * ClientId =
        @"client_id=SECRET_CLIENT_ID_CHANGE_IT";
static NSString * RedirectURI =
        @"redirect_uri=iterco://beeminder-callback";
static NSString * ResponseType =
        @"response_type=token";

@implementation NFBeeminderHelper {
    AFHTTPClient *_client;
}

- (id)init
{
    self = [super init];
    if (self) {
        _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:BackendBaseURL]];
        [_client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

/**
 *  Beeminder Helper Singleton
 *
 *  @return Pointer to a singleton class instance.
 */
+ (instancetype)sharedBeeMinder {
    static NFBeeminderHelper *_sharedBeeMinder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedBeeMinder = [[NFBeeminderHelper alloc] init];
    });
    
    return _sharedBeeMinder;
}

- (void) setSelectedGoal:(NSString *)slugname {
    [[NSUserDefaults standardUserDefaults] setObject:slugname forKey:@"beeminder_slugname"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *) getSelectedGoal {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"beeminder_slugname"];
}

/**
 *  Get Beeminder secret auth token
 *
 *  @return the value of the auth token as a NSString
 */
- (NSString *) getToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"beeminder_token"];
}

/**
 *  Start the OAuth2 process
 */
- (void) beginOAuth
{
    if ([[NSUserDefaults standardUserDefaults]
         stringForKey:@"beeminder_token"] == nil)
    {
        NSString * auth =
            [BackendBaseURL
                stringByAppendingFormat:@"%@?%@&%@&%@",
                OAuth2Path,
                ClientId,
                RedirectURI,
                ResponseType];
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:auth]];
    }
}

/**
 *  Remove Authentication Token to force a re-Auth
 */
- (void) removeAuth
{
    [[NSUserDefaults standardUserDefaults]
        setObject:nil
        forKey:@"beeminder_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  Load Beeminder Goals from JSON response and fill a NSArray
 *
 *  @param completion callback that return if the operation was successful and the HTTP response code.
 */
- (void) refreshGoalsWithCompletion:
    (void (^)(BOOL, NSInteger))completion
{
    id success =
    ^(AFHTTPRequestOperation * operation, id JSON) {
        NSMutableArray *l_goals =
        [NSMutableArray arrayWithCapacity:[JSON count]];
        for (NSDictionary * goal in JSON) {
            [l_goals addObject:goal];
        }
        _goals = [l_goals copy];
        completion(YES,200);
    };
    id failure =
    ^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, [operation.response statusCode]);
    };
    NSDictionary *params =
    @{
        @"access_token" : [self getToken]
    };
    
    [_client getPath:@"/api/v1/users/me/goals.json"
          parameters:params
             success:success
             failure:failure];

}

/**
 *  Add One Unit to a Goal of Beeminder
 *
 *  @param completion callback that return if the operation was successful and the HTTP response code.
 */
- (void) addOneUnitToGoal:(void (^)(BOOL, NSInteger))completion
{
    id success = ^(AFHTTPRequestOperation * operation, id JSON) {
        completion(YES, 200);
    };
    id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, [operation.response statusCode]);
    };
    NSDictionary *params = @{
                             @"access_token" : [self getToken],
                             @"comment":
                                 @"Added by Electronic Rosary by Netfilter",
                             @"value":@"1"
                             };
    
    NSString * path = [NSString
                       stringWithFormat:
                       @"/api/v1/users/me/goals/%@/datapoints.json",
                       [self getSelectedGoal]];
    [_client postPath:path
          parameters:params
             success:success
             failure:failure];
}


@end
