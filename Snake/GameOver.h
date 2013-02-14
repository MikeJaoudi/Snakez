//
//  GameOver.h
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "GADBannerView.h"

@class AppDelegate;

@interface GameOver : CCLayerColor

+ (CCScene *) scene;
- (void)setMaxRank:(NSInteger)rank;
- (void)setCurrentRank:(NSInteger)rank;

@end
