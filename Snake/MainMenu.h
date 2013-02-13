//
//  MainMenu.h
//  Snake
//
//  Created by Mike Jaoudi on 9/12/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameKitConnector.h"
#import "TestFlight.h"
#import <GameKit/GameKit.h>

typedef enum {
  kMenuMain,
  kMenuClassic,
  kMenuGameCenter,
  kMenuAbout,
  kMenuControl
} MenuSelected;



@interface MainMenu : CCLayerColor<GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
  CGSize size;

  MenuSelected menuState;
  
  CCMenuItemFont *classic;
  CCMenuItemFont *multiplayer;
  CCMenuItemFont *controls;
  CCMenuItemFont *gamecenter;
  CCMenuItemFont *about;
  
  CCMenu *mainMenu;
  
  
  CCMenuItemLabel *easy;  
  CCMenuItemLabel *normal;  
  CCMenuItemLabel *hard;
  
  CCMenu *difficulty;

  CCMenuItemLabel *leaderboard;  
  CCMenuItemLabel *achievements;
  
  CCMenu *gcMenu;
  
  CCLabelTTF *version;
  CCLabelTTF *name;
  
  CCLabelTTF *aboutText;

  CCLabelTTF *titleLabel;
  
  GKLeaderboardViewController *leaderboardController;
  GKAchievementViewController *achievementsController;

    
    NSInteger fontSize;
    NSInteger titleHeight;
    NSInteger detailSize;
  
  CCMenuItemImage *dpad;
  CCMenuItemImage *fullScreen;
  
  CCMenu *controlMenu;
}
+(CCScene *) scene;

-(void)controls;
@end
