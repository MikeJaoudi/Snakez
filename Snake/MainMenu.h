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
#import <GameKit/GameKit.h>
#import <FlurrySDK/Flurry.h>

typedef enum {
    kMenuMain,
    kMenuClassic,
    kMenuGameCenter,
    kMenuAbout,
    kMenuControl
} MenuSelected;

#define MENUFONT @"HelveticaNeue-Light"
#define SUBMENUFONT @"HelveticaNeue-Light"



@interface MainMenu : CCLayerColor<GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, UIAlertViewDelegate>
+(CCScene *) scene;

-(void)controls;
@end
