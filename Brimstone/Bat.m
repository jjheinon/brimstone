//
//  Bat.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "Bat.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "MenuLogic.h"
#import "SoundManager.h"

@implementation Bat

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node
{
    [self setScale:0.6];
    self.zPosition = 21; //80;
    self.fastPaddle = NO;

    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.lightingBitMask = 1+2+4+8+16;
        self.shadowCastBitMask = 1;
        self.shadowedBitMask = 1+2+4+8;
    } else {
        self.lightingBitMask = 1+2+4+8+16;
        self.shadowCastBitMask = 0;
        self.shadowedBitMask = 1+2+4+8;
    }

    self.blendMode = SKBlendModeAlpha;//Replace;
    
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.name = @"bat";
    self.physicsBody.dynamic = NO;
    self.physicsBody.mass = 1000;
    self.physicsBody.categoryBitMask = batCategory;
    self.physicsBody.collisionBitMask = ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.physicsBody.contactTestBitMask = ballCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|brickCategoryButNoCollisionWithBall|chainCategory;
    self.position = CGPointZero;
    
    [GameScene sceneInstance].batSprite = self;
    
    [GameScene sceneInstance].bat = self;
    [GameScene sceneInstance].bat.position = CGPointMake(x, y);
    
    self.batFires = [[NSMutableArray alloc] init];
    self.batSmokes = [[NSMutableArray alloc] init];
    
    for (int i=0; i<BAT_FIRE_REGIONS; i++) {
        float x = (i-2)*self.size.width/4 + self.size.width/8;
        SKEmitterNode* fire = [[GameScene factoryInstance] createFire:x withY:self.size.height/2];
        fire.particleBirthRate = 0;
        fire.particleZPosition = 89;
        [self.batFires addObject:fire];
        [self addChild:fire];

        SKEmitterNode* smoke = [[GameScene factoryInstance] createSmoke:x withY:self.size.height/2];
        smoke.particleBirthRate = 0;
        smoke.particleZPosition = 125;
        [self.batSmokes addObject:smoke];
        [self addChild:smoke];
    }
    
    self.flammability = 80;
    if (self.flammability <= 20) {
        self.flammability = 20;
    }
    self.impactThreshold = self.physicsBody.mass*10;
    
    self.burnSpeed = 50;
    self.turnsToAshesAt = self.physicsBody.mass*3;
    self.initialFireAmount = 0;
    self.initialSmokeAmount = 0;
    
    self.physicalHealth = 50000;
    self.generatesShardsWhenDestroyed = YES; // destroy bat in pieces when health == 0
    self.aboutToGetDestroyedOnImpact = YES; // let's bounce once when we destroy the bat so user gets a warning. ..but cannot do anything about it.
    
    self.canBeDamaged = YES;
    
    self.light = [[GameScene factoryInstance] createLight:self falloff:5.0 category:16 ambientColor:0.0 lightColor:0.0 shadowColor:0.0];
    
    [[GameScene sceneInstance] addChild:[GameScene sceneInstance].bat];
    
    return self;
}

// collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact pos:(int)pos
{
    if (self.fastPaddle == NO) {
       [super onCollision:otherParty impact:impact]; // collision damage + check if ignite happens
    }
    
    // additional code here
    if (abs((int)impact.dx)>=MIN_VELOCITY_TO_PLAY_SFX || abs((int)impact.dy)>MIN_VELOCITY_TO_PLAY_SFX) { // don't play sound fx if too small velocity to avoid series of impact sounds when touching the object
        
        if (self.fastPaddle == YES) {
            [[GameScene soundManagerInstance] playSound:@"metal-bat-hit.mp3"];
        } else {
            [[GameScene soundManagerInstance] playSound:@"wood-hit-crack.mp3"];
        }
    }
    
    [self burnAt:pos spreading:NO];
}

-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    [self onCollision:otherParty impact:impact pos:0];
    
    NSLog(@"bat health %d", self.physicalHealth);
}

-(void)burnAt:(int)pos spreading:(Boolean)spreading
{
    if (self.fastPaddle == YES) {
        return;
    }
    if (self.isOnFire == NO) {
        self.light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.6];
    }
    
    self.isOnFire = YES;
    
    Boolean spread = NO;
    SKEmitterNode* fire = [self.batFires objectAtIndex:pos];
    SKEmitterNode* smoke = [self.batSmokes objectAtIndex:pos];
    
    int br = fire.particleBirthRate;
    int lastBr = br;
    
    br = br + 5;
    if (br > 50) {
        br = 50;
        spread = YES;
    }
    if (lastBr != br) { // don't update if we were already at max
        fire.particleBirthRate = br;
        smoke.particleBirthRate = br/3;
        float range = fire.particlePositionRange.dx + 5;
        if (range > self.size.width/BAT_FIRE_REGIONS) {
            range = self.size.width/BAT_FIRE_REGIONS;
        }
        fire.particlePositionRange = CGVectorMake(range, 0);
        smoke.particlePositionRange = CGVectorMake(range, 0);
    }
    if (spread == YES && spreading == NO) { // spread only if we arrived here at direct collision, prevent looping
        if (pos>0) {
            [self burnAt:pos-1 spreading:YES];
        }
        if (pos<BAT_FIRE_REGIONS-1) {
            [self burnAt:pos+1 spreading:YES];
        }
    }
    [[GameScene gameLogicInstance] checkBurningObjectsCount];

    self.currentFireDamage = self.currentFireDamage + self.burnSpeed;
    
  //  NSLog(@"bat fire damage %d", self.currentFireDamage);
    
    if (self.currentFireDamage > self.turnsToAshesAt) {
        if (self.destroy == NO) {
            self.destroy = YES;
            [self onDestroy];
        }
    }
}

-(void)upgradePaddle
{
    self.fastPaddle = YES;
    self.texture = [SKTexture textureWithImageNamed:@"Bat-metal"];
    [self removeAllActions];
    self.zRotation = 0;
    self.isOnFire = NO;
    self.currentFireDamage = 0;
    self.canBeDamaged = NO;
    self.physicalHealth = 50000;
    self.flammability = 0;
    
    for (int i=0; i<self.batFires.count; i++) {
        SKEmitterNode* fire = [self.batFires objectAtIndex:i];
        fire.numParticlesToEmit = 1;
    }
    for (int i=0; i<self.batSmokes.count; i++) {
        SKEmitterNode* smoke = [self.batSmokes objectAtIndex:i];
        smoke.numParticlesToEmit = 1;
    }
    [[GameScene soundManagerInstance] playSound:@"power-up.mp3"];
}

-(void)downgradePaddle
{
    self.fastPaddle = NO;    
    self.texture = [SKTexture textureWithImageNamed:@"Bat"];
    [self removeAllActions];
    self.zRotation = 0;
    self.canBeDamaged = YES;
    self.flammability = 80;
    
    if ([GameScene gameLogicInstance].gameRunning == YES) {
        [[GameScene soundManagerInstance] playSound:@"power-down.mp3"];
    }
}

// ignite happened
-(void)onBurn
{
//    [super onBurn];
}

-(void)onDestroy
{
    [[GameScene sceneInstance].burningObjects removeObject:self];
    self.hidden = YES;
    self.physicsBody = nil;
    for (int i=0; i<self.batFires.count; i++) {
        SKEmitterNode* fire = [self.batFires objectAtIndex:i];
        fire.numParticlesToEmit = 1;
    }
    for (int i=0; i<self.batSmokes.count; i++) {
        SKEmitterNode* smoke = [self.batSmokes objectAtIndex:i];
        smoke.numParticlesToEmit = 1;
    }
    [[GameScene gameLogicInstance] checkBurningObjectsCount]; // update sound volume
    
    [[GameScene menuLogicInstance] showInfoText:[GameScene sceneInstance].bat.position text:@"Paddle destroyed!"];
}

@end
