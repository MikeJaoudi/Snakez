//
//  SnakeBody.m
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import "SnakeBody.h"


@implementation SnakeBody

@synthesize otherBody;

-(id)initWithTexture:(CCTexture2D *)texture{
    self = [super initWithTexture:texture];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
    
        snakeStep = 20;
    }
    else{
        snakeStep = 10;
    }
    return self;
}

-(void)setPosition:(CGPoint)position{

    if(nextBody!=nil){
        [nextBody setPosition:self.position];
    }
    [super setPosition:position];

}


-(void)addDirection:(SnakeDirection)direction{
    int dx, dy;
    if(direction == kLeftDirection){
        dx=-snakeStep;
        dy=0;
    }
    
    else if(direction == kRightDirection){

        dx=snakeStep;
        dy=0;
    }
    
    else if(direction == kUpDirection){

        dx=0;
        dy=snakeStep;
    }
    
    else if(direction == kDownDirection){
        dx=0;
        dy=-snakeStep;
    }
    
    [self setPosition:ccp(self.position.x+dx, self.position.y+dy)];
}


-(SnakeBody*)addBody{
	if(nextBody==nil){
    CCTexture2D *texture;
    if(self.otherBody){
      texture = [[CCTextureCache sharedTextureCache] addImage:@"OtherBody.png"];
    }
    else {
      texture = [[CCTextureCache sharedTextureCache] addImage:@"SnakeBody.png"];
    }
    nextBody=[[SnakeBody alloc] initWithTexture:texture];
    nextBody.position=ccp(self.position.x, self.position.y);
    nextBody.otherBody = self.otherBody;
    return nextBody;
	}
  return [nextBody addBody];
}

-(BOOL)collidedWith:(CCSprite*)s{
 // if( CGRectIntersectsRect([self boundingBox], [s boundingBox])&&self!=s ) {
  if(CGPointEqualToPoint(s.position, self.position)){
    return TRUE;
  }
  if(nextBody==nil){
    return FALSE;
  }
  return [nextBody collidedWith:s];
}

-(SnakeBody*)getNext{
  return nextBody;
}

-(void)setNormal{
  [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"SnakeBody.png"]];
  self.otherBody = FALSE;
  if(nextBody!=nil){
    [nextBody setNormal];
  }
}

-(void)setOther{
  [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"OtherBody.png"]];
  self.otherBody = TRUE;
  if(nextBody!=nil){
    [nextBody setOther];
  }
}

-(void)releaseAll{
  if(nextBody!=nil){
    [nextBody releaseAll];
  }
}

-(SnakeBody*)getLast{
  if (nextBody!=nil) {
    return [nextBody getLast];
  }
  return self;
}

-(NSInteger)getLength{
  if(nextBody!=nil){
    return [nextBody getLength]+1;
  }
  return 1;
}

-(NSInteger)getXTile{
    return self.position.x/snakeStep;
}


-(NSInteger)getYTile{
    return self.position.y/snakeStep;
}


@end
