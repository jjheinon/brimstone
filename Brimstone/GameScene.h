//
//  GameScene.h
//  Brimstone
//


//

#ifndef Brimstone_GameScene_h
#define Brimstone_GameScene_h

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>

#import "ObjectFactory.h"

#import "GameViewController.h"


@class CMMotionManager;
@class GameLogic;
@class MenuLogic;
@class SoundManager;
@class Explosions;
@class Shaders;
@class Bat;

@class GameViewController;

@interface GameScene : SKScene
<SKPhysicsContactDelegate>

+(instancetype)unarchiveFromFile:(NSString *)file;

// static class definitions for managers
+(GameScene*)sceneInstance;
+(ObjectFactory*)factoryInstance;
+(GameLogic*)gameLogicInstance;
+(MenuLogic*)menuLogicInstance;
+(SoundManager*)soundManagerInstance;
+(Explosions*)explosionManagerInstance;
+(Shaders*)shaderInstance;

-(void)showMainScene;

//-(void)orientationChanged:(NSNotification *)notification;

-(void)initLevel:(int)level;
-(void)updateBallLights;

-(void)hideAllSprites;
-(void)showAllSprites;


@property float orientation;
@property CMMotionManager* motionManager;

@property CGVector gravityDirection;

//@property Boolean mainMenuVisible;


@property NSMutableArray* menuItems;
@property SKSpriteNode* startButton;
@property SKLabelNode* copyrightText;

@property SKSpriteNode* aboutMenuHelpButton;
@property SKSpriteNode* aboutMenuBackButton;
@property SKSpriteNode* bonusScreenBackButton;
@property SKSpriteNode* bonusScreenMainMenuButton;
@property SKSpriteNode* bonusScreenContinueButton;
@property SKSpriteNode* selectLevelBackButton;
@property SKSpriteNode* selectLevelPrevButton;
@property SKSpriteNode* selectLevelNextButton;
@property SKSpriteNode* inAppPurchaseButton;
@property SKSpriteNode* inAppPurchaseBackButton;
@property SKSpriteNode* restorePurchaseButton;
@property SKSpriteNode* helpOKButton;

@property Boolean mainMenuClicked;

@property int beaconCount;
@property int spreadingFireCount;

@property SKSpriteNode* bat; // container node for mask and bat sprite (parent)
//@property SKSpriteNode* batMask; // crop mask for bat (for burning effects)
@property Bat* batSprite; // actual bat sprite

@property NSMutableArray* ball;
@property NSMutableArray* ballFireEmitter;
@property NSMutableArray* ballSmokeEmitter;

@property NSMutableArray* sparks;
@property NSMutableArray* hotSparks;
@property int currentSparkIndex;
@property int currentHotSparkIndex;

@property NSMutableArray* beacons;

@property NSMutableArray* firePixelColumns; // for main screen logo

@property float batTargetX;
@property float batCurrentlyMovingToX;

@property NSMutableArray* bricksAndObjects;

@property NSMutableArray* burningObjects;
@property NSTimer* burnTimer;
@property NSTimer* levelCompleteTimer;

-(CGSize)screenSize;
-(CGSize)sceneSize;

-(Boolean)isLowPerfMode;

@property SKSpriteNode* menuPanel;
@property CGPoint oldTouchLocation;
@property CGPoint oldNodeLocation;

@property SKSpriteNode* menuBackground;
@property SKSpriteNode* bonusScreenBackground;
@property SKSpriteNode* selectLevelBackground;

@property SKSpriteNode* tmp;
@property SKSpriteNode* tmpParent;


@property NSTimeInterval lastImpulseApplied;

@property CGPoint oldpos;
@end


#endif
