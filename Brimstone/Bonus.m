//
//  Bonus.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import <SpriteKit/SpriteKit.h>

#import "Bonus.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "Ball.h"
#import "Shaders.h"
#import "MenuLogic.h"
#import "BonusFeatures.h"
#import "SoundManager.h"

@implementation Bonus

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node;
{
    self.zPosition = 17;
    [super onCreate:x withY:y scale:scale spriteNode:node];
    
    self.flammability = 0; // does not ignite
    self.impactThreshold = 0; // does not break
    self.canBeDamaged = NO;
    self.physicalHealth = 100;
    
    if (node != nil) {
        self.position = node.position;
        self.size = node.size;
        self.zRotation = node.zRotation;
    } else {
        self.position = CGPointMake(x+arc4random()%10-5, y+arc4random()%10-5);
        [self setScale:0.01];
    }
    
    self.name = @"bonus";
    self.lightingBitMask = 1+2+4+8+16;
    self.shadowCastBitMask = 0;
    self.shadowedBitMask = 1+2+4+8+16; // bonus lights itself
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
    self.physicsBody.mass = 0;
    self.physicsBody.linearDamping = 0.5;
    self.physicsBody.angularDamping = 0.0;
    self.physicsBody.friction = 1.0;
    self.physicsBody.pinned = YES;
    self.physicsBody.restitution = 0.01;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = bonusCategory;
    self.physicsBody.collisionBitMask = ballCategory;
    self.physicsBody.contactTestBitMask = ballCategory;
    self.physicsBody.dynamic = NO;

    [[GameScene sceneInstance] addChild:self];
  //  [[GameScene sceneInstance].bricksAndObjects addObject:self];
    
    self.light = [[GameScene factoryInstance] createLightNoAdd:6.0 category:8 ambientColor:0.0 lightColor:1.0 shadowColor:0.2];

    self.light.lightColor = self.col; //[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    self.light.alpha = 0.5;
    
#ifndef LIGHTS_DISABLED
    [self addChild:self.light];
#endif
    
/*#ifndef DISABLE_SHADERS
    self.shader = [GameScene shaderInstance].glowShader;
    self.shader.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make(self.size.width, self.size.height, 0)]];
#endif*/
  
    
    SKAction* movex = [SKAction moveByX:10.0 y:0.0 duration:1.0];
    movex.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* movex2 = [SKAction moveByX:-10.0 y:0.0 duration:1.0];
    movex2.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* movey = [SKAction moveByX:0.0 y:10.0 duration:0.5];
    movey.timingMode = SKActionTimingEaseInEaseOut;
    SKAction* movey2 = [SKAction moveByX:0.0 y:-10.0 duration:0.5];
    movey2.timingMode = SKActionTimingEaseInEaseOut;
    
    SKAction* seq1 = [SKAction sequence:@[movex, movex2]];
    SKAction* seq2 = [SKAction sequence:@[movey, movey2]];
    
    [self runAction:[SKAction repeatActionForever: seq1 ]];
    [self runAction:[SKAction repeatActionForever: seq2 ]];
    [self runAction:[SKAction scaleTo:scale duration: 0.5]];

    
    // wait for certain time before removing the bonus
    SKAction* w = [SKAction waitForDuration:60.0];
    SKAction* scale2 = [SKAction scaleTo: 0.01 duration: 1.0];
    SKAction* remove = [SKAction runBlock:^{
        NSLog(@"Removing bonus");
        if (self.parent != nil) {
            [self removeFromParent];
        }
    }];
    SKAction* seq3 = [SKAction sequence:@[scale2, remove]];
    [self runAction:[SKAction sequence:@[w,seq3]]];
    
    return self;
}

// collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    // additional code here
}

// ignite happened
-(void)onBurn
{
}


-(void)collected:(Ball*)ball {
    
    NSString* txt = nil;
    if (self.type == EXTRA_LIFE) {
        [GameScene gameLogicInstance].lives = [GameScene gameLogicInstance].lives+1;
        self.type = ALREADY_COLLECTED;
        
        [[GameScene soundManagerInstance] playSound:@"xtralife.mp3"];
        
        [[GameScene gameLogicInstance] updateStatusBar];
        
        SKAction* scaleup = [SKAction scaleYTo:1.5 duration: 0.5];
        scaleup.timingMode = SKActionTimingEaseInEaseOut;
        SKAction* scaledown = [SKAction scaleYTo:1.0 duration: 0.5];
        scaleup.timingMode = SKActionTimingEaseInEaseOut;
        SKAction* seq = [SKAction sequence:@[scaleup,scaledown]];
        [[GameScene gameLogicInstance].statusBarLives runAction:seq];
        
        txt = NSLocalizedString(@"EXTRA LIFE", "Player acquires an extra life.");
    } else if (self.type == MULTIBALL) {
        Ball* ball2 = (Ball*)[[GameScene factoryInstance] createBall:self];
        [ball2 enableMovements];
        [ball2.physicsBody applyImpulse: CGVectorMake((arc4random()%200)-100.0, (arc4random()%200)-100.0)];
        if (ball.isSuperHot == YES) {
            [ball2 igniteSuperHot];
        } else if (ball.isOnFire == NO) {
            [ball2 snuffOut];
        }
        self.type = ALREADY_COLLECTED;

        [[GameScene soundManagerInstance] playSound:@"multiball.mp3"];

        txt = NSLocalizedString(@"MULTIBALL", "Bonus feature, the player acquires multiple balls.");
    } else if (self.type == SUPERHOT_BALL) {
        self.type = ALREADY_COLLECTED;
        
        [[GameScene menuLogicInstance].bonusFeatures addBonusFeature:SUPERHOT_BALL node:self];
        //        [ball igniteSuperHot];
        
        [[GameScene soundManagerInstance] playSound:@"multiball.mp3"];
        txt = NSLocalizedString(@"HOT", "Bonus feature, the player acquires an extra hot ball -feature");

        [[GameScene menuLogicInstance] showInfoText:ball.position text:txt];
        return;
    } else if (self.type == FAST_PADDLE_UPGRADE) {
        self.type = ALREADY_COLLECTED;
        
        [[GameScene menuLogicInstance].bonusFeatures addBonusFeature:FAST_PADDLE_UPGRADE node:self];
        [[GameScene soundManagerInstance] playSound:@"power-up.mp3"];
        txt = NSLocalizedString(@"PADDLE UPGRADE", "Bonus feature, the player's paddle/bat gets upgraded to better one.");
        
        [[GameScene menuLogicInstance] showInfoText:ball.position text:txt];
        return;
    } else if (self.type == BONUS_POINTS) {
        self.type = ALREADY_COLLECTED;

        [[GameScene gameLogicInstance] addScore:POINTS_FOR_BONUS pos:self.position];
        [[GameScene gameLogicInstance] updateStatusBar];

        [[GameScene soundManagerInstance] playSound:@"bonus_points.mp3"];
        txt = NSLocalizedString(@"BONUS POINTS", "Player acquires extra points");
    }
    [[GameScene menuLogicInstance] showInfoText:ball.position text:txt];
//    [[GameScene sceneInstance].bricksAndObjects removeObject:self];
    if (self.parent != nil) {
        [self removeFromParent];
    }
}

@end
