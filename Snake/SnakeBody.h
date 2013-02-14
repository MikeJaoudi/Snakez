//
//  SnakeBody.h
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    kUpDirection = 0,
    kDownDirection = 1,
    kRightDirection = 2,
    kLeftDirection = 3
} SnakeDirection;

@interface SnakeBody : CCSprite 

-(void)addDirection:(SnakeDirection)direction;
-(SnakeBody*)addBody;
-(BOOL)collidedWith:(CCSprite*)s;
-(SnakeBody*)getNext;
-(void)setOther;
-(void)setNormal;
-(void)releaseAll;
-(SnakeBody*)getLast;
-(NSInteger)getLength;
-(NSInteger)getXTile;
-(NSInteger)getYTile;

@property() BOOL otherBody;

@end
