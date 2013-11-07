//
//  AppDelegate.h
//  Snake
//
//  Created by Mike Jaoudi on 9/9/11.
//  Copyright Mike Jaoudi 2011. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GADBannerView.h"


#define kHardSpeed 4
#define kNormalSpeed 6
#define kEasySpeed 8


// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate, GADBannerViewDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;
  
	CCDirectorIOS	*__unsafe_unretained director_;							// weak ref
  
  NSInteger score;

 GADBannerView *banner;
  int tries;

}

-(void)makeBanner;
-(GADBannerView*)getBanner;

@property (nonatomic) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (unsafe_unretained, readonly) CCDirectorIOS *director;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger speed;
@property (nonatomic) NSInteger wins;

@end

