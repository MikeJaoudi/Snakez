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
@interface GameOver : CCLayerColor {
  CCLabelTTF *score;
  CCLabelTTF *gameOver;
  CCLabelTTF *highscore;
  UIViewController *viewController;
  NSInteger reloads;
  
  CCMenuItem *item;
  CCMenuItem *item2;

  float screenMultiplier;
  
  NSInteger currentRank;
  NSInteger totalRank;
  
  GADBannerView *banner;
  
  CCMenuItemImage *facebook;
  CCMenuItemImage *twitter;
  
  CCMenu *shareMenu;
}

+(CCScene *) scene;
-(void)setMaxRank:(NSInteger)rank;
-(void)setCurrentRank:(NSInteger)rank;

@end
