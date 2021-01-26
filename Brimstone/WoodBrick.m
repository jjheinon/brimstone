//
//  WoodBrick.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "WoodBrick.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "Bonus.h"

@implementation WoodBrick

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node
{
    self.zPosition = 10;
    [super onCreate:x withY:y scale:scale spriteNode:node];

    if (node != nil) {
        self.position = node.position;
        self.size = node.size;
        self.zRotation = node.zRotation;
    } else {
        self.position = CGPointMake(x, y);
        [self setScale:scale];
    }

    self.name = @"woodbrick";
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
    self.physicsBody.mass = self.size.width*self.size.height/10;
    self.physicsBody.linearDamping = 0.5;
    self.physicsBody.angularDamping = 0.5;
    self.physicsBody.friction = 1.0;
    self.physicsBody.restitution = 0.5;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = brickCategory;
    self.physicsBody.collisionBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.physicsBody.contactTestBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.physicsBody.dynamic = YES;
    self.physicsBody.fieldBitMask = 1;
    
    self.flammability = 80;//-(self.physicsBody.mass/500);
    if (self.flammability <= 20) {
        self.flammability = 20;
    }
    self.impactThreshold = self.physicsBody.mass;

    self.burnSpeed = 50;
    self.turnsToAshesAt = self.physicsBody.mass*10;
    self.initialFireAmount = 10;
    self.initialSmokeAmount = 10;
    
    self.physicalHealth = 500;

    self.generatesShardsWhenDestroyed = YES;
    
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
        if (arc4random()%2 == 0) {
            SKAction* snd = [SKAction playSoundFileNamed:@"wood_hit.mp3" waitForCompletion:NO];
            [[GameScene sceneInstance] runAction:snd];
        } else {
            SKAction* snd = [SKAction playSoundFileNamed:@"wood_hit2.mp3" waitForCompletion:NO];
            [[GameScene sceneInstance] runAction:snd];
        }
    }
}

// ignite happened
-(void)onBurn
{
    [super onBurn];
}

-(void)onDestroy
{
    if (self.isDestroyed == YES) {
        return;
    }
    [[GameScene gameLogicInstance] addScore:POINTS_FOR_WOODBRICK_DESTROYED pos:self.position];
#ifndef DISABLE_PARTICLES
    self.fire.numParticlesToEmit = 30;
    self.smoke.numParticlesToEmit = 30;
#endif
//    [super onDestroy];

    self.lightingBitMask = 1+2+4+8;
    self.shadowCastBitMask = 0;
    self.shadowedBitMask = 0;
    self.physicsBody = nil;
    self.texture = [SKTexture textureWithImageNamed:@"ashes"];
    self.zPosition = 2;
    
    // TODO clean this up
    
    [super onDestroy];
}

@end
