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

@implementation MainMenu{
    CGSize _size;
    
    MenuSelected _menuState;
    
    
    CCMenuItemFont *_classic;
    CCMenuItemFont *_multiplayer;
    CCMenuItemFont *_controls;
    CCMenuItemFont *_gamecenter;
    CCMenuItemFont *_about;
    
    CCMenu *_mainMenu;
    
    
    CCMenuItemLabel *_easy;
    CCMenuItemLabel *_normal;
    CCMenuItemLabel *_hard;
    
    CCMenu *_difficulty;
    
    
    CCMenuItemLabel *_leaderboard;
    CCMenuItemLabel *_achievements;
    
    CCMenu *_gameCenterMenu;
    
    
    CCLabelTTF *_version;
    CCLabelTTF *_name;
    CCLabelTTF *_aboutText;
    CCLabelTTF *titleLabel;
    
    GKLeaderboardViewController *_leaderboardController;
    GKAchievementViewController *_achievementsController;
    
    
    NSInteger _fontSize;
    NSInteger _titleHeight;
    NSInteger _detailSize;
    
    CCMenuItemImage *_dpad;
    CCMenuItemImage *_fullScreen;
    
    CCMenu *_controlMenu;
    
    CCSprite *_background;
    
}

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
        _size = [[CCDirector sharedDirector] winSize];
        
        int c = [[NSUserDefaults standardUserDefaults] integerForKey:@"Control"];
        if(c == 0){
                [[NSUserDefaults standardUserDefaults] setInteger:kControlsDPad forKey:@"Control"];
        }
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            _fontSize = 110;
            _titleHeight = 640;
            _detailSize = 80;
        }
        else{
            _titleHeight = 272;
            _fontSize = 48;
            _detailSize = 40;
        }
        
        _background = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"MenuBackground.png"]];
        
        int widthDiff = _background.contentSize.width - _size.width;
        int heightDiff = _background.contentSize.height - _size.height;
        
        
        _background.position = ccp(_size.width/2 , _size.height/2 - heightDiff/2);
        ccBezierConfig bezier;
        bezier.controlPoint_1 = ccp(_size.width/2 - widthDiff/2, _size.height/2 + heightDiff/2);
        bezier.controlPoint_2 = ccp(_size.width/2 + widthDiff/2, _size.height/2 + heightDiff/2);;
        bezier.endPosition = ccp(_size.width/2, _size.height/2 - heightDiff/2);
        
        id bezierForward = [CCBezierTo actionWithDuration:30 bezier:bezier];
        
        
        [_background runAction:[CCRepeatForever actionWithAction:bezierForward]];
        [self addChild:_background];
        
        [CCMenuItemFont setFontName:MENUFONT];
        
        _aboutText = [[CCLabelTTF alloc] initWithString:@"Snakez created and programmed by\n Mike Jaoudi ©2013.\n\nSpecial thanks to Orta Therox, Cole Krug, Kuntal Bhowmick, Jessica Korsgård, Pierson Andreas, Louis Bedford, Kane Karsteter-Mckernan, Jake Jarvis and Josh Vickerson" fontName:MENUFONT fontSize:_detailSize/2 dimensions:CGSizeMake(_size.width-3*_fontSize, 5*_fontSize) hAlignment:kCCTextAlignmentCenter lineBreakMode:kCCLineBreakModeWordWrap];
        _aboutText.position = ccp(-1000,-1000);
        
        [_aboutText runAction:[CCHide action]];
        [self addChild:_aboutText];
        
        
        _leaderboard = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Leaderboards" fontName:SUBMENUFONT fontSize:_detailSize] target:self selector:@selector(leaderboard)];
		_leaderboard.position = ccp(0, _detailSize + 10);
        
        _achievements = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Achievements" fontName:SUBMENUFONT fontSize:_detailSize] target:self selector:@selector(achievements)];
		_achievements.position = ccp(0, 0);
        
        
		_gameCenterMenu = [CCMenu menuWithItems:_leaderboard, _achievements, nil];
		_gameCenterMenu.position = ccp(-1000, -1000);
        [_gameCenterMenu runAction:[CCFadeOut actionWithDuration:0]];
        [_gameCenterMenu runAction:[CCHide action]];
		[self addChild:_gameCenterMenu];
        
        //  classic = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Classic" fontName:@"Helvetica" fontSize:45] target:self selector:@selector(classic)];
        _classic = [[CCMenuItemFont alloc] initWithString:@"Classic" target:self selector:@selector(classic)];
        _classic.position = ccp(0, 2*(_fontSize+5));
        [_classic setFontSize:_fontSize];
        
        _multiplayer = [[CCMenuItemFont alloc] initWithString:@"Multiplayer" target:self selector:@selector(multiplayer)];
		_multiplayer.position = ccp(0, 1*(_fontSize+5));
        [_multiplayer setFontSize:_fontSize];
        
        _gamecenter = [[CCMenuItemFont alloc] initWithString:@"Game Center" target:self selector:@selector(gamecenter)];
		_gamecenter.position = ccp(0, 0);
        [_gamecenter setFontSize:_fontSize];
        
        _controls = [[CCMenuItemFont alloc] initWithString:@"Controls" target:self selector:@selector(controls)];
		_controls.position = ccp(0, -1*(_fontSize+5));
        [_controls setFontSize:_fontSize];
        
        _about = [[CCMenuItemFont alloc] initWithString:@"About" target:self selector:@selector(about)];
		_about.position = ccp(0, -2*(_fontSize+5));
        [_about setFontSize:_fontSize];
        
		_mainMenu = [CCMenu menuWithItems:_classic, _multiplayer, _controls, _gamecenter, _about,nil];
		_mainMenu.position = ccp(_size.width/2, _size.height/2);
		[self addChild:_mainMenu];
        
        _easy = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Easy" fontName:SUBMENUFONT fontSize:_detailSize] target:self selector:@selector(easy)];
		_easy.position = ccp(0, _detailSize+10);
		
        
        _normal = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Normal" fontName:SUBMENUFONT fontSize:_detailSize] target:self selector:@selector(normal)];
		_normal.position = ccp(0, 0);
        
        _hard = [[CCMenuItemLabel alloc] initWithLabel:[CCLabelTTF labelWithString:@"Hard" fontName:SUBMENUFONT fontSize:_detailSize] target:self selector:@selector(hard)];
		_hard.position = ccp(0, -_detailSize-10);
        
        
		_difficulty = [CCMenu menuWithItems:_easy, _normal, _hard, nil];
		_difficulty.position = ccp(-1000, -1000);
        [_difficulty runAction:[CCFadeOut actionWithDuration:0]];
        [_difficulty runAction:[CCHide action]];
        
		[self addChild:_difficulty];
        
        
        
        _menuState = kMenuMain;
        
        
        //version = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Version %@ Build %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] fontName:@"Helvetica" fontSize:14];
        _version = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] fontName:MENUFONT fontSize:_fontSize/3];
        _version.position = ccp(_size.width-_version.contentSize.width/2-5, _version.contentSize.height/2);
        [self addChild:_version];
        
        _name = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Mike Jaoudi ©2013"] fontName:MENUFONT fontSize:_fontSize/3];
        _name.position = ccp(5+_name.contentSize.width/2, _name.contentSize.height/2);
        [self addChild:_name];
        
        
        titleLabel = [[CCLabelTTF alloc] initWithString:@"Classic" fontName:MENUFONT fontSize:_fontSize];
        titleLabel.position = ccp(-100, -100);
        [titleLabel runAction:[CCHide action]];
        [self addChild:titleLabel];
        
        //        classicLabel.position = ccp(classic.position.x+mainMenu.position.x, classic.position.y+mainMenu.position.y);
        //      [classicLabel runAction:[CCHide action]];
        //    [self addChild:classicLabel];
        
        
        
        _dpad = [[CCMenuItemImage alloc] initWithNormalImage:@"DPadMenu.png" selectedImage:nil disabledImage:nil target:self selector:@selector(dpadClicked)];
        _dpad.position = ccp((_dpad.contentSize.width*1.2)/2, 0);
        
        _fullScreen = [[CCMenuItemImage alloc] initWithNormalImage:@"FullScreenMenu.png" selectedImage:nil disabledImage:nil target:self selector:@selector(fullScreenClicked)];
        _fullScreen.position = ccp(-(_fullScreen.contentSize.width*1.2)/2, 0);
        _controlMenu = [[CCMenu alloc] initWithArray:@[_dpad,_fullScreen]];
        _controlMenu.position = ccp(-1000, -1000);
        [_controlMenu runAction:[CCHide action]];
        [self addChild:_controlMenu];
        
	}
	return self;
}

-(void)dpadClicked{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsDPad){
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:kControlsDPad forKey:@"Control"];
    
    [_fullScreen stopAllActions];
    [_fullScreen runAction:[CCScaleTo actionWithDuration:.2 scale:1.0]];
    [_dpad runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:.6 scale:1.2] two:[CCScaleTo actionWithDuration:.6 scale:.9]]]];
    
    [self controlToMain];
}

-(void)fullScreenClicked{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsFullScreen){
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:kControlsFullScreen forKey:@"Control"];
    
    [_dpad stopAllActions];
    [_dpad runAction:[CCScaleTo actionWithDuration:.2 scale:1.0]];
    
    [_fullScreen runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:.6 scale:1.2] two:[CCScaleTo actionWithDuration:.6 scale:0.9]]]];
    [self controlToMain];
}

-(void)classic{
    [titleLabel stopAllActions];
    _difficulty.position = ccp(_size.width/2, _size.height/2);
    
    [_mainMenu runAction:[CCHide action]];
    titleLabel.position = ccp(_classic.position.x+_mainMenu.position.x, _classic.position.y+_mainMenu.position.y);
    [titleLabel setString:@"Classic"];
    
    [titleLabel runAction:[CCShow action]];
    [titleLabel runAction:[CCMoveTo actionWithDuration:.5 position:ccp(_classic.position.x+_mainMenu.position.x, _titleHeight)]];
    [_difficulty runAction:[CCShow action]];
    
    [_difficulty runAction:[CCFadeIn actionWithDuration:.5]];
    _menuState = kMenuClassic;
}

-(void)controls{
    [titleLabel stopAllActions];
    
    [_mainMenu runAction:[CCHide action]];
    _controlMenu.position = ccp(_size.width/2, _size.height/2);
    [_controlMenu runAction:[CCShow action]];
    [_controlMenu runAction:[CCFadeIn actionWithDuration:.5]];
    
    titleLabel.position = ccp(_controls.position.x+_mainMenu.position.x, _controls.position.y+_mainMenu.position.y);
    [titleLabel setString:_controls.label.string];
    
    [titleLabel runAction:[CCShow action]];
    [titleLabel runAction:[CCMoveTo actionWithDuration:.5 position:ccp(_classic.position.x+_mainMenu.position.x, _titleHeight)]];
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsDPad){
        [_dpad runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:.6 scale:1.2] two:[CCScaleTo actionWithDuration:.6 scale:0.9]]]];
    }
    else{
        [_fullScreen runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:.6 scale:1.2] two:[CCScaleTo actionWithDuration:.6 scale:0.9]]]];
    }
    
    _menuState = kMenuControl;
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
    _gameCenterMenu.position = ccp(_size.width/2, _size.height/2);
    
    [_mainMenu runAction:[CCHide action]];
    titleLabel.position = ccp(_gamecenter.position.x+_mainMenu.position.x, _gamecenter.position.y+_mainMenu.position.y);
    [titleLabel setString:_gamecenter.label.string];
    [titleLabel runAction:[CCShow action]];
    [titleLabel runAction:[CCMoveTo actionWithDuration:.5 position:ccp(_gamecenter.position.x+_gameCenterMenu.position.x, _titleHeight)]];
    [_gameCenterMenu runAction:[CCShow action]];
    
    [_gameCenterMenu runAction:[CCFadeIn actionWithDuration:.5]];
    
    _menuState = kMenuGameCenter;
}

-(void)leaderboard{
    _leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (_leaderboardController != nil)
    {
        _leaderboardController.category=nil;
        _leaderboardController.leaderboardDelegate = self;
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [app.navController presentModalViewController: _leaderboardController animated: YES];
        
    }
    
}

-(void)achievements{
    
    _achievementsController = [[GKAchievementViewController alloc] init];
    if (_achievementsController != nil)
    {
        _achievementsController.achievementDelegate = self;
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.navController.topViewController presentModalViewController: _achievementsController animated: YES];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
    [_leaderboardController dismissModalViewControllerAnimated:YES];
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
    [_achievementsController dismissModalViewControllerAnimated:YES];
    
}
-(void)about{
    _aboutText.position = ccp(_size.width/2,_size.height/2-_fontSize);
    
    [_mainMenu runAction:[CCHide action]];
    [titleLabel stopAllActions];
    titleLabel.position = ccp(_about.position.x+_mainMenu.position.x, _about.position.y+_mainMenu.position.y);
    [titleLabel setString:_about.label.string];
    [titleLabel runAction:[CCShow action]];
    [_aboutText runAction:[CCShow action]];
    [titleLabel runAction:[CCMoveTo actionWithDuration:.5 position:ccp(_about.position.x+_mainMenu.position.x, _titleHeight)]];
    
    [_aboutText runAction:[CCFadeIn actionWithDuration:.5]];
    _menuState = kMenuAbout;
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
    [titleLabel runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(_classic.position.x+_mainMenu.position.x, _classic.position.y+_mainMenu.position.y)],[CCHide action],nil]];
    [_difficulty runAction:[CCSequence actions:[CCHide action],nil]];
    [_mainMenu runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:.5],nil]];
    [_classic runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:.5],[CCShow action],nil]];
    
    
    _menuState = kMenuMain;
}

-(void)controlToMain{
    [_dpad stopAllActions];
    [_dpad runAction:[CCScaleTo actionWithDuration:0 scale:1.0]];
    
    [_fullScreen stopAllActions];
    [_fullScreen runAction:[CCScaleTo actionWithDuration:0 scale:1.0]];
    [titleLabel runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(_controls.position.x+_mainMenu.position.x, _controls.position.y+_mainMenu.position.y)],[CCHide action],nil]];
    [_mainMenu runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:.5],nil]];
    [_controls runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:.5],[CCShow action],nil]];
    [_controlMenu runAction:[CCHide action]];
    
    _menuState = kMenuMain;
}

-(void)aboutToMain{
    [titleLabel runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(_about.position.x+_mainMenu.position.x, _about.position.y+_mainMenu.position.y)],[CCHide action],nil]];
    [_aboutText runAction:[CCSequence actions:[CCHide action],nil]];
    
    [_mainMenu runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:.5],nil]];
    [_about runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:.5],[CCShow action],nil]];
    
    
    _menuState = kMenuMain;
}

-(void)gcToMain{
    [titleLabel runAction:[CCSequence actions:[CCMoveTo actionWithDuration:.5 position:ccp(_gamecenter.position.x+_mainMenu.position.x, _gamecenter.position.y+_mainMenu.position.y)],[CCHide action],nil]];
    [_gameCenterMenu runAction:[CCSequence actions:[CCHide action],nil]];
    [_mainMenu runAction:[CCSequence actions:[CCShow action],[CCFadeIn actionWithDuration:.5],nil]];
    [_gamecenter runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:.5],[CCShow action],nil]];
    
    
    _menuState = kMenuMain;
    
}



- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(_menuState == kMenuMain){ return; }
    for (UITouch * touch in touches) {
        if(_menuState == kMenuClassic){
            [self backToMain];
        }
        else if(_menuState == kMenuAbout){
            [self aboutToMain];
        }
        else if(_menuState == kMenuGameCenter){
            [self gcToMain];
        }
        else if(_menuState == kMenuControl){
            [self controlToMain];
        }
        
    }
    
}

-(void)dealloc{
    CCLOG(@"Dealloc %@",self);
    
    
}



@end
