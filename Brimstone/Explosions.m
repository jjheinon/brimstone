//
//  Explosions.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "Explosions.h"
#import "Shaders.h"
#import "GameScene.h"
#import "Constants.h"
#import "SoundManager.h"

@implementation Explosions

-(void)setup
{
#ifndef LIGHTS_DISABLED
    // XXX TODO: no scale for light cached
    SKLightNode* light = [[GameScene factoryInstance] createLightNoAdd:1 category:1 ambientColor:0.5 lightColor:1.0 shadowColor:0.2];
    light.ambientColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.1 alpha:0.5];
    light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    self.light = light;
#endif
    
/*#ifndef DISABLE_SHADERS
    SKSpriteNode* s = [SKSpriteNode spriteNodeWithImageNamed:@"wood.png"];
    s.size = [[GameScene sceneInstance] size];
    s.position = CGPointMake(0,0);
    s.zPosition = 1000;
    s.lightingBitMask = 0;
    s.shadowCastBitMask = 0;
    s.shadowedBitMask = 0;
    s.shader = [GameScene shaderInstance].bigExplosionShader;
    
    self.shaderContainer = s;
#endif*/
    
/*    self.bigExplosionShader = [SKShader shaderWithFileNamed:@"bigexplosion.fsh"];
 
     SKSpriteNode *s = [[SKSpriteNode alloc] init];
    s.size = [GameScene sceneInstance].scene.size;
    s.zPosition = -1;
    s.lightingBitMask = 0;
    s.shadowCastBitMask = 0;
    s.shadowedBitMask = 0;
    s.blendMode = SKBlendModeAlpha;
    s.shader = self.bigExplosionShader;
    [[GameScene sceneInstance].scene addChild:s];
    self.bigExplosionSprite = s;*/
}

-(void)explodeObject:(GameObject*)node yield:(float)yield
{
    SKAction* wait = [SKAction waitForDuration:(arc4random()%100)/100.0+0.1];
    // throw objects around
    SKAction* explosionForce = [SKAction runBlock:^ {
        
        SKFieldNode *expNode = [[SKFieldNode alloc] init];
        expNode.categoryBitMask = 1;
        
        expNode.enabled = YES;
        
        for(GameObject *piece in [GameScene sceneInstance].bricksAndObjects) {
            if (piece != nil) {
                float xdiff = piece.position.x - node.position.x;
                float ydiff = piece.position.y - node.position.y;
                float distanceSquare = xdiff*xdiff + ydiff*ydiff;
                float distance = sqrt(distanceSquare);
                
                if (distance == 0 || distanceSquare == 0 || distance >= 100) {
                    continue;
                }
                CGVector impulse = CGVectorMake(xdiff / distance, ydiff / distance);
                float multiplier = yield*5000.0/distanceSquare;
                
                impulse.dx = impulse.dx * multiplier;
                impulse.dy = impulse.dy * multiplier;
                
                if (multiplier >= 10000) {
                    multiplier = 10000;
                }
                
                SKAction* w = [SKAction waitForDuration:(arc4random()%20)*0.2+0.05];
                SKAction* r = [SKAction runBlock:^{
                    [piece onCollision:nil impact:impulse]; // try to ignite the object
                }];
                [[GameScene sceneInstance] runAction:[SKAction sequence: @[w,r]]];
                
                NSLog(@"Distance was %f, Impulse was %f,%f", distance, impulse.dx, impulse.dy);
                [piece.physicsBody applyImpulse:impulse];
            }
        }
    }];
    SKAction* sequence = [SKAction sequence:@[wait, explosionForce]];
    [[GameScene sceneInstance].scene runAction:sequence];
    
#ifndef LIGHTS_DISABLED
    // flash the scene
    if (self.light != nil && self.light.parent == nil) {
        [node addChild:self.light];
    }
#endif
/*    self.bigExplosionSprite.position = CGPointMake([GameScene sceneInstance].scene.size.width/2, [GameScene sceneInstance].scene.size.height/2);
    self.bigExplosionSprite.zPosition = 1000;
  */
  /*  if (self.shaderContainer != nil && self.shaderContainer.parent == nil) {
        [[GameScene sceneInstance].scene addChild:self.shaderContainer];
        // with this shader: pos -0.25,-0.25 = top right corner, 0.25,0.25 = bottom left
        float px = -(((node.position.x)/[GameScene sceneInstance].scene.size.width/2)-0.25);
        float py = (((node.position.y)/[GameScene sceneInstance].scene.size.height/2)-0.25);
        
        self.shaderContainer.shader.uniforms = @[[SKUniform uniformWithName:@"position" floatVector3:GLKVector3Make(px, py, 0)], [SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        
//        self.shaderContainer.position = node.position;
    }*/
    
    // create explosion effect
    [[GameScene factoryInstance] createExplosion:node.position.x withY:node.position.y size:node.size.width];
    
    node.zPosition = -1; // hide it, but not "Hide" as otherwise the light source would be hidden as well
    node.physicsBody.dynamic = NO; // disable collisions for hidden object
    
    // play explosion sound
//    [[GameScene soundManagerInstance] play:NO playerNum:EXPLOSION];
  //  [[GameScene soundManagerInstance] setVolume:1.0 playerNum:EXPLOSION];
    
    [[GameScene soundManagerInstance] playSound:@"explosion.mp3"];
    
    // more smoke after blow up
//    node.fire.numParticlesToEmit = 100*scale;
  //  node.smoke.numParticlesToEmit = 10*scale;

    [[GameScene factoryInstance] deleteAfter:node delay:0.5+(arc4random()%100)/100.0];
    return;
}

@end

