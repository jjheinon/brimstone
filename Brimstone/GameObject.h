//
//  GameObject.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_GameObject_h
#define Brimstone_GameObject_h

#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@class SpreadingFire;

@interface GameObject : SKSpriteNode

@property int flammability; // 0 == cannot burn
@property int impactThreshold; // amount of force needed to break immediately. 0 = cannot break

@property int physicalHealth; // level of health left (physical damage)

@property int initialFireAmount; // how much fire it generates
@property int initialSmokeAmount; // how much smoke it generates
@property int burnSpeed; // fire spreading rate
@property int currentFireDamage; // how much of it has burnt
@property int turnsToAshesAt; // how long can it burn

@property Boolean aboutToGetDestroyedOnImpact; // if YES, object will shatter to shards on next impact
@property Boolean destroy; // if YES, object is going to be removed soon
@property Boolean isDestroyed; // if YES, object is marked as destroyed/removed

@property Boolean canBeDamaged;   // can be damaged by physical hit
@property Boolean generatesShardsWhenDestroyed;
@property Boolean leavesCorpse; // if body is left behind when destroyed (i.e. explosion hole, ashes)
@property Boolean rotatesWhenDestroyed; // rotates according to where the impact came from when destroyed (i.e. falling tree)

@property Boolean isMadeOfIce; // for ice cubes

@property SKEmitterNode* fire;
@property SKEmitterNode* smoke;
@property SKEmitterNode* spark;

@property Boolean isOnFire;
@property Boolean isSuperHot;


@property SKLightNode* light;

@property NSTimer* timer;

@property NSTimeInterval lastBurnedAt;

-(id)copyWithZone:(NSZone *)zone;

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)nodes;
-(void)onBirth;
-(void)onDeath;

-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact;

-(Boolean)canIgnite;

-(void)onBurn;
-(void)onDestroy;

@end

#endif
