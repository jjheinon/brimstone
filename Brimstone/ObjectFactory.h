//
//  ObjectFactory.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_ObjectFactory_h
#define Brimstone_ObjectFactory_h

#import <SpriteKit/SpriteKit.h>
#import "GameObject.h"

@interface ObjectFactory : NSObject

-(GameObject*)createBat:(float)x withY:(float)y scale:(float)scale spriteNode:(SKSpriteNode*)node;
-(GameObject*)createBall:(GameObject*)ob;


-(SKEmitterNode*)createFire:(float)x withY:(float)y;
-(SKEmitterNode*)createSmoke:(float)x withY:(float)y;

-(SKEmitterNode*)createSpark:(float)x withY:(float)y color:(UIColor*)color;
-(SKEmitterNode*)createExplosion:(float)x withY:(float)y size:(float)size;

-(GameObject*)createCrate:(float)x withY:(float)y scale:(float)scale;
-(GameObject*)createBeacon:(float)x withY:(float)y scale:(float)scale;
-(void)createWall:(SKSpriteNode *)wall stone:(Boolean)stone;
-(GameObject*)createOilBarrel:(float)x withY:(float)y scale:(float)scale;
-(GameObject*)createTree:(float)x withY:(float)y scale:(float)scale;

-(SKLightNode*)createLight:(SKNode*)node falloff:(int)falloff category:(uint32_t)category ambientColor:(float)ambientColor lightColor:(float)lightColor shadowColor:(float)shadowColor;

-(SKLightNode*)createLightNoAdd:(int)falloff category:(uint32_t)category ambientColor:(float)ambientColor lightColor:(float)lightColor shadowColor:(float)shadowColor;

-(void)deleteAfter:(GameObject*)ob delay:(float)delay;

-(void)createWoodOrIceShards:(GameObject*)ob;
@end

#endif
