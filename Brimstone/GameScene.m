//
//  GameScene.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import <CoreMotion/CoreMotion.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#import "GameScene.h"
#import "GameLogic.h"
#import "MenuLogic.h"
#import "SoundManager.h"
#import "Explosions.h"

#import "Constants.h"
#import "Explosions.h"
#import "Shaders.h"

#import "Beacon.h"
#import "OilBarrel.h"
#import "Crate.h"
#import "WoodBrick.h"
#import "WallBrick.h"
#import "Tree.h"
#import "Bonus.h"
#import "Ball.h"
#import "Bat.h"
#import "Highscores.h"
#import "IceCube.h"
#import "WaterBarrel.h"

#import "InAppPurchase.h"
#import "BonusFeatures.h"

static Boolean initialized;

@implementation GameScene

+ (instancetype)unarchiveFromFile:(NSString *)file {
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    
    GameScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}


- (CGSize)screenSize {
    if ([GameScene menuLogicInstance].initialized == YES) {
 //       return [GameScene sceneInstance].scene.size;
    }
   /*     CGSize ores = [GameScene menuLogicInstance].origRes;
        if (ores.width/ores.height != [GameScene sceneInstance].scene.size.width/[GameScene sceneInstance].scene.size.height) {
     */
//            float aspect = (ores.width/ores.height) / ([GameScene sceneInstance].scene.size.width/[GameScene sceneInstance].scene.size.height);
/*            CGSize newres = CGSizeMake([GameScene sceneInstance].scene.size.width / *aspect, [GameScene sceneInstance].scene.size.height);
            return newres;
        }*/
/*        float aspect = [[UIScreen mainScreen] currentMode].size.width/[[UIScreen mainScreen] currentMode].size.height;
        float aspect2 = [GameScene sceneInstance].scene.size.width/[GameScene sceneInstance].scene.size.height;
        float mult = aspect/aspect2;*/
   /*     return CGSizeMake([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height);
    }*/
//    CGSize screenSize = CGSizeMake([[UIScreen mainScreen] currentMode].size.width,
  //                                 [[UIScreen mainScreen] currentMode].size.height);
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    // In some cases width and height are reversed on portrait mode, here we fix it
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}

-(void)showMainScene
{
    //if (self.initialized == YES) {
    [GameScene sceneInstance].scene.size = [[UIScreen mainScreen] bounds].size; //[[UIScreen mainScreen] currentMode].size; //CGSizeMake(320, 480);
    [GameScene sceneInstance].scene.scaleMode = SKSceneScaleModeAspectFit; // hack
    //}

    /*    SKView* skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    SKScene *scene = [GameScene unarchiveFromFile:@"MainScene"];
    scene.scaleMode = SKSceneScaleModeResizeFill;
    
    // Present the scene.
    [skView presentScene:scene];*/
}

-(CGSize)sceneSize
{
    return [GameScene sceneInstance].scene.frame.size;
}

static GameScene* gameScene;
static ObjectFactory* factory;
static GameLogic* gameLogic;
static MenuLogic* menuLogic;
static SoundManager* soundManager;
static Explosions* explosionManager;
static Shaders* shaderInstance;


+(GameScene*)sceneInstance {
    return gameScene;
}

+(ObjectFactory*)factoryInstance {
    return factory;
}

+(GameLogic*)gameLogicInstance {
    return gameLogic;
}

+(MenuLogic*)menuLogicInstance {
    return menuLogic;
}

+(SoundManager*)soundManagerInstance {
    return soundManager;
}

+(Explosions*)explosionManagerInstance {
    return explosionManager;
}

+(Shaders*)shaderInstance {
    return shaderInstance;
}

-(void)initLevel:(int)level
{
    NSLog(@"removeAllChildren");
    [[GameScene sceneInstance].scene removeAllChildren]; // clear all old stuff
    [[GameScene sceneInstance] removeAllChildren]; // clear all old stuff
    NSLog(@"removeAllChildren done");
    self.mainMenuClicked = NO;

    self.view.alpha = 0.0;
    
    NSString *file = [NSString stringWithFormat:@"Level%03d", level];
    NSLog(@"%@", file);
    GameScene *scene = [GameScene unarchiveFromFile:file];
    scene.scaleMode = SKSceneScaleModeAspectFit;

   /* NSArray* obs = [scene children];
    for (int i=0; i<obs.count; i++) {
        NSObject *o = [obs objectAtIndex:i];
        if ([o isKindOfClass:[SKSpriteNode class]]) {
            SKSpriteNode *n = (SKSpriteNode*)o;
            [n.texture preloadWithCompletionHandler:^{
                NSLog(@"Loaded");
            }];
        }
    }*/
    
    [self.view presentScene:scene];
    gameScene = scene;

    [[GameScene soundManagerInstance] stopAll];
    [[GameScene soundManagerInstance] preload:ALL]; // preload samples

    [GameScene gameLogicInstance].currentLevel = level;

    [GameScene sceneInstance].physicsWorld.speed = GAME_SPEED;

    [GameScene sceneInstance].beaconCount = 0;
    [GameScene sceneInstance].bricksAndObjects = [[NSMutableArray alloc] init];
    [GameScene sceneInstance].burningObjects = [[NSMutableArray alloc] init];
    [GameScene sceneInstance].beacons = [[NSMutableArray alloc] init];

    [GameScene sceneInstance].sparks = [[NSMutableArray alloc] init];
    [GameScene sceneInstance].hotSparks = [[NSMutableArray alloc] init];


    if ([GameScene sceneInstance].burnTimer != nil) {
        [[GameScene sceneInstance].burnTimer invalidate];
        [GameScene sceneInstance].burnTimer = nil;
    }

    [[GameScene menuLogicInstance].highscores retrieveLevelHighScoreForPlayer:level]; // fetch current high scores

    NSArray* obs = [scene children];
    for (int i=0; i<obs.count; i++) {
        NSObject *o = [obs objectAtIndex:i];
        if ([o isKindOfClass:[SKSpriteNode class]]) {
            SKSpriteNode *n = (SKSpriteNode*)o;
            n.physicsBody.affectedByGravity = NO;
            n.physicsBody.restitution = 0.0;
            n.physicsBody.friction = 1.0;
            n.physicsBody.dynamic = NO;
            n.physicsBody.linearDamping = 1.0;
            n.physicsBody.angularDamping = 1.0;
            n.physicsBody.categoryBitMask = 0;
            n.physicsBody.collisionBitMask = 0;
            n.physicsBody.contactTestBitMask = 0;
            
            if ([[n name] isEqualToString:@"background"]) {
           //     int rnd = arc4random() % 3;
                NSString* back;
                int bg = level%7;
                if (bg == 1) {
                    back = @"Background2";
                } else if (bg == 2) {
                    back = @"Background3";
                } else if (bg == 3) {
                    back = @"Background4";
                } else if (bg == 4) {
                    back = @"Background5";
                } else if (bg == 5) {
                    back = @"Background6";
                } else if (bg == 6) {
                    back = @"Background7";
                } else {
                    back = @"Background";
                }
                if (level>=5 && level<=13) {
                    back = @"Background-ice";
                }
                
                
                SKSpriteNode* b = [SKSpriteNode spriteNodeWithImageNamed:back normalMapped:TRUE];
                b.size = [scene size];
                b.position = CGPointMake(n.size.width/2, n.size.height/2);
                b.zPosition = 1;
                b.lightingBitMask = 1+2+4+8;
                b.shadowedBitMask = 1+2;
              //  b.blendMode = SKBlendModeReplace;

#ifdef ENABLE_SMOKE
#ifndef DISABLE_SHADERS
                /*if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
                    SKSpriteNode* shaderContainer = [SKSpriteNode spriteNodeWithImageNamed:@"EmptyBody"];
                    shaderContainer.size = [scene size];
                    shaderContainer.position = CGPointMake(n.size.width/2, n.size.height/2);
                    shaderContainer.zPosition = 1000;
                    shaderContainer.lightingBitMask = 0;
                    shaderContainer.shader = [GameScene shaderInstance].fullscreenSmokeShader;
                    
                    [scene addChild:shaderContainer];
                }*/
#endif
#endif
                [scene addChild:b];
                [n removeFromParent];
                
            } else if ([[n name] isEqualToString:@"beacon_template"]) {
                Beacon* ob = [Beacon spriteNodeWithImageNamed:@"Beacon"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n color:WHITE];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"beacon_template_chain"]) {
                Beacon* ob = [Beacon spriteNodeWithImageNamed:@"Beacon"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n color:WHITE];
                [ob createChain];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"beacon_template_chain_red"]) {
                Beacon* ob = [Beacon spriteNodeWithImageNamed:@"Beacon"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n color:RED];
                [ob createChain];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"beacon_template_chain_blue"]) {
                Beacon* ob = [Beacon spriteNodeWithImageNamed:@"Beacon"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n color:BLUE];
                [ob createChain];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"beacon_template_chain_green"]) {
                Beacon* ob = [Beacon spriteNodeWithImageNamed:@"Beacon"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n color:GREEN];
                [ob createChain];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"beacon_template_red"]) {
                Beacon* ob = [Beacon spriteNodeWithImageNamed:@"Beacon_red"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n color:RED];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"beacon_template_green"]) {
                Beacon* ob = [Beacon spriteNodeWithImageNamed:@"Beacon_green"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n color:GREEN];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"beacon_template_blue"]) {
                Beacon* ob = [Beacon spriteNodeWithImageNamed:@"Beacon_blue"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n color:BLUE];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"stonewall_template"]) {
                [[GameScene factoryInstance] createWall:n stone:YES];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"woodwall_template"]) {
                [[GameScene factoryInstance] createWall:n stone:NO];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"icecube_template"]) {
                IceCube* ob = [IceCube spriteNodeWithImageNamed:[NSString stringWithFormat:@"IceCube%d", (arc4random()%2)+1]];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"brick_template"]) {
                Crate* ob = [Crate spriteNodeWithImageNamed:@"Crate"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                ob.hasAlwaysBonus = NO;
                ob.bonusType = NONE;
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"brick_template_extralife"]) {
                Crate* ob = [Crate spriteNodeWithImageNamed:@"Crate"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                ob.hasAlwaysBonus = YES;
                ob.bonusType = EXTRA_LIFE;
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"brick_template_multiball"]) {
                Crate* ob = [Crate spriteNodeWithImageNamed:@"Crate"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                ob.hasAlwaysBonus = YES;
                ob.bonusType = MULTIBALL;
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"brick_template_superhot_ball"]) {
                Crate* ob = [Crate spriteNodeWithImageNamed:@"Crate"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                ob.hasAlwaysBonus = YES;
                ob.bonusType = SUPERHOT_BALL;
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"brick_template_paddle_upgrade"]) {
                Crate* ob = [Crate spriteNodeWithImageNamed:@"Crate"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                ob.hasAlwaysBonus = YES;
                ob.bonusType = FAST_PADDLE_UPGRADE;
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"brick_template_points"]) {
                Crate* ob = [Crate spriteNodeWithImageNamed:@"Crate"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                ob.hasAlwaysBonus = YES;
                ob.bonusType = BONUS_POINTS;
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"oilbarrel_template"]) {
                OilBarrel* ob = [OilBarrel spriteNodeWithImageNamed:@"Oil_Barrel"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"waterbarrel_template"]) {
                WaterBarrel* ob = [WaterBarrel spriteNodeWithImageNamed:@"Water_Barrel"];
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                [n removeFromParent];
            } else if ([[n name] isEqualToString:@"tree_template"]) {
                Tree* ob = [Tree spriteNodeWithImageNamed:@"BallBody"]; // ballbody = trunk, tree top is created as a child
                [ob onCreate:n.position.x withY:n.position.y scale:1.0 spriteNode:n];
                [n removeFromParent];
            } else {
                [n removeFromParent];
            }
        }
    }
    
    [self hideAllSprites];

    [GameScene sceneInstance].ball = [[NSMutableArray alloc] init];
    [GameScene sceneInstance].ballFireEmitter = [[NSMutableArray alloc] init];
    [GameScene sceneInstance].ballSmokeEmitter = [[NSMutableArray alloc] init];

    [factory createBall:nil];
    [factory createBat:[GameScene sceneInstance].scene.size.width/2 withY:BAT_START_YPOS scale:0.6 spriteNode:nil];

    self.batTargetX = 0;
    self.batCurrentlyMovingToX = 0;
    
    [GameScene sceneInstance].burnTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                           target:[GameScene gameLogicInstance]
                                                                         selector:@selector(onFireGrows:)
                                                                         userInfo:nil
                                                                          repeats:YES];
    
    SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, -BOTTOM_PIT_DEPTH, [[GameScene sceneInstance] sceneSize].width, [[GameScene sceneInstance] sceneSize].height+BOTTOM_PIT_DEPTH)];
    borderBody.usesPreciseCollisionDetection = YES; // see if this helps
    borderBody.affectedByGravity = NO;
    borderBody.categoryBitMask = edgeCategory;
    borderBody.collisionBitMask = ballCategory;
    borderBody.contactTestBitMask = ballCategory;
    borderBody.restitution = 1.0;
    scene.physicsBody = borderBody;
}

-(void)hideAllSprites
{
    NSArray* obs2 = [self.scene children];
    for (int i=0; i<obs2.count; i++) {
        NSObject *o = [obs2 objectAtIndex:i];
        if ([o isKindOfClass:[SKSpriteNode class]]) {
            SKSpriteNode *n = (SKSpriteNode*)o;
            n.hidden = YES;
        }
    }
}

-(void)showAllSprites
{
    NSArray* obs2 = [self.scene children];
    for (int i=0; i<obs2.count; i++) {
        NSObject *o = [obs2 objectAtIndex:i];
        if ([o isKindOfClass:[SKSpriteNode class]]) {
            SKSpriteNode *n = (SKSpriteNode*)o;
            n.hidden = NO;
        }
    }
}

-(void)didMoveToView:(SKView *)view {
    if (!initialized || factory == nil)
    {
        initialized = YES;
        NSLog(@"Initializing classes, resetting data");
        gameScene = (GameScene*)self;
        factory = [[ObjectFactory alloc]init];
        gameLogic = [[GameLogic alloc]init];
        menuLogic = [[MenuLogic alloc]init];
        soundManager = [[SoundManager alloc]init];
        [soundManager setup];

        shaderInstance = [[Shaders alloc]init];
        [shaderInstance setup];
        
        explosionManager = [[Explosions alloc]init];
        [explosionManager setup];
        
        [menuLogic.bonusFeatures setup];
        
        self.physicsWorld.gravity = CGVectorMake(0, -1.0 * GRAVITY);
        self.physicsWorld.speed = GAME_SPEED;
        
        gameLogic.lives = MAX_LIVES;
        
        self.batCurrentlyMovingToX = -1;

        [GameScene gameLogicInstance].LOW_PERFORMANCE_MODE = NO;
        if ([self isLowPerfMode] == YES) {
            [GameScene gameLogicInstance].LOW_PERFORMANCE_MODE = YES;
            self.view.frameInterval = 2; // 30 fps
        }
        
        [GameScene menuLogicInstance].highscoreData = [[NSMutableArray alloc] init]; // clean up first
        
        
#ifndef DISABLE_MAIN_MENU
        // release
        [[GameScene menuLogicInstance] mainMenu];
#else
        [GameScene gameLogicInstance].mainMenuVisible = YES;
        
        [[GameScene menuLogicInstance] onMainMenuExit:nil];
/*        [NSTimer scheduledTimerWithTimeInterval:0.0
                                         target:[GameScene menuLogicInstance]
                                       selector:@selector(onMainMenuExit:)
                                       userInfo:nil
                                        repeats:NO];*/
        
#endif
    }
    self.physicsWorld.contactDelegate = self;

    [self startDeviceMotionUpdates];
}

-(void)startDeviceMotionUpdates // gyroscope data for updating the flame
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.showsDeviceMovementDisplay = YES;

    CGFloat updateInterval = 1/60.0; // adjust 60 times a second
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        self.motionManager.deviceMotionUpdateInterval = 1.0/60.0; // for gyro
    } else {
        updateInterval = 1/30.0;
        self.motionManager.deviceMotionUpdateInterval = 1.0/30.0; // for gyro
    }
    NSOperationQueue* motionQueue = [[NSOperationQueue alloc] init];
    CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
    [self.motionManager setDeviceMotionUpdateInterval:updateInterval];
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:frame
                                                           toQueue:motionQueue
                                                       withHandler:

     ^(CMDeviceMotion* motion, NSError* error){
         CGFloat angle =  atan2( motion.gravity.x, motion.gravity.y) - M_PI;
         [GameScene sceneInstance].orientation = -(angle *(180.0 / M_PI)) ;//+ 90;
         if ([GameScene sceneInstance].orientation >= 360) {
             [GameScene sceneInstance].orientation = [GameScene sceneInstance].orientation - 360;
         }
         if ([GameScene gameLogicInstance].gameRunning == YES) {
           //  NSLog(@"device orientation: %f", self.orientation);
             if ([GameScene sceneInstance].orientation > 45 && [GameScene sceneInstance].orientation <= 180) { // don't allow bigger gravity orientation changes for ball or the game would be too easy
                 [GameScene sceneInstance].orientation = 45;
             }
             if ([GameScene sceneInstance].orientation < 315 && [GameScene sceneInstance].orientation > 180) {
                 [GameScene sceneInstance].orientation = 315;
             }
             [GameScene sceneInstance].gravityDirection = CGVectorMake(sin([GameScene sceneInstance].orientation*M_PI/180)*GRAVITY, -cos([GameScene sceneInstance].orientation*M_PI/180)*GRAVITY);  // for ball direction

//             NSLog([NSString stringWithFormat:@"orientation %f", [GameScene sceneInstance].orientation]);
         } else {
             // all orientations allowed for flame
             [GameScene sceneInstance].gravityDirection = CGVectorMake(sin([GameScene sceneInstance].orientation*M_PI/180)*GRAVITY, -cos([GameScene sceneInstance].orientation*M_PI/180)*GRAVITY); // for menus
         }
//        [GameScene sceneInstance].physicsWorld.gravity = self.gravityDirection;
     }];
}

//-(void)orientationChanged:(NSNotification *)notification
//{
//    self.orientation = [UIDevice currentDevice].orientation;
//}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // main menu user click:
    
    if ([GameScene gameLogicInstance].helpScreenVisible == YES) {
        
        NSLog(@"helpScreen menu visible, skipping main menu commands");
        for (UITouch *touch in touches) {
            
            CGPoint touchLocation = [touch locationInView:self.view];
            touchLocation = [[GameScene sceneInstance] convertPointFromView:touchLocation];
            SKNode *touchedNode = (SKNode *)[[GameScene sceneInstance] nodeAtPoint:touchLocation];
            
            if ([touchedNode isKindOfClass:SKLabelNode.class]) {
                touchedNode = touchedNode.parent;
            }
            
            if ([touchedNode.name isEqualToString:@"helpOKButton"]) {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] exitHelpScreen];
                return;
            }
        }
        return;
    }
    
    if ([GameScene gameLogicInstance].highScoresVisible == YES) {
        NSLog(@"High scores visible, skipping main menu commands");
        for (UITouch *touch in touches) {
/*            CGPoint location = [touch locationInNode:self];
            self.oldTouchLocation = location;
            self.oldNodeLocation = [GameScene menuLogicInstance].node.position;*/
            CGPoint touchLocation = [touch locationInView:self.view];
            touchLocation = [[GameScene sceneInstance] convertPointFromView:touchLocation];
            SKNode *touchedNode = (SKNode *)[[GameScene sceneInstance] nodeAtPoint:touchLocation];
            
            
//            if (location.x < 40 + 60 && location.y <= 80) { // back button
            if ([touchedNode.name isEqualToString:@"backButton"]) {
                
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] exitHighscores];
                return;
            }
        }
        return;
    }
    if ([GameScene gameLogicInstance].aboutMenuVisible == YES) {
        NSLog(@"About menu visible, skipping main menu commands");
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            location.x = location.x - [GameScene sceneInstance].sceneSize.width/2;
            location.y = location.y - [GameScene sceneInstance].sceneSize.height/2;
            
            SKSpriteNode* b = [GameScene sceneInstance].aboutMenuBackButton;
            if (location.x > b.position.x-b.size.width/2-20 &&
                location.x < b.position.x+b.size.width/2+20 &&
                location.y > b.position.y-b.size.height/2-20 &&
                location.y < b.position.y+b.size.height/2+20) {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] exitAbout];
                return;
            }
            SKSpriteNode* b2 = [GameScene sceneInstance].aboutMenuHelpButton;
            if (location.x > b2.position.x-b2.size.width/2-20 &&
                location.x < b2.position.x+b2.size.width/2+20 &&
                location.y > b2.position.y-b2.size.height/2-20 &&
                location.y < b2.position.y+b2.size.height/2+20) {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] showHelpScreen];
                return;
            }
        }
        return;
    }
    if ([GameScene gameLogicInstance].inAppPurchaseMenuVisible == YES) {
        NSLog(@"InAppPurchase menu visible, skipping main menu commands");
        for (UITouch *touch in touches) {
            
            CGPoint touchLocation = [touch locationInView:self.view];
            touchLocation = [[GameScene sceneInstance] convertPointFromView:touchLocation];
            SKNode *touchedNode = (SKNode *)[[GameScene sceneInstance] nodeAtPoint:touchLocation];

            if ([touchedNode isKindOfClass:SKLabelNode.class]) {
                touchedNode = touchedNode.parent;
            }
            
            if ([touchedNode.name isEqualToString:@"inAppButton"]) {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] doInAppPurchase];
                return;
            } else
            if ([touchedNode.name isEqualToString:@"inAppBackButton"]) {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] exitInAppPurchaseMenu];
                return;
            } else
            if ([touchedNode.name isEqualToString:@"restorePurchaseButton"]) {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] restorePurchase];
                return;
            }
/*
            CGPoint location = [touch locationInNode:self];
            location.x = location.x - [GameScene sceneInstance].sceneSize.width/2;
            location.y = location.y - [GameScene sceneInstance].sceneSize.height/2;

            SKSpriteNode* b = [GameScene sceneInstance].inAppPurchaseButton;
            if (location.x > b.position.x-b.size.width/2-20 &&
                location.x < b.position.x+b.size.width/2+20 &&
                location.y > b.position.y-b.size.height/2-20 &&
                location.y < b.position.y+b.size.height/2+20) {
                
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
              //  [[GameScene menuLogicInstance] doInAppPurchase];
                return;
            }
            b = [GameScene sceneInstance].inAppPurchaseBackButton;
            if (location.x > b.position.x-b.size.width/2-20 &&
                location.x < b.position.x+b.size.width/2+20 &&
                location.y > b.position.y-b.size.height/2-20 &&
                location.y < b.position.y+b.size.height/2+20) {
                
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] exitInAppPurchaseMenu];
                return;
            }*/
        }
        return;
    }
    if ([GameScene gameLogicInstance].selectLevelMenuVisible == YES) {
        NSLog(@"Select level menu visible, skipping main menu commands");
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            location.x = location.x - [GameScene sceneInstance].sceneSize.width/2;
            location.y = location.y - [GameScene sceneInstance].sceneSize.height/2;
            
            SKSpriteNode* b = [GameScene sceneInstance].selectLevelBackButton;
            if (location.x > b.position.x-b.size.width/2-20 &&
                location.x < b.position.x+b.size.width/2+20 &&
                location.y > b.position.y-b.size.height/2-20 &&
                location.y < b.position.y+b.size.height/2+20) {
                
               // [[GameScene soundManagerInstance] playSound:@"click.mp3"];  moved to menuinstance
                [[GameScene menuLogicInstance] exitSelectLevelMenu];
                return;
            }
            b = [GameScene sceneInstance].selectLevelPrevButton;
            if (b != nil && location.x > b.position.x-b.size.width/2-20 &&
                location.x < b.position.x+b.size.width/2+20 &&
                location.y > b.position.y-b.size.height/2-20 &&
                location.y < b.position.y+b.size.height/2+20) {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] showSelectLevelMenu:[GameScene gameLogicInstance].currentLevel-1];
                return;
            }
            b = [GameScene sceneInstance].selectLevelNextButton;
            if (b != nil && location.x > b.position.x-b.size.width/2-20 &&
                location.x < b.position.x+b.size.width/2+20 &&
                location.y > b.position.y-b.size.height/2-20 &&
                location.y < b.position.y+b.size.height/2+20) {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                [[GameScene menuLogicInstance] showSelectLevelMenu:[GameScene gameLogicInstance].currentLevel+1];
                return;
            }
        }
        return;
    }
    
    if ([GameScene gameLogicInstance].mainMenuVisible) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            location.x = location.x - [GameScene sceneInstance].sceneSize.width/2;
            location.y = location.y - [GameScene sceneInstance].sceneSize.height/2;
            
            for (int i=0; i<self.menuItems.count; i++) {
                SKLabelNode* n = [[self menuItems] objectAtIndex:i];
                if (location.x >= n.position.x-n.frame.size.width/2-10 && location.x <= n.position.x+ n.frame.size.width/2+10 &&
                    location.y >= n.position.y-n.frame.size.height/2-10 && location.y <= n.position.y+n.frame.size.height/2+10) {
                    //     NSArray* menus = @[@"Best players", @"Select level", @"About"];

                    [[GameScene soundManagerInstance] playSound:@"click.mp3"];

                    if (i == 0) { // best players
                        NSLog(@"Best players menu clicked");
                        [[GameScene menuLogicInstance] showHighscores];
                    } else if (i == 1) { // select level
                        NSLog(@"Select level menu clicked");
                        [[GameScene menuLogicInstance] showSelectLevelMenu:[GameScene gameLogicInstance].currentLevel];
                    } else if (i == 2) { // about
                        NSLog(@"About menu clicked");
                        [[GameScene menuLogicInstance] showAbout];
                    }
                    return;
                }
            }
        }
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            location.x = location.x - [GameScene sceneInstance].sceneSize.width/2;
            location.y = location.y - [GameScene sceneInstance].sceneSize.height/2;
            SKSpriteNode* n = [GameScene sceneInstance].startButton;
            
            if (location.x >= n.position.x-n.frame.size.width/2 && location.x <= n.position.x+ n.frame.size.width/2 &&
                location.y >= n.position.y-n.frame.size.height/2 && location.y <= n.position.y+n.frame.size.height/2) {

                if ([GameScene gameLogicInstance].aboutMenuVisible == YES ||
                    [GameScene gameLogicInstance].highScoresVisible == YES) {
                    return;
                }
                
                n.alpha = 0.7;
                // start button clicked
                [GameScene gameLogicInstance].mainMenuVisible = NO;

                [[GameScene soundManagerInstance] playSound:@"game_start.mp3"];

                [[GameScene menuLogicInstance] onMainMenuExit:nil];
/*                [NSTimer scheduledTimerWithTimeInterval:0.0
                                                 target:[GameScene menuLogicInstance]
                                               selector:@selector(onMainMenuExit:)
                                               userInfo:nil
                                                repeats:NO];*/
                }
        }
        return;
    }
    
    if ([GameScene gameLogicInstance].bonusScreenVisible == YES) {
        // game over, user clicked retry
        
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            location.x = location.x - [GameScene sceneInstance].sceneSize.width/2;
            location.y = location.y - [GameScene sceneInstance].sceneSize.height/2;
            SKSpriteNode* retryButton = [GameScene sceneInstance].bonusScreenBackButton;
            
            if (retryButton != nil && location.x >= retryButton.position.x - retryButton.size.width/2 -10 &&
                location.x <= retryButton.position.x + retryButton.size.width/2 +10 &&
                location.y >= retryButton.position.y - retryButton.size.height/2 -10 &&
                location.y <= retryButton.position.y + retryButton.size.height/2 +10)
            {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];

                [GameScene gameLogicInstance].gameIsOver = NO;
                [GameScene gameLogicInstance].gameRunning = NO;
                [GameScene gameLogicInstance].bonusScreenVisible = NO;
                [[GameScene gameLogicInstance] retryLevel];
                return;
            }
            
            SKSpriteNode* continueButton = [GameScene sceneInstance].bonusScreenContinueButton;
            if (continueButton != nil && location.x >= continueButton.position.x - continueButton.size.width/2 -10 &&
                location.x <= continueButton.position.x + continueButton.size.width/2 +10 &&
                location.y >= continueButton.position.y - continueButton.size.height/2 -10 &&
                location.y <= continueButton.position.y + continueButton.size.height/2 +10)
            {
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];

                if ([GameScene gameLogicInstance].currentLevel+1 >= IN_APP_PURCHASE_REQUIRED_FOR_LEVEL &&
                    [[InAppPurchase instance] isAppPurchased] == NO) {
                    [[GameScene menuLogicInstance] showInAppPurchaseMenu];
                    return;
                }
            
                [GameScene gameLogicInstance].levelComplete = NO;
                [GameScene gameLogicInstance].gameRunning = NO;
                [GameScene gameLogicInstance].bonusScreenVisible = NO;
                
                if ([GameScene gameLogicInstance].currentLevel >= MAX_LEVEL)
                {
                    [[GameScene sceneInstance] showMainScene];
                    [[GameScene menuLogicInstance] mainMenu];
                    return;
                }
                [[GameScene gameLogicInstance] nextLevel];
                return;
            }
            
            
            SKSpriteNode* mainMenuButton = [GameScene sceneInstance].bonusScreenMainMenuButton;
            
            if (mainMenuButton != nil && location.x >= mainMenuButton.position.x - mainMenuButton.size.width/2 -10 &&
                location.x <= mainMenuButton.position.x + mainMenuButton.size.width/2 +10 &&
                location.y >= mainMenuButton.position.y - mainMenuButton.size.height/2 -10 &&
                location.y <= mainMenuButton.position.y + mainMenuButton.size.height/2 +10)
            {
                if (self.mainMenuClicked == YES) {
                    return;
                }
                self.mainMenuClicked = YES;
                
                [[GameScene soundManagerInstance] playSound:@"click.mp3"];
                SKAction *fadeOutAction = [SKAction fadeAlphaTo:0.0 duration: 1.0];
                SKAction *mainMenuAction = [SKAction runBlock:^{
                    [[GameScene sceneInstance].bonusScreenBackButton removeFromParent];
                    [[GameScene sceneInstance].bonusScreenContinueButton removeFromParent];
                    [[GameScene gameLogicInstance].label removeFromParent];
                    [[GameScene gameLogicInstance].label2 removeFromParent];
                    
                    if ([GameScene gameLogicInstance].statusBarTimer != nil) {
                        [[GameScene gameLogicInstance].statusBarTimer invalidate];
                        [GameScene gameLogicInstance].statusBarTimer = nil;
                    }
                    [GameScene gameLogicInstance].statusBarDirty = NO;
                    [[GameScene gameLogicInstance].statusBarLevel removeFromParent];
                    [[GameScene gameLogicInstance].statusBarLives removeFromParent];
                    [[GameScene gameLogicInstance].statusBarScore removeFromParent];
                    
                    [[GameScene sceneInstance] showMainScene];
                    
                    [[GameScene menuLogicInstance] mainMenu];
                    self.mainMenuClicked = NO;
                    SKAction *fadeInAction = [SKAction fadeAlphaTo:1.0 duration: 1.0];
                    [[GameScene sceneInstance].scene runAction:fadeInAction];
                }];
                [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:[GameScene soundManagerInstance]
                                               selector:@selector(fadeOut:)
                                               userInfo:nil
                                                repeats:NO];
                
                [self.scene runAction:[SKAction sequence: @[fadeOutAction, mainMenuAction]]];
            }
        }
        return;
    }
    if ([GameScene gameLogicInstance].lives == 0) {
        return;
    }
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
//        touchLocation = [[GameScene sceneInstance] convertPointFromView:touchLocation];
        SKSpriteNode *node = (SKSpriteNode *)[[GameScene sceneInstance] nodeAtPoint:location];
        if (node != nil &&
            ([node.name isEqualToString:@"EXTRA_HOT_BALL"] ||
             [node.name isEqualToString:@"PADDLE_UPGRADE"]))
        {
            return; // ignore clicks if touching the bonus nodes
        }
        
        
        if (location.x <= self.batSprite.size.width/2) {
            location.x = self.batSprite.size.width/2;
        }
        if (location.x >= [self sceneSize].width-self.batSprite.size.width/2) {
            location.x = [self sceneSize].width-self.batSprite.size.width/2;
        }
        if (self.bat != nil) {
            self.batTargetX = location.x;
            [self runMoveAction];
        }
        
#ifdef ENABLE_TOUCH_TO_DESTROY_OBJECTS
        // debug feature
        NSArray* obs = [self.scene children];
        for (int i=0; i<obs.count; i++) {
            NSObject *o = [obs objectAtIndex:i];
            if ([o isKindOfClass:[GameObject class]]) {
                GameObject *n = (GameObject*)o;
                if (n.position.x <= location.x && n.position.x+n.size.width >= location.x &&
                    n.position.y <= location.y && n.position.y+n.size.height >= location.y) {
                    [n onCollision:nil impact:CGVectorMake(100, 100)];
                }
            }
        }
#endif
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([GameScene gameLogicInstance].lives == 0) {
        return;
    }
    if (self.bat == nil) {
        return;
    }
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint currentPos = self.bat.position;
        
        if (location.x <= self.batSprite.size.width/2) {
            location.x = self.batSprite.size.width/2;
        }
        if (location.x >= [self sceneSize].width-self.batSprite.size.width/2) {
            location.x = [self sceneSize].width-self.batSprite.size.width/2;
        }
        
        SKAction* runningAction = [self.bat actionForKey:@"moveToClick"];
        if (runningAction != nil) {
            if (self.batTargetX-currentPos.x<0 && location.x<currentPos.x) {
                self.batTargetX = location.x; // store the new target X
                return;
            }
            if (self.batTargetX-currentPos.x>0 && location.x>currentPos.x) {
                self.batTargetX = location.x; // store the new target X
                return;
            }
        }
        self.batTargetX = location.x; // store the new target X
        [self runMoveAction];
    }
}

-(void)runMoveAction { // bat movement
    float distance = fabs(self.batTargetX-self.bat.position.x);
    
    float ang = M_PI_4/6;
    if (self.batTargetX > self.bat.position.x || // check if we're moving right..
        (self.batTargetX >= self.bat.position.x && self.bat.position.x >= [self sceneSize].width-self.batSprite.size.width/2-1)) { // ..or if we're in the right edge, force rotation to right
        ang = -ang;
    }
    
    if (self.batCurrentlyMovingToX > 0 && // this is zero at startup, ignore check at first round until bat really is moving somewhere
        self.batTargetX != self.bat.position.x &&
        [self.bat hasActions] == YES) {
        if (self.batCurrentlyMovingToX < self.bat.position.x &&
            self.batTargetX < self.bat.position.x) {
        //    NSLog(@"Ignored click, target is %f", self.batTargetX);
            return;
        }
        if (self.batCurrentlyMovingToX > self.bat.position.x &&
            self.batTargetX > self.bat.position.x) {
          //  NSLog(@"Ignored click, target is %f", self.batTargetX);
            return;
        }
    }
    [self.bat removeAllActions];
    
    float multiplier = 1.0;
    if (self.batSprite.fastPaddle == YES) {
        multiplier = 5.0;
    }
    SKAction *move = [SKAction moveTo:CGPointMake(self.batTargetX, self.bat.position.y) duration:distance/(BAT_SPEED*multiplier)];
    SKAction *rotate = [SKAction rotateToAngle:ang duration:distance/(600*multiplier)];

    SKAction *moveToClick = [SKAction group:@[move, rotate]];
    self.batCurrentlyMovingToX = self.batTargetX;
    [self.bat runAction:moveToClick completion:^{
        [self completeAction];
    }];
}

-(void)completeAction { // bat movement
    if (self.batTargetX != self.bat.position.x) {
        [self.bat removeAllActions];
        [self runMoveAction];
    } else {
        SKAction *rotate = [SKAction rotateToAngle:0 duration:0.5];
        [self.bat runAction:rotate];
        self.batTargetX = self.bat.position.x;
        self.batCurrentlyMovingToX = 0;
    }
}

-(void)didBeginContact:(SKPhysicsContact*)contact {
    
    uint32_t bitMaskA = contact.bodyA.categoryBitMask;
    uint32_t bitMaskB = contact.bodyB.categoryBitMask;
    
    if (bitMaskA & ballCategory || bitMaskB & ballCategory) {
        Boolean biggerSparks = NO;
        Ball* ball;
        if (bitMaskA == ballCategory) {
            ball = (Ball*)contact.bodyA.node;
            if (bitMaskB == batCategory) {
                biggerSparks = YES;
            }
        } else {
            ball = (Ball*)contact.bodyB.node;
            if (bitMaskA == batCategory) {
                biggerSparks = YES;
            }
        }
        if (ball.isSuperHot == YES) {
            self.currentHotSparkIndex = (self.currentHotSparkIndex+1)%self.hotSparks.count;
            SKEmitterNode* spark = [self.hotSparks objectAtIndex:self.currentSparkIndex];
            spark.position = contact.contactPoint;
            if (biggerSparks == YES) {
                spark.numParticlesToEmit = 30;
            } else {
                spark.numParticlesToEmit = 10;
            }
            spark.zPosition = ball.zPosition;
            spark.hidden = NO;
            [spark resetSimulation];
        } else {
            self.currentSparkIndex = (self.currentSparkIndex+1)%self.sparks.count;
            SKEmitterNode* spark = [self.sparks objectAtIndex:self.currentSparkIndex];
            spark.position = contact.contactPoint;
            if (biggerSparks == YES) {
                spark.numParticlesToEmit = 30;
            } else {
                spark.numParticlesToEmit = 10;
            }
            spark.zPosition = ball.zPosition;
            spark.hidden = NO;
            [spark resetSimulation];
        }
    }

    if ((((bitMaskA & batCategory) != 0 && (bitMaskB & ballCategory)) != 0) ||
        (((bitMaskB & batCategory) != 0 && (bitMaskA & ballCategory)) != 0)) {
        
        Ball* ball;
        Bat* bat;
        CGVector velocity;
        if (bitMaskA == ballCategory) {
            ball = (Ball*)contact.bodyA.node;
            velocity = contact.bodyA.velocity;
            bat = (Bat*)contact.bodyB.node;
        } else {
            ball = (Ball*)contact.bodyB.node;
            velocity = contact.bodyB.velocity;
            bat = (Bat*)contact.bodyA.node;
        }

        
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970]*1000.0;
        if (now - self.lastImpulseApplied >= 100) {
            float horiz = 0;
            int movement = self.batTargetX-(int)self.bat.position.x;
            if (movement > 0) { // if the bat is moving, apply horiz force to ball
                horiz = 50.0f;
            } else if (movement < 0) {
                horiz = -50.0f;
            }
            [ball.physicsBody applyImpulse:CGVectorMake(horiz, BAT_BOUNCE_VELOCITY)];
            self.lastImpulseApplied = now;
        }
        
        int diff = (int)(contact.contactPoint.x - self.bat.position.x);
        int pos = (int)(diff + self.batSprite.size.width/2) / (int)(self.batSprite.size.width/4);
        if (pos<0) {
            pos = 0;
        } else if (pos>3) {
            pos = 3;
        }
        
        [bat onCollision:ball impact:velocity pos:pos];
        if (ball.isSuperHot == YES) { // double burn
            [bat burnAt:pos spreading:YES];
        }
        
/*        SpreadingFire* left = nil;
        SpreadingFire* right = nil;
        if (pos>0) {
            left = [self.batFires objectAtIndex:pos-1];
        }
        if (pos<3) {
            right = [self.batFires objectAtIndex:pos+1];
        }
        SpreadingFire* fire = [self.batFires objectAtIndex:pos];
        fire.size = fire.size+1;
        
        [fire grow:false fromRight:false ignoreCheck:YES];
  */
        
        
    } else if ((((bitMaskA & bonusCategory) != 0 && (bitMaskB & ballCategory)) != 0) ||
            (((bitMaskB & bonusCategory) != 0 && (bitMaskA & ballCategory)) != 0)) {
        
            Ball* ball;
            Bonus* bonus;
            if (bitMaskA == bonusCategory) {
                bonus = (Bonus*)contact.bodyA.node;
                ball = (Ball*)contact.bodyB.node;
            } else {
                bonus = (Bonus*)contact.bodyB.node;
                ball = (Ball*)contact.bodyA.node;
            }
            [bonus collected:ball];

    } else if ((((bitMaskA & (brickCategory+brickCategoryButNoCollisionWithBall)) != 0 && (bitMaskB & ballCategory)) != 0) ||
               (((bitMaskB & (brickCategory+brickCategoryButNoCollisionWithBall)) != 0 && (bitMaskA & ballCategory)) != 0)) {
        
        SKPhysicsBody* c;
        Ball* ball;
        CGVector velocity;
        if (bitMaskA == brickCategory || bitMaskA == brickCategoryButNoCollisionWithBall) {
            c = contact.bodyA;
            velocity = contact.bodyB.velocity;
            ball = (Ball*)contact.bodyB.node;
        } else {
            c = contact.bodyB;
            velocity = contact.bodyA.velocity;
            ball = (Ball*)contact.bodyA.node;
        }
        if ([c.node isKindOfClass:Crate.class]) {
            [(Crate*)c.node onCollision:ball impact:velocity];
            if (ball.isSuperHot == YES) {
                [(Crate*)c.node onBurn];
            }
        } else if ([c.node isKindOfClass:WoodBrick.class]) {
            [(WoodBrick*)c.node onCollision:ball impact:velocity];
            if (ball.isSuperHot == YES) {
                [(WoodBrick*)c.node onBurn];
            }
        } else if ([c.node isKindOfClass:WallBrick.class]) {
            [(WallBrick*)c.node onCollision:ball impact:velocity];
            if (ball.isSuperHot == YES) {
                [(WallBrick*)c.node onBurn];
            }
        } else if ([c.node isKindOfClass:IceCube.class]) {
            [(IceCube*)c.node onCollision:ball impact:velocity];
            if (ball.isSuperHot == YES) {
                [(IceCube*)c.node onBurn];
            }
        } if ([c.node isKindOfClass:Bat.class]) { // we come here if bat is about to get destroyed.
            [(Bat*)c.node onCollision:ball impact:velocity];
            if (ball.isSuperHot == YES) {
                [(Bat*)c.node onBurn];
            }
            // create sparks when bat gets destroyed
            self.currentSparkIndex = (self.currentSparkIndex+1)%self.sparks.count;
            SKEmitterNode* spark = [self.sparks objectAtIndex:self.currentSparkIndex];
            spark.position = contact.contactPoint;
            spark.numParticlesToEmit = 50;
            spark.hidden = NO;
            [spark resetSimulation];
        }

     /*   SKAction* snd = [SKAction playSoundFileNamed:@"wood-hit-crack.mp3" waitForCompletion:NO];
        [self runAction:snd];
*/
    } else if ((((bitMaskA & barrelCategory) != 0 && (bitMaskB & ballCategory)) != 0) ||
               (((bitMaskB & barrelCategory) != 0 && (bitMaskA & ballCategory)) != 0)) {
        
        SKPhysicsBody* c;
        CGVector velocity;
        Ball* ball;
        if (bitMaskA == barrelCategory) {
            c = contact.bodyA;
            velocity = contact.bodyB.velocity;
            ball = (Ball*)contact.bodyB.node;
        } else {
            c = contact.bodyB;
            velocity = contact.bodyA.velocity;
            ball = (Ball*)contact.bodyA.node;
        }
        [(OilBarrel*)c.node onCollision:ball impact:velocity];
        if (ball.isSuperHot == YES) {
            [(OilBarrel*)c.node onBurn];
        }

    } else if ( ((bitMaskA & edgeCategory) != 0 && (bitMaskB & ballCategory) != 0) ||
                ((bitMaskB & edgeCategory) != 0 && (bitMaskA & ballCategory) != 0)) {
        
        Ball* ball = nil;
        if (bitMaskA == ballCategory) {
            ball = (Ball*)contact.bodyA.node;
        } else if (bitMaskB == ballCategory) {
            ball = (Ball*)contact.bodyB.node;
        }

        if (contact.contactPoint.y < -BOTTOM_PIT_DEPTH+BALL_REBIRTH_SAFE_DISTANCE && [GameScene gameLogicInstance].gameRunning == YES) {
            
            ball.physicsBody.affectedByGravity = NO;
            ball.physicsBody.dynamic = NO;
            ball.physicsBody.velocity = CGVectorMake(0,0);
            ball.position = CGPointMake(ball.position.x, -BOTTOM_PIT_DEPTH+BALL_REBIRTH_SAFE_DISTANCE);
 
            if ([GameScene sceneInstance].ball.count <= 1) { // don't remove the last ball from array, just announce death
                [[GameScene gameLogicInstance] death];
            } else {
                [[GameScene sceneInstance].ball removeObject:ball];
            }
            return;
        }
        
        int force = 0;
        if (contact.contactNormal.dx<0.0f) {
            force = -1;
        } else if (contact.contactNormal.dx>0.0f) {
            force = 1;
        }
        if (force != 0) {
            CGVector reverse = CGVectorMake(force*WALL_BOUNCE_FACTOR, 0);
          //  NSLog(@"applying impulse to ball: %f, %f", reverse.dx, reverse.dy);
           // SKSpriteNode* ball = [[GameScene sceneInstance].ball objectAtIndex:0];
           // NSLog([NSString stringWithFormat:@"Applying impulse: %f, %f", reverse.dx, reverse.dy]);
           [ball.physicsBody applyImpulse:reverse];
        }
        if (abs((int)ball.physicsBody.velocity.dx)>=MIN_VELOCITY_TO_PLAY_SFX || abs((int)ball.physicsBody.velocity.dy)>MIN_VELOCITY_TO_PLAY_SFX) { // don't play sound fx if too small velocity to avoid series of impact sounds when touching the object
            
            if (ball.position.y > 0) { // play sound only on side and top border
                [[GameScene soundManagerInstance] playSound:@"stone_hit.mp3"];
            }
        }

    } else if ((((bitMaskA & beaconCategory) != 0 && (bitMaskB & ballCategory)) != 0) ||
               (((bitMaskB & beaconCategory) != 0 && (bitMaskA & ballCategory)) != 0)) {
        
        SKPhysicsBody* c;
        CGVector velocity;
        Ball* ball;
        if (bitMaskA == beaconCategory) {
            c = contact.bodyA;
            velocity = contact.bodyB.velocity;
            ball = (Ball*)contact.bodyB.node;
        } else {
            c = contact.bodyB;
            velocity = contact.bodyA.velocity;
            ball = (Ball*)contact.bodyA.node;
        }
        [(Beacon*)c.node onCollision:ball impact:velocity];

        [[GameScene soundManagerInstance] playSound:@"beacon-hit.mp3"];
        
        [(Beacon*)c.node powerUp];
        
    } else if ((((bitMaskA & treeTrunkCategory) != 0 && (bitMaskB & ballCategory)) != 0) ||
                    (((bitMaskB & treeTrunkCategory) != 0 && (bitMaskA & ballCategory)) != 0)) {
        
        SKPhysicsBody* c;
        CGVector velocity;
        Ball* ball;
        if (bitMaskA == treeTrunkCategory) {
            c = contact.bodyA;
            velocity = contact.bodyB.velocity;
            ball = (Ball*)contact.bodyB.node;
        } else {
            c = contact.bodyB;
            velocity = contact.bodyA.velocity;
            ball = (Ball*)contact.bodyA.node;
        }
        [(Tree*)c.node onCollision:ball impact:velocity];
        if (ball.isSuperHot == YES) {
            [(Tree*)c.node onBurn];
        }
        
    } else if ((((bitMaskA & treeTopCategory) != 0 && (bitMaskB & ballCategory)) != 0) ||
               (((bitMaskB & treeTopCategory) != 0 && (bitMaskA & ballCategory)) != 0)) {
        SKPhysicsBody* c;
        Ball* ball;
        if (bitMaskA == treeTopCategory) {
            c = contact.bodyA;
            ball = (Ball*)contact.bodyB.node;
        } else {
            c = contact.bodyB;
            ball = (Ball*)contact.bodyA.node;
        }
        [((Tree*)c.node.parent) onBranchCollision:ball];
        if (ball.isSuperHot == YES) {
            [(Tree*)c.node.parent onBurn];
        }

    }
}

-(void)adjustRingPositions:(NSArray*)chain
{
    //based on zRotations of all rings and the position of start ring adjust the rest of the rings positions starting from top to bottom
    for (int i = 1; i < chain.count; i++) {
        SKSpriteNode *nodeA = [chain objectAtIndex:i-1];
        SKSpriteNode *nodeB = [chain objectAtIndex:i];

        float xdiff = (nodeB.position.x - nodeA.position.x);
        float ydiff = (nodeB.position.y - nodeA.position.y);
        float dist = sqrtf(xdiff*xdiff + ydiff*ydiff);
        
        float limit = 8; // nodeA.size.height;
        if (dist > limit) {
            NSLog(@"dist %f", dist);
            
            float xd = (nodeB.position.x - nodeA.position.x)*limit/dist;
            float yd = (nodeB.position.y - nodeA.position.y)*limit/dist;
            NSLog(@"dist2 %f", sqrtf(xd*xd+yd*yd));
            nodeB.physicsBody.dynamic = NO;
            nodeB.position = CGPointMake(nodeA.position.x + xd, nodeA.position.y + yd);
            nodeB.physicsBody.dynamic = YES;
        }
        
/*        float chainDistance = nodeA.size.height;//-5;

        CGFloat thetaA = nodeA.zRotation - M_PI / 2,
        thetaB = nodeB.zRotation + M_PI / 2,
        jointRadius = (chainDistance + nodeA.size.height) / 2,
        xJoint = jointRadius * cosf(thetaA) + nodeA.position.x,
        yJoint = jointRadius * sinf(thetaA) + nodeA.position.y,
        theta = thetaB - M_PI,
        xB = jointRadius * cosf(theta) + xJoint,
        yB = jointRadius * sinf(theta) + yJoint;
        nodeB.position = CGPointMake(xB, yB);*/
    }
}

-(void)didSimulatePhysics
{
    /*if ([GameScene menuLogicInstance].chain1 != nil &&
        [GameScene menuLogicInstance].chain1.count > 0) {
        [self adjustRingPositions:[GameScene menuLogicInstance].chain1];
        [self adjustRingPositions:[GameScene menuLogicInstance].chain2];
    }*/
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
#ifndef DISABLE_SHADERS
    if ([self isLowPerfMode] == NO) {
        // hack to fix u_time in shaders. Using u_time will slow down shader performance after a while, using uniforms instead to update the current time from app code.
        if (shaderInstance.snowShader != nil && [GameScene gameLogicInstance].gameRunning == NO) {
            shaderInstance.snowShader.uniforms =  @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)], [SKUniform uniformWithName:@"currentTimeUniform" float:currentTime]];
        }
        if (shaderInstance.fullscreenSmokeShader2 != nil && [GameScene gameLogicInstance].gameRunning == NO) {
            shaderInstance.fullscreenSmokeShader2.uniforms =  @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)], [SKUniform uniformWithName:@"currentTimeUniform" float:currentTime]];
        }
    }
#endif
    
    if ([GameScene gameLogicInstance].gameRunning == NO &&
        [GameScene gameLogicInstance].mainMenuVisible == NO &&
        [GameScene gameLogicInstance].selectLevelMenuVisible == NO &&
        [GameScene gameLogicInstance].bonusScreenVisible == NO &&
        [GameScene gameLogicInstance].inAppPurchaseMenuVisible == NO &&
        [GameScene gameLogicInstance].highScoresVisible == NO &&
        [GameScene gameLogicInstance].helpScreenVisible == NO) {
        return;
    }
    
    // change world gravity to guide ball
    if ([GameScene sceneInstance].gravityDirection.dx == 0.0 &&
        [GameScene sceneInstance].gravityDirection.dy == 0.0) {
        [GameScene sceneInstance].physicsWorld.gravity = CGVectorMake(0, -1.0 * GRAVITY);
    } else {
        [GameScene sceneInstance].physicsWorld.gravity = [GameScene sceneInstance].gravityDirection;
    }
#ifndef DISABLE_PARTICLES
    float ang = ([GameScene sceneInstance].orientation + 90) * M_PI/180;

    // modify beacon emissions
    for (int i=0; i<self.beacons.count; i++) {
        GameObject *n = [self.beacons objectAtIndex:i];
        if (n != nil && n.fire != nil && n.smoke != nil) {
            n.fire.emissionAngle = ang;
        }
    }
    
    // modify flames and smoke direction
    for (int i=0; i<self.burningObjects.count; i++) {
        GameObject *n = [self.burningObjects objectAtIndex:i];
        if (n != nil && n.fire != nil && n.smoke != nil) {
            n.fire.emissionAngle = ang;
            n.smoke.emissionAngle = ang;
        }
    }

    // bat fires & smokes orientation
    Bat* bat = (Bat*)self.batSprite;
    if (bat != nil) {
        for (int i=0; i<bat.batFires.count; i++) {
            SKEmitterNode *n = [bat.batFires objectAtIndex:i];
            if (n != nil) {
                n.emissionAngle = ang;
            }
        }
        for (int i=0; i<bat.batSmokes.count; i++) {
            SKEmitterNode *n = [bat.batSmokes objectAtIndex:i];
            if (n != nil) {
                n.emissionAngle = ang;
            }
        }
    }
#endif
    if ([GameScene gameLogicInstance].helpScreenVisible == YES) {
        if ([GameScene menuLogicInstance].helpArrow != nil) {
//            [[GameScene menuLogicInstance].helpArrow removeAllActions];
//            float t = fabs(rot-ang) / M_PI *0.2;
            
            float a = [GameScene sceneInstance].orientation;
            
            if (a > 45 && a <= 180) {
                a = 45;
            }
            if (a < 315 && a > 180) {
                a = 315;
            }
            float angle = (a - 90) * M_PI/180;
            //[[GameScene menuLogicInstance].helpArrow runAction: [SKAction rotateToAngle:ang duration: t]];
            [GameScene menuLogicInstance].helpArrow.zRotation = angle+M_PI;
        }
    }

    // hack for preventing iOS physics bug which teleports the ball
    if (self.ball != nil && self.ball.count > 0) {
        Ball* ball = (Ball*)[self.ball objectAtIndex:0];
      //  NSLog(@"BALL position %f %f", ball.position.x, ball.position.y);
        float xdiff = fabs(self.oldpos.x - ball.position.x);
        float ydiff = fabs(self.oldpos.y - ball.position.y);
        if (self.oldpos.x != 0.0 && (xdiff > 100 || ydiff > 100)) {
          //  NSLog(@"BALL MOVED %f %f", xdiff, ydiff);
//            ball.position = CGPointMake((self.position.x - self.oldpos.x)/2, (self.position.y - self.oldpos.y)/2);
        }

        if (ball.position.x < ball.size.width/2) {
           // NSLog(@"Moving ball");
            ball.position = CGPointMake(ball.size.width/2, ball.position.y);
        }
        if (ball.position.x > self.scene.frame.size.width - ball.size.width/2) {
            //NSLog(@"Moving ball");
            ball.position = CGPointMake(self.scene.frame.size.width - ball.size.width/2, ball.position.y);
        }
        if (ball.position.y > self.scene.frame.size.height - ball.size.height/2) {
            //NSLog(@"Moving ball");
            ball.position = CGPointMake(ball.position.x, self.scene.frame.size.height - ball.size.height/2);
        }
        
        self.oldpos = ball.position;
    }
}


// update light source categories so we won't cast shadows if there's more than one bright light source (for perf reasons)
-(void)updateBallLights
{
    // calculate number of lit beacons
    long beaconsLit = [GameScene sceneInstance].beacons.count - [GameScene sceneInstance].beaconCount;
    if (beaconsLit<0) {
        beaconsLit = 0;
    }
    
    if (beaconsLit + [GameScene sceneInstance].ballFireEmitter.count > 1) {
        for (int i=0; i<[GameScene sceneInstance].ballFireEmitter.count; i++) {
            SKEmitterNode* fire = [[GameScene sceneInstance].ballFireEmitter objectAtIndex:i];
            SKLightNode* light = (SKLightNode*)[fire childNodeWithName:@"light"];
            if (light != nil) {
                if (light.categoryBitMask == 1) {
                    light.categoryBitMask = 8; // set category to 8 == no shadow cast for objects -> faster perf
                }
            }
        }
    } else {
        SKEmitterNode* fire = [[GameScene sceneInstance].ballFireEmitter objectAtIndex:0];
        SKLightNode* light = (SKLightNode*)[fire childNodeWithName:@"light"];
        if (light != nil) {
            if (light.categoryBitMask == 8) {
                light.categoryBitMask = 1; // only one ball with light, so we set category back to 1 == cast shadows again
            }
        }
    }
}

-(Boolean)isLowPerfMode {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    
    if ([sDeviceModel hasPrefix:@"iPhone4,1"] || [sDeviceModel isEqualToString:@"x86_64"] ||
        [sDeviceModel hasPrefix:@"iPad2"] ||
        [sDeviceModel hasPrefix:@"iPad3"] ||
        [sDeviceModel hasPrefix:@"iPod5,1"] ||
        [sDeviceModel hasPrefix:@"iPhone5,1"] ||
        [sDeviceModel hasPrefix:@"iPhone5,2"] ||
        [sDeviceModel hasPrefix:@"iPhone5,3"] ||
        [sDeviceModel hasPrefix:@"iPhone5,4"]
        ) {
        NSLog(@"Low perf device detected: %@", sDeviceModel);
        return YES;
    }
    return NO;
}

@end

