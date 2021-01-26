//
//  WaterBarrel.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT
//

#import "WaterBarrel.h"
#import "Constants.h"
#import "GameScene.h"
#import "Explosions.h"
#import "GameLogic.h"
#import "SoundManager.h"
#import "Ball.h"

@implementation WaterBarrel

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
    
    self.name = @"waterbarrel";
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

    
    self.flammability = 0;
    self.impactThreshold = self.physicsBody.mass;
    self.explosiveYield = self.physicsBody.mass;
    
    self.burnSpeed = 10;
    self.turnsToAshesAt = 250;
    self.initialFireAmount = 0;
    self.initialSmokeAmount = 40;
    
    self.physicalHealth = 300;
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
    if (self.physicalHealth < 100) {
        self.smoke.particleBirthRate = 20;
        self.smoke.particleColor = [UIColor whiteColor];
    }
    
    if (self.physicalHealth < 0) {
        if (self.hasExploded == NO) {
          //  [[GameScene explosionManagerInstance] explodeObject:(GameObject*)self yield:self.explosiveYield];
            [[GameScene soundManagerInstance] playSound:@"splash.mp3"];
            
            self.hasExploded = YES;
            if ([otherParty isMemberOfClass: Ball.class]) {
                Ball* b = (Ball*)otherParty;
                [b snuffOut];  // fire goes out when hitting water
            }
            [self onDestroy];
        }
    }
}

// ignite happened
-(void)onBurn
{
}

-(void)onDestroy
{
    if (self.isDestroyed == YES) {
        return;
    }
#ifndef DISABLE_PARTICLES
    self.fire.numParticlesToEmit = 0;
    self.smoke.numParticlesToEmit = 30;
#endif
    
    self.lightingBitMask = 1+2+4+8;
    self.shadowCastBitMask = 0;
    self.shadowedBitMask = 0;
    self.physicsBody = nil;
    self.texture = [SKTexture textureWithImageNamed:@"WaterHole"];
    self.zPosition = 2;
    self.alpha = 0.6;
    
    [super onDestroy];
    self.hidden = NO;
    
    [[GameScene gameLogicInstance] addScore:POINTS_FOR_WATERBARREL_DESTROYED pos:self.position];
}

@end
