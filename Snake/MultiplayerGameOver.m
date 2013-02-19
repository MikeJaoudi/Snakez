//
//  GameOver.m
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import "MultiplayerGameOver.h"
#import "AppDelegate.h"
#import "MultiplayerLayer.h"
#import "MainMenu.h"

@implementation MultiplayerGameOver{
    CCLabelTTF *_score;
    
    CCLabelTTF *_winlabel;
    CCLabelTTF *_loselabel;
    CCLabelTTF *_wincount;
    CCLabelTTF *_losecount;
}
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MultiplayerGameOver *layer = [MultiplayerGameOver node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    
    self = [super init];

    CGSize size = [[CCDirector sharedDirector] winSize];
    
    [self setTouchEnabled:YES];
    
    
    _score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"You Tied"] fontName:@"Helvetica" fontSize:52*_screenMultiplier];
    
    if([[GameKitConnector sharedConnector] getMatchResult]==kResultTied){
        [_score setString:@"You Tied"];
        [GameKitConnector sharedConnector].streak = 0;
    }
    else if([[GameKitConnector sharedConnector] getMatchResult]==kResultWon){
        [_score setString:@"You WON!"];
        [GameKitConnector sharedConnector].streak++;
        
    }
    else {
        [_score setString:@"You Lost"];
        [GameKitConnector sharedConnector].streak = 0;
        
    }
    [[GameKitConnector sharedConnector] updateRecord];
    _score.position =  ccp( size.width /2 , size.height-40*_screenMultiplier);
    
    [self addChild: _score];
    
    
    _winlabel = [[CCLabelTTF alloc] initWithString:@"Wins" fontName:@"Helvetica" fontSize:30*_screenMultiplier];
    _winlabel.position = ccp(size.width/2-60*_screenMultiplier, size.height-130*_screenMultiplier);
    [self addChild:_winlabel];
    
    _loselabel = [[CCLabelTTF alloc] initWithString:@"Losses" fontName:@"Helvetica" fontSize:30*_screenMultiplier];
    _loselabel.position = ccp(size.width/2+60*_screenMultiplier, size.height-130*_screenMultiplier);
    [self addChild:_loselabel];
    
    _wincount = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i",[GameKitConnector sharedConnector].wins] fontName:@"Helvetica" fontSize:30*_screenMultiplier];
    _wincount.position = ccp(size.width/2-60*_screenMultiplier, size.height-160*_screenMultiplier);
    [self addChild:_wincount];
    
    _losecount = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i",[GameKitConnector sharedConnector].loses] fontName:@"Helvetica" fontSize:30*_screenMultiplier];
    _losecount.position = ccp(size.width/2+60*_screenMultiplier, size.height-160*_screenMultiplier);
    [self addChild:_losecount];
    
    [[GameCenter sharedGameCenter] saveAchievements];
    
    
    return self;
}


-(void)reset:(id)sender{
    // NSLog(@"Reset");
    [TestFlight passCheckpoint:@"Play Multiplayer Again"];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app makeBanner];
    CCScene * newScene = [MultiplayerLayer scene];
    [[CCDirector sharedDirector] replaceScene:newScene];
}

-(void)menu:(id)sender{
    [super menu:sender];
    
    [[GameKitConnector sharedConnector] disconnect];
}




-(void)dealloc{
    CCLOG(@"Dealloc %@",self);
    _banner.delegate = nil;
    [_banner removeFromSuperview];
}


@end
