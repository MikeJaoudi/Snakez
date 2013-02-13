//
//  GameKitConnector.m
//  PingPong
//
//  Created by orta therox on 04/07/2011.
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//



#import "GameKitConnector.h"
#import "GameCenter.h"
#import "AppDelegate.h"
#import "MainMenu.h"
#import "MJAPIKeys.h"


// private non-API related methods
@interface GameKitConnector() 
- (void)decideHost;
@end 



static GameKitConnector *sharedInstance;
@implementation GameKitConnector
@synthesize delegate, peerPicker, session, wins, loses, streak;

+(GameKitConnector*)sharedConnector{
  if(sharedInstance==nil){
    sharedInstance = [[GameKitConnector alloc] init];
  }
  return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
      peerPicker = [[GKPeerPickerController alloc] init];
      peerPicker.delegate = self;
      peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    }
  ignoreInput = false;
  [self setMatchState:kMatchStateWaitingForMatch];
  [self setMatchResult:kResultUnknown];
  self.wins=0;
  self.loses=0;
  
    return self;
}

-(void)startPeerToPeer {
  //Show the connector
	[peerPicker show];
}

-(void)startHostServer {
  isHostServer = YES;
  [peerPicker show];
}


#pragma mark PeerPickerControllerDelegate stuff
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
  if([delegate respondsToSelector:@selector(connectionCancelled)]){
    [delegate connectionCancelled];
  }
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {  
	session = [[GKSession alloc] initWithSessionID:BLUETOOTHKEY displayName:nil sessionMode:GKSessionModePeer];
  return session;
}

/* Notifies delegate that the peer was connected to a GKSession.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)newSession {
 // NSLog(@"Connected");
	// Use a retaining property to take ownership of the session.
  self.session = newSession;
	// Assumes our object will also become the session's delegate.
  self.session.delegate = self;
  [self.session setDataReceiveHandler: self withContext: nil];
	// Remove the picker.
  picker.delegate = nil;
  [picker dismiss];
  
    [self checkConnected];
}

-(void)checkConnected{
    [self sendReliableCommand:@"Connected" withArgument:@"Done"];
  [TestFlight passCheckpoint:@"Multiplayer - Connected!"];
  [self sendVersion];

}

-(void)startMatch{
  if(matchStarted){
    return;
  }
  matchStarted = true;
  //Compare Versions, if different disconnect
//  [self sendVersion];

	// Start your game.
  if (isHostServer) {
  //  NSLog(@"Starting");
      // when emulating host / server over a p2p network
      // there needs to be a way to detemine host / client
      // I do this by a small game of Rock Paper Scissors
    [self decideHost];
  }else{
    [delegate connected];
  }
  [self setMatchState:kMatchStateWaitingToApprove];

}

-(void) sendCommand:(NSString*)command {
  [self sendCommand:command withArgument:@""];
} 


-(void) sendCommand:(NSString*)command withFloat:(float)argument{
  [self sendCommand:command withArgument:[NSString stringWithFormat:@"%f", argument]];
} 

-(void) sendCommand:(NSString*)command withInt:(int)argument{

  [self sendCommand:command withArgument:[NSString stringWithFormat:@"%d", argument]];
} 

-(void) sendReliableCommand:(NSString*)command withInt:(int)argument{
  
  [self sendReliableCommand:command withArgument:[NSString stringWithFormat:@"%d", argument]];
}

-(void) sendCommand:(NSString*)command withArgument:(NSString*)argument{
  if(self.session==NULL||!self.session.available){return;}
  NSError *error;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:command, argument, nil]];
  [self.session sendDataToAllPeers:data withDataMode:GKSendDataUnreliable error:&error];
}

-(void) sendReliableCommand:(NSString*)command withArgument:(NSString*)argument{
  if(self.session==NULL||!self.session.available){return;}
  NSError *error;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:command, argument, nil]];
  [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{
  if(ignoreInput){
    return;
  }
  NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if([array count] == 2){
      
      if([@"Connected" isEqualToString:[array objectAtIndex:0]]){
        [self sendReliableCommand:@"Begin" withArgument:@"Bleh"];
        [self startMatch];
      }
      else if([@"Begin" isEqualToString:[array objectAtIndex:0]]){
        [self startMatch];
      }
      else if([@"_HOST_SERVER" isEqualToString:[array objectAtIndex:0]]){
        //  NSLog(@"HOST SERVER");
        NSString * theirNumber = [array objectAtIndex:1];
         // NSLog(@"Their guess:%i Your guess:%i",[theirNumber intValue],_hostGuess);
        if ( _hostGuess > [theirNumber intValue]) {
          [delegate isHost];
        }else if(_hostGuess==[theirNumber intValue]){
            [self decideHost];
        }
        else{
          [delegate isClient];
          isHostServer = FALSE;
        }
        return;
      }
      
      if([@"_OTHER_VERSION" isEqualToString:[array objectAtIndex:0]]){
        NSString * versionNumber = [array objectAtIndex:1];
        float otherVersion = [versionNumber floatValue];
         float version = MULTIPLAYERVERSION;
     //   NSLog(@"Your Version:%f Other Version:%f",otherVersion, version);
        if(otherVersion<version){
        //  NSLog(@"I am bad");
          UIAlertView* dialog = [[UIAlertView alloc] init];
          [dialog setDelegate:self];
          [dialog setTitle:@"Incompatible Versions"];
          [dialog setMessage:@"Your opponent must upgrade their game in order to play you"];
          [dialog addButtonWithTitle:@"Ok"];
          [dialog show];
          ignoreInput = true;
          [self performSelector:@selector(disconnect) withObject:nil afterDelay:1.0f];
      //    NSLog(@"Finished");
        }
        else if(otherVersion>version){
         // NSLog(@"You are bad");
          UIAlertView* dialog = [[UIAlertView alloc] init];
          [dialog setDelegate:self];
          [dialog setTitle:@"Incompatible Versions"];
          [dialog setMessage:@"You must upgrade your game in order to play your opponent"];
          [dialog addButtonWithTitle:@"Ok"];
          [dialog show];
          
          ignoreInput = true;
          [self performSelector:@selector(disconnect) withObject:nil afterDelay:1.0f];
        }
        return;
      }
      
      if([@"ready" isEqualToString:[array objectAtIndex:0]]){
        if([self getMatchState]==kMatchStateWaitingForOpponent){
          [self setMatchState:kMatchStateWaitingForStart];
          [delegate startMatch];
        }
        else {
          [self setMatchState:kMatchStartWaitingOnLocalPlayer];
        }
        return;
      }
      
      [delegate recievedCommand:[array objectAtIndex:0] withArgument:[array objectAtIndex:1]];
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    
//    if(state == GKPeerStateConnected){
//        NSLog(@"GK Connected");
//    }
//    if(state == GKPeerStateConnecting){
//        NSLog(@"GK Connecting");
//        
//    }
  if(state==GKPeerStateDisconnected){
     //NSLog(@"Other Disconnected");
    [delegate opponentDisconnected];
    [self disconnect];
  }
}

-(void) decideHost {
  _hostGuess =  arc4random() % 10;
  NSString * guess = [NSString stringWithFormat:@"%d", _hostGuess];
  [self sendReliableCommand:@"_HOST_SERVER" withArgument:guess];
    //NSLog(@"Sent host command");
}


-(void)disconnect{
  [session disconnectFromAllPeers];
	session.available = NO;
	[session setDataReceiveHandler: nil withContext: nil];
  sharedInstance.delegate = nil;
  sharedInstance=nil;
	session.delegate = nil;
  CCScene * newScene = [MainMenu scene];
  [[CCDirector sharedDirector] replaceScene:newScene];
  
  
	

}

-(BOOL)isConnected{
  if([[session peersWithConnectionState:GKPeerStateConnected] count]>0){
    return TRUE;
  }
  return FALSE;
}

-(BOOL)isHost{
  return isHostServer;
}

-(void)setMatchState:(MatchState)match{
  if(match == kMatchStateWaitingForOpponent){
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]+2.5;
    [[GameKitConnector sharedConnector] sendReliableCommand:@"ready" withArgument:[NSString stringWithFormat:@"%f",time]];
    
    if(matchState==kMatchStartWaitingOnLocalPlayer){
      [self setMatchState:kMatchStateWaitingForStart];
      [delegate startMatch];
    }
  }
  if(matchState==kMatchStateActive&&match!=kMatchStateGameOver){
    return;
  }
  if(matchState==kMatchStartWaitingOnLocalPlayer&&match==kMatchStateWaitingToApprove){
    return;
  }
  matchState = match;
//  if(matchState == kMatchStateGameOver){
//    NSLog(@"State Game Over");
//  }
//  else if(matchState == kMatchStateWaitingForMatch){
//    NSLog(@"Waiting For Match");
//  }
//  else if(matchState == kMatchStateWaitingToApprove){
//    NSLog(@"Waiting For Approval");
//  }
//  else if(matchState == kMatchStateWaitingForOpponent){
//    NSLog(@"Waiting For Opponent");
//  }
//  else if(matchState == kMatchStartWaitingOnLocalPlayer){
//    NSLog(@"Waiting For LocalPlayer");
//  }
//  else if(matchState == kMatchStateWaitingForStart){
//    NSLog(@"Waiting For Start");
//  }
//  else if(matchState == kMatchStateActive){
//    NSLog(@"Match Active");
//  }

}

-(MatchState)getMatchState{
  return matchState;
}

-(void)sendGameOver{
  [self sendReliableCommand:@"gameover" withInt:kResultWon];
  [self setMatchResult:kResultLost];
}

-(void)sendTiedGame{
  [self sendReliableCommand:@"gameover" withInt:kResultTied];
  [self setMatchResult:kResultTied];
}

-(void)setMatchResult:(Result)r{
  if(result==kResultTied&&r!=kResultUnknown){
    return;
  }
 // if((r==kResultWon||r==kResultLost)&&result!=kResultUnknown){ return; }
  
  result=r;
}

-(Result)getMatchResult{
  return result;
}

-(void)updateRecord{
  int total;
  if(result==kResultWon){
    wins++;
    total = [[NSUserDefaults standardUserDefaults] integerForKey:@"wins"]+1;
    [[NSUserDefaults standardUserDefaults] setInteger:total forKey:@"wins"];
  }
  else if(result==kResultLost){
    loses++;
  }

  [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"win1game" percentComplete:(float)(100*(total/1))];
  [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"win10games" percentComplete:(float)(100*(total/10))];
  if(streak==3){
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"3inarow" percentComplete:100.0f];
  }
}

-(void)sendVersion{

  NSString *ver = [NSString stringWithFormat:@"%f",MULTIPLAYERVERSION];
  [self sendReliableCommand:@"_OTHER_VERSION" withArgument:ver];
}

-(void)dealloc{
  self.delegate = nil;
}

@end
