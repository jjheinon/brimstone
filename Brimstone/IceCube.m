//
//  IceCube.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "IceCube.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "Bonus.h"
#import "SoundManager.h"

@implementation IceCube

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

    self.name = @"icecube";
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.lightingBitMask = 1+2+4+8;
        self.shadowCastBitMask = 1;
        self.shadowedBitMask = 1+4;
    } else {
        self.lightingBitMask = 1;
        self.shadowCastBitMask = 0;
        self.shadowedBitMask = 0;
    }
    self.alpha = 0.9;

    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.mass = node.size.width*node.size.height/20;
    self.physicsBody.linearDamping = 0.5;
    self.physicsBody.angularDamping = 0.5;
    self.physicsBody.friction = 1.0;
    self.physicsBody.restitution = 1.0;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = brickCategory;
    self.physicsBody.collisionBitMask = batCategory|ballCategory|brickCategory|brickCategoryButNoCollisionWithBall|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|chainCategory;
    self.physicsBody.contactTestBitMask = batCategory|ballCategory|brickCategory|brickCategoryButNoCollisionWithBall|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|chainCategory;
    self.physicsBody.dynamic = YES;
    self.physicsBody.fieldBitMask = 1;
    
    self.flammability = 0;//-(self.physicsBody.mass/500);
    self.impactThreshold = self.physicsBody.mass;

    self.burnSpeed = 50;
    self.turnsToAshesAt = self.physicsBody.mass*10;
    self.initialFireAmount = 0;
    self.initialSmokeAmount = 0;
    
    self.physicalHealth = 50;
    
    self.isMadeOfIce = YES;
    self.bonusCreated = NO;
    self.generatesShardsWhenDestroyed = YES;
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
        if (arc4random()%2 == 0) {
            [[GameScene soundManagerInstance] playSound:@"ice-hit.mp3"];
        } else {
            [[GameScene soundManagerInstance] playSound:@"ice-hit2.mp3"];
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
    [[GameScene gameLogicInstance] addScore:POINTS_FOR_ICECUBE_DESTROYED pos:self.position];
    
//    [super onDestroy];

    if (self.physicalHealth > 0) { // destroyed at health >0, means it was burnt to ashes
        self.lightingBitMask = 1+2+4+8;;
        self.shadowCastBitMask = 0;
        self.shadowedBitMask = 0;
        self.physicsBody = nil;
        self.texture = [SKTexture textureWithImageNamed:@"WaterHole"];
        self.alpha = 0.5;
        self.zPosition = 2;
        
        // TODO clean this up
        
        [super onDestroy];
        self.hidden = NO;
    } else { // was destroyed on impact, no body remaining as it has been broken to shards
        self.physicsBody = nil;
        [super onDestroy];
    }
}

@end
