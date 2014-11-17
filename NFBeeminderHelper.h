//
//  NFBeeminderHelper.h
//  HolyRosary
//
//  Created by Pedro Paulo Oliveira Junior on 11/11/14.
//  Copyright (c) 2014 NetFilter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFBeeminderHelper : NSObject
+ (instancetype)sharedBeeMinder;
- (void) refreshGoalsWithCompletion:(void (^)(BOOL, NSInteger))completion;
- (void) addOneUnitToGoal:(void (^)(BOOL, NSInteger))completion;
- (void) setSelectedGoal:(NSString *)slugname;
- (NSString *) getSelectedGoal;
- (NSString *) getToken;
- (void) beginOAuth;
- (void) removeAuth;
@property (strong) NSArray * goals;
@end
