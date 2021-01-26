//
//  Brick.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "Tree.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "SoundManager.h"

@implementation Tree

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node
{
    self.zPosition = 11;
    [super onCreate:x withY:y scale:scale spriteNode:nil];
    
#ifndef DISABLE_PARTICLES
    self.fire.particleZPosition = 11;
    self.fire.zPosition = 11;
#endif
    
    self.flammability = 50;
    self.impactThreshold = 10000*scale;
    self.burnSpeed = 10;
    self.turnsToAshesAt = 500;
    self.initialFireAmount = 25;
    self.initialSmokeAmount = 20;
    
    GameObject *b = [GameObject spriteNodeWithImageNamed:[NSString stringWithFormat:@"Tree%d", (arc4random()%4)+1]];
    
    if (node != nil) {
        b.size = node.size;
    } else {
        b.size = CGSizeMake(100*scale, 100*scale);
    }
    b.position = CGPointMake(0, 0);
    b.name = @"treetop";
    b.zPosition = 24;
    b.zRotation = arc4random()%360;
    b.alpha = 0.95; // slightly transparent tree top
    
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        b.lightingBitMask = 1+2+4+8;
        b.shadowedBitMask = 1+2;
    } else {
        b.lightingBitMask = 1;
        b.shadowedBitMask = 0;
        b.shadowCastBitMask = 0;
    }

    b.flammability = 50;
    b.impactThreshold = 10000*scale;
    b.burnSpeed = 20;
    b.turnsToAshesAt = 500;
    b.initialFireAmount = 15;
    b.initialSmokeAmount = 10;

    self.physicalHealth = 1000;

    float r = b.size.width/2;
    if (r>b.size.height/2) {
        r = b.size.height/2; // take smaller value
    }
    b.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:r];
    b.physicsBody.dynamic = YES;
    b.physicsBody.mass = b.size.width*b.size.height;
    b.physicsBody.pinned = YES;
    b.physicsBody.linearDamping = 0.5;
    b.physicsBody.angularDamping = 1.0;
    b.physicsBody.friction = 1.0;
    b.physicsBody.restitution = 0.4;
    b.physicsBody.affectedByGravity = NO;
    b.physicsBody.categoryBitMask = treeTopCategory;
    b.physicsBody.collisionBitMask = 0;
    b.physicsBody.contactTestBitMask = ballCategory;
 
    // tree trunk
    if (node != nil) {
        self.position = node.position;
    } else {
        self.position = CGPointMake(x, y);
    }
    self.size = CGSizeMake(b.size.width/4, b.size.height/4); // trunk diameter
    
    self.lightingBitMask = 1+2+4+8;
    self.shadowCastBitMask = 1;
    self.shadowedBitMask = 1+2;
    
    self.leavesCorpse = YES;
    self.rotatesWhenDestroyed = YES;
    
    self.name = @"treetrunk";
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
    self.physicsBody.mass = b.size.width*b.size.height;
    self.physicsBody.dynamic = YES;
    self.physicsBody.density = 10;
    self.physicsBody.pinned = YES;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.friction = 1.0;
    self.physicsBody.restitution = 0.4;
    self.physicsBody.categoryBitMask = treeTrunkCategory;
    self.physicsBody.collisionBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.physicsBody.contactTestBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    [self addChild:b];
    
    [[GameScene sceneInstance] addChild:self];
    [[GameScene sceneInstance].bricksAndObjects addObject:self];
    
    return self;
}


// tree branch collision with other object happened
-(void)onBranchCollision:(GameObject*)otherParty
{
    [super onCollision:otherParty impact:CGVectorMake(0,0)]; // no collision damage for branch, but check if ignite happens
    
    // additional code here
}

// tree trunk collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    [super onCollision:otherParty impact:impact]; // collision damage + check if ignite happens
    
    // additional code here
    if (abs((int)impact.dx)>=MIN_VELOCITY_TO_PLAY_SFX || abs((int)impact.dy)>MIN_VELOCITY_TO_PLAY_SFX) { // avoid series of impact sounds when touching the object

        if (otherParty != nil) { // no colliding object = do not play crate breaking sounds if destroyed by explosion (as the destruction is delayed -> sounds stupid)
            SKAction *snd = nil;
            if (arc4random()%2==0) {
                [[GameScene soundManagerInstance] playSound:@"branch_hit1.mp3"];
            } else {
                [[GameScene soundManagerInstance] playSound:@"branch_hit2.mp3"];
            }
            [[GameScene sceneInstance] runAction:snd];
        }
    }
}

-(Boolean)canIgnite
{
    if (self.flammability == 0) {
        return NO;
    }
    if (arc4random()%100 > self.flammability) {
        return NO;
    }
/*    if ([self.name isEqualToString:@"treetop"]) {
        if (arc4random()%100 > 10) { // tree branch probability to lit is lower as ball contacts it more often /(as it goes through)
            return NO;
        }
    } else {
        if (arc4random()%100 > self.flammability) { // tree trunk
            return NO;
        }
    }*/
    return YES;
}

// ignite happened
-(void)onBurn
{
    [super onBurn];

    if (self.currentFireDamage >= 100) { // fire spreads to treetop
        if (self.treeTopBurning == NO) {
            self.treeTopBurning = YES;
#ifndef DISABLE_PARTICLES
            GameObject* treetop = (GameObject*)[self childNodeWithName:@"treetop"];
            self.fire.particleBirthRate = 50;
            self.fire.particlePositionRange = CGVectorMake(treetop.size.width*3/4, treetop.size.height*3/4);
            self.fire.zPosition = 102;
            self.fire.particleZPosition = 102;
            self.smoke.particleBirthRate = 30;
            self.smoke.particlePositionRange = CGVectorMake(treetop.size.width*3/4, treetop.size.height*3/4);
#endif
        }
        
    }
}

-(void)onDestroy
{
    if (self.isDestroyed == YES) {
        return;
    }
    self.lightingBitMask = 1+2+4+8;
    self.shadowCastBitMask = 0;
    self.shadowedBitMask = 0;
    self.physicsBody = nil;
    self.texture = [SKTexture textureWithImageNamed:@"Tree_burned"];
    self.zPosition = 2;
    self.scale = 5.0;
//    self.anchorPoint = CGPointMake(self.size.width/2, -self.size.height/2+5);
    
//    [super onDestroy];
    self.isDestroyed = YES;
    // remove from the list of burning objects
#ifndef DISABLE_PARTICLES
    if (self.smoke != nil) {
        self.smoke.particleZPosition = 99;
        self.smoke.particleBirthRate = 5;
        self.smoke.particlePositionRange = CGVectorMake(self.size.width*3/4, self.size.height*3/4);
        self.smoke.numParticlesToEmit = 50;
    }
    if (self.fire != nil) {
        self.fire.particleZPosition = 100;
        self.fire.particleBirthRate = 5;
        self.fire.numParticlesToEmit = 50;
    }
#endif
    [[GameScene sceneInstance].burningObjects removeObject:self];


    GameObject* treetop = (GameObject*)[self childNodeWithName:@"treetop"];
    treetop.physicsBody = nil;
    treetop.hidden = YES;
    
    self.hidden = NO;
    
    [[GameScene soundManagerInstance] playSound:@"tree-falling.mp3"];
    
    [[GameScene gameLogicInstance] addScore:POINTS_FOR_TREE_DESTROYED pos:self.position];
}

@end
