//
//  ClassicLayer.m
//  Snake
//
//  Created by Mike Jaoudi on 3/24/12.
//  Copyright (c) 2012 Mike Jaoudi. All rights reserved.
//

#import "ClassicLayer.h"

@implementation ClassicLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ClassicLayer *layer = [ClassicLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init{
  self = [super init];
  CGSize size = [[CCDirector sharedDirector] winSize];
  
  pauseButton = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"PauseButton.png"]];
  pauseButton.position = ccp(size.width-20*screenMultiplier, size.height-15*screenMultiplier);
  [self addChild:pauseButton];
  
  arrow = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Arrow.png"]];
  arrow.position = ccp(-100, -100);
  [arrow runAction:[CCHide action]];
  [playArea addChild:arrow z:30];
  
  
  points=0;
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  [app setScore:points];
  
  
  scorecounter = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Points: %i",points] fontName:GAMEFONT fontSize:20*screenMultiplier dimensions:CGSizeMake(150*screenMultiplier, 30*screenMultiplier) hAlignment:kCCTextAlignmentLeft];
  
  scorecounter.position =  ccp(82*screenMultiplier, size.height-15*screenMultiplier);
  [self addChild:scorecounter z:4];

  
  
  
  [self placePickup];
  [self startGame];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(pause)
                                               name:@"Pause"
                                             object:nil];
    
    NSString *difficulty;
    switch ([app speed]) {
        case kEasySpeed:
            difficulty = @"Easy";
            break;
            
        case kNormalSpeed:
            difficulty = @"Normal";
            break;
            
        case kHardSpeed:
            difficulty = @"Hard";
            break;
    }
    
    NSString *c;
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsDPad){
        c = @"DPad Controls";
    }
    else{
        c = @"Full Screen Controls";
    }
    
    [Flurry logEvent:@"Play Classic" withParameters:@{@"Difficulty": difficulty, @"Control": c} timed:YES];
  
  return self;
}

-(void)nextFrame:(ccTime)dt{
  if(!ready||paused){
    return;
  }
  [super nextFrame:dt];
  
  
  if (toAdd>0) {
    toAdd--;
    points++;
    scorecounter.string = [NSString stringWithFormat:@"Points: %i", points];
  }
  
  
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  CGSize size = [[CCDirector sharedDirector] winSize];
  
  for (UITouch * touch in touches) {
    CGPoint location = [self convertTouchToNodeSpace:touch];
    if(paused){
      [self pauseButton];
      return;
    }
    if(!ready){
      return;
    }
    if(location.x>size.width-50*screenMultiplier&&location.y>size.height-50*screenMultiplier){
      [self pauseButton];
      return;
    }
  }
  [super ccTouchesBegan:touches withEvent:event];
}
-(void)pauseButton{
 // NSLog(@"Pause Button");
  if(!paused){
    [self pause];
  }
  else{
 //   NSLog(@"Resume");
    ready = NO;
    paused = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:[CCDirector sharedDirector] selector:@selector(pause) object:nil];
    [[CCDirector sharedDirector] resume];
    
    [pausedLabel runAction:[CCHide action]];
    [go runAction:[CCShow action]];
    [readyl runAction:[CCShow action]];
    [self startGame];
    
    arrow.position = ccp(snake.position.x, snake.position.y);
    if(currentDirection == kRightDirection){
      arrow.rotation = 0.0f;
      arrow.position = ccp(arrow.position.x+20*screenMultiplier,arrow.position.y);
    }
    else if(currentDirection == kLeftDirection){
      arrow.rotation = 180.0f;
      arrow.position = ccp(arrow.position.x-20*screenMultiplier,arrow.position.y);
      
    }
    else if(currentDirection == kUpDirection){
      arrow.rotation = 270.0f;
      arrow.position = ccp(arrow.position.x,arrow.position.y+20*screenMultiplier);
      
    }
    else if(currentDirection == kDownDirection){
      arrow.rotation = 90.0f;
      arrow.position = ccp(arrow.position.x,arrow.position.y-20*screenMultiplier);
      
    }
    
    [snake  runAction:[CCBlink actionWithDuration:2 blinks:10]];
    [arrow runAction:[CCSequence actions:[CCBlink actionWithDuration:2 blinks:10],[CCHide action],nil]];
  }
}

-(void)hitPickup{
  [super hitPickup];
  toAdd+=10;
  if(points+toAdd==20){
    [controls fadeToOpacity:50]
     ;
  }
  else if(points+toAdd==30){
    [controls fadeToOpacity:30];
  }
  
  
  scorecounter.string = [NSString stringWithFormat:@"Points: %i", points];
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  [app setScore:points+toAdd];
  
  if(app.speed==kHardSpeed&&app.score>=500){
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"champ" percentComplete:100.0f];
  }
}

-(void)gameOver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super gameOver];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1],[CCCallFunc actionWithTarget:self selector:@selector(goToGameOver)], nil]];
    
    snakeParticle.position=[snake getNext].position;
    [snakeParticle resetSystem];
    [Flurry endTimedEvent:@"Play Classic" withParameters:@{@"Score":[NSNumber numberWithInt:points]}];

}

-(void)numberOfGames{
  int number=[[NSUserDefaults standardUserDefaults] integerForKey:@"classicgames"]+1;
  [[NSUserDefaults standardUserDefaults] setInteger:number forKey:@"classicgames"];
  
}

-(void)pause{
  //NSLog(@"Pause");
  paused = YES;
  [go stopAllActions];
  [readyl stopAllActions];
  [snake stopAllActions];
  [arrow stopAllActions];
  [arrow runAction:[CCHide action]];
  [pausedLabel runAction:[CCShow action]];
  [go runAction:[CCHide action]];
  [readyl runAction:[CCHide action]];
  [self recordTime];
  
  [[CCDirector sharedDirector] performSelector:@selector(pause) withObject:nil afterDelay:2.0f];
}
/*
-(void)draw{
  [super draw];
  CGSize size = [[CCDirector sharedDirector] winSize];

  ccDrawRect(CGPointMake(size.width-300, 300), CGPointMake(size.width, 0));
  ccDrawRect(CGPointMake(0, 300), CGPointMake(300, 0));

}*/ 

@end
