//
//  OilBarrel.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_OilBarrel_h
#define Brimstone_OilBarrel_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class GameObject;

@interface OilBarrel : GameObject

@property float explosiveYield; // how big bang it generates 1.0 = default big barrel
@property Boolean hasExploded; // have we exploded yet

@end

#endif
