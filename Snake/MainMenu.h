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



@interface MainMenu : CCLayerColor<GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
+(CCScene *) scene;

-(void)controls;
@end
