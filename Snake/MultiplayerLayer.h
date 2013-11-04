//
//  MultiplayerLayer.h
//  Snake
//
//  Created by Mike Jaoudi on 3/24/12.
//  Copyright (c) 2012 Mike Jaoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLayer.h"
#import "GameKitConnector.h"


@interface MultiplayerLayer : GameLayer<ORLocalNetworkProtocol, UIAlertViewDelegate>{
  GameKitConnector * connection;
    
  SnakeBody *secondSnake;
  SnakeDirection secondDirection;
  
 // CCSprite *instructions;
  
  CCLabelTTF *tapToStart;
  CCLabelTTF *waitingl;
  
  CCNode *circleNode;
  CCLabelTTF *thisIsYou;
  
  CGPoint *clientPoint;
  CGPoint *hostPoint;
}

- (void)sendMove;
- (void)sendGameOver;
-(void)sendGrow;

@end
