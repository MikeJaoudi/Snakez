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

@implementation MultiplayerGameOver
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
  CGSize size = [[CCDirector sharedDirector] winSize];

	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(54, 54, 57, 255)])) {
    self.isTouchEnabled=YES;
		// create and initialize a Label
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    viewController=app.navController.topViewController;
    
    banner = [app getBanner];
    banner.frame = CGRectMake(size.width/2-banner.frame.size.width/2, size.height-banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);

    [viewController.view addSubview:banner];
    //    [RevMobAds showBannerAdWithFrame:CGRectMake(80, 270, 320, 50) withDelegate:nil withSpecificOrientations:UIInterfaceOrientationLandscapeLeft,UIInterfaceOrientationLandscapeRight,nil];

    
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
      screenMultiplier = 2.2;
    }
    else{
      screenMultiplier = 1;
    }
    
    item = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Play Again" fontName:@"Helvetica" fontSize:36*screenMultiplier] target:self selector:@selector(reset:)];
		item.position = ccp(-item.contentSize.width/2-40, 0);
    
    item2 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Main Menu" fontName:@"Helvetica" fontSize:36*screenMultiplier] target:self selector:@selector(menu:)];
		item2.position = ccp(item2.contentSize.width/2+40, 0);
    
    [item setIsEnabled:YES];
    [item2 setIsEnabled:YES];
    
    CCMenu *menu = [CCMenu menuWithItems:item, item2,nil];
    menu.position = ccp(size.width/2, banner.frame.size.height*1.5);
    [self addChild:menu];
    
    

    
    
    NSInteger points=app.score;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"]<points)
    {
      [[NSUserDefaults standardUserDefaults] setInteger:points forKey:@"highscore"];
    }
    


    score = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"You Tied"] fontName:@"Helvetica" fontSize:52*screenMultiplier];

    if([[GameKitConnector sharedConnector] getMatchResult]==kResultTied){
      [score setString:@"You Tied"];
      [GameKitConnector sharedConnector].streak = 0;
    }
    else if([[GameKitConnector sharedConnector] getMatchResult]==kResultWon){
      [score setString:@"You WON!"];
      [GameKitConnector sharedConnector].streak++;

    }
    else {
      [score setString:@"You Lost"];
      [GameKitConnector sharedConnector].streak = 0;

    }
    [[GameKitConnector sharedConnector] updateRecord];
    score.position =  ccp( size.width /2 , size.height-40*screenMultiplier);

		[self addChild: score];
    
    
    winlabel = [[CCLabelTTF alloc] initWithString:@"Wins" fontName:@"Helvetica" fontSize:30*screenMultiplier];
    winlabel.position = ccp(size.width/2-60*screenMultiplier, size.height-130*screenMultiplier);
    [self addChild:winlabel];
    
    loselabel = [[CCLabelTTF alloc] initWithString:@"Losses" fontName:@"Helvetica" fontSize:30*screenMultiplier];
    loselabel.position = ccp(size.width/2+60*screenMultiplier, size.height-130*screenMultiplier);
    [self addChild:loselabel];
    
    wincount = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i",[GameKitConnector sharedConnector].wins] fontName:@"Helvetica" fontSize:30*screenMultiplier];
    wincount.position = ccp(size.width/2-60*screenMultiplier, size.height-160*screenMultiplier);
    [self addChild:wincount];
    
    losecount = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i",[GameKitConnector sharedConnector].loses] fontName:@"Helvetica" fontSize:30*screenMultiplier];
    losecount.position = ccp(size.width/2+60*screenMultiplier, size.height-160*screenMultiplier);
    [self addChild:losecount];
    

//		[self addChild: highscore];
    
    
    reloads=0;
    
    /* CCLabelTTF *friends = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Weekly Friend Highscores",points] fontName:@"Helvetica" fontSize:28];
     friends.position =  ccp( size.width /2 , 160);
     [self addChild: friends];
     CCLabelTTF *friends1 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"1. Frank - 450 points"] fontName:@"Helvetica" fontSize:28];
     friends1.position =  ccp( size.width /2 , 130);
     [self addChild: friends1];
     CCLabelTTF *friends2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"2. Phil - 370 points"] fontName:@"Helvetica" fontSize:28];
     friends2.position =  ccp( size.width /2 , 100);
     [self addChild: friends2];
     CCLabelTTF *friends3 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"3. Louis - 280 points"] fontName:@"Helvetica" fontSize:28];
     friends3.position =  ccp( size.width /2 , 70);
     [self addChild: friends3];*/
    [[GameCenter sharedGameCenter] saveAchievements];

	}
	return self;
}

/*
- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error{
  reloads++;
  if(reloads>20){
    return;
  }
  [banner loadRequest:[GADRequest request]];
  
}

- (void)adViewDidReceiveAd:(GADBannerView *)view{

}*/
/*
 - (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
 //CCScene * newScene = [GameLayer scene];
 //[[CCDirector sharedDirector] replaceScene:newScene];
 }*/

-(void)reset:(id)sender{
 // NSLog(@"Reset");
  [TestFlight passCheckpoint:@"Play Multiplayer Again"];
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  [app makeBanner];
  CCScene * newScene = [MultiplayerLayer scene];
  [[CCDirector sharedDirector] replaceScene:newScene];
}

-(void)menu:(id)sender{
    
  [[GameKitConnector sharedConnector] disconnect];
  [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
}




-(void)setMaxRank:(NSInteger)rank{
  
}

-(void)setCurrentRank:(NSInteger)rank{
  
}


-(void)dealloc{
  CCLOG(@"Dealloc %@",self);
  banner.delegate = nil;
  [banner removeFromSuperview];
  
}


@end
