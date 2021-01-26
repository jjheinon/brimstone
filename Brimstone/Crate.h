//
//  Crate.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Crate_h
#define Brimstone_Crate_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class GameObject;

@interface Crate : GameObject

@property Boolean bonusCreated;

@property Boolean hasAlwaysBonus;
@property enum BonusType bonusType;

@end

#endif
