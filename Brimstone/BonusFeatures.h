//
//  BonusFeatures.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_BonusFeatures_h
#define Brimstone_BonusFeatures_h

#include "GameScene.h"
#include "Crate.h"

@class Bonus;

@interface BonusFeatures : NSObject

-(void)setup;
-(void)reCreate;
-(void)removeBonusFeatures;
-(void)addBonusFeature:(enum BonusType)type node:(Bonus*)bonus;

-(void)unhideBonusFeatures;
-(void)hideBonusFeatures;

@property NSMutableArray* featureButtons;

@property int hotBallCount;
@property int paddleUpgradeCount;
@property UISwipeGestureRecognizer* gesture;

@end

#endif
