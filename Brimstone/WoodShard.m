//
//  WoodShard.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "WoodShard.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "Bonus.h"

@implementation WoodShard

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node
{
 //   GameObject *obj = (GameObject*)node;
    if (arc4random()%10 == 0 /*&& obj.isOnFire == YES*/) { // 10% chance of burning shards
        [super onCreate:x withY:y scale:scale spriteNode:node];
#ifndef DISABLE_PARTICLES
        //        self.fire.particleBirthRate = 5;
  //      self.fire.numParticlesToEmit = 6;
        self.smoke.particleBirthRate = 5;
        self.smoke.particleScale = 0.5;
        self.smoke.numParticlesToEmit = arc4random()%10+10;
#endif
    }
    self.zPosition = 2;

    self.position = CGPointMake(x, y);
    [self setScale:scale];
    self.zRotation = (arc4random()%360)*M_PI/180;

    self.name = @"woodshard";
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.lightingBitMask = 1+2+4+8;
        self.shadowCastBitMask = 0;
        self.shadowedBitMask = 1+2+8;
    } else {
        self.lightingBitMask = 1;
        self.shadowCastBitMask = 0;
        self.shadowedBitMask = 0;
    }

    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.mass = 0.3;//self.size.width*self.size.height/100;
    self.physicsBody.linearDamping = 1.0;
    self.physicsBody.angularDamping = 1.0;
    self.physicsBody.friction = 1.0;
    self.physicsBody.restitution = 0.1;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = woodShardCategory;
    self.physicsBody.collisionBitMask = ballCategory;
    self.physicsBody.contactTestBitMask = 0;
    self.physicsBody.dynamic = YES;
    self.physicsBody.fieldBitMask = 0;

    self.flammability = 0;
    self.impactThreshold = self.physicsBody.mass;

    self.burnSpeed = 0;
    self.turnsToAshesAt = self.physicsBody.mass*10;
    self.initialFireAmount = 0;
    self.initialSmokeAmount = 0;
    
    self.physicalHealth = 500;

    [[GameScene sceneInstance] addChild:self];
    
//    [[GameScene sceneInstance].bricksAndObjects addObject:self];
    
    return self;
}

// collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
}

// ignite happened
-(void)onBurn
{
    self.physicsBody = nil;
}

-(void)onDestroy
{
}

@end
