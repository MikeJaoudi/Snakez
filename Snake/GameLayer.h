//
//  HelloWorldLayer.h
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright Mike Jaoudi 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "AppDelegate.h"
#import "SnakeBody.h"
#import "GameCenter.h"
#import "ControlLayer.h"

// HelloWorldLayer

typedef enum{
  kControlsFullScreen = 1,
  kControlsDPad = 2
}ControlType;

@class AppDelegate;
@interface GameLayer : CCLayerColor<CCTargetedTouchDelegate>
{
  SnakeBody *snake;
  SnakeDirection currentDirection;
  
  
  CCSprite *pickup;
  NSInteger points;
  CCLabelTTF *scorecounter;
  
  ControlLayer *controls;
  
  BOOL ready;
  
  NSMutableArray *moveStack;
  
  CCLabelTTF *pausedLabel;
  BOOL paused;
  
  CCParticleSystemQuad *particleSystem;
  CCParticleSystemQuad *snakeParticle;
  CCParticleSystemQuad *spawnParticle;
  NSInteger toAdd;
  
  CCLabelTTF *readyl;
  CCLabelTTF *go;
  
  NSDate *startTime;
  BOOL moved;
  int hitCorner;
  
  CCLayerColor *playArea;
  
  NSInteger screenMultiplier;
  
  NSInteger snakeStep;
  
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)gameOver;
-(void)placePickup;
-(void)startGame;

-(void)setReady;

-(void)nextFrame:(ccTime)dt;

-(void)addToPickup;
-(void)recordTime;
-(void)hitPickup;
-(void)endGame;
-(void)hitTail;
-(void)didMove;


@end
