//
//  GameCenter.m
//  Snake
//
//  Created by Mike Jaoudi on 4/7/12.
//  Copyright (c) 2012 Mike Jaoudi. All rights reserved.
//

#import "GameCenter.h"

GameCenter *sharedInstance = nil;

@implementation GameCenter {
    BOOL _gameCenterAvailable;
    BOOL _userAuthenticated;

    NSMutableArray *_savedHighScores;
}


+ (GameCenter *)sharedGameCenter{
    if(!sharedInstance) {
        sharedInstance = [[GameCenter alloc] init];
    }
    return sharedInstance;
}

-(id)init{
    if ((self = [super init])) {
        _gameCenterAvailable = YES;

        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ach"];
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _achievementsDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];

    }
    return self;
}
- (void)authenticate{
    if (!_gameCenterAvailable) return;

    if (![GKLocalPlayer localPlayer].authenticated) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
            if(error!=nil){
                // TODO: Network Errors
            }
        }];
    }

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(authenticationChanged)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
}

- (void)authenticationChanged {

    if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated) {
        _userAuthenticated = YES;

        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
            if (!error) {
                for (GKAchievement* achievement in achievements){
                    [_achievementsDictionary setObject:achievement forKey:achievement.identifier];
                }
            }
        }];

        [self retrieveScoresForCategory:@"easy_leaderboard"     withKey:@"highscoreeasy"];
        [self retrieveScoresForCategory:@"normal_leaderboard"   withKey:@"highscore"];
        [self retrieveScoresForCategory:@"hard_leaderboard"     withKey:@"highscorehard"];

    } else {
        _userAuthenticated = [GKLocalPlayer localPlayer].isAuthenticated;
    }
}

-(BOOL)isConnected {
    return _userAuthenticated;
}

- (void)reportScore:(int64_t)score forLeaderboard:(NSString *)leaderboard {

    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:leaderboard];
    scoreReporter.value = score;

    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {}];
}

- (GKAchievement *)getAchievementForIdentifier:(NSString*) identifier {
    GKAchievement *achievement = [_achievementsDictionary objectForKey:identifier];
    if (!achievement){
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [_achievementsDictionary setObject:achievement forKey:achievement.identifier];

    }
    return achievement;
}


- (void)reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent {
    GKAchievement *achievement = [_achievementsDictionary objectForKey:identifier];

    if (!achievement) {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    }

    if(achievement.completed) return;

    achievement.percentComplete = percent;
    achievement.showsCompletionBanner=YES;
    [_achievementsDictionary setObject:achievement forKey:achievement.identifier];

    if(_userAuthenticated){
        [achievement reportAchievementWithCompletionHandler:^(NSError *error){}];
    }
}


-(void)saveAchievements{
    NSData * archivedAchievements = [NSKeyedArchiver archivedDataWithRootObject:_achievementsDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:archivedAchievements forKey:@"ach"];
}

-(void)retrieveScoresForCategory:(NSString*)category withKey:(NSString*)key {
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    leaderboardRequest.category = category;

    if (leaderboardRequest != nil) {
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (!error) {
                int savedScore = [[NSUserDefaults standardUserDefaults] integerForKey:key];
                
                if( savedScore < leaderboardRequest.localPlayerScore.value){
                    [[NSUserDefaults standardUserDefaults] setInteger:leaderboardRequest.localPlayerScore.value forKey:key];
                }
            }
        }];
    }
}

@end
