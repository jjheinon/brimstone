//
//  GameLogic.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_GameLogic_h
#define Brimstone_GameLogic_h

#import <SpriteKit/SpriteKit.h>
#import "ObjectFactory.h"
#import "GameScene.h"

@interface GameLogic : SKNode

@property int lives;
@property int currentLevel;
@property int score;
@property int levelScore; // score collected from current level (for high scores)
@property int levelsCompleted;

@property SKLabelNode* label;
@property SKLabelNode* label2;

@property SKLabelNode* statusBarLives;
@property SKLabelNode* statusBarLevel;
@property SKLabelNode* statusBarScore;

@property Boolean levelComplete;
@property Boolean mainMenuVisible;
@property Boolean highScoresVisible;
@property Boolean aboutMenuVisible;
@property Boolean bonusScreenVisible;
@property Boolean selectLevelMenuVisible;
@property Boolean inAppPurchaseMenuVisible;

@property Boolean helpScreenVisible;

@property Boolean gameRunning;
@property Boolean playerDied;
@property Boolean gameIsOver;
@property Boolean levelStarted; // ball launched and bonuses can be activated

@property int updateIndex;

@property Boolean statusBarDirty;
@property NSTimer* statusBarTimer;

@property UIImage* theScreenshotImage;

@property Boolean LOW_PERFORMANCE_MODE;

-(void)onLevelPrepareStart:(NSTimer *)timer;
-(void)onLevelStart:(NSTimer *)timer;
-(void)onLevelStarted:(NSTimer *)timer;
-(void)updateStatusBar;

-(void)onLevelCompleted:(NSTimer *)timer;
//-(void)onNextLevel:(NSTimer*)timer;

-(void)pauseGame;
-(void)resumeGame;

-(void)death;
-(void)gameOver;

-(void)nextLevel;
-(void)retryLevel;

-(void)onFireGrows:(NSTimer *)timer;
-(void)checkBurningObjectsCount;
-(void)addScore:(int)score pos:(CGPoint)position;

@end

#endif
