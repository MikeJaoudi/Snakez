//
//  GameCenter.h
//  Snake
//
//  Created by Mike Jaoudi on 4/7/12.
//  Copyright (c) 2012 Mike Jaoudi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface GameCenter : NSObject

@property (assign, readonly) BOOL gameCenterAvailable;
@property(nonatomic) NSMutableDictionary *achievementsDictionary;

+ (GameCenter *)sharedGameCenter;
- (void)authenticate;
- (BOOL)isConnected;
- (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float) percent;
- (void)reportScore:(int64_t)score forLeaderboard:(NSString *)leaderboard;
-(void)saveAchievements;
@end
