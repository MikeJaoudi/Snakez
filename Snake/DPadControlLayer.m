//
//  DPadControlLayer.m
//  Snake
//
//  Created by Mike Jaoudi on 1/6/13.
//
//

#import "DPadControlLayer.h"

@implementation DPadControlLayer

-(id)init{
  self = [super init];
  
  if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
    dpadSize = 300;
  }
  else{
    dpadSize = 150;
  }
  
  rightPad = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ControlPad.png"]];
  rightPad.position = ccp(size.width-dpadSize/2, dpadSize/2);
  [self addChild:rightPad];
  
  leftPad = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"ControlPad.png"]];
  leftPad.position = ccp(dpadSize/2, dpadSize/2);
  [self addChild:leftPad];
  
  angle = 45;
  
  return self;
}

-(void)getDirectionForPosition:(CGPoint)location Stack:(NSMutableArray*)moveStack Current:(SnakeDirection)current{
  
  float degree;
  if(location.x>size.width-dpadSize-100&&location.y<dpadSize+100){
    degree = [self getDegreeAroundPoint:rightPad.position forLocation:location];
  }
  else if(location.x<dpadSize+100&&location.y<dpadSize+100){
    degree = [self getDegreeAroundPoint:leftPad.position forLocation:location];
  }
  else{
    return;
  }
  
  
  if([moveStack count]>0){
    current = [[moveStack lastObject] intValue];
  }

  SnakeDirection direction = [self getDirection:degree Current:current];
  
  [self addDirection:direction toStack:moveStack Current:current];

  
  
}

-(void)fadeToOpacity:(NSInteger)opacity{
  [leftPad runAction:[CCFadeTo actionWithDuration:2 opacity:opacity*2]];
  [rightPad runAction:[CCFadeTo actionWithDuration:2 opacity:opacity*2]];

}

@end

