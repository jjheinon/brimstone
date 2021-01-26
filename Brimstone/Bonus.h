//
//  Brick.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Bonus_h
#define Brimstone_Bonus_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class Ball;

enum BonusType
{
    NONE = 0,
    ALREADY_COLLECTED = 1,
    EXTRA_LIFE = 2,
    MULTIBALL = 3,
    SUPERHOT_BALL = 4,
    BONUS_POINTS = 5,
    FAST_PADDLE_UPGRADE = 6
};

@class GameObject;

@interface Bonus : GameObject

-(void)collected:(Ball*)ball;

@property enum BonusType type;
@property UIColor* col;

@end

#endif
