//
//  SoundManager.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_SoundManager_h
#define Brimstone_SoundManager_h

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundManager : NSObject

//@property (nonatomic, retain) AVQueuePlayer* player;
//@property (nonatomic, retain) AVQueuePlayer* player2;
@property NSOperationQueue* fadingQueue;

@property NSTimer* fadeTimer;
@property int fadeDir;

@property NSMutableArray* players;

-(void)setup;

-(void)addToPlaylist:(NSString*)pathForResource ofType:(NSString*)ofType playerNum:(int)playerNum;
-(void)clearPlaylist:(int)playerNum;

-(void)stopAll;

-(int)play:(Boolean)loopForever playerNum:(int)playerNum;
-(void)pause:(int)playerNum;


-(void)fadeIn:(NSTimer*)timer;
-(void)fadeOut:(NSTimer*)timer;

-(void)setVolume:(float)volume playerNum:(int)playerNum;

-(void)preload:(int)channel;

@property int beaconPlayerIndex; // 0..1
@property int beaconPlayerIndexSmall; // 0..1
@property int beaconPlayerIndexLarge; // 0..1
@property int explosionPlayerIndex; // 0..3

// sounds
@property NSMutableDictionary* sndActions;
-(void)playSound:(NSString*)sndFile;

#define NUM_OF_BEACON_CHANNELS 2
#define NUM_OF_EXPLOSION_CHANNELS 4

enum PreloadedChannels
{
    ALL = -1,
    BACKGROUND_MUSIC = 1, // background music & fire burning
    MENU_MUSIC = 2, // highscore & select level menu music
    BEACON_POWER_UP = 3, // two channels 3..4
    BEACON_POWER_UP_SMALL = 5, // two channels 5..6
    BEACON_POWER_UP_LARGE = 7, // two channels 7..8
    EXPLOSION = 9, // four channels 9..12
    MAX_CHANNEL_NUM = 12
};

@end
#endif
