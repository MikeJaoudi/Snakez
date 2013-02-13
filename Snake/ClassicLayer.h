//
//  ClassicLayer.h
//  Snake
//
//  Created by Mike Jaoudi on 3/24/12.
//  Copyright (c) 2012 Mike Jaoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLayer.h"
#import "AppDelegate.h"

@class AppDelegate;
@interface ClassicLayer : GameLayer{
  CCSprite *pauseButton;
  CCSprite *arrow;
    
}

-(void)pause;

@end
