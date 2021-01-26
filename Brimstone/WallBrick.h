//
//  Brick.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_WallBrick_h
#define Brimstone_WallBrick_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class GameObject;

@interface WallBrick : GameObject

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node;

@end

#endif
