//
//  MultiplayerLayer.m
//  Snake
//
//  Created by Mike Jaoudi on 3/24/12.
//  Copyright (c) 2012 Mike Jaoudi. All rights reserved.
//

#import "MultiplayerLayer.h"
#import "MultiplayerGameOver.h"
#import "MainMenu.h"



@implementation MultiplayerLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MultiplayerLayer *layer = [MultiplayerLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
  
	// return the scene
	return scene;
}

-(id) init{
  self=[super init];
  
  pickup.position = ccp(-100, -100);
  
  
  CGSize size = [[CCDirector sharedDirector] winSize];

  secondSnake=[[SnakeBody alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"OtherBody.png"]];
  secondSnake.position=ccp(playArea.contentSize.width-55*screenMultiplier, playArea.contentSize.height-45*screenMultiplier);
  secondSnake.otherBody=YES;
  [playArea addChild:secondSnake z:20];
  for (int x=0;x<4; x++){
    [playArea addChild:[secondSnake addBody] z:20];
    
  }
  currentDirection = kRightDirection;
  for (int x=0;x<5; x++){
    [secondSnake addDirection:kLeftDirection];
  }
  [snake setOther];
  [secondSnake setOther];
  
//  instructions = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Player1Start.png"]];
//  instructions.position = ccp(size.width/2, size.width/2);
//  [instructions runAction:[CCHide action]];
//  [self addChild:instructions];
  
  
  tapToStart = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Tap to Start!"]  fontName:@"Helvetica" fontSize:36*screenMultiplier];
  tapToStart.position = ccp(size.width/2, size.height/2);
  [tapToStart runAction:[CCHide action]];
    [self addChild:tapToStart z:30];
  
  thisIsYou = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"This is you!"]  fontName:@"Helvetica" fontSize:40*screenMultiplier];
  thisIsYou.position = ccp(-100, -1000);
    [playArea addChild:thisIsYou z:30];
  [thisIsYou runAction:[CCHide action]];
  
  
  CCSprite *arrow = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"YouArrow.png"]];
  circleNode = [CCNode node];
  circleNode.position = ccp(-1000, -1000);
  arrow.position = ccp(-50*screenMultiplier, 0);
  [circleNode addChild:arrow];
  circleNode.rotation = 20;
    [playArea addChild:circleNode z:30];
  [circleNode runAction:[CCHide action]];
  waitingl = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Waiting for Opponent"]  fontName:@"Helvetica" fontSize:40*screenMultiplier];
  waitingl.position = ccp(size.width/2, size.height/2);
  
  
  [GameKitConnector sharedConnector].delegate = self;
  if(![[GameKitConnector sharedConnector] isConnected]){
      NSLog(@"IS NOT CONNECTED!!");
    [[GameKitConnector sharedConnector] startHostServer];
  }
  else{
    if([[GameKitConnector sharedConnector] isHost]){
      [self isHost];
    }
    
    else{
      [self isClient];
    }
  }
  
  return self;
}

int x=0;

-(void)setReady{

  [super setReady];
  [[GameKitConnector sharedConnector] setMatchState:kMatchStateActive];
}

-(void)nextFrame:(ccTime)dt{
    if ([[GameKitConnector sharedConnector] getMatchState]!=kMatchStateActive){return; }
    
    [super nextFrame:dt];
    
    [self sendMove];
    if([secondSnake collidedWith:snake]){
        //   NSLog(@"Hit Other");
        [self sendFinalMove];
    }
    
}
- (void)sendMove {
  NSInteger value = ([snake getXTile]+0)*100 + ([snake getYTile] + 0);
  [[GameKitConnector sharedConnector] sendCommand:@"move" withInt:value];
  
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  if([[GameKitConnector sharedConnector] getMatchState]==kMatchStateWaitingToApprove||[[GameKitConnector sharedConnector] getMatchState]==kMatchStartWaitingOnLocalPlayer){
//    [instructions runAction:[CCSequence actions:[CCSpawn actions:[CCScaleTo actionWithDuration:.5 scale:4], [CCFadeOut actionWithDuration:.3], [CCHide action], [CCFadeIn actionWithDuration:0], nil], nil]];
    [tapToStart runAction:[CCSequence actions:[CCSpawn actions:[CCScaleTo actionWithDuration:.5 scale:4], [CCFadeOut actionWithDuration:.3], [CCHide action], [CCFadeIn actionWithDuration:0], nil], nil]];
    [circleNode stopAllActions];

    [circleNode runAction:[CCHide action]];
    [thisIsYou runAction:[CCHide action]];
    [[GameKitConnector sharedConnector] setMatchState:kMatchStateWaitingForOpponent];
    
    
    
    [self addChild:waitingl z:30];
    
    return;
  }
  [super ccTouchesBegan:touches withEvent:event];
  
}
-(void)sendGrow{
  [[GameKitConnector sharedConnector] sendReliableCommand:@"grow" withArgument:@"hi"];
}



-(void)placePickup{
  particleSystem.position=ccp(pickup.position.x, pickup.position.y);
  [particleSystem resetSystem];
  
  pickup.position=ccp(((arc4random()%48)*10+5)*screenMultiplier, ((arc4random()%32)*10+5)*screenMultiplier);
  while ([snake collidedWith:pickup]||[secondSnake collidedWith:pickup]){
    pickup.position=ccp(((arc4random()%48)*10+5)*screenMultiplier, ((arc4random()%32)*10+5)*screenMultiplier);
  }
  
  int value = (pickup.position.x/screenMultiplier)*1000+(pickup.position.y/screenMultiplier);
  [[GameKitConnector sharedConnector] sendReliableCommand:@"pickup" withInt:value];
  
  spawnParticle.position=ccp(pickup.position.x, pickup.position.y);
  [spawnParticle resetSystem];
  
}





-(void) isHost{
  
  [[GameKitConnector sharedConnector] setMatchState:kMatchStateWaitingToApprove];
  [particleSystem stopSystem];
  [snake setNormal];
  [secondSnake setOther];
  [tapToStart runAction:[CCShow action]];
  //[instructions runAction:[CCShow action]];
  thisIsYou.position = ccp(320*screenMultiplier, 30*screenMultiplier);
  [thisIsYou runAction:[CCShow action]];
  [circleNode runAction:[CCShow action]];
  circleNode.rotation = 185;
  circleNode.position = snake.position;

//  [circleNode runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCRotateBy actionWithDuration:1 angle:-30] two:[CCRotateBy actionWithDuration:1 angle:30]]]];

}
-(void) isClient{
  currentDirection = kLeftDirection;
  
  [[GameKitConnector sharedConnector] setMatchState:kMatchStateWaitingToApprove];
  SnakeBody *temp = secondSnake;
  secondSnake = snake;
  snake = temp;
  [snake setNormal];
  [secondSnake setOther];
  //[instructions setTexture:[[CCTextureCache sharedTextureCache] addImage:@"Player2Start.png"]];
  //[instructions runAction:[CCShow action]];
  [tapToStart runAction:[CCShow action]];
  circleNode.rotation = 5;
  circleNode.position = snake.position;
  [circleNode runAction:[CCShow action]];
  thisIsYou.position = ccp(180*screenMultiplier, playArea.contentSize.height-30*screenMultiplier);
  [thisIsYou runAction:[CCShow action]];

 // [circleNode runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCRotateBy actionWithDuration:1 angle:-30] two:[CCRotateBy actionWithDuration:1 angle:30]]]];

}


-(void) connectionCancelled{
  CCScene * newScene = [MainMenu scene];
  [[CCDirector sharedDirector] replaceScene:newScene];
}

-(void) opponentDisconnected{
  UIAlertView* dialog = [[UIAlertView alloc] init];
  [dialog setTitle:@"Opponent Disconnected"];
  [dialog setMessage:@"Your opponent has disconnected"];
  [dialog addButtonWithTitle:@"Ok"];
  [dialog show];
  
  CCScene * newScene = [MainMenu scene];
  [[CCDirector sharedDirector] replaceScene:newScene];
}

-(void) recievedCommand:(NSString *)command withArgument:(NSString *)argument{
  //NSLog(@"Recieved");
  if([command isEqualToString:@"pickup"]){
    int value = [argument intValue];
    particleSystem.position=ccp(pickup.position.x, pickup.position.y);
    [particleSystem resetSystem];
    pickup.position = ccp((value/1000)*screenMultiplier, (value%1000)*screenMultiplier);
    
    spawnParticle.position=ccp(pickup.position.x, pickup.position.y);
    [spawnParticle resetSystem];
  }
  
  else if([command isEqualToString:@"move"]){
    int move = [argument intValue];
    
    int odx = move/100-[secondSnake getXTile];
    int ody = move%100-[secondSnake getYTile];
    
    while (odx!=0){
      if(odx>0){
        [secondSnake addDirection:kRightDirection];
        odx = odx - 1;
      }
      else {
        [secondSnake addDirection:kLeftDirection];
        odx = odx + 1;
      }
      if([secondSnake collidedWith:snake]){
    //    NSLog(@"Hit Other");
        [self sendFinalMove];
      }
    }
    while (ody!=0){
      if(ody>0){
        [secondSnake addDirection:kUpDirection];
        ody = ody - 1;
      }
      else {
        [secondSnake addDirection:kDownDirection];
        ody = ody + 1;
      }
      if([secondSnake collidedWith:snake]){
       // NSLog(@"Hit Other");
        [self sendFinalMove];
      }
    }
    
    
    
  }
  
  else if([command isEqualToString:@"grow"]){
    for (int x=0;x<5; x++){
        [playArea addChild:[secondSnake addBody] z:20];
      
    }
  }
  
  else if([command isEqualToString:@"gameover"]){
    //NSLog(@"Game Over");
    Result result = [argument intValue];
    [[GameKitConnector sharedConnector] setMatchResult:result];
    [self gameOver];
  }
    
  else if([command isEqualToString:@"finalmove"]){
      int move = [argument intValue];
      
      int odx = move/100 - [secondSnake getXTile];
      int ody = move%100 - [secondSnake getYTile];
      
      NSLog(@"Move to x:%i and y:%i",move/100, move%100);
      
      while (odx!=0){
          if(odx>0){
              [secondSnake addDirection:kRightDirection];
              odx = odx - 1;
          }
          else {
              [secondSnake addDirection:kLeftDirection];
              odx = odx + 1;
          }
      }
      while (ody!=0){
          if(ody>0){
              [secondSnake addDirection:kUpDirection];
              ody = ody - 1;
          }
          else {
              [secondSnake addDirection:kDownDirection];
              ody = ody + 1;
          }
      }
      
      [self finalPosition];
      
  }
  
}
-(void)gameOver{
    [super gameOver];
    [[GameKitConnector sharedConnector] setMatchState:kMatchStateGameOver];
    
    if([[GameKitConnector sharedConnector] getMatchResult]==kResultWon){
        [secondSnake runAction:[CCHide action]];
        
        ccColor4F start ={0.0f, 0.43f, 1.0f, 1.0f};
        snakeParticle.startColor=start;
        ccColor4F end = {0.0f, 0.43f, 1.0f, 0.0f};
        snakeParticle.endColor = end;
        snakeParticle.position=ccp([secondSnake getNext].position.x, [secondSnake getNext].position.y);
        [snakeParticle resetSystem];
    }
    else {
        [snake runAction:[CCHide action]];
        
        ccColor4F start ={0.0f, 1.0f, 0.0f, 1.0f};
        snakeParticle.startColor=start;
        ccColor4F end = {0.0f, 1.0f, 0.0f, 0.0f};
        snakeParticle.endColor = end;
        snakeParticle.position=ccp([snake getNext].position.x, [snake getNext].position.y);
        [snakeParticle resetSystem];
    }
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1],[CCCallFunc actionWithTarget:self selector:@selector(goToGameOver)], nil]];
    
    
}

-(void)goToGameOver{
  CCScene * newScene = [MultiplayerGameOver scene];
  [[CCDirector sharedDirector] replaceScene:newScene];
  
}

-(void)onExit{
  [super onExit];
}

- (void) dealloc
{
  CCLOG(@"Dealloc %@",self);
  
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
  
  if(self!=nil){
    //NSLog(@"Dealloc Retain Count:%i",[self retainCount]);
  }
  
}

-(void)connected{
  
}

-(void)startMatch{
  [[GameKitConnector sharedConnector] setMatchState:kMatchStateWaitingForStart];
  
  //NSLog(@"Starting");
  [waitingl runAction:[CCFadeOut actionWithDuration:.2]];
  [[GameKitConnector sharedConnector] setMatchResult:kResultUnknown];
  
  if([[GameKitConnector sharedConnector] isHost]){
    [self placePickup];
  }
  [super startGame];
  
}

-(void)sendFinalMove{
//  NSLog(@"Send Game Over");
  [[GameKitConnector sharedConnector] setMatchState:kMatchStateGameOver];
    NSLog(@"X is %i",[snake getXTile]);
    NSInteger value = ([snake getXTile]+0)*100 + [snake getYTile] + 0;
    NSLog(@"Hit at to x:%i and y:%i",value/100, value%100);
    [[GameKitConnector sharedConnector] sendCommand:@"finalmove" withInt:value];

  
}

-(void)finalPosition{
    if( CGRectIntersectsRect([snake boundingBox], [secondSnake boundingBox])) {
        [[GameKitConnector sharedConnector] sendTiedGame];
    }
    else {
        [[GameKitConnector sharedConnector] sendGameOver];
    }
    [self gameOver];
}

-(void)hitPickup{
  [self sendGrow];
  [super hitPickup];
}

-(void)endGame{
 // NSLog(@"End Game");
  [self sendFinalMove];
}

-(void)numberOfGames{
  int number=[[NSUserDefaults standardUserDefaults] integerForKey:@"multigames"]+1;
  [[NSUserDefaults standardUserDefaults] setInteger:number forKey:@"multigames"];
  
}

@end
