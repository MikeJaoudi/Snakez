//
//  GameOver.m
//  
//
//  Created by Mike Jaoudi on 2/18/13.
//
//

#import "GameOver.h"
#import "AppDelegate.h"
#import "ClassicLayer.h"
#import "MainMenu.h"

@implementation GameOver{
    CCSprite *_background;
}
+ (CCScene *) scene {
	[NSException exceptionWithName:@"Must Overwrite" reason:@"You must overwrite this class" userInfo:nil];
    
    return NULL;
}

- (id)init {
    self = [super initWithColor:ccc4(54, 54, 57, 255)];
    if(!self) return nil;
    
    [self setTouchEnabled:YES];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        _screenMultiplier = 2.2;
    }
    else{
        _screenMultiplier = 1;
    }
    
    _background = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"MenuBackground.png"]];
    
    int widthDiff = _background.contentSize.width - size.width;
    int heightDiff = _background.contentSize.height - size.height;
    
    
    _background.position = ccp(size.width/2 , size.height/2 - heightDiff/2);
    ccBezierConfig bezier;
    bezier.controlPoint_1 = ccp(size.width/2 - widthDiff/2, size.height/2 + heightDiff/2);
    bezier.controlPoint_2 = ccp(size.width/2 + widthDiff/2, size.height/2 + heightDiff/2);;
    bezier.endPosition = ccp(size.width/2, size.height/2 - heightDiff/2);
    
    id bezierForward = [CCBezierTo actionWithDuration:30 bezier:bezier];
    
    
    [_background runAction:[CCRepeatForever actionWithAction:bezierForward]];
    [self addChild:_background];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _banner = [app getBanner];
    _banner.frame = CGRectMake(size.width/2-_banner.frame.size.width/2, size.height-_banner.frame.size.height, _banner.frame.size.width, _banner.frame.size.height);
    [app.navController.topViewController.view addSubview:_banner];
    
    _playAgain = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Play Again" fontName:MENUFONT fontSize:36*_screenMultiplier] target:self selector:@selector(reset:)];
    _playAgain.position = ccp(-_playAgain.contentSize.width/2-40, 0);
    
    _mainMenu = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Main Menu" fontName:MENUFONT fontSize:36*_screenMultiplier] target:self selector:@selector(menu:)];
    _mainMenu.position = ccp(_mainMenu.contentSize.width/2+40, 0);
    
    [_playAgain setIsEnabled:YES];
    [_mainMenu setIsEnabled:YES];
    
    CCMenu *menu = [CCMenu menuWithItems:_playAgain, _mainMenu, nil];
    menu.position = ccp(size.width / 2, _banner.frame.size.height * 1.6);
    [self addChild:menu];
    

    
    [[GameCenter sharedGameCenter] saveAchievements];
    
    return self;
}

- (void)reset:(id)sender{
}

- (void)menu:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
}



@end
