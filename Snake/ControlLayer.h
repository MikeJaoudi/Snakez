//
//  ControlLayer.h
//  Snake
//
//  Created by Mike Jaoudi on 12/28/12.
//  Copyright 2012 Mike Jaoudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SnakeBody.h"


@interface ControlLayer : CCLayer {
  CGSize size;
  
  float angle;
  
}

-(void)getDirectionForPosition:(CGPoint)location Stack:(NSMutableArray*)moveStack Current:(SnakeDirection)current;

-(SnakeDirection)getDirection:(float)degree Current:(SnakeDirection)current;
-(float)getDegreeAroundPoint:(CGPoint)center forLocation:(CGPoint)position;
-(void)fadeToOpacity:(NSInteger)opacity;
-(void)addDirection:(SnakeDirection)direction toStack:(NSMutableArray*)moveStack Current:(SnakeDirection)current;
@end
