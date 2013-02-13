//
//  GameOver.h
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GADBannerView.h"


@class AppDelegate;
@interface MultiplayerGameOver : CCLayerColor {
  CCLabelTTF *score;
  GADBannerView *banner;
  UIViewController *viewController;
  NSInteger reloads;
  
  CCMenuItem *item;
  CCMenuItem *item2;
  CCMenuItem *item3;
  CCMenuItem *item4;
  
  CCLabelTTF *winlabel;
  CCLabelTTF *loselabel;
  CCLabelTTF *wincount;
  CCLabelTTF *losecount;

  NSInteger screenMultiplier;
  
  NSInteger currentRank;
  NSInteger totalRank;
}

+(CCScene *) scene;
-(void)setMaxRank:(NSInteger)rank;
-(void)setCurrentRank:(NSInteger)rank;

@end
