//
//  Shaders.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Shaders_h
#define Brimstone_Shaders_h

#import <SpriteKit/SpriteKit.h>

@interface Shaders : NSObject


@property float currTime;

@property SKShader* circleShader;
@property SKShader* beaconShader;
@property SKShader* fullscreenSmokeShader;  // smoke for intro screen
@property SKShader* fullscreenSmokeShader2; // smoke for main screen
@property SKShader* bigfireShader; // fire for end of game screen
@property SKShader* bigExplosionShader;
@property SKShader* snowShader; // snow for level intro
@property SKShader* glowingShader; // main menu (not used)
@property SKShader* glowShader; // bonus
@property SKShader* waterShader;
@property SKShader* windyShader; // snow for level intro
@property SKShader* mainGlowShader; // main screen

-(void)setup;

@end
#endif
