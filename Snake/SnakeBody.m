//
//  SnakeBody.m
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import "SnakeBody.h"


@implementation SnakeBody {
	SnakeBody *_nextBody;
    NSInteger _snakeStep;
}

-(id)initWithTexture:(CCTexture2D *)texture{
    self = [super initWithTexture:texture];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
    
        _snakeStep = 20;
    }
    else{
        _snakeStep = 10;
    }
    return self;
}

-(void)setPosition:(CGPoint)position{

    if(_nextBody!=nil){
        [_nextBody setPosition:self.position];
    }
    [super setPosition:position];

}


-(void)addDirection:(SnakeDirection)direction{
    int dx, dy;
    if(direction == kLeftDirection){
        dx = -_snakeStep;
        dy = 0;
    }
    
    else if(direction == kRightDirection){

        dx = _snakeStep;
        dy = 0;
    }
    
    else if(direction == kUpDirection){

        dx = 0;
        dy = _snakeStep;
    }
    
    else if(direction == kDownDirection){
        dx = 0;
        dy = -_snakeStep;
    }
    
    [self setPosition:ccp(self.position.x+dx, self.position.y+dy)];
}


- (SnakeBody *)addBody {
	if(_nextBody==nil){
        CCTexture2D *texture;
        if(_otherBody){
            texture = [[CCTextureCache sharedTextureCache] addImage:@"OtherBody.png"];
        }
        else {
          texture = [[CCTextureCache sharedTextureCache] addImage:@"SnakeBody.png"];
        }
        _nextBody=[[SnakeBody alloc] initWithTexture:texture];
        _nextBody.position=ccp(self.position.x, self.position.y);
        _nextBody.otherBody = _otherBody;
        return _nextBody;
	}
  return [_nextBody addBody];
}

- (BOOL)collidedWith:(CCSprite *)s{
  if(CGPointEqualToPoint(s.position, self.position)){
    return YES;
  }

  if(_nextBody == nil){
    return NO;
  }

  return [_nextBody collidedWith:s];
}

- (SnakeBody *)getNext {
  return _nextBody;
}

- (void)setNormal {
    [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"SnakeBody.png"]];
    _otherBody = NO;
    
    if(_nextBody != nil){
        [_nextBody setNormal];
    }
}

- (void)setOther {
  [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"OtherBody.png"]];
  _otherBody = YES;

  if(_nextBody != nil){
    [_nextBody setOther];
  }
}

-(void)releaseAll{
  if(_nextBody!=nil){
    [_nextBody releaseAll];
  }
}

-(SnakeBody*)getLast{
  if (_nextBody!=nil) {
    return [_nextBody getLast];
  }
  return self;
}

-(NSInteger)getLength{
  if(_nextBody!=nil){
    return [_nextBody getLength]+1;
  }
  return 1;
}

-(NSInteger)getXTile{
    return self.position.x/_snakeStep;
}


-(NSInteger)getYTile{
    return self.position.y/_snakeStep;
}


@end
