//
//  Crate.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_IceCube_h
#define Brimstone_IceCube_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class GameObject;

@interface IceCube : GameObject

@property Boolean bonusCreated;

@property Boolean hasAlwaysBonus;
@property enum BonusType bonusType;

@end

#endif
