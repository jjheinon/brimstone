//
//  Bat.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Bat_h
#define Brimstone_Bat_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class GameObject;

@interface Bat : GameObject

@property NSMutableArray* batFires;
@property NSMutableArray* batSmokes;

//@property SKLightNode* light;

@property Boolean fastPaddle;

-(void)onCollision:(GameObject*)otherParty impact:(CGVector)impact pos:(int)pos;
-(void)burnAt:(int)pos spreading:(Boolean)spreading;

-(void)upgradePaddle;
-(void)downgradePaddle;


@end

#endif
