//
//  MenuLogic.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_MenuLogic_h
#define Brimstone_MenuLogic_h

#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"

@class Highscores;
@class BonusFeatures;

@interface MenuLogic : SKNode

-(void)mainMenu;
-(void)onMainMenuExit:(NSTimer*)timer;

//-(void)runExit:(NSTimer*)timer;

-(void)showHelpScreen;
-(void)exitHelpScreen;

-(void)showLevelIntroText;
-(void)showHighscores;
-(void)exitHighscores;

-(void)showAbout;
-(void)exitAbout;

-(void)showBonusScreen;
-(void)updateProductInfo:(NSArray*)products;
-(void)doInAppPurchase;
-(void)restorePurchase;
-(void)showSelectLevelMenu:(int)level;
-(void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;

-(void)exitSelectLevelMenu;

-(void)updateScores;
-(void)showInfoText:(CGPoint)pos text:(NSString*)text;
-(void)showPointsInfoText:(CGPoint)pos text:(NSString*)text;

-(void)createChain:(SKSpriteNode*)plaque isLeft:(Boolean)isLeft;

-(void)checkIfChainMakesSound:(NSTimer*)timer;

-(void)showInAppPurchaseMenu;
-(void)exitInAppPurchaseMenu;

-(void)showError:(NSString*)error;

@property SKSpriteNode* menu;
@property SKSpriteNode* node; // high score screen root node
@property SKSpriteNode* textContainer; // high score screen child of root node

@property float scrollIndex;

@property float scaleSpeed;
@property NSMutableArray* smokeArr;

@property SKLabelNode* levelIntroText;
@property SKLabelNode* levelIntroText2;
@property SKSpriteNode* levelIntroDesc; // multiline text converted to sprite

@property SKSpriteNode* helpScreen;
@property SKSpriteNode* helpArrow;

// for inAppPurchase view
@property SKSpriteNode* touchedNode; // for dragging on InAppPurchase view
@property CGPoint touchStartPos; // for dragging on InAppPurchase view
@property CGPoint touchedNodePos; // for dragging on InAppPurchase view
@property CGVector touchedNodeVelocity; // for dragging on InAppPurchase view
@property NSTimer* chainTimer;
@property CGVector lastPlaqueVelocity;
@property SKSpriteNode* leftAnchor; // chain anchors
@property SKSpriteNode* rightAnchor;
@property SKSpriteNode* inAppOverlay; // black overlay

@property NSMutableArray* chain1;
@property NSMutableArray* chain2;

@property float cTime; // temp

@property Boolean initialized; // has main screen been initialized once
@property CGSize origRes; // screen res at startup

@property UIPanGestureRecognizer* panGesture;

// inAppPurchaseView ends

@property Boolean inAppPurchaseClicked;
@property Boolean restorePurchaseClicked;

@property Highscores* highscores;
@property NSMutableArray* highscoreData;
@property int playerHighscoreRanking; // current player ranking at top 100 list

@property NSMutableDictionary* levelHighScores; // per level high scores

@property SKSpriteNode* levelImage;

@property SKSpriteNode* shaderContainer;

@property BonusFeatures* bonusFeatures;

@property NSString* inAppTitle;
@property NSString* inAppDesc;
@property NSString* inAppPrice;


@property SKSpriteNode* plaque;


@property GameViewController* gameViewController;

@end

#endif
