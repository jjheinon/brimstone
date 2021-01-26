//
//  Explosions.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Explosions_h
#define Brimstone_Explosions_h

#import <SpriteKit/SpriteKit.h>

@class GameObject;

@interface Explosions : SKNode

-(void)setup;
-(void)explodeObject:(GameObject*)node yield:(float)yield;

@property SKLightNode* light;

@property SKSpriteNode* shaderContainer;

@end

#endif
