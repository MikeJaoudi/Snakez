//
//  DPadControlLayer.h
//  Snake
//
//  Created by Mike Jaoudi on 1/6/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SnakeBody.h"
#import "ControlLayer.h"

@interface DPadControlLayer : ControlLayer{
  CCSprite *leftPad;
  CCSprite *rightPad;
  
  int dpadSize;
}

@end
