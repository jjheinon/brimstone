//
//  ObjectFactory.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "ObjectFactory.h"
#import "Constants.h"
#import "GameScene.h"

#import "Crate.h"
#import "WoodBrick.h"
#import "WallBrick.h"
#import "Beacon.h"
#import "OilBarrel.h"
#import "Tree.h"
#import "Ball.h"
#import "Bat.h"
#import "Bonus.h"
#import "WoodShard.h"
#import "GameLogic.h"

@implementation ObjectFactory

-(GameObject*)createBat:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node
{
    Bat* bat = [Bat spriteNodeWithImageNamed:@"Bat"];
    [bat onCreate:x withY:y scale:scale spriteNode:nil];
    return bat;
}

-(SKEmitterNode*)createFire:(float)x withY:(float)y
{
    NSString *fireEmitterPath = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
    SKEmitterNode *fireEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:fireEmitterPath];
    fireEmitter.particlePosition = CGPointMake(x, y);
    //fireEmitter.name = @"fireEmitter"; //[NSString stringWithFormat:@"batFireEmitter%d",i];
    fireEmitter.particleZPosition = 20;
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        fireEmitter.particleBirthRate = 10;
    } else {
        fireEmitter.particleBirthRate = 2;
    }
    fireEmitter.targetNode = [GameScene sceneInstance];
    return fireEmitter;
}

-(SKEmitterNode*)createSmoke:(float)x withY:(float)y
{
    NSString *smokeEmitterPath = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
    SKEmitterNode *smokeEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:smokeEmitterPath];
    smokeEmitter.particlePosition = CGPointMake(x, y);
    smokeEmitter.name = @"smokeEmitter";
    smokeEmitter.particleZPosition = 100; // smoke needs to be on top
    smokeEmitter.particleBirthRate = 0;
    smokeEmitter.targetNode = [GameScene sceneInstance];
    return smokeEmitter;
}

-(SKEmitterNode*)createSpark:(float)x withY:(float)y color:(UIColor*)color
{
    NSString *sparkEmitterPath = [[NSBundle mainBundle] pathForResource:@"Spark" ofType:@"sks"];
    SKEmitterNode *sparkEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:sparkEmitterPath];
    sparkEmitter.particlePosition = CGPointMake(x, y);
    sparkEmitter.name = @"sparkEmitter";
    if (color != nil) {
        sparkEmitter.particleColor = color;
    }
    sparkEmitter.particleZPosition = 20;
    
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        sparkEmitter.particleBirthRate = 200;
    } else {
        sparkEmitter.particleBirthRate = 20;
    }
    sparkEmitter.numParticlesToEmit = 1;
    sparkEmitter.targetNode = [GameScene sceneInstance];
    
    return sparkEmitter;
}

-(SKEmitterNode*)createExplosion:(float)x withY:(float)y size:(float)size
{
    NSString *expEmitterPath = [[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"];
    SKEmitterNode *expEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:expEmitterPath];
    expEmitter.particlePosition = CGPointMake(x, y);
    expEmitter.name = @"explosionEmitter";
    expEmitter.particleZPosition = 900;
    expEmitter.targetNode = [GameScene sceneInstance];
    expEmitter.particlePositionRange = CGVectorMake(size*3/4, size*3/4);
    [[GameScene sceneInstance] addChild:expEmitter];
    
    NSString *smokeEmitterPath = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
    SKEmitterNode *smokeEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:smokeEmitterPath];
    smokeEmitter.position = CGPointMake(x, y);
    smokeEmitter.name = @"smokeEmitter";
    smokeEmitter.particleZPosition = 15;
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        smokeEmitter.particleBirthRate = 50;
        smokeEmitter.numParticlesToEmit = 250;
    } else {
        smokeEmitter.particleBirthRate = 10;
        smokeEmitter.numParticlesToEmit = 50;
    }
    smokeEmitter.targetNode = [GameScene sceneInstance];
    smokeEmitter.particlePositionRange = CGVectorMake(size*3/4, size*3/4);
    [[GameScene sceneInstance] addChild:smokeEmitter];

  /*  [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(onReduceSmoke:)
                                   userInfo:smokeEmitter
                                    repeats:NO];
    */
    return expEmitter;
}

-(void)onReduceSmoke:(NSTimer *)timer {
    SKEmitterNode *smokeEmitter = (SKEmitterNode*)[timer userInfo];
    if (smokeEmitter == nil) {
        return;
    }
    float rate = smokeEmitter.particleBirthRate;
    rate = rate - 50;
//    NSLog(@"Reducing smoke %f",rate);
    if ((int)rate <= 0) {
        rate = 0;
        smokeEmitter.particleBirthRate = rate;
        return;
    }
    smokeEmitter.particleBirthRate = rate;
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(onReduceSmoke:)
                                   userInfo:smokeEmitter
                                    repeats:NO];
}

-(GameObject *)createBall:(GameObject*)ob
{
    Ball* ball = [Ball spriteNodeWithImageNamed:@"BallBody"];
    if (ob == nil) {
        [ball onCreate:0 withY:0 scale:1.0 spriteNode:ob ignite:NO]; // let's not ignite at level start
    } else {
        [ball onCreate:ob.position.x withY:ob.position.y scale:1.0 spriteNode:ob ignite:YES]; // let's ignite, ball created during game (target ob exists)
    }
    
    return ball;
}

-(GameObject*)createCrate:(float)x withY:(float)y scale:(float)scale
{
    Crate* crate = [Crate spriteNodeWithImageNamed:@"Crate"];
    [crate onCreate:x withY:y scale:scale spriteNode:nil];
    return crate;
}

-(GameObject*)createOilBarrel:(float)x withY:(float)y scale:(float)scale
{
    OilBarrel* barrel = [OilBarrel spriteNodeWithImageNamed:@"Oil_Barrel"];
    [barrel onCreate:x withY:y scale:scale spriteNode:nil];

    return barrel;
}

-(GameObject*)createTree:(float)x withY:(float)y scale:(float)scale
{
    Tree* tree = [Tree spriteNodeWithImageNamed:@"BallBody"];
    [tree onCreate:x withY:y scale:scale spriteNode:nil];
    return tree;
}

-(GameObject*)createBeacon:(float)x withY:(float)y scale:(float)scale
{
    Beacon* beacon = [Beacon spriteNodeWithImageNamed:@"Beacon"];
    [beacon onCreate:x withY:y scale:scale spriteNode:nil];
    return beacon;
}

-(GameObject*)createBonus:(float)x withY:(float)y scale:(float)scale
{
    Bonus* bonus = [Bonus spriteNodeWithImageNamed:@"Bonus"];
    [bonus onCreate:x withY:y scale:scale spriteNode:nil];
    return bonus;
}


-(void)createWall:(SKSpriteNode *)wall stone:(Boolean)stone
{
    float w = wall.size.width;
    float h = wall.size.height;
    
    for (int ypos=0; ypos<h;) {
        float h = 100.0;
        for (int xpos=0; xpos<w;) {
            NSString* name;
            
            float scale = 1.0;
            GameObject* b;
            if (stone == YES) {
                name = [NSString stringWithFormat:@"Brick%d", ((arc4random()%3)+1)];
                b = [WallBrick spriteNodeWithImageNamed:name];
                scale = 0.25;
            } else {
                name = [NSString stringWithFormat:@"Sandstone1"];
                b = [WoodBrick spriteNodeWithImageNamed:name];
            }
            [b onCreate:0 withY:0 scale:scale spriteNode:nil];
            b.position = CGPointMake(xpos + wall.position.x-wall.size.width/2, ypos + wall.position.y-wall.size.height/2);
            b.zPosition = 10;
            
            xpos = xpos + b.size.width+1;
            
            h = b.size.height;
        }
        ypos = ypos + h+1;
    }
}



-(SKLightNode*)createLight:(SKNode*)node falloff:(int)falloff category:(uint32_t)category ambientColor:(float)ambientColor lightColor:(float)lightColor shadowColor:(float)shadowColor
{
    SKLightNode* light = [[SKLightNode alloc] init];
#ifndef LIGHTS_DISABLED
    light.name = @"light";
    light.categoryBitMask = category;
    light.falloff = falloff;
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        light.zPosition = 15;
    } else {
        light.zPosition = 1;
    }
    light.ambientColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.0 alpha:ambientColor];
    light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:lightColor];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:shadowColor];
    
    //light.ambientColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.1 alpha:0.6];
    //      light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.2];
    //    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    [node addChild:light];
#endif
    return light;
}

// just create the light, don't add to node
-(SKLightNode*)createLightNoAdd:(int)falloff category:(uint32_t)category ambientColor:(float)ambientColor lightColor:(float)lightColor shadowColor:(float)shadowColor
{
    SKLightNode* light = [[SKLightNode alloc] init];
#ifndef LIGHTS_DISABLED
    light.name = @"light";
    light.categoryBitMask = category;
    light.falloff = falloff;
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        light.zPosition = 15;
    } else {
        light.zPosition = 1;
    }
    light.ambientColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.0 alpha:ambientColor];
    light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:lightColor];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:shadowColor];
#endif
    return light;
}

// deletes object after delay seconds
-(void)deleteAfter:(GameObject*)ob delay:(float)delay
{
    [NSTimer scheduledTimerWithTimeInterval:delay
                                     target:self
                                   selector:@selector(onDelayedDelete:)
                                   userInfo:ob
                                    repeats:NO];
}

-(void)onDelayedDelete:(NSTimer*)timer
{
    // let's not really destroy the ob as it is very slow. Instead, hide it.
    GameObject* ob = timer.userInfo;
    if (ob != nil && ob.parent != nil) {
     //   NSLog(@"Deleting object");
//        [ob removeFromParent];
        SKLightNode* light = (SKLightNode*)[ob childNodeWithName:@"light"];
        if (light != nil) {
            light.hidden = YES;
        }
        SKEmitterNode* fire = (SKEmitterNode*)[ob childNodeWithName:@"fireEmitter"];
        if (fire != nil) {
            fire.numParticlesToEmit = 0;
            fire.hidden = YES;
        }
        SKEmitterNode* smoke = (SKEmitterNode*)[ob childNodeWithName:@"smokeEmitter"];
        if (smoke != nil) {
            smoke.numParticlesToEmit = 0;
            smoke.hidden = YES;
        }
        ob.physicsBody = nil;
        
        if (ob.leavesCorpse == NO) {
            ob.hidden = YES;
        }
        [[GameScene sceneInstance].bricksAndObjects removeObject:ob];
       // NSLog(@"Objects remaining %d", [[GameScene sceneInstance].bricksAndObjects.count] );
    }
}

-(void)createWoodOrIceShards:(GameObject*)ob
{
//    NSLog(@"creating shards");
    float w = ob.size.width;
    float h = ob.size.height;

    // create shards in front of the moving object to get better splatter effect and more flying shards
    float xdiff = ob.physicsBody.velocity.dx/30.0f;
    float ydiff = ob.physicsBody.velocity.dy/30.0f;

    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int ypos=0; ypos<h;) {
        float h = 100.0;
        for (int xpos=0; xpos<w;) {
            NSString* name;
            
            float scale = 0.8 + (arc4random()%40/100);
            GameObject* b;
            if (ob.isMadeOfIce == YES) {
                name = [NSString stringWithFormat:@"iceshard%d", ((arc4random()%2)+1)];
            } else {
                name = [NSString stringWithFormat:@"shard%d", ((arc4random()%5)+1)];
            }
            b = [WoodShard spriteNodeWithImageNamed:name];
            [b onCreate:xdiff + xpos + ob.position.x-ob.size.width/2 withY: ydiff + ypos + ob.position.y-ob.size.height/2 scale:scale spriteNode:ob];

/*            if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
                xpos = xpos + b.size.width/2 + 1;
                h = b.size.height/2;
            } else {*/
                xpos = xpos + b.size.width + 1;
                h = b.size.height;
//            }
            [arr addObject:b];
        }
        ypos = ypos + h+1;
    }
    SKAction *w2 = [SKAction waitForDuration:0.5];
    SKAction *modify = [SKAction runBlock:^{
        for (int i=0; i<arr.count; i++) {
            GameObject *ob = [arr objectAtIndex:i];
            ob.physicsBody.categoryBitMask = 0; // stop collisions
        }
    }];
    SKAction *w3 = [SKAction waitForDuration:3.5];
    SKAction *stop = [SKAction runBlock:^{
        for (int i=0; i<arr.count; i++) {
            GameObject *ob = [arr objectAtIndex:i];
            ob.physicsBody = nil; // render shards immobile
            
            // TODO: merge objects to background texture here
        }
    }];
    [[GameScene sceneInstance].scene runAction:[SKAction sequence: @[w2, modify]]];
    [[GameScene sceneInstance].scene runAction:[SKAction sequence: @[w3, stop]]];
}

@end
