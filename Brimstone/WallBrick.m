//
//  Brick.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "WallBrick.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"

@implementation WallBrick

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
    
    self.name = @"wallbrick";
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
    self.physicsBody.mass = self.size.width*self.size.height/4;
    self.physicsBody.linearDamping = 0.5;
    self.physicsBody.angularDamping = 0.5;
    self.physicsBody.friction = 1.0;
    self.physicsBody.restitution = 0.6;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = brickCategory;
    self.physicsBody.collisionBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.physicsBody.contactTestBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.physicsBody.dynamic = YES;
    self.physicsBody.fieldBitMask = 1;
    
    self.flammability = 0;
    self.impactThreshold = self.physicsBody.mass*10;

    self.burnSpeed = 10;
    self.turnsToAshesAt = self.physicsBody.mass*10;
    self.initialFireAmount = 10;
    self.initialSmokeAmount = 10;
    
    self.physicalHealth = 10000;

    
    [[GameScene sceneInstance] addChild:self];
    
    [[GameScene sceneInstance].bricksAndObjects addObject:self];
    
    return self;
}

// collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    [super onCollision:otherParty impact:impact]; // collision damage + check if ignite happens
    
    // additional code here
    if (abs((int)impact.dx)>=MIN_VELOCITY_TO_PLAY_SFX || abs((int)impact.dy)>MIN_VELOCITY_TO_PLAY_SFX) { // don't play sound fx if too small velocity to avoid series of impact sounds when touching the object
        SKAction* snd = [SKAction playSoundFileNamed:@"stone_hit.mp3" waitForCompletion:NO];
        [[GameScene sceneInstance] runAction:snd];
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
    [[GameScene gameLogicInstance] addScore:POINTS_FOR_WALLBRICK_DESTROYED pos:self.position];
    [super onDestroy];
}

@end
