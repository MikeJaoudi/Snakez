//
//  FullScreenControlLayer.h
//  Snake
//
//  Created by Mike Jaoudi on 12/29/12.
//  Copyright 2012 Mike Jaoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ControlLayer.h"

@interface FullScreenControlLayer : ControlLayer {
  float currentAngle;
  
  CCSprite *controlImage;
}

@end
