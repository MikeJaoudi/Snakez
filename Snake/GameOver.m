//
//  GameOver.m
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import "GameOver.h"
#import "AppDelegate.h"
#import "ClassicLayer.h"
#import "MainMenu.h"
#import "GameCenter.h"

@implementation GameOver
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOver *layer = [GameOver node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(54, 54, 57, 255)])) {
    self.isTouchEnabled=YES;
		// create and initialize a Label
    
    CGSize size = [[CCDirector sharedDirector] winSize];

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    viewController=app.navController.topViewController;
    
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
          screenMultiplier = 2.2;
        }
        else{
          screenMultiplier = 1;
        }
        
   banner = [app getBanner];
    banner.frame = CGRectMake(size.width/2-banner.frame.size.width/2, size.height-banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);
        [viewController.view addSubview:banner];
       // [RevMobAds showPopupWithDelegate:nil];
//[RevMobAds showBannerAdWithFrame:CGRectMake(80, 270, 320, 50) withDelegate:nil withSpecificOrientations:UIInterfaceOrientationLandscapeLeft,UIInterfaceOrientationLandscapeRight,nil];
        
  
    
    item = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Play Again" fontName:@"Helvetica" fontSize:36*screenMultiplier] target:self selector:@selector(reset:)];
		item.position = ccp(-item.contentSize.width/2-40, 0);
    
    item2 = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Main Menu" fontName:@"Helvetica" fontSize:36*screenMultiplier] target:self selector:@selector(menu:)];
		item2.position = ccp(item2.contentSize.width/2+40, 0);
    
    [item setIsEnabled:YES];
    [item2 setIsEnabled:YES];
    
    CCMenu *menu = [CCMenu menuWithItems:item, item2,nil];
    menu.position = ccp(size.width/2, banner.frame.size.height*1.5);
    [self addChild:menu];
    
    gameOver = [[CCLabelTTF  alloc] initWithString:@"Game Over" fontName:@"Helvetica" fontSize:52*screenMultiplier];
    gameOver.position =  ccp( size.width /2 , size.height-40*screenMultiplier);
    [self addChild:gameOver];
    
    NSInteger points=app.score;
    NSString *highscoreString;
    if([app speed]==kEasySpeed){
      highscoreString = @"highscoreeasy";
      [[GameCenter sharedGameCenter] reportScore:points forLeaderboard:@"easy_leaderboard"];
    }
    else if([app speed]==kNormalSpeed){
      highscoreString = @"highscore";
      [[GameCenter sharedGameCenter] reportScore:points forLeaderboard:@"normal_leaderboard"];
    }
    else if([app speed]==kHardSpeed){
        highscoreString = @"highscorehard";
      [[GameCenter sharedGameCenter] reportScore:points forLeaderboard:@"hard_leaderboard"];

    }
    if ([[NSUserDefaults standardUserDefaults] integerForKey:highscoreString]<points)
    {
      [[NSUserDefaults standardUserDefaults] setInteger:points forKey:highscoreString];
    }
    
    
    
    score = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"You scored %i points", points] fontName:@"Helvetica" fontSize:40*screenMultiplier];
		score.position =  ccp( size.width /2 , size.height-100*screenMultiplier);
		[self addChild: score];
    
//    TFLog(@"Scored:%i Highscore:%i",app.score,[[NSUserDefaults standardUserDefaults] integerForKey:highscoreString]);
    highscore = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"CHANGE ME!"] fontName:@"Helvetica" fontSize:30*screenMultiplier];
    [highscore setHorizontalAlignment:kCCTextAlignmentCenter];

    if([app speed]==kEasySpeed){
      [highscore setString:[NSString stringWithFormat:@"Easy Highscore : %i points",[[NSUserDefaults standardUserDefaults] integerForKey:highscoreString]]];
    }
    else if([app speed]==kNormalSpeed){
      [highscore setString:[NSString stringWithFormat:@"Normal Highscore : %i points",[[NSUserDefaults standardUserDefaults] integerForKey:highscoreString]]];

    }
    else if([app speed]==kHardSpeed){
      [highscore setString:[NSString stringWithFormat:@"Hard Highscore : %i points",[[NSUserDefaults standardUserDefaults] integerForKey:highscoreString]]];

    }
		highscore.position =  ccp( size.width /2 , size.height-150*screenMultiplier);
		[self addChild: highscore];
    
    
    facebook = [[CCMenuItemImage alloc] initWithNormalImage:@"facebook.png" selectedImage:nil disabledImage:nil target:self selector:@selector(postToFacebook)];
    facebook.position = ccp(facebook.contentSize.width/2+4*screenMultiplier, 0);
    twitter = [[CCMenuItemImage alloc] initWithNormalImage:@"twitter.png" selectedImage:nil disabledImage:nil target:self selector:@selector(postToTwitter)];
    twitter.position = ccp(-twitter.contentSize.width/2-4*screenMultiplier, 0);
    
    if(NSClassFromString(@"SLComposeViewController") != nil){
       shareMenu = [[CCMenu alloc] initWithArray:@[facebook, twitter]];
    }
    else if(NSClassFromString(@"TWTweetComposeViewController") != nil){
      shareMenu = [[CCMenu alloc] initWithArray:@[twitter]];
      twitter.position = ccp(0, 0);
    }
    else{
      shareMenu = [[CCMenu alloc] initWithArray:@[]];
    }
    shareMenu.position = ccp(size.width/2, size.height-190*screenMultiplier);
    [self addChild:shareMenu];
    
    reloads=0;
    [[GameCenter sharedGameCenter] saveAchievements];
	}
	return self;
}

-(void)postToFacebook{
  [self postToNetwork:SLServiceTypeFacebook];

}

-(void)postToTwitter{
  if(NSClassFromString(@"SLComposeViewController") != nil){
    [self postToNetwork:SLServiceTypeTwitter];
  }
  else if(NSClassFromString(@"TWTweetComposeViewController") != nil){
    TWTweetComposeViewController *sheet = [[TWTweetComposeViewController alloc] init];
    
    [sheet addImage:[self screenshot]];

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *difficulty;
    if([app speed]==kHardSpeed){
      difficulty = @"Hard";
    }
    else if([app speed]==kNormalSpeed){
      difficulty = @"Normal";
      
    }
    else{
      difficulty = @"Easy";
    }
    
    [sheet setInitialText:[NSString stringWithFormat:@"I got %i points in Snakez on %@! Beat that! https://itunes.apple.com/us/app/snakez/id517540318?mt=8",app.score, difficulty]];
    

    [app.navController presentModalViewController:sheet animated:YES];
    
    }
}

-(void)postToNetwork:(NSString*)network{
  SLComposeViewController *sheet = [SLComposeViewController composeViewControllerForServiceType:network];
  [sheet addImage:[self screenshot]];
  
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

  NSString *difficulty;
  if([app speed]==kHardSpeed){
    difficulty = @"Hard";
  }
  else if([app speed]==kNormalSpeed){
    difficulty = @"Normal";
    
  }
  else{
    difficulty = @"Easy";
  }
  
  [sheet setInitialText:[NSString stringWithFormat:@"I got %i points in Snakez on %@! Beat that! https://itunes.apple.com/us/app/snakez/id517540318?mt=8",app.score, difficulty]];
  
  [app.navController presentModalViewController:sheet animated: YES];
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
}
*/
-(void)reset:(id)sender{
 // NSLog(@"Reset");
  //[TestFlight passCheckpoint:@"Play Classic Again"];
  CCScene * newScene = [ClassicLayer scene];
  [[CCDirector sharedDirector] replaceScene:newScene];
    //[RevMobAds deactivateBannerAd];
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

  if([app speed]==kHardSpeed){
    [TestFlight passCheckpoint:@"Play Hard Classic Again"];
  }
  else if([app speed]==kNormalSpeed){
    [TestFlight passCheckpoint:@"Play Normal Classic Again"];
    
  }
  else{
    [TestFlight passCheckpoint:@"Play Easy Classic Again"];
  }
}

-(void)menu:(id)sender{
  [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
   // [RevMobAds deactivateBannerAd];
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

-(UIImage*) screenshot
{
  [CCDirector sharedDirector].nextDeltaTimeZero = YES;
  
  CGSize winSize = [CCDirector sharedDirector].winSize;
  CCRenderTexture* rtx =
  [CCRenderTexture renderTextureWithWidth:winSize.width
                                   height:winSize.height];
  [rtx begin];
  [self visit];
  [rtx end];
  
  return [rtx getUIImage];}

@end
