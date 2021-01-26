//
//  SoundManager.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "SoundManager.h"
#import "GameScene.h"
#import "Constants.h"

@implementation SoundManager

-(void)setup
{
    self.fadingQueue = [[NSOperationQueue alloc] init];
    self.players = [[NSMutableArray alloc] init];
    for (int i=0; i<=MAX_CHANNEL_NUM; i++) {
        AVQueuePlayer* player = [[AVQueuePlayer alloc] init];
        [self.players addObject:player];
    }
    
    self.sndActions = [[NSMutableDictionary alloc] init];
 
    SKAction *w1 = [SKAction waitForDuration:1.0];
    SKAction *w2 = [SKAction waitForDuration:2.0];
    SKAction *w3 = [SKAction waitForDuration:3.0];

    SKAction *a1 = [SKAction runBlock:^{
        [self loadSound:@"tree-falling.mp3"];
        [self loadSound:@"chain-dropping.mp3"];
        [self loadSound:@"chain-link1.mp3"];
        [self loadSound:@"chain-link2.mp3"];
        [self loadSound:@"chain-link3.mp3"];
        [self loadSound:@"multiball.mp3"];
        [self loadSound:@"xtralife.mp3"];
    }];
    SKAction *a2 = [SKAction runBlock:^{
        [self loadSound:@"multiball.mp3"];
        [self loadSound:@"bonus_points.mp3"];
        [self loadSound:@"explosion.mp3"];
        [self loadSound:@"wood-debris.mp3"];
        [self loadSound:@"beacon-hit.mp3"];
        [self loadSound:@"barrel_hit.mp3"];
        [self loadSound:@"branch_hit1.mp3"];
        [self loadSound:@"branch_hit2.mp3"];
    }];
    SKAction *a3 = [SKAction runBlock:^{
        [self loadSound:@"power-up.mp3"];
        [self loadSound:@"power-down.mp3"];
        [self loadSound:@"metal-bat-hit.mp3"];
        [self loadSound:@"splash.mp3"];
        [self loadSound:@"hiss.mp3"];
        [self loadSound:@"ice-hit.mp3"];
        [self loadSound:@"ice-hit2.mp3"];
    }];
    [self loadSound:@"click.mp3"];
    [self loadSound:@"game_start.mp3"];
    [self loadSound:@"sizzle.mp3"];
    [self loadSound:@"fireball_launch.mp3"];
    [self loadSound:@"stone_hit.mp3"];
    [self loadSound:@"wood-hit-crack.mp3"];
    [self loadSound:@"wood_hit.mp3"];
    [self loadSound:@"wood_hit2.mp3"];
    [self loadSound:@"leveldone.mp3"];
    [self loadSound:@"death.mp3"];
    [self loadSound:@"gameover.mp3"];

    [[GameScene sceneInstance] runAction:[SKAction sequence:@[w1,a1]]];
    [[GameScene sceneInstance] runAction:[SKAction sequence:@[w2,a2]]];
    [[GameScene sceneInstance] runAction:[SKAction sequence:@[w3,a3]]];
}

- (void)addToPlaylist:(NSString*)pathForResource ofType:(NSString*)ofType playerNum:(int)playerNum
{
    NSString *path = [[NSBundle mainBundle] pathForResource:pathForResource ofType:ofType];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        AVQueuePlayer* player = [self.players objectAtIndex:playerNum];
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
        [player insertItem:item afterItem:nil];
    }
}

-(void)clearPlaylist:(int)playerNum
{
    if (self.players.count <= playerNum || self.players.count == 0) {
        return;
    }
    if (playerNum == BEACON_POWER_UP) {
        for (int i=0; i<NUM_OF_BEACON_CHANNELS; i++) {
            [[self.players objectAtIndex:BEACON_POWER_UP+i] removeAllItems];
        }
        return;
    }
    if (playerNum == BEACON_POWER_UP_SMALL) {
        for (int i=0; i<NUM_OF_BEACON_CHANNELS; i++) {
            [[self.players objectAtIndex:BEACON_POWER_UP_SMALL+i] removeAllItems];
        }
        return;
    }
    if (playerNum == BEACON_POWER_UP_LARGE) {
        for (int i=0; i<NUM_OF_BEACON_CHANNELS; i++) {
            [[self.players objectAtIndex:BEACON_POWER_UP_LARGE+i] removeAllItems];
        }
        return;
    }
    [[self.players objectAtIndex:playerNum] removeAllItems];
}

-(void)stopAll
{
    for (int i=0; i<self.players.count; i++) {
        [[self.players objectAtIndex:i] removeAllItems];
    }
}

-(int)play:(Boolean)loopForever playerNum:(int)playerNum
{
    int orig = playerNum;
    if (playerNum == BEACON_POWER_UP) {
        self.beaconPlayerIndex = (self.beaconPlayerIndex+1)%NUM_OF_BEACON_CHANNELS;
        playerNum = BEACON_POWER_UP+self.beaconPlayerIndex;
    }
    if (playerNum == BEACON_POWER_UP_SMALL) {
        self.beaconPlayerIndex = (self.beaconPlayerIndex+1)%NUM_OF_BEACON_CHANNELS;
        playerNum = BEACON_POWER_UP_SMALL+self.beaconPlayerIndex;
    }
    if (playerNum == BEACON_POWER_UP_LARGE) {
        self.beaconPlayerIndex = (self.beaconPlayerIndex+1)%NUM_OF_BEACON_CHANNELS;
        playerNum = BEACON_POWER_UP_LARGE+self.beaconPlayerIndex;
    }
    if (playerNum == EXPLOSION) {
        self.explosionPlayerIndex = (self.explosionPlayerIndex+1)%NUM_OF_EXPLOSION_CHANNELS;
        playerNum = EXPLOSION+self.explosionPlayerIndex;
    }
    AVQueuePlayer* player = [self.players objectAtIndex:playerNum];
    if ([player.items count] == 0) { // no items in the queue we're attempting to play, preload default contents
        [self preload:orig];
    }

    [player play];
/*    if (loopForever == YES) {
        // TODO: does this work?
        __weak typeof(self) weakSelf = self; // prevent memory cycle
        NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
        [noteCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                object:nil // any object can send
                                 queue:nil // the queue of the sending
                            usingBlock:^(NSNotification *note) {
                                // holding a pointer to avPlayer to reuse it
                                [weakSelf.player seekToTime:kCMTimeZero];
                                [weakSelf.player play];
                            }];
    } else {
        if (playerNum == 1) {
            [self.player play];
        } else {
            [self.player2 play];
        }
    }*/
    return playerNum;
}

-(void)pause:(int)playerNum
{
    AVQueuePlayer* player = [self.players objectAtIndex:playerNum];
    [player pause];
}

-(void)fadeIn:(NSTimer*)timer
{
    if (self.fadeDir == -1 && self.fadeTimer != nil) {
        [self.fadeTimer invalidate];
    }
    AVQueuePlayer* player = [self.players objectAtIndex:1];
    self.fadeDir = 1;
    if (player.volume == 0.0) {
        player.volume = 0.1;
        [player play];
    } else {
        player.volume += 0.1;
    }
    if (player.volume >= 1.0) {
        player.volume = 1.0;
        return;
    }
    self.fadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(fadeIn:)
                                   userInfo:nil
                                    repeats:NO];
}


-(void)fadeOut:(NSTimer*)timer 
{
    if (self.fadeDir == 1 && self.fadeTimer != nil) {
        [self.fadeTimer invalidate];
    }
    AVQueuePlayer* player = [self.players objectAtIndex:1];
    self.fadeDir = -1;
    if (player.volume <= 0.1) {
        player.volume = 0;
        [player pause];
        return;
    } else {
        player.volume -= 0.1;
        self.fadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(fadeOut:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

-(void)setVolume:(float)volume playerNum:(int)playerNum
{
    if (self.players.count <= playerNum) {
        return;
    }
    AVQueuePlayer* player = [self.players objectAtIndex:playerNum];
    player.volume = volume;
}

// here we preload the samples to avoid FPS problems when playing the sample for the first time
-(void)preload:(int)channel // preload samples
{
    if (self.players.count <= MAX_CHANNEL_NUM) {
        return;
    }
    // preload sample
    if (channel == -1 || channel == BEACON_POWER_UP) {
        for (int i=0; i<NUM_OF_BEACON_CHANNELS; i++) {
            [[GameScene soundManagerInstance] clearPlaylist:BEACON_POWER_UP+i];
            [[GameScene soundManagerInstance] addToPlaylist:@"beacon-power-up" ofType:@"mp3" playerNum:BEACON_POWER_UP+i];
            [[GameScene soundManagerInstance] setVolume:0.0 playerNum:BEACON_POWER_UP+i];
            [[GameScene soundManagerInstance] pause:BEACON_POWER_UP+i];
        }
    }
    if (channel == -1 || channel == BEACON_POWER_UP_SMALL) {
        for (int i=0; i<NUM_OF_BEACON_CHANNELS; i++) {
            [[GameScene soundManagerInstance] clearPlaylist:BEACON_POWER_UP+i];
            [[GameScene soundManagerInstance] addToPlaylist:@"beacon-power-up-small" ofType:@"mp3" playerNum:BEACON_POWER_UP_SMALL+i];
            [[GameScene soundManagerInstance] setVolume:0.0 playerNum:BEACON_POWER_UP_SMALL+i];
            [[GameScene soundManagerInstance] pause:BEACON_POWER_UP_SMALL+i];
        }
    }
    if (channel == -1 || channel == BEACON_POWER_UP_LARGE) {
        for (int i=0; i<NUM_OF_BEACON_CHANNELS; i++) {
            [[GameScene soundManagerInstance] clearPlaylist:BEACON_POWER_UP_LARGE+i];
            [[GameScene soundManagerInstance] addToPlaylist:@"beacon-power-up-large" ofType:@"mp3" playerNum:BEACON_POWER_UP_LARGE+i];
            [[GameScene soundManagerInstance] setVolume:0.0 playerNum:BEACON_POWER_UP_LARGE+i];
            [[GameScene soundManagerInstance] pause:BEACON_POWER_UP_LARGE+i];
        }
    }
    if (channel == -1 || channel == EXPLOSION) {
        for (int i=0; i<NUM_OF_EXPLOSION_CHANNELS; i++) {
            [[GameScene soundManagerInstance] clearPlaylist:EXPLOSION+i];
            [[GameScene soundManagerInstance] addToPlaylist:@"explosion" ofType:@"mp3" playerNum:EXPLOSION+i];
            [[GameScene soundManagerInstance] setVolume:0.0 playerNum:EXPLOSION+i];
            [[GameScene soundManagerInstance] pause:EXPLOSION+i];
        }
    }
}

-(void)loadSound:(NSString *)sndFile
{
    self.sndActions[sndFile] = [SKAction playSoundFileNamed:sndFile waitForCompletion:NO];
}

-(void)playSound:(NSString *)sndFile
{
    if (self.sndActions[sndFile] == nil) {
        NSLog(@"Loading %@", sndFile);
        [self loadSound:sndFile];
    }
    
    [[GameScene sceneInstance] runAction:self.sndActions[sndFile]];
}
@end

