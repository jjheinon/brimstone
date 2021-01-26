//
//  GameObject.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "GameScene.h"
#import "ObjectFactory.h"
#import "GameObject.h"
#import "GameLogic.h"
#import "SoundManager.h"

@implementation GameObject

-(id)copyWithZone:(NSZone *)zone
{
    // ignore the zone for now
    return [super copyWithZone: zone];
}

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node
{
    self.canBeDamaged = YES;
    self.leavesCorpse = NO;
    self.generatesShardsWhenDestroyed = NO;
    int zpos = 100;
    if (node != nil) {
        zpos = node.zPosition;
    }

#ifndef DISABLE_PARTICLES
    self.fire = [[GameScene factoryInstance] createFire:0 withY:0];
    self.fire.particleBirthRate = 0;
    self.fire.particleZPosition = zpos+101;
    self.fire.particlePositionRange = CGVectorMake(node.size.width/2, node.size.height/4);
    [self addChild:self.fire];
    
    self.smoke = [[GameScene factoryInstance] createSmoke:0 withY:0];
    self.smoke.particleZPosition = zpos+100; // smoke needs to be on top
    self.smoke.particleBirthRate = 0;
    self.smoke.particlePositionRange = CGVectorMake(node.size.width/2, node.size.height/4);
    [self addChild: self.smoke];
#endif
 //   [[GameScene factoryInstance] createLight:[GameScene sceneInstance].ballFireEmitter falloff:4.0 category:2 ambientColor:0.0 lightColor:0.0 shadowColor:0.0];
    
    self.lastBurnedAt = 0;
    
    return nil;
}

-(void)onBirth
{
}

-(void)onDeath
{
}

-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    if (self.canBeDamaged == YES) {
        // check if is destroyed at once
        // if (impactDamage >= self.impactThreshold) {
        //    self.physicalHealth = 0;
        //    [self onDestroy];
        //}
    
        int impactDamage = (int)sqrt(impact.dx*impact.dx + impact.dy*impact.dy);
        if (impactDamage < 20) {
            impactDamage = 20;
        }
        if (impactDamage > 600) {
            impactDamage = 600;
        }
      //  NSLog(@"ImpactDamage: %d", impactDamage);
        if (otherParty.isSuperHot == YES) {
            impactDamage = impactDamage * 3;
        }

        self.physicalHealth = self.physicalHealth - impactDamage; // TODO: calc impact force here and damage accordingly
        if (self.physicalHealth <= 0) {

            if (self.aboutToGetDestroyedOnImpact == YES) {
                [[GameScene factoryInstance] createWoodOrIceShards:self];
                
                if (otherParty != nil) { // no colliding object = do not play crate breaking sounds if destroyed by explosion (as the destruction is delayed -> sounds stupid)
                    
                    if (self.isMadeOfIce == YES) {
                        // play some ice cracking sounds
                        [[GameScene soundManagerInstance] playSound:@"ice-hit.mp3"];
                    } else {
                        // else play wood-debris.mp3
                        [[GameScene soundManagerInstance] playSound:@"wood-debris.mp3"];
                    }
                }
            }
                
            if (self.generatesShardsWhenDestroyed == YES && self.aboutToGetDestroyedOnImpact == NO ) {
                self.aboutToGetDestroyedOnImpact = YES;
                self.physicalHealth = 0;
              //  self.physicsBody.mass = 0;
                self.physicsBody.categoryBitMask = brickCategoryButNoCollisionWithBall;
//                self.physicsBody.collisionBitMask = self.physicsBody.collisionBitMask & (-1 ^ ballCategory);
                return;
            }

            if (self.hidden == NO) {
                self.hidden = YES;
                if (self.rotatesWhenDestroyed == YES) {
                    self.zRotation = atan2f(impact.dy, impact.dx) - M_PI_2; // rotate fallen tree
                    // XXX temp hack for tree, fix it to be generic:
//                    self.position = self.position +
                }
                [self onDestroy];
            }
            return;
        }
    }
    if ((otherParty == nil || otherParty.isOnFire) && [self canIgnite] == YES) { // otherParty == nil when explosion happens. Assume "isOnFire == true" when it happens to ignite stuff.
        [self onBurn];
    }
}

-(Boolean)canIgnite
{
    if (self.flammability == 0) {
        return NO;
    }
    if (arc4random()%100 > self.flammability) {
        NSLog(@"Failed to ignite at probability %d", self.flammability);
        
        // puff smoke
        if (self.smoke.particleBirthRate == 0) {
            self.smoke.particleBirthRate = 10;
            self.smoke.numParticlesToEmit = 10;
        }
        return NO;
    }
    return YES;
}

-(void)onBurn
{
    if (self.isOnFire == NO && self.flammability > 0) {
#ifndef DISABLE_PARTICLES
        self.fire.particleBirthRate = self.initialFireAmount;
        self.smoke.particleBirthRate = self.initialSmokeAmount;
#endif
        [[GameScene sceneInstance].burningObjects addObject:self];
        
        [[GameScene gameLogicInstance] checkBurningObjectsCount];
        self.isOnFire = YES;
    } else {
        int burnDamage = self.burnSpeed;
        if (self.lastBurnedAt > 0) {  // damage multiplied by seconds since last burn
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970]*1.0;
            int diff = now - self.lastBurnedAt;
            if (diff < 1.0) {
                diff = 1.0; // always do some damage, to burn through things if ball is constantly touching. TODO: check if this is too much
            }
            burnDamage = self.burnSpeed * diff;
            self.lastBurnedAt = now;
       //     NSLog(@"Fire damage %d", burnDamage);
        }
        self.currentFireDamage = self.currentFireDamage + burnDamage;
        if (self.currentFireDamage >= self.turnsToAshesAt) {
            if (self.destroy == NO) {
                self.destroy = YES;
#ifndef DISABLE_PARTICLES
                if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
                    self.smoke.particleBirthRate = 10;
                    self.smoke.numParticlesToEmit = 30;
                    self.fire.particleBirthRate = 10;
                    self.fire.numParticlesToEmit = 30;
                } else {
                    self.smoke.particleBirthRate = 2;
                    self.smoke.numParticlesToEmit = 6;
                    self.fire.particleBirthRate = 2;
                    self.fire.numParticlesToEmit = 6;
                }
                self.fire.particlePositionRange = CGVectorMake(self.size.width*3/4, self.size.height*3/4);
                self.smoke.particlePositionRange = CGVectorMake(self.size.width*3/4, self.size.height*3/4);
#endif
            }
            if (self.generatesShardsWhenDestroyed == YES || self.physicsBody.mass == 0) {
                if (self.leavesCorpse == NO) {
                    self.hidden = YES;
                }
                [self onDestroy];
                return;
            }
            
            int destroyAt = self.turnsToAshesAt+self.burnSpeed;
            if (self.currentFireDamage >= destroyAt && self.destroy == YES)
            {
                if (self.hidden == NO) {
                    if (self.leavesCorpse == NO) {
                        self.hidden = YES;
                    }
                    [self onDestroy];
                }
            }
        }
    }
}

-(void)onDestroy
{
    if (self.isDestroyed == YES) {
        return;
    }
    self.isDestroyed = YES;
    // remove from the list of burning objects
#ifndef DISABLE_PARTICLES
    if (self.smoke != nil) {
        self.smoke.particleBirthRate = 0;
        self.smoke.numParticlesToEmit = 10;
    }
    if (self.fire != nil) {
        self.fire.particleBirthRate = 0;
        self.fire.numParticlesToEmit = 10;
    }
#endif
    [[GameScene sceneInstance].burningObjects removeObject:self];

    // destroy
    self.physicsBody = nil;
    
    [[GameScene gameLogicInstance] updateStatusBar];
    
    //[self removeFromParent];
    // delayed update of score in status bar
/*    SKAction* w = [SKAction waitForDuration:0.5];
    SKAction* update = [SKAction runBlock:^{
        [[GameScene gameLogicInstance] checkBurningObjectsCount]; // update sound volume
        [[GameScene gameLogicInstance] updateStatusBar];
    }];
    SKAction *sequence = [SKAction sequence:@[w, update]];
    [[GameScene gameLogicInstance] runAction:sequence];
*/
}
@end

