//
//  Chain.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "Chain.h"
#import "Constants.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "SoundManager.h"

@implementation Chain

-(GameObject*)onCreate:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node
{
    int ypos = y;
    
    GameObject *prev = nil;
    
    GameObject *ob = nil;
    for (int i=0; i<=25; i++) {
        
        ob = [GameObject spriteNodeWithImageNamed: [NSString stringWithFormat:@"chain%d", ((i+1)%2+1)]];
        ob.name = @"chain";
        ob.position = CGPointMake(x, ypos);
        ob.scale = scale;
        
        self.flammability = 0; // does not ignite
        self.impactThreshold = 0; // does not break
        self.canBeDamaged = NO;
        self.physicalHealth = 10000;
        
        ob.zPosition = 47+((i+1)%2);
        ob.physicsBody = [SKPhysicsBody
                          bodyWithRectangleOfSize:
                          ob.size];
        ob.physicsBody.affectedByGravity = YES;
        ob.physicsBody.mass = 1;
        ob.physicsBody.linearDamping = 0.5f;
        ob.physicsBody.angularDamping = 0.5f;
        ob.physicsBody.restitution = 0.5f;
        ob.physicsBody.friction = 0.5;
        ob.physicsBody.allowsRotation = YES;
        
        ob.lightingBitMask = 1+4;
        ob.shadowedBitMask = 4;
        ob.shadowCastBitMask = 0;
    
        ob.physicsBody.categoryBitMask = chainCategory;
        ob.physicsBody.collisionBitMask = batCategory|ballCategory|brickCategory|edgeCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall;
        ob.physicsBody.contactTestBitMask = batCategory|ballCategory|brickCategory|edgeCategory|barrelCategory|treeTrunkCategory|brickCategoryButNoCollisionWithBall;
        ob.physicsBody.dynamic = YES;
        
        [[GameScene sceneInstance] addChild:ob];
        
        if (i == 0) {
            CGPoint pos;
            pos = CGPointMake(x, ob.position.y - ob.size.height/2 + 3);
            SKPhysicsJointPin* jointLast = [SKPhysicsJointPin jointWithBodyA:ob.physicsBody
                                                                       bodyB:node.physicsBody
                                                                      anchor:pos];
            [[GameScene sceneInstance].physicsWorld addJoint:jointLast];
        }
        
        //[self.chain1 addObject:ob];
        
        SKPhysicsBody* bodyA;
        if (i == 0)
        {
            bodyA = node.physicsBody;
        }
        else
        {
            bodyA = prev.physicsBody;
        }
        prev = ob;
        
        if (i == 25 || ypos > [GameScene sceneInstance].sceneSize.height) {
            GameObject * anchor = [GameObject spriteNodeWithImageNamed:@"EmptyBody"];
            anchor.position = CGPointMake(x, ypos);
            anchor.size = CGSizeMake(1, 1);
            anchor.zPosition = 9001;
            anchor.physicsBody = [SKPhysicsBody
                                  bodyWithRectangleOfSize:
                                  anchor.size];
            anchor.physicsBody.affectedByGravity = NO;
            anchor.physicsBody.mass = 999999999;
            [[GameScene sceneInstance] addChild:anchor];
            
            SKPhysicsJointPin* joint = [SKPhysicsJointPin jointWithBodyA:ob.physicsBody bodyB:anchor.physicsBody anchor:CGPointMake(ob.position.x, ob.position.y - ob.size.height/2 - 3)];
            [[GameScene sceneInstance].physicsWorld addJoint:joint];
            i = 25; // break out of the loop
        }
        SKPhysicsJointPin* joint = [SKPhysicsJointPin jointWithBodyA:bodyA bodyB:ob.physicsBody anchor:CGPointMake(ob.position.x, ob.position.y - ob.size.height/2 - 3)];
        [[GameScene sceneInstance].physicsWorld addJoint:joint];
        
        ypos = ypos + ob.size.height-5;
    }
    return nil;
}

// collision with other object happened
-(void)onCollision:(GameObject *)otherParty impact:(CGVector)impact
{
    [super onCollision:otherParty impact:impact]; // collision damage + check if ignite happens
    // additional code here
    
    if (abs((int)impact.dx)>=MIN_VELOCITY_TO_PLAY_SFX || abs((int)impact.dy)>MIN_VELOCITY_TO_PLAY_SFX) { // avoid series of impact sounds when touching the object
        
        int r = arc4random()%3;
        if (r == 0) {
            [[GameScene soundManagerInstance] playSound:@"chain-link1.mp3"];
        } else if (r == 1) {
            [[GameScene soundManagerInstance] playSound:@"chain-link2.mp3"];
        } else {
            [[GameScene soundManagerInstance] playSound:@"chain-link3.mp3"];
        }
    }
}


@end
