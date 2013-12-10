//
//  GameOver.h
//  
//
//  Created by Mike Jaoudi on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Google-Mobile-Ads-SDK/GADBannerView.h>

#define MENUFONT @"HelveticaNeue-Light"
#define HEADERFONT @"HelveticaNeue"

@interface GameOver : CCLayerColor{
    CCMenuItem *_playAgain;
    CCMenuItem *_mainMenu;
    
    float _screenMultiplier;
    
    GADBannerView *_banner;
}

+ (CCScene *) scene;
- (void)reset:(id)sender;
- (void)menu:(id)sender;

@end
