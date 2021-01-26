//
//  Brick.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "OilBarrel.h"
#import "Constants.h"
#import "GameScene.h"
#import "Explosions.h"
#import "GameLogic.h"
#import "SoundManager.h"

@implementation OilBarrel

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node
{
    [super onCreate:x withY:y scale:scale spriteNode:node];

    if (node != nil) {
        self.position = node.position;
        self.size = node.size;
        self.zRotation = node.zRotation;
    } else {
        self.position = CGPointMake(x, y);
        [self setScale:scale];
    }
    
    self.name = @"barrel";
    self.zPosition = 10;
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.lightingBitMask = 1+2+4+8;
        self.shadowCastBitMask = 1;
        self.shadowedBitMask = 1+2+8;
    } else {
        self.lightingBitMask = 1;
        self.shadowCastBitMask = 0;
        self.shadowedBitMask = 0;
    }
    
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.mass = node.size.width*node.size.height*5;
    self.physicsBody.linearDamping = 0.5;
    self.physicsBody.angularDamping = 0.5;
    self.physicsBody.friction = 1.0;
    self.physicsBody.restitution = 0.01;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = barrelCategory;
    self.physicsBody.collisionBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.physicsBody.contactTestBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.physicsBody.dynamic = YES;
    self.physicsBody.fieldBitMask = 1;

    
    self.flammability = 90;
    self.impactThreshold = self.physicsBody.mass;
    self.explosiveYield = self.physicsBody.mass;
    
    self.burnSpeed = 10;
    self.turnsToAshesAt = 250;
    
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.initialFireAmount = 100;
        self.initialSmokeAmount = 40;
    } else {
        self.initialFireAmount = 10;
        self.initialSmokeAmount = 4;
    }
    
    self.physicalHealth = 1000;
    self.leavesCorpse = YES;
    
    [[GameScene sceneInstance] addChild:self];
    
    [[GameScene sceneInstance].bricksAndObjects addObject:self];
    
    return self;
}

// collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    [super onCollision:otherParty impact:impact]; // collision damage + check if ignite happens
    
    // additional code here
    if (abs((int)impact.dx)>=MIN_VELOCITY_TO_PLAY_SFX || abs((int)impact.dy)>MIN_VELOCITY_TO_PLAY_SFX) { // avoid series of impact sounds when touching the object
        if (otherParty != nil) { // no colliding object = do not play crate breaking sounds if destroyed by explosion (as the destruction is delayed -> sounds stupid)
            [[GameScene soundManagerInstance] playSound:@"barrel_hit.mp3"];
        }
    }
    
    if (self.physicalHealth < 0) {
        if (self.hasExploded == NO) {
            [[GameScene explosionManagerInstance] explodeObject:(GameObject*)self yield:self.explosiveYield];
            self.currentFireDamage = self.turnsToAshesAt-1;
            self.hasExploded = YES;
        }
    }
}

// ignite happened
-(void)onBurn
{
    if (self.currentFireDamage == 0) {
        [super onBurn];
        // more smoke on oil barrel:
        self.smoke.particleBirthRate = 50;
        self.smoke.particleSpeed = 120;
        self.smoke.yAcceleration = 100;
        self.smoke.particlePositionRange = CGVectorMake(self.size.width,20);
    } else {
        [super onBurn];
    }
    if (arc4random()%30 == 0 || self.currentFireDamage > self.currentFireDamage) {
        if (self.hasExploded == NO) {
            [[GameScene explosionManagerInstance] explodeObject:(GameObject*)self yield:self.explosiveYield];
            self.currentFireDamage = self.turnsToAshesAt-1;
            self.hasExploded = YES;
        }
    }
}

-(void)onDestroy
{
    if (self.isDestroyed == YES) {
        return;
    }
#ifndef DISABLE_PARTICLES
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.fire.numParticlesToEmit = 30;
        self.smoke.numParticlesToEmit = 30;
    } else {
        self.fire.numParticlesToEmit = 6;
        self.smoke.numParticlesToEmit = 6;
    }
#endif
    
    self.lightingBitMask = 1+2+4+8;
    self.shadowCastBitMask = 0;
    self.shadowedBitMask = 0;
    self.physicsBody = nil;
    self.texture = [SKTexture textureWithImageNamed:@"ExplosionHole"];
    self.zPosition = 2;
    self.alpha = 0.8,
    
    [super onDestroy];
    self.hidden = NO;
    
    [[GameScene gameLogicInstance] addScore:POINTS_FOR_OILBARREL_DESTROYED pos:self.position];
}

@end
