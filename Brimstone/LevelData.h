//
//  LevelData.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_LevelData_h
#define Brimstone_LevelData_h

#include "GameScene.h"

@interface LevelData : NSObject

+(SKShader*)getShaderForLevelIntro:(long)level;
+(NSString*)getLevelIntroText:(long)level;

@end

#endif
