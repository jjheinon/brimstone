//
//  LevelData.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import <Foundation/Foundation.h>
#include "LevelData.h"
#include "GameScene.h"
#include "Shaders.h"

@implementation LevelData

+(SKShader*)getShaderForLevelIntro:(long)level
{
    if (level >= 5 && level <= 13) {
        return [GameScene shaderInstance].snowShader;
    } /*else if (level == 6) {
        return [GameScene shaderInstance].windyShader;
    }*/
    return nil;
}

+(NSString*)getLevelIntroText:(long)level
{
    NSString *str;
    switch (level)
    {
        case 1:
            str = NSLocalizedString(@"Banish the darkness by lighting up the beacons!", "Instructions for the player to light up the light sources.");
            break;
        case 2:
            str = NSLocalizedString(@"Break the crates to find special objects!", "Instructions for the player to break the boxes to find useful objects.");
            break;
        case 3:
            str = NSLocalizedString(@"Break the crates to find special objects!", "Instructions for the player to break the boxes to find useful objects.");
            break;
        case 4:
            str = NSLocalizedString(@"Break the crates to find special objects!", "Instructions for the player to break the boxes to find useful objects.");            break;
        case 5:
            str = NSLocalizedString(@"Wintertime. Collect upgrades for future levels.", "Instructions for the player.");
            break;
        case 6:
            str = NSLocalizedString(@"Beware of water barrels!", "Instructions for the player to avoid water barrels.");
            break;
        case 7:
            str = NSLocalizedString(@"Break the crates.", "Instructions for the player to break the boxes");
            break;
        case 8:
            str = NSLocalizedString(@"Break the doors to get the reward.", "Instructions for the player to break doors.");
            break;
        case 9:
            str = NSLocalizedString(@"Multicolor.", "Level introduction");
            break;
        case 10:
            str = NSLocalizedString(@"Bigger beacon.", "Level introduction");
            break;
        case 11:
            str = NSLocalizedString(@"Ice, ice, ice.", "Level introduction");
            break;
        default:
            str = NSLocalizedString(@"Banish the darkness by lighting up the beacons!", "Instructions for the player to light up the light sources.");
    }
    return str;
}

      
@end
