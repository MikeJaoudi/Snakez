//
//  FullScreenControlLayer.m
//  Snake
//
//  Created by Mike Jaoudi on 12/29/12.
//  Copyright 2012 Mike Jaoudi. All rights reserved.
//

#import "FullScreenControlLayer.h"


@implementation FullScreenControlLayer

-(id)init{
  self = [super init];
  
  controlImage = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Controls.png"]];
  controlImage.position = ccp(size.width/2, size.height/2);
   [self addChild:controlImage];
  
  if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
    angle = 33.69;
  }
  else{
    angle = 33.69;
  }
  currentAngle = angle;
  return self;
}

-(void)getDirectionForPosition:(CGPoint)location Stack:(NSMutableArray*)moveStack Current:(SnakeDirection)current{
  
  if([moveStack count]>0){
    current = [[moveStack lastObject] intValue];
  }
  
  
  float degree = [self getDegreeAroundPoint:CGPointMake(size.width/2, size.height/2) forLocation:location];
  
  SnakeDirection direction = [self getDirection:degree Current:current];
  
  [self addDirection:direction toStack:moveStack Current:current];
  
  
}
/*
-(void)draw{
  [super draw];
  int drawAngle = currentAngle+90;
  ccDrawLine(CGPointMake(size.width/2, size.height/2), [self getCircumferencePoints:1000 startPoint:CGPointMake(size.width/2, size.height/2) Angle:drawAngle]);
  ccDrawLine(CGPointMake(size.width/2, size.height/2), [self getCircumferencePoints:1000 startPoint:CGPointMake(size.width/2, size.height/2) Angle:-drawAngle]);
  ccDrawLine(CGPointMake(size.width/2, size.height/2), [self getCircumferencePoints:1000 startPoint:CGPointMake(size.width/2, size.height/2) Angle:180-drawAngle]);
  ccDrawLine(CGPointMake(size.width/2, size.height/2), [self getCircumferencePoints:1000 startPoint:CGPointMake(size.width/2, size.height/2) Angle:-180+drawAngle]);
}
 
 
-(CGPoint)getCircumferencePoints:(int)radius startPoint:(CGPoint)start Angle:(float)angle {
	float x = start.x+radius*sin(CC_DEGREES_TO_RADIANS(angle));
	float y = start.y+radius*-cos(CC_DEGREES_TO_RADIANS(angle));
	CGPoint newPoint = ccp(x,y);
	return newPoint;
}*/


-(void)fadeToOpacity:(NSInteger)opacity{
  [controlImage runAction:[CCFadeTo actionWithDuration:2 opacity:opacity]];

}

@end
