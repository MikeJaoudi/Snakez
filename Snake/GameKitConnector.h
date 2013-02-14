//
//  GameKitConnector.h
//  PingPong
//
//  Created by orta therox on 04/07/2011.
//  Modified by Mike Jaoudi
//  Copyright 2011 http://ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "ORLocalNetworkProtocol.h"


typedef enum {
  kMatchStateWaitingForMatch = 0,   //Waiting For Player To Be Found
  kMatchStateWaitingToApprove,      //Neither Player is ready to play
  kMatchStateWaitingForOpponent,    //Waiting for the opponent to be ready
  kMatchStartWaitingOnLocalPlayer,  //Opponent is ready, waiting for local player
  kMatchStateWaitingForStart,       //Both players ready, waiting for match to start
  kMatchStateActive,                //Game is currently active
  kMatchStateGameOver               //Players at Game Over Screen
} MatchState;


typedef enum {
  kResultUnknown = 0,
  kResultWon,
  kResultLost,
  kResultTied,
  }Result;

@interface GameKitConnector : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>

@property( nonatomic) NSObject<ORLocalNetworkProtocol>* delegate;
@property( nonatomic) GKPeerPickerController* peerPicker;
@property( nonatomic) GKSession* session;

@property () NSInteger wins;
@property () NSInteger streak;
@property () NSInteger loses;

+(GameKitConnector*)sharedConnector;

-(void)startPeerToPeer;
-(void)startHostServer;

-(void)sendCommand:(NSString*)command withArgument:(NSString*)arguments;
-(void)sendReliableCommand:(NSString*)command withArgument:(NSString*)argument;

// some  convienience functions
-(void)sendCommand:(NSString*)command withFloat:(float)argument;
-(void)sendReliableCommand:(NSString*)command withInt:(int)argument;
-(void)sendCommand:(NSString*)command withInt:(int)argument;
-(void)sendCommand:(NSString*)command;

-(void)disconnect;
-(BOOL)isHost;
-(BOOL)isConnected;

-(MatchState)getMatchState;
-(void)setMatchState:(MatchState)match;

-(void)sendGameOver;
-(void)sendTiedGame;

-(void)setMatchResult:(Result)r;
-(Result)getMatchResult;
-(void)updateRecord;

-(void)checkConnected;
-(void)startMatch;


@end
