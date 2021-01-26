//
//  Crate.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "Crate.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "Bonus.h"
#import "SoundManager.h"

@implementation Crate

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

    
    self.name = @"crate";
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.lightingBitMask = 1+2+4+8;
        self.shadowCastBitMask = 1;
        self.shadowedBitMask = 1+4;
    } else {
        self.lightingBitMask = 1;
        self.shadowCastBitMask = 0;
        self.shadowedBitMask = 0;
    }

    self.blendMode = SKBlendModeReplace;
    
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
    
    self.flammability = 80;//-(self.physicsBody.mass/500);
    if (self.flammability <= 20) {
        self.flammability = 20;
    }
    self.impactThreshold = self.physicsBody.mass;

    self.burnSpeed = 50;
    self.turnsToAshesAt = self.physicsBody.mass*10;
    self.initialFireAmount = 10;
    self.initialSmokeAmount = 10;
    
    self.physicalHealth = 200;
    
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
            [[GameScene soundManagerInstance] playSound:@"wood_hit.mp3"];
        } else {
            [[GameScene soundManagerInstance] playSound:@"wood_hit2.mp3"];
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
    if (self.hasAlwaysBonus == YES || (arc4random() % BONUS_PROBABILITY == 0)) {

        if (self.bonusCreated == NO) {
            self.bonusCreated = YES;

            Bonus *ob = nil;
            int type = arc4random()%40;
            if (self.bonusType != NONE) {
                type = self.bonusType;
            }
            switch (type) {
                case SUPERHOT_BALL:
                    ob = [Bonus spriteNodeWithImageNamed:@"bonus_red"];
                    ob.type = SUPERHOT_BALL;
                    ob.color = [UIColor redColor];
                    break;
                case FAST_PADDLE_UPGRADE:
                    ob = [Bonus spriteNodeWithImageNamed:@"bonus_red_paddle"];
                    ob.type = FAST_PADDLE_UPGRADE;
                    ob.color = [UIColor redColor];
                    break;
                    break;
                case EXTRA_LIFE:
                    ob = [Bonus spriteNodeWithImageNamed:@"bonus_blue"];
                    ob.type = EXTRA_LIFE;
                    ob.color = [UIColor blueColor];
                    break;
                case MULTIBALL:
                    ob = [Bonus spriteNodeWithImageNamed:@"bonus_yellow"];
                    ob.type = MULTIBALL;
                    ob.color = [UIColor yellowColor];
                    break;
                default:
                    ob = [Bonus spriteNodeWithImageNamed:@"bonus_green"];
                    ob.type = BONUS_POINTS;
                    ob.color = [UIColor greenColor];
                    break;
            }
            [ob onCreate:self.position.x withY:self.position.y scale:0.3 spriteNode:nil];
        }
    }
    [[GameScene gameLogicInstance] addScore:POINTS_FOR_CRATE_DESTROYED pos:self.position];

#ifndef DISABLE_PARTICLES
    self.fire.numParticlesToEmit = 30;
    self.smoke.numParticlesToEmit = 30;
#endif
//    [super onDestroy];

    if (self.physicalHealth > 0) { // destroyed at health >0, means it was burnt to ashes
        self.lightingBitMask = 1+2+4+8;;
        self.shadowCastBitMask = 0;
        self.shadowedBitMask = 0;
        self.texture = [SKTexture textureWithImageNamed:@"ashes"];
        self.physicsBody = nil;
        self.alpha = 0.5;
        self.zPosition = 2;
        self.blendMode = SKBlendModeAlpha;
        
        // TODO clean this up
        
        [super onDestroy];
        self.hidden = NO;
    } else { // was destroyed on impact, no body/ashes remaining as it has been broken to shards
        self.physicsBody = nil;
        self.texture = nil;
        [super onDestroy];
    }
}

@end
