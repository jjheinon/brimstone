//
//  Ball.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Ball_h
#define Brimstone_Ball_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class GameObject;

@interface Ball : GameObject

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node ignite:(Boolean)ignite;

-(void)enableMovements;
-(void)ignite;
-(void)igniteSuperHot;
-(void)disableSuperHot;
-(void)snuffOut;
-(void)decreaseBrightness:(NSTimer*)timer;

@property float brightness;

@property SKEmitterNode* fireEmitter;
@property SKEmitterNode* smokeEmitter;
@end

#endif
