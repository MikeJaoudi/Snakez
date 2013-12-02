//
//  HelloWorldLayer.m
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright Mike Jaoudi 2011. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "ClassicGameOver.h"
#import "FullScreenControlLayer.h"
#import "DPadControlLayer.h"

@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
// on "init" you need to initialize your instance
-(id) init
{
    //NSLog(@"Start");
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        
        snakeStep = 20;
    }
    else{
        snakeStep = 10;
    }
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(60, 60, 60, 255)])) {
        

        
        [self setTouchEnabled:YES];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            screenMultiplier = 2;
        }
        else{
            screenMultiplier = 1;
        }
        
        
        playArea = [[CCLayerColor alloc] initWithColor:ccc4(29, 29, 31, 255)];
        [playArea setContentSize:CGSizeMake(480*screenMultiplier, 320*screenMultiplier)];
        playArea.position = ccp((size.width-playArea.contentSize.width)/2, (size.height-playArea.contentSize.height)/2);
        [self addChild:playArea z:2];
        
        CCSprite *background = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Background.png"]];
        background.position = ccp(playArea.contentSize.width/2,playArea.contentSize.height/2);
        [playArea addChild:background z:1];
        
        id glowAction = [CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:4.0f opacity:100.0f],[CCFadeTo actionWithDuration:4.0f opacity:250.0f],nil]];
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            CCSprite *glow = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Glow.png"]];
            glow.position = ccp(size.width/2,size.height/2);
            [self addChild:glow z:0];
            
            [glow runAction:glowAction];
        }
        else{
            CCSprite *leftSideGlow = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"SideGlow.png"]];
            leftSideGlow.position = ccp(leftSideGlow.contentSize.width/2 ,playArea.contentSize.height/2);
            [self addChild:leftSideGlow z:0];
            
            [leftSideGlow runAction:glowAction];
            
            CCSprite *rightSideGlow = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"SideGlow.png"]];
            rightSideGlow.position = ccp(size.width - rightSideGlow.contentSize.width/2 ,playArea.contentSize.height/2);
            rightSideGlow.rotation = 180.0f;
            [self addChild:rightSideGlow z:0];
            
            [rightSideGlow runAction:glowAction];
        }
        
        //controls = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Controls.png"]];
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsDPad){
            controls = [[DPadControlLayer alloc] init];
        }
        else if([[NSUserDefaults standardUserDefaults] integerForKey:@"Control"] == kControlsFullScreen){
            controls = [[FullScreenControlLayer alloc] init];
        }
        [controls setContentSize:size];
        controls.position = ccp((playArea.contentSize.width-size.width)/2, (playArea.contentSize.height-size.height)/2);
        [playArea addChild:controls z:2];
        
        
        
        snake=[[SnakeBody alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"SnakeBody.png"]];
        snake.position=ccp(45*screenMultiplier, 45*screenMultiplier);
        [playArea addChild:snake z:20];
        for (int x=0;x<4; x++){
            [playArea addChild:[snake addBody] z:20];
            
        }
        // NSLog(@"Yup");
        moveStack=[[NSMutableArray alloc] init];
        currentDirection = kRightDirection;
        for (int x=0;x<6; x++){
            [snake addDirection:kRightDirection];
        }
        toAdd=0;
        
        
        
        particleSystem = [CCParticleSystemQuad particleWithFile:@"PickupHit.plist"];
        [playArea addChild:particleSystem z:10];
        
        particleSystem.speed = particleSystem.speed * screenMultiplier;
        particleSystem.speedVar = particleSystem.speedVar * screenMultiplier;
        particleSystem.startSize = particleSystem.startSize * screenMultiplier;
        particleSystem.startSizeVar = particleSystem.startSizeVar * screenMultiplier;
        
        [particleSystem stopSystem];
        
        snakeParticle = [[CCParticleSystemQuad alloc] initWithFile:@"SnakeHit.plist"];
        [playArea addChild:snakeParticle z:10];
        
        snakeParticle.speed = snakeParticle.speed * screenMultiplier;
        snakeParticle.speedVar = snakeParticle.speedVar * screenMultiplier;
        snakeParticle.startSize = snakeParticle.startSize * screenMultiplier;
        snakeParticle.startSizeVar = snakeParticle.startSizeVar * screenMultiplier;
        
        [snakeParticle stopSystem];
        
        
        spawnParticle = [[CCParticleSystemQuad alloc] initWithFile:@"Spawn.plist"];
        
        spawnParticle.speed = spawnParticle.speed * screenMultiplier;
        spawnParticle.speedVar = spawnParticle.speedVar * screenMultiplier;
        spawnParticle.startSize = spawnParticle.startSize * screenMultiplier;
        spawnParticle.startSizeVar = spawnParticle.startSizeVar * screenMultiplier;
        
        [playArea addChild:spawnParticle z:10];
        
        
        [spawnParticle stopSystem];
        
        pickup = [[CCSprite alloc] initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"Pickup.png"]];
        [playArea addChild:pickup z:30];
        
        
        pickup.position = ccp(-100, -100);
        [particleSystem stopSystem];
        
        
        
        ready=NO;
        
        [self schedule:@selector(next:)];
        // NSLog(@"Interval %f for speed %i",(float)([app speed]/60.0f), [app speed]);
        [self schedule:@selector(nextFrame:) interval:([app speed]/60.0f)];
        
        pausedLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Paused"] fontName:@"Helvetica" fontSize:40*screenMultiplier];
        pausedLabel.position=ccp(size.width/2,size.height/2);
        [pausedLabel runAction:[CCHide action]];
        [self addChild:pausedLabel z:2];
        paused=NO;
        hitCorner = 0;
        
        readyl = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Ready"] fontName:@"Helvetica" fontSize:40*screenMultiplier];
        readyl.position = ccp(size.width/2, size.height/2);
        [readyl runAction:[CCHide action]];
        
        go = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"GO!"] fontName:@"Helvetica" fontSize:40*screenMultiplier];
        go.position = ccp(size.width/2, size.height/2);
        [go runAction:[CCHide action]];
        
        
        [self addChild:readyl z:4];
        [self addChild:go z:4];
        
        [app makeBanner];
        
        
    }
	return self;
}

-(void)startGame{
    //NSLog(@"Starting");
    [snake runAction:[CCShow action]];
    
    [readyl runAction:[CCSequence actions:[CCShow action],[CCDelayTime actionWithDuration:1.5], [CCSpawn actions:[CCScaleTo actionWithDuration:.5 scale:4], [CCFadeOut actionWithDuration:.3],nil], [CCScaleTo actionWithDuration:0 scale:1],[CCHide action], [CCFadeIn actionWithDuration:0], nil]];
    
    
    [go runAction:[CCSequence actions:[CCHide action],[CCDelayTime actionWithDuration:2],[CCShow action],[CCCallFunc actionWithTarget:self selector:@selector(setReady)], [CCDelayTime actionWithDuration:1.5], [CCFadeOut actionWithDuration:.3],[CCHide action],[CCFadeIn actionWithDuration:0], nil]];
}

-(void)setReady{
    moved=NO;
    ready=YES;
    startTime = [[NSDate alloc] init];
}

-(void)next:(ccTime)dt{
    //  NSLog(@"Tick");
    if (toAdd>0) {
        toAdd--;
        points++;
        scorecounter.string = [NSString stringWithFormat:@"Points: %i", points];
    }
}

-(void)nextFrame:(ccTime)dt{
    //NSLog(@"Frame");
    if(!ready){
        return;
    }
    
    
    
    // frame++;
    //frame = frame % interval;
    //if(frame != 0){
    //  return;
    //}
    
    if([moveStack count]>0){
        currentDirection = [[moveStack objectAtIndex:0] intValue];
        [moveStack removeObjectAtIndex:0];
        [snake addDirection:currentDirection];

    }
    if([[[snake getNext] getNext] collidedWith:snake]){
        [self hitTail];
        [self endGame];
        return;
    }
    
    if( CGRectIntersectsRect([snake boundingBox], [pickup boundingBox]) ) {
        [self hitPickup];
    }
    
    
    if(snake.position.x<0||snake.position.x>playArea.contentSize.width||snake.position.y>playArea.contentSize.height||snake.position.y<0){
        [self endGame];
        return;
    }
    hitCorner--;
    if(hitCorner==1){
        [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"corner" percentComplete:100.0f];
        hitCorner = 0;
    }
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!ready){
        return;
    }
    moved=YES;
    for (UITouch * touch in touches) {
        CGPoint location = [self convertTouchToNodeSpace:touch];
        [controls getDirectionForPosition:location Stack:moveStack Current:currentDirection];
    }
}


-(void)gameOver{
    ready=NO;
    [self recordTime];
    [self didMove];
    
}
-(void)recordTime{
    if(startTime==nil){ return; }
    NSTimeInterval time = -[startTime timeIntervalSinceNow];
    NSTimeInterval total = time + [[NSUserDefaults standardUserDefaults] doubleForKey:@"timeelapsed"];
    [[NSUserDefaults standardUserDefaults] setDouble:total forKey:@"timeelapsed"];
    // NSLog(@"Time Played %f",[[NSUserDefaults standardUserDefaults] doubleForKey:@"timeelapsed"]);
    // NSLog(@"This Game:%f",time);
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"10mins" percentComplete:(float)(100*((total/60)/10))];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"30mins" percentComplete:(float)(100*((total/60)/30))];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"60mins" percentComplete:(float)(100*((total/60)/60))];
    
    if(time>=300.0){
        [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"stayalive" percentComplete:100.0f];
    }
    
    
}

-(void)didMove{
    if(!moved){
        [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"nomove" percentComplete:100.0f];
    }
}

-(void)goToGameOver{
  CCScene *gameOverScene = [ClassicGameOver scene];
  [[CCDirector sharedDirector] replaceScene:gameOverScene];
}


-(void)placePickup{
    particleSystem.position=ccp(pickup.position.x, pickup.position.y);
    [particleSystem resetSystem];
    
    pickup.position=ccp(((arc4random()%48)*10+5)*screenMultiplier, ((arc4random()%32)*10+5)*screenMultiplier);
    while ([snake collidedWith:pickup]){
        pickup.position=ccp(((arc4random()%48)*10+5)*screenMultiplier, ((arc4random()%32)*10+5)*screenMultiplier);
    }
    spawnParticle.position=ccp(pickup.position.x, pickup.position.y);
    [spawnParticle resetSystem];
}

-(void)addToPickup{
    int number=[[NSUserDefaults standardUserDefaults] integerForKey:@"pickups"]+1;
    [[NSUserDefaults standardUserDefaults] setInteger:number forKey:@"pickups"];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"1pickup" percentComplete:(float)(100*(number/1))];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"20pickup" percentComplete:100*((float)number/20)];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"50pickup" percentComplete:100*((float)number/50)];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"100pickup" percentComplete:100*((float)number/100)];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"250pickup" percentComplete:100*((float)number/250)];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"500pickup" percentComplete:100*((float)number/500)];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"1000pickup" percentComplete:100*((float)number/1000)];
    
    
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    CCLOG(@"Dealloc %@",self);
    
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [snake releaseAll];
    
}

-(void)hitPickup{
    for (int x=0;x<5; x++){
        [playArea addChild:[snake addBody] z:20];
    }
    if (pickup.position.x==5||pickup.position.x==475) {
        if(pickup.position.y==5||pickup.position.y==315){
            hitCorner = 3;
        }
    }
    [self addToPickup];
    [self placePickup];
}

-(void)endGame{
    [snake runAction:[CCHide action]];
    [self gameOver];
}

-(void)hitTail{
    
    if(CGRectIntersectsRect([snake boundingBox], [[snake getLast] boundingBox])){
        [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"circle" percentComplete:100.0f];
    }
    
}





@end
