//
//  Brick.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import <SpriteKit/SpriteKit.h>

#import "Beacon.h"
#import "Chain.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "SoundManager.h"

@implementation Beacon

-(void)createChain
{
    Chain* ob = [[Chain alloc] init];

    [ob onCreate:self.position.x withY:self.position.y scale:1.0 spriteNode:self];
    self.physicsBody.mass = 100; //self.size.width*self.size.height/50;
    self.physicsBody.affectedByGravity = YES;
    self.physicsBody.pinned = NO;
    self.position = CGPointMake(self.position.x, self.position.y - 20);
    self.physicsBody.velocity = CGVectorMake(0, 0);
}

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node color:(int)color
{
    self.zPosition = 50;//117;
    [super onCreate:x withY:y scale:scale spriteNode:node];
    
    self.flammability = 0; // does not ignite
    self.impactThreshold = 0; // does not break
    self.poweredUp = NO;
    self.canBeDamaged = NO;
    self.physicalHealth = 100;
    
    [GameScene sceneInstance].beaconCount++;

    if (node != nil) {
        self.position = node.position;
        self.size = node.size;
        self.zRotation = node.zRotation;
    } else {
        self.position = CGPointMake(x, y);
        [self setScale:scale];
    }
    
    self.name = @"beacon";
    self.lightingBitMask = 1+4;
    self.shadowedBitMask = 4; // beacon lights itself
    
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
    self.physicsBody.mass = node.size.width*node.size.height * 20;
    self.physicsBody.linearDamping = 0.5;
    self.physicsBody.angularDamping = 0.0;
    self.physicsBody.friction = 1.0;
    self.physicsBody.pinned = YES;
    self.physicsBody.restitution = 0.01;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = beaconCategory;
    self.physicsBody.collisionBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall;
    self.physicsBody.contactTestBitMask = batCategory|ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall;
    self.physicsBody.dynamic = YES;

    [[GameScene sceneInstance] addChild:self];
    
    [[GameScene sceneInstance].bricksAndObjects addObject:self];
    [[GameScene sceneInstance].beacons addObject:self];
    
    float fallOff = 3.0 - (self.size.width/40.0);
    if (fallOff < 1.8) {
        fallOff = 1.8;
    }
    if (fallOff > 6.0) {
        fallOff = 6.0;
    }
    self.col = color;
    self.light = [[GameScene factoryInstance] createLightNoAdd:fallOff category:4 ambientColor:0.0 lightColor:1.0 shadowColor:0.2];
    self.light.zPosition = 10;
    if (color == WHITE) {
        self.light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.03];
    } else if (color == RED) {
        self.light.lightColor = [[UIColor alloc] initWithRed:1.0 green:0.1 blue:0.1 alpha:0.03];
    } else if (color == GREEN) {
        self.light.lightColor = [[UIColor alloc] initWithRed:0.1 green:1.0 blue:0.1 alpha:0.03];
    } else if (color == BLUE) {
        self.light.lightColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:1.0 alpha:0.03];
    }
    
#ifndef LIGHTS_DISABLED
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        [self addChild:self.light];
    }
#endif

    return self;
}

// collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    [super onCollision:otherParty impact:impact]; // collision damage + check if ignite happens
    
    // additional code here
}

// ignite happened
-(void)onBurn
{
}

-(void)powerUp
{
    if (self.poweredUp == NO) { // check if we already have light
        self.poweredUp = YES;

        int player = BEACON_POWER_UP;
        if (self.size.width <= 30) {
            player = [[GameScene soundManagerInstance] play:NO playerNum:BEACON_POWER_UP_SMALL];
            self.timeInterval = 0.125;
            self.sampleTime = 12.5;
        } else if (self.size.width >= 100) {
            player = [[GameScene soundManagerInstance] play:NO playerNum:BEACON_POWER_UP_LARGE];
            self.timeInterval = 0.5;
            self.sampleTime = 46;
        } else {
            player = [[GameScene soundManagerInstance] play:NO playerNum:BEACON_POWER_UP];
            self.timeInterval = 0.25;
            self.sampleTime = 23;
        }
        [[GameScene soundManagerInstance] setVolume:1.0 playerNum:player];
        
        [[GameScene gameLogicInstance] addScore:POINTS_FOR_BEACON_POWERUP pos:self.position];
        [[GameScene gameLogicInstance] updateStatusBar];
        
        float alpha = 0.1;
        // scale light gradually to full intensity
        [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                         target:self
                                       selector:@selector(onLightIntensityScaleUp:)
                                       userInfo:[NSNumber numberWithFloat:alpha]
                                        repeats:NO];
        
        
        [GameScene sceneInstance].beaconCount--;
        if ([GameScene sceneInstance].beaconCount == 0 && [GameScene gameLogicInstance].gameRunning) {
            [GameScene sceneInstance].levelCompleteTimer = [NSTimer scheduledTimerWithTimeInterval:self.sampleTime // wait for sample to finish
                                             target:[GameScene gameLogicInstance]
                                           selector:@selector(onLevelCompleted:)
                                           userInfo:nil
                                            repeats:NO];
        }
    }
}

-(void)onLightIntensityScaleUp:(NSTimer*)timer
{
    if ([GameScene gameLogicInstance].gameIsOver == YES) {
        return;
    }
    
    float alpha = [timer.userInfo floatValue];
    alpha = alpha+(1.0/(23*4));

    float r,g,b;
    if (self.col == RED) {
        r = 1.0;
        g = 0.1;
        b = 0.1;
    } else if (self.col == GREEN) {
        r = 0.1;
        g = 1.0;
        b = 0.1;
    } else if (self.col == BLUE) {
        r = 0.1;
        g = 0.1;
        b = 1.0;
    } else {
        r = 1.0;
        g = 1.0;
        b = 1.0;
    }

    if (alpha >= 0.9 && self.fire.particleBirthRate == 0) {
#ifndef DISABLE_PARTICLES
        self.fire.particleZPosition = 200;
        if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
            self.fire.particleBirthRate = 200;
        } else {
            self.fire.particleBirthRate = 20;
        }
        self.fire.particleColor = [[UIColor alloc] initWithRed:r green:g blue:b alpha:1.0];
        self.fire.particlePositionRange = CGVectorMake(self.size.width/2, self.size.height/2);
#endif
    }
    
    if (alpha < 0.9) {
        self.light.lightColor = [[UIColor alloc] initWithRed:r green:g blue:b alpha:alpha/2];
    } else {
        self.light.lightColor = [[UIColor alloc] initWithRed:r green:g blue:b alpha:alpha];
    }
    [self.physicsBody applyTorque:self.physicsBody.mass * 1.5];
//    [self.physicsBody applyAngularImpulse:400.0];
    
    if (alpha >= 1.0) {
        // set up a shader
        //self.shader = [GameScene sceneInstance].beaconShader;
        return; // done
    }
//    info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:alpha], @"alpha", light, @"lightNode", nil];

    // XXX TODO: make ball light source shadows less dark, or it looks bad when there's another bright light
    // insert code here
    
    
    // scale light towards full intensity
    [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                     target:self
                                   selector:@selector(onLightIntensityScaleUp:)
                                   userInfo:[NSNumber numberWithFloat:alpha]
                                    repeats:NO];
}

@end
