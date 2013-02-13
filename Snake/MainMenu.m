//
//  MainMenu.m
//  Snake
//
//  Created by Mike Jaoudi on 9/12/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import "MainMenu.h"
#import "ClassicLayer.h"
#import "MultiplayerLayer.h"

@implementation MainMenu
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenu *layer = [MainMenu node];
	
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
        [self setTouchEnabled:YES];
		// create and initialize a Label
    size = [[CCDirector sharedDirector] winSize];
  
    int c = [[NSUserDefaults standardUserDefaults] integerForKey:@"Control"];
    if(c == 0){
      if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        [[NSUserDefaults standardUserDefaults] setInteger:kControlsDPad forKey:@"Control"];
      }
      else{
        [[NSUserDefaults standardUserDefaults] setInteger:kControlsFullScreen forKey:@"Control"];
      }
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
      fontSize = 110;
      titleHeight = 640;
      detailSize = 80;
    }
    else{
      titleHeight = 272;
      fontSize = 45;
      detailSize = 40;
    }
    aboutText = [[CCLabelTTF alloc] initWithString:@"Snakez created and programmed by\n Mike Jaoudi ©2013.\n\nSpecial thanks to Orta Therox, Cole Krug, Kuntal Bhowmick, Jessica Korsgård, Pierson Andreas, Louis Bedford, Kane Karsteter-Mckernan, Jake Jarvis and Josh Vickerson" fontName:@"Helvetica" fontSize:detailSize/2 dimensions:CGSizeMake(size.width-3*fontSize, 5*fontSize) hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap];
    aboutText.position = ccp(-1000,-1000);
    
    [aboutText runAction:[CCHide action]];
    [self addChild:aboutText];
    
    
    leaderboard = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Leaderboards" fontName:@"Helvetica" fontSize:detailSize] target:self selector:@selector(leaderboard)];
		leaderboard.position = ccp(0, detailSize/2);
    
    achievements = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Achievements" fontName:@"Helvetica" fontSize:detailSize] target:self selector:@selector(achievements)];
		achievements.position = ccp(0, -detailSize/2);
    
    
		gcMenu = [CCMenu menuWithItems:leaderboard, achievements, nil];
		gcMenu.position = ccp(-1000, -1000);
    [gcMenu runAction:[CCFadeOut actionWithDuration:0]];
    [gcMenu runAction:[CCHide action]];
		[self addChild:gcMenu];
    
    //  classic = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Classic" fontName:@"Helvetica" fontSize:45] target:self selector:@selector(classic)];
    classic = [[CCMenuItemFont alloc] initWithString:@"Classic" target:self selector:@selector(classic)];
    classic.position = ccp(0, 2*(fontSize+5));
    [classic setFontSize:fontSize];
    [classic setFontName:@"Helvetica"];
    
    multiplayer = [[CCMenuItemFont alloc] initWithString:@"Multiplayer" target:self selector:@selector(multiplayer)];
		multiplayer.position = ccp(0, 1*(fontSize+5));
    [multiplayer setFontSize:fontSize];
    [multiplayer setFontName:@"Helvetica"];
    
    gamecenter = [[CCMenuItemFont alloc] initWithString:@"Game Center" target:self selector:@selector(gamecenter)];
		gamecenter.position = ccp(0, 0);
    [gamecenter setFontSize:fontSize];
    [gamecenter setFontName:@"Helvetica"];
    
    controls = [[CCMenuItemFont alloc] initWithString:@"Controls" target:self selector:@selector(controls)];
		controls.position = ccp(0, -1*(fontSize+5));
    [controls setFontSize:fontSize];
    [controls setFontName:@"Helvetica"];

    about = [[CCMenuItemFont alloc] initWithString:@"About" target:self selector:@selector(about)];
		about.position = ccp(0, -2*(fontSize+5));
    [about setFontSize:fontSize];
    [about setFontName:@"Helvetica"];
    
    
		mainMenu = [CCMenu menuWithItems:classic, multiplayer, controls, gamecenter, about,nil];
		mainMenu.position = ccp(size.width/2, size.height/2);
		[self addChild:mainMenu];
    
    easy = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Easy" fontName:@"Helvetica" fontSize:detailSize] target:self selector:@selector(easy)];
		easy.position = ccp(0, detailSize+10);
		
    
    normal = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Normal" fontName:@"Helvetica" fontSize:detailSize] target:self selector:@selector(normal)];
		normal.position = ccp(0, 0);
    
    hard = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Hard" fontName:@"Helvetica" fontSize:detailSize] target:self selector:@selector(hard)];
		hard.position = ccp(0, -detailSize-10);
    
    
		difficulty = [CCMenu menuWithItems:easy, normal, hard, nil];
		difficulty.position = ccp(-1000, -1000);
    [difficulty runAction:[CCFadeOut actionWithDuration:0]];
    [difficulty runAction:[CCHide action]];
    
		[self addChild:difficulty];
    
    
    
    menuState = kMenuMain;
    
    
    //version = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Version %@ Build %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] fontName:@"Helvetica" fontSize:14];
    version = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] fontName:@"Helvetica" fontSize:fontSize/3];
    version.position = ccp(size.width-version.contentSize.width/2-5, version.contentSize.height/2);
    [self addChild:version];
    
    name = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Mike Jaoudi ©2013"] fontName:@"Helvetica" fontSize:fontSize/3];
    name.position = ccp(5+name.contentSize.width/2, name.contentSize.height/2);
    [self addChild:name];
    
    
    titleLabel = [[CCLabelTTF alloc] initWithString:@"Classic" fontName:@"Helvetica" fontSize:fontSize];
    titleLabel.position = ccp(-100, -100);
    [titleLabel runAction:[CCHide action]];
    [self addChild:titleLabel];
    
    //        classicLabel.position = ccp(classic.position.x+mainMenu.position.x, classic.position.y+mainMenu.position.y);
    //      [classicLabel runAction:[CCHide action]];
    //    [self addChild:classicLabel];
    
    
    
    dpad = [[CCMenuItemImage alloc] initWithNormalImage:@"DPadMenu.png" selectedImage:nil disabledImage:nil target:self selector:@selector(dpadClicked)];
    dpad.position = ccp((dpad.contentSize.width*1.2)/2, 0);
    
    fullScreen = [[CCMenuItemImage alloc] initWithNormalImage:@"FullScreenMenu.png" selectedImage:nil disabledImage:nil target:self selector:@selector(fullScreenClicked)];
    fullScreen.position = ccp(-(fullScreen.contentSize.width*1.2)/2, 0);
    controlMenu = [[CCMenu alloc] initWithArray:@[dpad,fullScreen]];
    controlMenu.position = ccp(-1000, -1000);
    [controlMenu runAction:[CCHide action]];
    [self addChild:controlMenu];

	}
	return self;
}

-(void)dpadClicked{
  if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsDPad){
    return;
  }
  [[NSUserDefaults standardUserDefaults] setInteger:kControlsDPad forKey:@"Control"];

  [fullScreen stopAllActions];
  [fullScreen runAction:[CCScaleTo actionWithDuration:.2 scale:1.0]];
  [dpad runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:.6 scale:1.2] two:[CCScaleTo actionWithDuration:.6 scale:.9]]]];

    [self controlToMain];
}

-(void)fullScreenClicked{
  if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsFullScreen){
    return;
  }
  
  [[NSUserDefaults standardUserDefaults] setInteger:kControlsFullScreen forKey:@"Control"];

  [dpad stopAllActions];
  [dpad runAction:[CCScaleTo actionWithDuration:.2 scale:1.0]];

  [fullScreen runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:.6 scale:1.2] two:[CCScaleTo actionWithDuration:.6 scale:0.9]]]];
    [self controlToMain];
}

-(void)classic{
  [titleLabel stopAllActions];
  difficulty.position = ccp(size.width/2, size.height/2);

  [mainMenu runAction:[CCHide action]];
  titleLabel.position = ccp(classic.position.x+mainMenu.position.x, classic.position.y+mainMenu.position.y);
  [titleLabel setString:@"Classic"];
  
  [titleLabel runAction:[CCShow action]];
  [titleLabel runAction:[CCMoveTo actionWithDuration:.5 position:ccp(classic.position.x+mainMenu.position.x, titleHeight)]];
  [difficulty runAction:[CCShow action]];
  
  [difficulty runAction:[CCFadeIn actionWithDuration:.5]];
  menuState = kMenuClassic;
}

-(void)controls{
  [titleLabel stopAllActions];

  [mainMenu runAction:[CCHide action]];
  controlMenu.position = ccp(size.width/2, size.height/2);
  [controlMenu runAction:[CCShow action]];
  [controlMenu runAction:[CCFadeIn actionWithDuration:.5]];

  titleLabel.position = ccp(controls.position.x+mainMenu.position.x, controls.position.y+mainMenu.position.y);
  [titleLabel setString:controls.label.string];
  
  [titleLabel runAction:[CCShow action]];
  [titleLabel runAction:[CCMoveTo actionWithDuration:.5 position:ccp(classic.position.x+mainMenu.position.x, titleHeight)]];

  if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsDPad){
      [dpad runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:.6 scale:1.2] two:[CCScaleTo actionWithDuration:.6 scale:0.9]]]];
  }
  else{
      [fullScreen runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:.6 scale:1.2] two:[CCScaleTo actionWithDuration:.6 scale:0.9]]]];
  }
  
  menuState = kMenuControl;
}

-(void)multiplayer{
  [TestFlight passCheckpoint:@"Multiplayer"];
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  
  [app setSpeed:kNormalSpeed];
  
  [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:0.5 scene:[MultiplayerLayer scene]]];
  
}

-(void)gamecenter{
  if(![[GameCenter sharedGameCenter] isConnected]){
    [[GameCenter sharedGameCenter] authenticate];
    return;
  }
  [titleLabel stopAllActions];
  gcMenu.position = ccp(size.width/2, size.height/2+detailSize);

  [mainMenu runAction:[CCHide action]];
  titleLabel.position = ccp(gamecenter.position.x+mainMenu.position.x, gamecenter.position.y+mainMenu.position.y);
  [titleLabel setString:gamecenter.label.string];
  [titleLabel runAction:[CCShow action]];
  [titleLabel runAction:[CCMoveTo actionWithDuration:.5 position:ccp(gamecenter.position.x+gcMenu.position.x, titleHeight)]];
  [gcMenu runAction:[CCShow action]];
  
  [gcMenu runAction:[CCFadeIn actionWithDuration:.5]];
  
  menuState = kMenuGameCenter;
}

-(void)leaderboard{
  leaderboardController = [[GKLeaderboardViewController alloc] init];
  if (leaderboardController != nil)
  {
    leaderboardController.category=nil;
    leaderboardController.leaderboardDelegate = self;
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [app.navController presentModalViewController: leaderboardController animated: YES];
    
  }
  
}

-(void)achievements{
  
  achievementsController = [[GKAchievementViewController alloc] init];
  if (achievementsController != nil)
  {
    achievementsController.achievementDelegate = self;
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.navController.topViewController presentModalViewController: achievementsController animated: YES];
  }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
  [leaderboardController dismissModalViewControllerAnimated:YES];
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
  [achievementsController dismissModalViewControllerAnimated:YES];
  
}
-(void)about{
    aboutText.position = ccp(size.width/2,size.height/2-fontSize);
  
  [mainMenu runAction:[CCHide action]];
  [titleLabel stopAllActions];
  titleLabel.position = ccp(about.position.x+mainMenu.position.x, about.position.y+mainMenu.position.y);
  [titleLabel setString:about.label.string];
  [titleLabel runAction:[CCShow action]];
  [aboutText runAction:[CCShow action]];
  [titleLabel runAction:[CCMoveTo actionWithDuration:.5 position:ccp(about.position.x+mainMenu.position.x, titleHeight)]];
  
  [aboutText runAction:[CCFadeIn actionWithDuration:.5]];
  menuState = kMenuAbout;
}

-(void)easy{
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  [app setSpeed:kEasySpeed];
  
  [TestFlight passCheckpoint:@"Easy"];
  [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:0.5 scene:[ClassicLayer scene]]];
}
-(void)normal{
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  [app setSpeed:kNormalSpeed];
  
  
  [TestFlight passCheckpoint:@"Normal"];
  [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:0.5 scene:[ClassicLayer scene]]];
}
-(void)hard{
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  [app setSpeed:kHardSpeed];
  
  
  [TestFlight passCheckpoint:@"Hard"];
  
  [[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:0.5 scene:[ClassicLayer scene]]];
}

-(void)backToMain{
  [titleLabel runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(classic.position.x+mainMenu.position.x, classic.position.y+mainMenu.position.y)],[CCHide action],nil]];
  [difficulty runAction:[CCSequence actions:[CCHide action],nil]];
  [mainMenu runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:.5],nil]];
  [classic runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:.5],[CCShow action],nil]];
  
  
  menuState = kMenuMain;
}

-(void)controlToMain{
  [dpad stopAllActions];
  [dpad runAction:[CCScaleTo actionWithDuration:0 scale:1.0]];
  
  [fullScreen stopAllActions];
  [fullScreen runAction:[CCScaleTo actionWithDuration:0 scale:1.0]];
  [titleLabel runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(controls.position.x+mainMenu.position.x, controls.position.y+mainMenu.position.y)],[CCHide action],nil]];
  [mainMenu runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:.5],nil]];
  [controls runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:.5],[CCShow action],nil]];
  [controlMenu runAction:[CCHide action]];
  
  menuState = kMenuMain;
}

-(void)aboutToMain{
  [titleLabel runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(about.position.x+mainMenu.position.x, about.position.y+mainMenu.position.y)],[CCHide action],nil]];
  [aboutText runAction:[CCSequence actions:[CCHide action],nil]];
  
  [mainMenu runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:.5],nil]];
  [about runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:.5],[CCShow action],nil]];
  
  
  menuState = kMenuMain;
}

-(void)gcToMain{
  [titleLabel runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(gamecenter.position.x+mainMenu.position.x, gamecenter.position.y+mainMenu.position.y)],[CCHide action],nil]];
  [gcMenu runAction:[CCSequence actions:[CCHide action],nil]];
  [mainMenu runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:.5],nil]];
  [gamecenter runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:.5],[CCShow action],nil]];
  
  
  menuState = kMenuMain;

}



- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  if(menuState == kMenuMain){ return; }
  for (UITouch * touch in touches) {
    if(menuState == kMenuClassic){
      [self backToMain];
    }
    else if(menuState == kMenuAbout){
      [self aboutToMain];
    }
    else if(menuState == kMenuGameCenter){
      [self gcToMain];
    }
    else if(menuState == kMenuControl){
      [self controlToMain];
    }
    
  }
  
}

-(void)dealloc{
  CCLOG(@"Dealloc %@",self);
  
  
}



@end
