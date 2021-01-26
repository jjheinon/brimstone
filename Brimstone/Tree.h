//
//  Brick.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Tree_h
#define Brimstone_Tree_h

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@class GameObject;

@interface Tree : GameObject

@property Boolean treeTopBurning;

-(void)onBranchCollision:(GameObject*)otherParty;

@end

#endif
