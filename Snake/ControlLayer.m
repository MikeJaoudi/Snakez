//
//  ControlLayer.m
//  Snake
//
//  Created by Mike Jaoudi on 12/28/12.
//  Copyright 2012 Mike Jaoudi. All rights reserved.
//

#import "ControlLayer.h"

@implementation ControlLayer

-(id)init{
    self = [super init];
    
    
    size = [[CCDirector sharedDirector] winSize];

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
    
    }
    else{
        
    }
    return self;
}

-(void)getDirectionForPosition:(CGPoint)location Stack:(NSMutableArray*)moveStack Current:(SnakeDirection)current{
   [NSException raise:@"Must Overwrite" format:@"Must overwrite this function"];
}

-(SnakeDirection)getDirection:(float)degree Current:(SnakeDirection)current{
  float currentAngle;
  if (current == kUpDirection||current == kDownDirection) {
    currentAngle = angle + 15;
  }
  else{
    currentAngle = angle - 15;
  }
  
  if (degree <= currentAngle && degree >= -currentAngle) {
    return kRightDirection;
  }
  else if(degree > currentAngle && degree < 180-currentAngle){
    return kUpDirection;
  }
  else if(degree < -currentAngle && degree > -180+currentAngle){
    return kDownDirection;
  }
  else{
    return kLeftDirection;
  }
}

-(float)getDegreeAroundPoint:(CGPoint)center forLocation:(CGPoint)position{
  return CC_RADIANS_TO_DEGREES(atan2f(position.y-center.y, position.x-center.x));
}

-(void)fadeToOpacity:(NSInteger)opacity{
  [NSException raise:@"Must Overwrite" format:@"Must overwrite this function"];
}


-(void)addDirection:(SnakeDirection)direction toStack:(NSMutableArray*)moveStack Current:(SnakeDirection)current{
  if(direction == kRightDirection && current == kLeftDirection){
    return;
  }
  else if(direction == kUpDirection && current == kDownDirection){
    return;
  }
  else if(direction == kLeftDirection && current == kRightDirection){
    return;
  }
  else if(direction == kDownDirection && current == kUpDirection){
    return;
  }
  [moveStack addObject:[NSNumber numberWithInt:direction]];
}

@end
