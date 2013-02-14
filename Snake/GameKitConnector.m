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

@implementation GameKitConnector {
    GKPeerPickerController * _peerPicker;
    GKSession * _session;

    bool _isHostServer;
    int _hostGuess;
    bool _matchStarted;

    MatchState _matchState;
    Result _result;

    bool _ignoreInput;
}


+ (GameKitConnector*)sharedConnector {
    if(!sharedInstance) {
        sharedInstance = [[GameKitConnector alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _peerPicker = [[GKPeerPickerController alloc] init];
        _peerPicker.delegate = self;
        _peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;

        _ignoreInput = NO;

        [self setMatchState:kMatchStateWaitingForMatch];
        [self setMatchResult:kResultUnknown];
        
        _wins = 0;
        _loses = 0;
    }

    return self;
}

-(void)startPeerToPeer {
    //Show the connector
	[_peerPicker show];
}

-(void)startHostServer {
    _isHostServer = YES;
    [_peerPicker show];
}

#pragma mark PeerPickerControllerDelegate stuff

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    if([_delegate respondsToSelector:@selector(connectionCancelled)]){
        [_delegate connectionCancelled];
    }
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
	_session = [[GKSession alloc] initWithSessionID:BLUETOOTHKEY displayName:nil sessionMode:GKSessionModePeer];
    return _session;
}

/* Notifies delegate that the peer was connected to a GKSession.  */

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)newSession {
	// Use a retaining property to take ownership of the session.
    _session = newSession;
	// Assumes our object will also become the session's delegate.
    _session.delegate = self;
    [_session setDataReceiveHandler: self withContext: nil];
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
    if(_matchStarted){
        return;
    }
    
    _matchStarted = YES;

	// Start your game.
    if (_isHostServer) {
        // when emulating host / server over a p2p network
        // there needs to be a way to detemine host / client
        // I do this by a small game of Rock Paper Scissors

        [self decideHost];
    }else{
        [_delegate connected];
    }
    [self setMatchState:kMatchStateWaitingToApprove];

}

-(void) sendCommand:(NSString *)command {
    [self sendCommand:command withArgument:@""];
}


-(void) sendCommand:(NSString *)command withFloat:(float)argument {
    [self sendCommand:command withArgument:[NSString stringWithFormat:@"%f", argument]];
}

-(void) sendCommand:(NSString *)command withInt:(int)argument {
    [self sendCommand:command withArgument:[NSString stringWithFormat:@"%d", argument]];
}

-(void) sendReliableCommand:(NSString *)command withInt:(int)argument {
    [self sendReliableCommand:command withArgument:[NSString stringWithFormat:@"%d", argument]];
}

-(void) sendCommand:(NSString*)command withArgument:(NSString *)argument {
    if(_session==NULL || !_session.available){return;}

    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:command, argument, nil]];
    [_session sendDataToAllPeers:data withDataMode:GKSendDataUnreliable error:&error];
}

-(void) sendReliableCommand:(NSString*)command withArgument:(NSString*)argument{
    if(_session==NULL || !_session.available){return;}

    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:command, argument, nil]];
    [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context{
    if(_ignoreInput) return;

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

            NSString * theirNumber = [array objectAtIndex:1];

            if ( _hostGuess > [theirNumber intValue]) {
                [_delegate isHost];

            }else if(_hostGuess == [theirNumber intValue]){
                [self decideHost];
            }

            else{
                [_delegate isClient];
                _isHostServer = NO;
            }
            return;
        }

        if([@"_OTHER_VERSION" isEqualToString:[array objectAtIndex:0]]){
            NSString * versionNumber = [array objectAtIndex:1];
            float otherVersion = [versionNumber floatValue];
            float version = MULTIPLAYERVERSION;

            if(otherVersion < version){
                UIAlertView *dialog = [[UIAlertView alloc] init];
                [dialog setDelegate:self];
                [dialog setTitle:@"Incompatible Versions"];
                [dialog setMessage:@"Your opponent must upgrade their game in order to play you"];
                [dialog addButtonWithTitle:@"Ok"];
                [dialog show];

                _ignoreInput = YES;
                [self performSelector:@selector(disconnect) withObject:nil afterDelay:1.0f];
            }
            else if( otherVersion > version){

                UIAlertView *dialog = [[UIAlertView alloc] init];
                [dialog setDelegate:self];
                [dialog setTitle:@"Incompatible Versions"];
                [dialog setMessage:@"You must upgrade your game in order to play your opponent"];
                [dialog addButtonWithTitle:@"Ok"];
                [dialog show];

                _ignoreInput = YES;
                [self performSelector:@selector(disconnect) withObject:nil afterDelay:1.0f];
            }
            return;
        }

        if([@"ready" isEqualToString:[array objectAtIndex:0]]){
            if([self getMatchState]==kMatchStateWaitingForOpponent){
                [self setMatchState:kMatchStateWaitingForStart];
                [_delegate startMatch];
            }
            else {
                [self setMatchState:kMatchStartWaitingOnLocalPlayer];
            }
            return;
        }

        [_delegate recievedCommand:[array objectAtIndex:0] withArgument:[array objectAtIndex:1]];
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    if(state == GKPeerStateDisconnected ){
        [_delegate opponentDisconnected];
        [self disconnect];
    }
}

-(void)decideHost {
    _hostGuess =  arc4random() % 10;
    NSString * guess = [NSString stringWithFormat:@"%d", _hostGuess];
    [self sendReliableCommand:@"_HOST_SERVER" withArgument:guess];
}


-(void)disconnect{
    [_session disconnectFromAllPeers];
	_session.available = NO;

    [_session setDataReceiveHandler: nil withContext: nil];
    sharedInstance.delegate = nil;

    sharedInstance=nil;
	_session.delegate = nil;

    CCScene * newScene = [MainMenu scene];
    [[CCDirector sharedDirector] replaceScene:newScene];
}

-(BOOL)isConnected {
    if([[_session peersWithConnectionState:GKPeerStateConnected] count] > 0){
        return YES;
    }
    return NO;
}

-(BOOL)isHost {
    return _isHostServer;
}

-(void)setMatchState:(MatchState)match{

    if(match == kMatchStateWaitingForOpponent) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970] + 2.5;
        NSString *readyTimeString = [NSString stringWithFormat:@"%f",time];
        [[GameKitConnector sharedConnector] sendReliableCommand:@"ready" withArgument:readyTimeString];

        if(_matchState == kMatchStartWaitingOnLocalPlayer){
            [self setMatchState:kMatchStateWaitingForStart];
            [_delegate startMatch];
        }
    }

    if(_matchState == kMatchStateActive && match != kMatchStateGameOver) {
        return;
    }
    if(_matchState == kMatchStartWaitingOnLocalPlayer && match == kMatchStateWaitingToApprove) {
        return;
    }
    _matchState = match;

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

-(MatchState)getMatchState {
    return _matchState;
}

-(void)sendGameOver {
    [self sendReliableCommand:@"gameover" withInt:kResultWon];
    [self setMatchResult:kResultLost];
}

-(void)sendTiedGame {
    [self sendReliableCommand:@"gameover" withInt:kResultTied];
    [self setMatchResult:kResultTied];
}

-(void)setMatchResult:(Result)r {
    if(_result==kResultTied && r!=kResultUnknown){
        return;
    }
    // if((r==kResultWon||r==kResultLost)&&result!=kResultUnknown){ return; }

    _result=r;
}

-(Result)getMatchResult {
    return _result;
}

-(void)updateRecord {
    int total;
    switch (_result) {
        case kResultWon:
            _wins++;
            total = [[NSUserDefaults standardUserDefaults] integerForKey:@"wins"] + 1;
            [[NSUserDefaults standardUserDefaults] setInteger:total forKey:@"wins"];
            break;
        case kResultLost:
            _loses++;
        default:
            break;
    }

    CGFloat percentTowards1Game = 100 * (total / 1);
    CGFloat percentTowrads10Games = 100 * (total / 10);
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"win1game" percentComplete:percentTowards1Game];
    [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"win10games" percentComplete:percentTowrads10Games];

    if(_streak == 3){
        [[GameCenter sharedGameCenter] reportAchievementIdentifier:@"3inarow" percentComplete:100.0f];
    }
}

-(void)sendVersion{
    NSString *ver = [NSString stringWithFormat:@"%f", MULTIPLAYERVERSION];
    [self sendReliableCommand:@"_OTHER_VERSION" withArgument:ver];
}

-(void)dealloc{
    _delegate = nil;
}

@end
