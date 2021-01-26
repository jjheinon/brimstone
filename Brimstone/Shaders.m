//
//  Shaders.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "Shaders.h"
#import "GameScene.h"
#import "GameLogic.h"

@implementation Shaders

-(void)setup
{
#ifndef DISABLE_SHADERS
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        
        /*    self.beaconShader = [SKShader shaderWithFileNamed:@"beaconglow.fsh"];
         self.beaconShader.uniforms = @[
         [SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([scene size].width, [scene size].height, 0)],
         ];
         */
        self.currTime = 0;
        
        SKShader *exp = [SKShader shaderWithFileNamed:@"smoke_fullscreen.fsh"]; //bigexplosion.fsh"];
        exp.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.fullscreenSmokeShader = exp;

        SKShader *exp1 = [SKShader shaderWithFileNamed:@"smoke_fullscreen2.fsh"]; //bigexplosion.fsh"];
        exp1.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)], [SKUniform uniformWithName:@"currentTimeUniform" float:self.currTime]];
        self.fullscreenSmokeShader2 = exp1;
        
/*        SKShader *exp2 = [SKShader shaderWithFileNamed:@"fire_fullscreen.fsh"]; //bigexplosion.fsh"];
        exp2.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.bigfireShader = exp2;
        
        SKShader *exp3 = [SKShader shaderWithFileNamed:@"bigexplosion.fsh"];
        exp3.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.bigExplosionShader = exp3;
  */
        SKShader *exp4 = [SKShader shaderWithFileNamed:@"snow.fsh"];
        exp4.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.snowShader = exp4;
        
    /*    SKShader *exp5 = [SKShader shaderWithFileNamed:@"glowing.fsh"];
        exp5.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.glowingShader = exp5;
        
        SKShader *exp6 = [SKShader shaderWithFileNamed:@"water.fsh"];
        exp6.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.waterShader = exp6;
        
        SKShader *exp7 = [SKShader shaderWithFileNamed:@"glow.fsh"];
        exp7.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.glowShader = exp7;
        
        SKShader *exp8 = [SKShader shaderWithFileNamed:@"windy.fsh"];
        exp8.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.windyShader = exp8;
        
        SKShader *exp9 = [SKShader shaderWithFileNamed:@"main_glow.fsh"];
        exp9.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];
        self.mainGlowShader = exp9;*/
    }
#endif
}


@end
