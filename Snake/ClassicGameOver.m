//
//  ClassicGameOver.m
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright 2011 Mike Jaoudi. All rights reserved.
//

#import "ClassicGameOver.h"
#import "AppDelegate.h"
#import "ClassicLayer.h"
#import "MainMenu.h"

@interface ClassicGameOver()

- (void)postToFacebook;
- (void)postToTwitter;
- (void)postToNetwork:(NSString*)network;

- (UIImage*) screenshot;

@end

@implementation ClassicGameOver  {
    CCLabelTTF *_score;
    CCLabelTTF *_gameOver;
    CCLabelTTF *_highscore;
    
    CCMenu *_shareMenu;
    CCMenuItemImage *_facebook;
    CCMenuItemImage *_twitter;
}

+ (CCScene *) scene {
	CCScene *scene = [CCScene node];
	ClassicGameOver *layer = [ClassicGameOver node];

	[scene addChild:layer];
	return scene;
}

- (id)init {
    self = [super init];
    if(!self) return nil;

    CGSize size = [[CCDirector sharedDirector] winSize];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    _gameOver = [[CCLabelTTF  alloc] initWithString:@"Game Over" fontName:HEADERFONT fontSize:52 * _screenMultiplier];
    _gameOver.position = ccp( size.width / 2 , size.height - 40 * _screenMultiplier);
    [self addChild:_gameOver];

    NSInteger points = app.score;
    NSString *highscoreString;

    switch ([app speed]) {
        case kEasySpeed:
            highscoreString = @"highscoreeasy";
            [[GameCenter sharedGameCenter] reportScore:points forLeaderboard:@"easy_leaderboard"];
            break;

        case kNormalSpeed:
            highscoreString = @"highscore";
            [[GameCenter sharedGameCenter] reportScore:points forLeaderboard:@"normal_leaderboard"];
            break;

        case kHardSpeed:
            highscoreString = @"highscorehard";
            [[GameCenter sharedGameCenter] reportScore:points forLeaderboard:@"hard_leaderboard"];
            break;
    }

    if ([[NSUserDefaults standardUserDefaults] integerForKey:highscoreString] < points) {
        [[NSUserDefaults standardUserDefaults] setInteger:points forKey:highscoreString];
    }

    _score = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"You scored %i points", points] fontName:MENUFONT fontSize:40*_screenMultiplier];
    _score.position =  ccp( size.width /2 , size.height -100 * _screenMultiplier);
    [self addChild: _score];


    _highscore = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"CHANGE ME!"] fontName:MENUFONT fontSize:30*_screenMultiplier];
    [_highscore setHorizontalAlignment:kCCTextAlignmentCenter];

    NSInteger scoreInterger = [[NSUserDefaults standardUserDefaults] integerForKey:highscoreString];
    switch ([app speed]) {
        case kEasySpeed:
            [_highscore setString:[NSString stringWithFormat:@"Easy Highscore : %i points", scoreInterger]];
            break;

        case kNormalSpeed:
            [_highscore setString:[NSString stringWithFormat:@"Normal Highscore : %i points", scoreInterger]];
            break;

        case kHardSpeed:
            [_highscore setString:[NSString stringWithFormat:@"Hard Highscore : %i points", scoreInterger]];
            break;
    }

    _highscore.position =  ccp( size.width /2 , size.height-150*_screenMultiplier);
    [self addChild: _highscore];


    _facebook = [[CCMenuItemImage alloc] initWithNormalImage:@"facebook.png" selectedImage:nil disabledImage:nil target:self selector:@selector(postToFacebook)];
    _facebook.position = ccp(_facebook.contentSize.width/2+4*_screenMultiplier, 0);
    _twitter = [[CCMenuItemImage alloc] initWithNormalImage:@"twitter.png" selectedImage:nil disabledImage:nil target:self selector:@selector(postToTwitter)];
    _twitter.position = ccp(-_twitter.contentSize.width/2-4*_screenMultiplier, 0);

    if(NSClassFromString(@"SLComposeViewController") != nil){
        _shareMenu = [[CCMenu alloc] initWithArray:@[_facebook, _twitter]];
    }
    else if(NSClassFromString(@"TWTweetComposeViewController") != nil){
        _shareMenu = [[CCMenu alloc] initWithArray:@[_twitter]];
        _twitter.position = ccp(0, 0);
    }
    else{
        _shareMenu = [[CCMenu alloc] initWithArray:@[]];
    }
    _shareMenu.position = ccp(size.width/2, size.height-190*_screenMultiplier);
    [self addChild:_shareMenu];

    [[GameCenter sharedGameCenter] saveAchievements];

    return self;
}

- (void)postToFacebook{
    [self postToNetwork:SLServiceTypeFacebook];
}

- (void)postToTwitter{
    [self postToNetwork:SLServiceTypeTwitter];

}


- (void)reset:(id)sender{

    CCScene * newScene = [ClassicLayer scene];
    [[CCDirector sharedDirector] replaceScene:newScene];

    [Flurry logEvent:@"Play Again"];
}

- (void)dealloc{
    CCLOG(@"Dealloc %@",self);
    _banner.delegate = nil;
    [_banner removeFromSuperview];
}

- (void)postToNetwork:(NSString*)network{
    SLComposeViewController *sheet = [SLComposeViewController composeViewControllerForServiceType:network];
    [sheet addImage:[self screenshot]];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *difficulty;
    switch ([app speed]) {
        case kEasySpeed:
            difficulty = @"Easy";
            break;
            
        case kNormalSpeed:
            difficulty = @"Normal";
            break;
            
        case kHardSpeed:
            difficulty = @"Hard";
            break;
    }
    
    [sheet setInitialText:[NSString stringWithFormat:@"I got %i points in Snakez on %@! Beat that! https://itunes.apple.com/us/app/snakez/id517540318?mt=8", app.score, difficulty]];
    
    [app.navController presentModalViewController:sheet animated: YES];
}

- (UIImage*) screenshot {
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCRenderTexture* rtx =
    [CCRenderTexture renderTextureWithWidth:winSize.width
                                     height:winSize.height];
    [rtx begin];
    [self visit];
    [rtx end];
    
    return [rtx getUIImage];
}

@end
