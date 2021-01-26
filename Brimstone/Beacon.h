//
//  Brick.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Beacon_h
#define Brimstone_Beacon_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class GameObject;

@interface Beacon : GameObject

-(void)createChain;
-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node color:(int)color;
-(void)onLightIntensityScaleUp:(NSTimer*)timer;

-(void)powerUp;

@property Boolean poweredUp;

@property int col;

@property float timeInterval;
@property float sampleTime;

@end

enum Color
{
    WHITE = 0,
    RED = 1,
    GREEN = 2,
    BLUE = 3
};

#endif
