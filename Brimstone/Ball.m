//
//  Ball.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "Ball.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "SoundManager.h"

@implementation Ball

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node ignite:(Boolean)ignite
{
    long count = [GameScene sceneInstance].ball.count;
    CGPoint pos = CGPointMake([GameScene sceneInstance].scene.size.width/2+count*20, BALL_START_YPOS);
    if (node != nil) {
        pos = CGPointMake(node.position.x, node.position.y);
    }
    
    // screen size iphone 6 375 x 667
    // scene size also set to 375 x 667
    GameScene* scene = [GameScene sceneInstance];
    self.name = @"ball";
    self.position = pos;
    self.zPosition = 11;
    self.size = CGSizeMake(15, 15);
    self.alpha = 1.0;
    self.physicalHealth = 10000000;
    self.canBeDamaged = NO;
    
    SKConstraint* constraint = [SKConstraint positionX:[SKRange rangeWithLowerLimit:0.0 upperLimit:scene.size.width] Y: [SKRange rangeWithLowerLimit:-BOTTOM_PIT_DEPTH-50 upperLimit:scene.size.height]];
    self.constraints = @[constraint];

    self.blendMode = SKBlendModeAlpha;
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
    self.physicsBody.mass = 5;
    self.physicsBody.linearDamping = 0.0f;
    self.physicsBody.angularDamping = 0.0f;
    self.physicsBody.restitution = 1.0f;
    self.physicsBody.friction = 0.0;
    self.physicsBody.allowsRotation = YES;
    self.physicsBody.affectedByGravity = NO; // disabled on create, enable later
    self.physicsBody.dynamic = NO; // disabled on create, enable later

    self.physicsBody.categoryBitMask = ballCategory;
    self.physicsBody.collisionBitMask = batCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|ballCategory|woodShardCategory|chainCategory;
    self.physicsBody.contactTestBitMask = batCategory|brickCategory|edgeCategory|beaconCategory|barrelCategory|treeTrunkCategory|bonusCategory|ballCategory|chainCategory;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.lightingBitMask = 1+8;
    self.shadowCastBitMask = 0;
    [scene.ball addObject:self];
    [scene addChild:self];

    NSString *fireEmitterPath = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
    SKEmitterNode *fireEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:fireEmitterPath];
    fireEmitter.position = CGPointZero;
    fireEmitter.name = @"fireEmitter";
    fireEmitter.particleZPosition = 20;
    fireEmitter.targetNode = scene;
    fireEmitter.particleBirthRate = 0;
    self.fireEmitter = fireEmitter;
    [scene.ballFireEmitter addObject:fireEmitter];
    [self addChild: fireEmitter];

    NSString *smokeEmitterPath = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
    SKEmitterNode *smokeEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:smokeEmitterPath];
    smokeEmitter.position = CGPointZero;
    smokeEmitter.name = @"smokeEmitter";
    smokeEmitter.particleZPosition = 15;
    smokeEmitter.particleBirthRate = 0;
    smokeEmitter.targetNode = scene;

    self.smokeEmitter = smokeEmitter;
    [scene.ballSmokeEmitter addObject:smokeEmitter];
    [self addChild: smokeEmitter];

    SKEmitterNode* spark = [[GameScene factoryInstance] createSpark:0 withY:0 color:nil];
    spark.hidden = YES;
    spark.zPosition = -100;
    [[GameScene sceneInstance].sparks addObject:spark];
    [scene addChild:spark];
    
    SKEmitterNode* hotSpark = [[GameScene factoryInstance] createSpark:0 withY:0 color:[UIColor whiteColor]];
    hotSpark.hidden = YES;
    hotSpark.zPosition = -100;
    [[GameScene sceneInstance].hotSparks addObject:hotSpark];
    [scene addChild:hotSpark];

#ifndef DISABLE_FIREBALL
    [[GameScene factoryInstance] createLight:fireEmitter falloff:4.0 category:1 ambientColor:0.01 lightColor:0.01 shadowColor:0.35];
#endif

    if (ignite == YES) {
        [self ignite]; // light it up
    }
    [[GameScene sceneInstance] updateBallLights];
    return self;
}

-(void)ignite
{
#ifndef LIGHTS_DISABLED
    SKLightNode* light = (SKLightNode*)[self.fireEmitter childNodeWithName:@"light"];
    light.falloff = 1.8;
    light.ambientColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.1 alpha:0.1];
    light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.3 alpha:1.0];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.15];
#endif
#ifndef DISABLE_FIREBALL
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.fireEmitter.particleBirthRate = 200;
        self.smokeEmitter.particleBirthRate = 20;
    } else {
        self.fireEmitter.particleBirthRate = 20;
        self.smokeEmitter.particleBirthRate = 5;
    }
#endif
    self.isOnFire = YES;    
}

// superhot ball -bonus
-(void)igniteSuperHot
{
#ifndef LIGHTS_DISABLED
    SKLightNode* light = (SKLightNode*)[self.fireEmitter childNodeWithName:@"light"];
    light.falloff = 1.8;
    light.ambientColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.1 alpha:0.1];
    light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.25];
#endif
#ifndef DISABLE_FIREBALL
    self.fireEmitter.particleColor = [UIColor whiteColor];
    self.smokeEmitter.particleBirthRate = 0;
#endif
    self.isSuperHot = YES;
    
    [[GameScene soundManagerInstance] playSound:@"multiball.mp3"];
    
    // double the speed
    [self.physicsBody applyImpulse: CGVectorMake(self.physicsBody.velocity.dx, self.physicsBody.velocity.dy)];
    self.isOnFire = YES;
}

-(void)disableSuperHot
{
    // back to normal
#ifndef LIGHTS_DISABLED
    SKLightNode* light = (SKLightNode*)[self.fireEmitter childNodeWithName:@"light"];
    light.falloff = 1.8;
    light.ambientColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.1 alpha:0.1];
    light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.3 alpha:1.0];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.25];
#endif
#ifndef DISABLE_FIREBALL
//    redComponent	double	0.30486425757408142	0.30486425757408142
  //  greenComponent	double	0.13019143044948578	0.13019143044948578
   // blueComponent	double	0.023160237818956375	0.023160237818956375
    self.fireEmitter.particleColor = [UIColor colorWithRed:0.30486425757408142 green:0.13019143044948578 blue:0.023160237818956375 alpha:1.0];
    //      self.fireEmitter.particleBirthRate = 200;
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.smokeEmitter.particleBirthRate = 20;
    } else {
        self.smokeEmitter.particleBirthRate = 5;
    }
#endif
    self.isSuperHot = NO;
}

-(void)decreaseBrightness:(NSTimer*)timer
{
    if (self.brightness > 0.0) {
        self.brightness = self.brightness - 0.1;
    } else {
        self.fireEmitter.particleBirthRate = 0;
        return;
    }
    self.fireEmitter.particleBirthRate = self.fireEmitter.particleBirthRate * 0.9;
#ifndef LIGHTS_DISABLED
    SKLightNode* light = (SKLightNode*)[self.fireEmitter childNodeWithName:@"light"];
    light.falloff = 4 - self.brightness*2;
    light.ambientColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.1 alpha:0.01];
    light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.3 alpha:self.brightness];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.01];
#endif

    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(decreaseBrightness:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)snuffOut
{
    self.brightness = 1.0;
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(decreaseBrightness:)
                                   userInfo:nil
                                    repeats:NO];
#ifndef DISABLE_FIREBALL
    self.fireEmitter.particleBirthRate = self.fireEmitter.particleBirthRate * 0.9;
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.smokeEmitter.particleBirthRate = 40;
    } else {
        self.smokeEmitter.particleBirthRate = 10;
    }
#endif
    self.isOnFire = NO;
    [[GameScene soundManagerInstance] playSound:@"hiss.mp3"];
}


// collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    
    // additional code here
}

-(void)enableMovements
{
#ifndef DISABLE_BALL_MOVEMENTS
    self.physicsBody.affectedByGravity = YES;
    self.physicsBody.dynamic = YES;
#endif
}

// ignite happened
-(void)onBurn
{
//    [super onBurn];
}

-(void)onDestroy
{
}

@end
