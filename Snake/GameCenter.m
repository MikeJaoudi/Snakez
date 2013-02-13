//
//  GameCenter.m
//  Snake
//
//  Created by Mike Jaoudi on 4/7/12.
//  Copyright (c) 2012 Mike Jaoudi. All rights reserved.
//

#import "GameCenter.h"


@implementation GameCenter
@synthesize  gameCenterAvailable, achievementsDictionary;

GameCenter *sharedInstance;
+ (GameCenter *)sharedGameCenter{
  if(sharedInstance==nil){
    sharedInstance = [[GameCenter alloc] init];
  }
  return sharedInstance;
}

-(id)init{
  if ((self = [super init])) {
    gameCenterAvailable = TRUE;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ach"];
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    achievementsDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];

  }
  return self;
}
- (void)authenticate{
 // NSLog(@"Authenticating...");
  if (!gameCenterAvailable) return;
  
 // NSLog(@"Authenticating local user...");
  if ([GKLocalPlayer localPlayer].authenticated == NO) {
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
      if(error!=nil){
     //   NSLog(@"UNABLE TO AUTHENTICATE");

      }
    }];
  } else {
  //  NSLog(@"Already authenticated!");
  }
  NSNotificationCenter *nc =
  [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(authenticationChanged)
             name:GKPlayerAuthenticationDidChangeNotificationName
           object:nil];
}

- (void)authenticationChanged {
  
  if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
   // NSLog(@"Authentication changed: player authenticated.");
    userAuthenticated = TRUE;
    
    
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
       if (error == nil)
       {
         
         for (GKAchievement* achievement in achievements){
           [achievementsDictionary setObject:achievement forKey:achievement.identifier];

         }
       }
       else{
         NSLog(@"Error:%@",error);
       }
       
     }];
 //   NSLog(@"Achievements");
    [self retrieveScoresForCategory:@"easy_leaderboard" AndKey:@"highscoreeasy"];
    [self retrieveScoresForCategory:@"normal_leaderboard" AndKey:@"highscore"];
    [self retrieveScoresForCategory:@"hard_leaderboard" AndKey:@"highscorehard"];

     //   [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error){ NSLog(@"Finished?");}];
    
  } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
   // NSLog(@"Authentication changed: player not authenticated");
    userAuthenticated = FALSE;
  }
}
-(BOOL)isConnected{
  return userAuthenticated;
}

- (void) reportScore:(int64_t)score forLeaderboard:(NSString*)leaderboard{
  
  GKScore *scoreReporter = [[GKScore alloc] initWithCategory:leaderboard];
 // NSLog(@"Reporting Score %lld to Leaderboard %@",score,leaderboard);
  scoreReporter.value = score;
  
  [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
    if (error != nil)
    {
      
    }
  }];
}

- (GKAchievement*) getAchievementForIdentifier:(NSString*) identifier
{
  GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
  if (achievement == nil)
  {
    achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    
  }
  return achievement;
}


- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
  // NSLog(@"Achievement Named:%@",identifier);
  GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];

  if (achievement == nil)
  {
    achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
  }
  else if(achievement.completed){
   // NSLog(@"Already Completed!");
    return;
  }
  else{
  }

  
  achievement.percentComplete = percent;
  achievement.showsCompletionBanner=TRUE;
  [achievementsDictionary setObject:achievement forKey:achievement.identifier];
  
  
  

  [achievement reportAchievementWithCompletionHandler:^(NSError *error)
   {
     if (error != nil)
     {
       
    //   NSLog(@"Achievement Not Registered!");
     }
   }];
  
}


-(void)saveAchievements{
  NSData * archivedAchievements = [NSKeyedArchiver archivedDataWithRootObject:achievementsDictionary];
  [[NSUserDefaults standardUserDefaults] setObject:archivedAchievements forKey:@"ach"];
}

-(void) retrieveScoresForCategory:(NSString*)category AndKey:(NSString*)key
{
  GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
  leaderboardRequest.category = category;
  
  if (leaderboardRequest != nil) {
    [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
      if (error == nil){
        int saved =[[NSUserDefaults standardUserDefaults] integerForKey:key];
        if(saved<leaderboardRequest.localPlayerScore.value){
          [[NSUserDefaults standardUserDefaults] setInteger:leaderboardRequest.localPlayerScore.value forKey:key];
        }
    //    NSLog(@"Retrieved localScore:%lld",leaderboardRequest.localPlayerScore.value);
      //  [delegate onLocalPlayerScoreReceived:leaderboardRequest.localPlayerScore ForCategory:category];
      }
    }];
  }
}

@end
