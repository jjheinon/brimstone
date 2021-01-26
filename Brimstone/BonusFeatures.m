//
//  BonusFeatures.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import <Foundation/Foundation.h>
#include "BonusFeatures.h"
#include "GameScene.h"
#include "Bonus.h"
#include "Shaders.h"
#include "Ball.h"
#include "Bat.h"
#include "WoodBrick.h"
#include "MenuLogic.h"
#include "GameLogic.h"

@implementation BonusFeatures

-(void)setup
{
    if (self.featureButtons != nil) {
        for (int i=0; i<self.featureButtons.count; i++) {
            [[self.featureButtons objectAtIndex:i] removeFromParent];
        }
    }
    self.featureButtons = [[NSMutableArray alloc] init];
    self.hotBallCount = 0;
    self.paddleUpgradeCount = 0;
    
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(activateBonus:)];
    [gesture setDirection:(UISwipeGestureRecognizerDirectionUp)];
    
    self.gesture = gesture;
//    NSMutableArray *gestureRecognizers = [NSMutableArray array];
  //  [gestureRecognizers addObject:gesture];
    [[GameScene sceneInstance].view addGestureRecognizer:self.gesture];
}

-(void)reCreate
{
//    [[GameScene sceneInstance].view removeGestureRecognizer:self.gesture];
   // self.gesture = nil;
    for (int i=0; i<self.featureButtons.count; i++) {
        [[self.featureButtons objectAtIndex:i] removeFromParent];
    }
    [self.featureButtons removeAllObjects];
//    [node removeFromParent];
    
    if (self.hotBallCount > 0) {
        [[GameScene menuLogicInstance].bonusFeatures addBonusFeature:SUPERHOT_BALL node:nil];
        self.hotBallCount--;
    }
    if (self.paddleUpgradeCount > 0) {
        [[GameScene menuLogicInstance].bonusFeatures addBonusFeature:FAST_PADDLE_UPGRADE node:nil];
        self.paddleUpgradeCount--;
    }
}

-(void)unhideBonusFeatures
{
    for (int i=0; i<self.featureButtons.count; i++) {
        SKSpriteNode *ob = (SKSpriteNode*)[self.featureButtons objectAtIndex:i];
        ob.hidden = NO;
    }
}

-(void)hideBonusFeatures
{
    for (int i=0; i<self.featureButtons.count; i++) {
        SKSpriteNode *ob = (SKSpriteNode*)[self.featureButtons objectAtIndex:i];
        ob.hidden = YES;
    }
}

-(void)removeBonusFeatures
{
    for (int i=0; i<self.featureButtons.count; i++) {
        [[self.featureButtons objectAtIndex:i] removeFromParent];
    }
    [self.featureButtons removeAllObjects];
    self.hotBallCount = 0;
    self.paddleUpgradeCount = 0;
}

-(void)addBonusFeature:(enum BonusType)type node:(Bonus*)bonus
{
    SKSpriteNode *bonusButton;
    if (type == SUPERHOT_BALL) {
        self.hotBallCount++;
        bonusButton = [SKSpriteNode spriteNodeWithImageNamed:@"bonus_red"];
        bonusButton.name = @"EXTRA_HOT_BALL";
        bonusButton.position = CGPointMake([GameScene sceneInstance].frame.size.width*0.9, 35);
    } else if (type == FAST_PADDLE_UPGRADE) {
        self.paddleUpgradeCount++;
        bonusButton = [SKSpriteNode spriteNodeWithImageNamed:@"bonus_red_paddle"];
        bonusButton.name = @"PADDLE_UPGRADE";
        bonusButton.position = CGPointMake([GameScene sceneInstance].frame.size.width*0.7, 35);
    } else {
        return;
    }
    bonusButton.scale = 0.8;
    bonusButton.zPosition = 3001;
    
    if (bonus != nil) {
        bonus.physicsBody = nil;
        [bonus removeFromParent];

        bonusButton.alpha = 0.0;
        SKAction* fade = [SKAction fadeAlphaTo:1.0 duration:1.0];
        [bonusButton runAction: fade];
        
/*        SKAction* w = [SKAction waitForDuration:1.0];
        SKAction* remove = [SKAction runBlock:^{
            if (bonus.parent != nil) {
                [bonus removeFromParent];
            }
        }];
        [[GameScene sceneInstance] runAction:[SKAction sequence:@[w, remove]]];*/
    }

    [self.featureButtons addObject:bonusButton];
    [[GameScene sceneInstance] addChild:bonusButton];
    
}

-(void)activateBonus:(UIGestureRecognizer*)sender
{
    if ([GameScene gameLogicInstance].levelStarted == NO &&
        [GameScene gameLogicInstance].helpScreenVisible == NO) {
        return;
    }
    
    CGPoint touchLocation = [sender locationInView:sender.view];
    touchLocation = [[GameScene sceneInstance] convertPointFromView:touchLocation];
    SKSpriteNode *node = (SKSpriteNode *)[[GameScene sceneInstance] nodeAtPoint:touchLocation];
    
    if (node == nil) {
        return;
    }
    if ([node.name isEqualToString:@"EXTRA_HOT_BALL"]) {
        if (self.hotBallCount > 0) {
            for (int i=0; i<[GameScene sceneInstance].ball.count; i++) {
                Ball* b = [[GameScene sceneInstance].ball objectAtIndex:i];
                [b removeAllActions]; // remove old actions
                if (b.isOnFire == NO) {
                    [b ignite];
                }
                [b igniteSuperHot];
            }
            for (int i=0; i<[GameScene sceneInstance].bricksAndObjects.count; i++) {
                SKNode* n = [[GameScene sceneInstance].bricksAndObjects objectAtIndex:i];
                if ([n.name isEqualToString:@"crate"] || [n.name isEqualToString:@"woodbrick"]) {
                    // change these back when hot ball ends
                    ((WoodBrick*)n).physicsBody.categoryBitMask = brickCategoryButNoCollisionWithBall;
                    ((WoodBrick*)n).aboutToGetDestroyedOnImpact = YES;
                }
            }

            // disable super hot balls after 20 seconds:
            SKAction* w = [SKAction waitForDuration:20.0];
            SKAction* disable = [SKAction runBlock:^{
                for (int i=0; i<[GameScene sceneInstance].ball.count; i++) {
                    Ball* b = [[GameScene sceneInstance].ball objectAtIndex:i];
                    [b disableSuperHot];
                }
                
                for (int i=0; i<[GameScene sceneInstance].bricksAndObjects.count; i++) {
                    SKNode* n = [[GameScene sceneInstance].bricksAndObjects objectAtIndex:i];
                    if ([n.name isEqualToString:@"crate"] || [n.name isEqualToString:@"woodbrick"]) {
                        // change these back when hot ball ends
                        ((WoodBrick*)n).physicsBody.categoryBitMask = brickCategory;
                        ((WoodBrick*)n).aboutToGetDestroyedOnImpact = NO;
                    }
                }
                
            }];
            [[GameScene sceneInstance] runAction:[SKAction sequence:@[w,disable]]];
            
            self.hotBallCount--;
            if (self.hotBallCount <= 0) {
                [self.featureButtons removeObject:node];
                [node removeFromParent];
            }
/*            if (self.featureButtons.count == 0) {
                [[GameScene sceneInstance].view removeGestureRecognizer:self.gesture];
                self.gesture = nil;
            }*/
        }
        return;
    }
    if ([node.name isEqualToString:@"PADDLE_UPGRADE"]) {
        
        if (self.paddleUpgradeCount > 0) {
            [[GameScene sceneInstance].batSprite upgradePaddle];
            
            // disable after 60 seconds:
            SKAction* w = [SKAction waitForDuration:60.0];
            SKAction* disable = [SKAction runBlock:^{
               [[GameScene sceneInstance].batSprite downgradePaddle];
            }];
            [[GameScene sceneInstance] runAction:[SKAction sequence:@[w,disable]]];
            
            self.paddleUpgradeCount--;
            if (self.paddleUpgradeCount <= 0) {
                [self.featureButtons removeObject:node];
                [node removeFromParent];
            }
/*            if (self.featureButtons.count == 0) {
                [[GameScene sceneInstance].view removeGestureRecognizer:self.gesture];
                self.gesture = nil;
            }*/
        }
        return;
    }
    
    [self.featureButtons removeObject:node];
    [node removeFromParent];
}
@end
