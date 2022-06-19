//
//  MenuLogic.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import <StoreKit/StoreKit.h>

#import "GameScene.h"
#import "GameLogic.h"
#import "MenuLogic.h"
#import "SoundManager.h"
#import "Logo.h"
#import "Explosions.h"
#import "Shaders.h"
#import "LevelData.h"
#import "Highscores.h"
#import "BonusFeatures.h"
#import "InAppPurchase.h"
#import "ObjectFactory.h"
#import "Bat.h"

@implementation MenuLogic

- (NSString *)splashImageName {
    CGSize viewSize = [GameScene sceneInstance].view.bounds.size;
    NSString* viewOrientation = @"Portrait";
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        NSLog(@"%@", dict[@"UILaunchImageName"]);
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
            return dict[@"UILaunchImageName"];
    }
    return nil;
}

-(void)mainMenu {
    [GameScene gameLogicInstance].mainMenuVisible = YES;
    [GameScene gameLogicInstance].aboutMenuVisible = NO;
    [GameScene gameLogicInstance].highScoresVisible = NO;
    [GameScene gameLogicInstance].bonusScreenVisible = NO;
    
    [[GameScene gameLogicInstance] pauseGame];

    [[GameScene soundManagerInstance] stopAll]; // stop music
    
    [[GameScene sceneInstance].scene removeAllChildren];
    [[GameScene sceneInstance] removeAllChildren];
//    [GameScene sceneInstance].size = CGSizeMake(375, 667);
//    [GameScene sceneInstance].scaleMode = SKSceneScaleModeResizeFill;
    
    // reset variables
    [GameScene gameLogicInstance].gameIsOver = NO;
    [GameScene gameLogicInstance].playerDied = NO;
    [GameScene gameLogicInstance].lives = MAX_LIVES;
    [GameScene gameLogicInstance].score = 0;
    [GameScene gameLogicInstance].levelsCompleted = 0;
    [GameScene sceneInstance].beaconCount = 0;
    [GameScene gameLogicInstance].currentLevel = START_LEVEL;
    
  //  float scale = [GameScene sceneInstance].screenSize.width / 375;

/*    SKScene *scene = [GameScene unarchiveFromFile:@"MainScene"];
    scene.scaleMode = SKSceneScaleModeResizeFill;
    // Present the scene.
    [[GameScene sceneInstance].view presentScene:scene];
  */
    
    float screenScale = 1.0;
    
    //CGSize f = [[UIScreen mainScreen] currentMode].size;
    
   // [GameScene sceneInstance].view.bounds = CGRectMake(0, 0, 768, 1024); //f.width, f.height);
   
    SKSpriteNode *panel = [SKSpriteNode spriteNodeWithImageNamed:@"HomeScreen"]; //[self splashImageName]];
    panel.name = @"mainMenu";
    
   // if (self.initialized == NO) {
        screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;
      //  panel.size = CGSizeMake([GameScene sceneInstance].screenSize.width, [GameScene sceneInstance].screenSize.height); // for some reason, the scene size is wrong at first launch
   /* } else {
        screenScale = 1.0 * [GameScene sceneInstance].scene.size.height/667;
        panel.size = [GameScene sceneInstance].scene.size;
    }*/
    panel.size = [GameScene sceneInstance].screenSize;
    //[GameScene sceneInstance].screenSize.height
    panel.position = CGPointMake(panel.size.width/2, panel.size.height/2);
    panel.zPosition = 900;
    panel.blendMode = SKBlendModeReplace;

    [[GameScene sceneInstance].scene addChild:panel];
    [GameScene sceneInstance].menuPanel = panel;

    self.plaque = nil;


/*#ifndef DISABLE_MAINSCREEN_SMOKE
#ifndef DISABLE_SHADERS
    SKSpriteNode* shaderContainer = [SKSpriteNode spriteNodeWithImageNamed:@"EmptyBody"];
    shaderContainer.size = [GameScene sceneInstance].scene.size;
    shaderContainer.position = CGPointMake(shaderContainer.size.width/2, shaderContainer.size.height/2);
    shaderContainer.zPosition = 1100;
    shaderContainer.lightingBitMask = 0;
    shaderContainer.shader = [GameScene shaderInstance].fullscreenSmokeShader2;
    [[GameScene sceneInstance] addChild:shaderContainer];
#endif
#endif*/
    /*SKSpriteNode* shaderContainer = [SKSpriteNode spriteNodeWithImageNamed:@"EmptyBody"];
    shaderContainer.size = [GameScene sceneInstance].scene.size;
    shaderContainer.position = CGPointMake(shaderContainer.size.width/2, shaderContainer.size.height/2);
    shaderContainer.zPosition = 1100;
    shaderContainer.lightingBitMask = 0;
    shaderContainer.shader = [GameScene shaderInstance].mainGlowShader;
    [[GameScene sceneInstance] addChild:shaderContainer];
    */
    int screenH = [GameScene sceneInstance].screenSize.height;
    //[UIScreen mainScreen].bounds.size.height;
    //[[UIScreen mainScreen] currentMode].size.height; //[GameScene sceneInstance].screenSize.height;
    
    NSArray *logoArray = [NSArray arrayWithObjects: LOGO_DATA, nil ];
    
    // BRIMSTONE logo starts here
    [GameScene sceneInstance].firePixelColumns = [[NSMutableArray alloc] init];
    float scale = (/*[GameScene sceneInstance].screenSize*/[GameScene sceneInstance].screenSize.width-40)/(2*logoArray.count);
    /*if (scale >= 2.0) {
        scale = 2.0;
    }*/
//    NSLog(@"Scale = %f", scale);
    for (int x=0; x<logoArray.count; x++) {
        //       NSString *row = @"";
        NSMutableArray *firePixelColumn = [[NSMutableArray alloc] init];
        
        NSString* column = [logoArray objectAtIndex:x];
        for (int y=0; y<column.length; y++) {
            if ([column characterAtIndex:y] == '1') {
                SKEmitterNode *fire = [self drawPixel:panel withX:(x*2-(int)logoArray.count)*scale withY:(column.length-y)*2*scale+screenH/6 pos:y];
                fire.particleScale = fire.particleScale*scale/1.92; //1.82065213;
                [firePixelColumn addObject:fire];
            }
        }
        [[GameScene sceneInstance].firePixelColumns addObject:firePixelColumn];
    }
    logoArray = nil;

    // now we add them to scene column by column to get a nice effect
    float initialDelay = 0.1;
    float biggestDelay = 0;
    for (int x=0; x<[GameScene sceneInstance].firePixelColumns.count; x++) {
        NSMutableArray *column = [[GameScene sceneInstance].firePixelColumns objectAtIndex:x];
        float d = initialDelay/[GameScene sceneInstance].firePixelColumns.count;
        float delay = x*(initialDelay-(x*d)); // accelerating swipe from left to right
        [NSTimer scheduledTimerWithTimeInterval:delay
                                         target:self
                                       selector:@selector(showLogoNode:)
                                       userInfo:column
                                        repeats:NO];
        if (biggestDelay < delay) {
            biggestDelay = delay; // save for later use
        }
        // [self.scene performSelector:@selector(showLogoNode:) withObject:column afterDelay:1.0+x*0.25];
    }

    
    SKAction *wait = [SKAction waitForDuration:biggestDelay];
    SKAction *run = [SKAction runBlock:^{
        // flames get higher when fire streams collide
        int count = (int)[GameScene sceneInstance].firePixelColumns.count;
        for (int x=0; x<count; x++) {
            NSMutableArray *column = [[GameScene sceneInstance].firePixelColumns objectAtIndex:x];
            SKEmitterNode* fire = (SKEmitterNode*)[column objectAtIndex:0];
            fire.particleBirthRate = 50; // agitated flames
            fire.particleSpeed = (count-abs(count/2-x));
            fire.particleSpeedRange = 20;
        }
    }];
    SKAction *sequence = [SKAction sequence:@[wait, run]];
    [[GameScene sceneInstance].scene runAction:sequence];
    
    SKAction *wait2 = [SKAction waitForDuration:biggestDelay+1.0];
    SKAction *run2 = [SKAction runBlock:^{
        // flames get higher when fire streams collide
        int count = (int)[GameScene sceneInstance].firePixelColumns.count;
        for (int x=0; x<count; x++) {
            NSMutableArray *column = [[GameScene sceneInstance].firePixelColumns objectAtIndex:x];
            SKEmitterNode* fire = (SKEmitterNode*)[column objectAtIndex:0];
            fire.particleBirthRate = 20; // back to normal
            fire.particleSpeed = 50;
            fire.particleSpeedRange = 20;
        }
    }];
    SKAction *sequence2 = [SKAction sequence:@[wait2, run2]];
    [[GameScene sceneInstance].scene runAction:sequence2];
    
    // logo ends
    
    
    
    UIColor* col = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4];
    SKShapeNode* mask = [SKShapeNode node];
    mask.zPosition = 902;
    [mask setPath:CGPathCreateWithRoundedRect(CGRectMake(-screenH/8, -screenH*0.05, screenH/4, screenH*0.1), 8, 8, nil)];
    [mask setFillColor:col];
    
    SKTexture* tex = [[GameScene sceneInstance].view textureFromNode:mask];
    SKSpriteNode* button = [SKSpriteNode spriteNodeWithTexture:tex];
    button.zPosition = 902;
    button.position = CGPointMake(0, screenH*0.15 -panel.position.y);
   /* button.shader = [GameScene shaderInstance].glowingShader;
    button.shader.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make(button.size.width, button.size.height, 0)]];
    */
    [panel addChild:button];
    [GameScene sceneInstance].startButton = button;
    [GameScene sceneInstance].menuItems = [[NSMutableArray alloc] init];
    NSArray* menus = @[NSLocalizedString(@"Best players", "High score menu"), NSLocalizedString(@"Select level", "Change the active level"), NSLocalizedString(@"About", "Info about the game")];
    
    for (int i=0; i<menus.count; i++)
    {
        SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        s.name = @"menuLabel";
        
        s.text = [menus objectAtIndex:i];
        s.color = [UIColor grayColor];
        s.fontSize = 22*screenScale;
        s.zPosition = 1001;
        s.position = CGPointMake([GameScene sceneInstance].screenSize.width/2 -panel.position.x, screenH*0.3 -panel.position.y + i*60*screenScale);
        s.scale = 1.0;
        
        [panel addChild:s];
        [[GameScene sceneInstance].menuItems addObject:s];
    }

    SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    s.name = @"startButton";
    s.text = NSLocalizedString(@"Start", "Start the game");
    s.color = [UIColor grayColor];
    s.fontSize = 25*screenScale;
    s.zPosition = 1001;
    s.position = CGPointMake(0, -10*screenScale); //PointMake([GameScene sceneInstance].screenSize.width/2 -panel.position.x, screenH*0.15 - 10 -panel.position.y);
    s.scale = 1.0;
    s.blendMode = SKBlendModeAlpha;
    s.alpha = 0.9;
    [button addChild:s];
    
    SKLabelNode *s1 = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    s1.text = NSLocalizedString(@"Created by Janne Heinonen 2015", "Copyright text");
    s1.color = [UIColor grayColor];
    s1.fontSize = 12*screenScale;
    s1.zPosition = 1001;
    s1.position = CGPointMake([GameScene sceneInstance].screenSize.width/2 -panel.position.x, 20 -panel.position.y);
    s1.scale = 1.0;
    s1.blendMode = SKBlendModeAlpha;
    s1.alpha = 0.9;
    [panel addChild:s1];
    [GameScene sceneInstance].copyrightText = s1;
    
    [[GameScene soundManagerInstance] clearPlaylist:BACKGROUND_MUSIC];
    [[GameScene soundManagerInstance] setVolume:1.0 playerNum:BACKGROUND_MUSIC];
    [[GameScene soundManagerInstance] addToPlaylist:@"start-screen-music" ofType:@"mp3" playerNum:BACKGROUND_MUSIC];
  //  [[GameScene soundManagerInstance] addToPlaylist:@"flowing-magma" ofType:@"mp3"];
    
    [[GameScene soundManagerInstance] play:NO playerNum:BACKGROUND_MUSIC];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(onCheckGyroscope:)
                                   userInfo:nil
                                    repeats:NO];
    
    self.highscores = [Highscores alloc];
    [self.highscores authenticateLocalUser];
    
    self.bonusFeatures = [BonusFeatures alloc];
    [self.bonusFeatures setup];
    
    self.origRes = panel.size;
    self.initialized = YES; // wrong res at startup, mark that we're using the correct one for next time
}

// fade out menu texts when switching to highscore view
-(void)hideMenuLabelAndStartButton
{
    SKAction *menuFade = [SKAction fadeAlphaTo:0.0 duration: 0.5];
    [[GameScene sceneInstance].startButton runAction:menuFade];

    SKAction *menuFade2 = [SKAction fadeAlphaTo:0.0 duration: 0.5];
    [[GameScene sceneInstance].copyrightText runAction:menuFade2];
    
    for (int i=0; i<[GameScene sceneInstance].menuItems.count; i++) {
        SKAction *menuFade = [SKAction fadeAlphaTo:0.0 duration: 0.5];
        [[[GameScene sceneInstance].menuItems objectAtIndex:i] runAction:menuFade];
    }
}

// fade in menu texts when switching to highscore view
-(void)showMenuLabelAndStartButton
{
    SKAction *menuFade = [SKAction fadeAlphaTo:1.0 duration: 1.5];
    [[GameScene sceneInstance].startButton runAction:menuFade];
    
    SKAction *menuFade2 = [SKAction fadeAlphaTo:1.0 duration: 1.5];
    [[GameScene sceneInstance].copyrightText runAction:menuFade2];
    
    for (int i=0; i<[GameScene sceneInstance].menuItems.count; i++) {
        SKAction *menuFade = [SKAction fadeAlphaTo:1.0 duration: 1.5];
        [[[GameScene sceneInstance].menuItems objectAtIndex:i] runAction:menuFade];
    }
}

-(void)onCheckGyroscope:(NSTimer *)timer {
    if ([GameScene gameLogicInstance].gameRunning == YES) {
        // adjust ball flame
        float ang = [GameScene sceneInstance].orientation + 90;
    
        for (int i=0; i<[GameScene sceneInstance].ballFireEmitter.count; i++) {
            SKEmitterNode* ballFire = [[GameScene sceneInstance].ballFireEmitter objectAtIndex:i];
            ballFire.emissionAngle = ang*M_PI/180;
        }
        
    } else if ([GameScene gameLogicInstance].mainMenuVisible == YES ||
        [GameScene gameLogicInstance].highScoresVisible == YES) {
        // let's adjust logo flames, if in main menu or highscore menu
        if ([GameScene sceneInstance].firePixelColumns.count > 0) {
            for (int x=0; x<[GameScene sceneInstance].firePixelColumns.count; x++) {
                NSMutableArray *column = [[GameScene sceneInstance].firePixelColumns objectAtIndex:x];
                for (int y=0; y<column.count; y++) {
                    SKEmitterNode* fire = (SKEmitterNode*)[column objectAtIndex:y];
                    float ang = [GameScene sceneInstance].orientation + 90;
                    fire.emissionAngle = ang*M_PI/180;
                }
            }
        }
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 // let's check orientation 10 times per second
                                     target:self
                                   selector:@selector(onCheckGyroscope:)
                                   userInfo:nil
                                    repeats:NO];
}

// XXX TODO: looping this is very slow, fix it (draw only once)
// XXX now fixed, loading static data instead. Keeping this here for possible future use.
+(CGFloat)getAvgPixelColorFromImage:(UIImage*)image atX:(NSInteger)xx andY:(NSInteger)yy
{
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), CGPointMake(xx,yy))) {
        return 0;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = xx;
    NSInteger pointY = yy;
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat avg = ((CGFloat)pixelData[0]+(CGFloat)pixelData[1]+(CGFloat)pixelData[2]) / 255.0f;
    return avg;
}
/*
 +(CGFloat)getAvgPixelColorFromImage:(UIImage*)image atX:(NSInteger)xx andY:(NSInteger)yy
 {
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 unsigned char rgba[4];
 CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
 
 CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
 CGColorSpaceRelease(colorSpace);
 CGContextRelease(context);
 
 return ((float)rgba[0]+(float)rgba[2]+(float)rgba[2])/3/255.0f;
 }*/

-(SKEmitterNode*)drawPixel:(SKSpriteNode*)parent withX:(float)x withY:(float)y pos:(int)pos
{
    SKEmitterNode* fire = [[GameScene factoryInstance] createFire:x withY:y];
    fire.particleZPosition = 1050;
    fire.particleLifetime = 2.5;
    if (pos == 0) {
        fire.particleBirthRate = 20;
        fire.particleSpeed = 50;
        fire.particleSpeedRange = 20;
    } else {
        fire.particleBirthRate = 10;
        fire.particleSpeed = 2;
        fire.particleSpeedRange = 0;
    }
    
    [parent addChild:fire];
    fire.particleBirthRate = 0;// = YES; // hide fire for now
    return fire;
}


-(void)showLogoNode:(NSTimer*)timer //(NSMutableArray*)column
{
    NSMutableArray* column = (NSMutableArray*)timer.userInfo;
    for (int y=0; y<column.count; y++) {
        SKEmitterNode *fire = [column objectAtIndex:y];
        
        if ([fire parent] == nil) {
            return;
        }
        int n = 10;
        if (y == 0) {
            n = 20;
        }
        fire.particleBirthRate = n; // reveal fire at correct sequence
    }
}

-(void)onScaleMenu:(NSTimer*)timer
{
    float scale = [(NSNumber*)timer.userInfo floatValue];
    scale = scale - self.scaleSpeed;
    self.scaleSpeed = self.scaleSpeed*0.80;

//    NSLog(@"scale: %f", scale);
    if (scale <= 0.3 || self.scaleSpeed < 0.0005) {
        scale = 0.3;
        [self.menu setScale:scale];
        return;
    }
    [self.menu setScale:scale];
    [NSTimer scheduledTimerWithTimeInterval:0.02
                                     target:self
                                   selector:@selector(onScaleMenu:)
                                   userInfo:[NSNumber numberWithFloat:scale]
                                    repeats:NO];
}

// exit from high scores
-(void)onScaleOutMenu:(NSTimer*)timer
{
    float scale = [(NSNumber*)timer.userInfo floatValue];
    scale = scale + self.scaleSpeed;
    self.scaleSpeed = self.scaleSpeed/0.80;
    
  //  NSLog(@"scale: %f", scale);
    if (scale >= 1.0) {
        scale = 1.0;
        [self.menu setScale:scale];
        return;
    }
    [self.menu setScale:scale];
    [NSTimer scheduledTimerWithTimeInterval:0.02
                                     target:self
                                   selector:@selector(onScaleOutMenu:)
                                   userInfo:[NSNumber numberWithFloat:scale]
                                    repeats:NO];
}

-(void)sniffOutFlames
{
    for (int x=0; x<[GameScene sceneInstance].firePixelColumns.count; x++) {
        NSMutableArray *column = [[GameScene sceneInstance].firePixelColumns objectAtIndex:x];
        for (int y=0; y<column.count; y++) {
            SKEmitterNode* fire = (SKEmitterNode*)[column objectAtIndex:y];
            //                fire.particleBirthRate = 100;
            fire.numParticlesToEmit = 4*(column.count-y);
        }
    }
}

-(void)reIgniteFlames
{
    for (int x=0; x<[GameScene sceneInstance].firePixelColumns.count; x++) {
        NSMutableArray *column = [[GameScene sceneInstance].firePixelColumns objectAtIndex:x];
        for (int y=0; y<column.count; y++) {
            SKEmitterNode* fire = (SKEmitterNode*)[column objectAtIndex:y];
            fire.numParticlesToEmit = 0;
        }
    }
}

// fade out main menu and run the given block
// this is used for exiting main menu when clicking "start"
/*-(void)fadeOutMenuAndExec:(void (^)(void))block
{
    [GameScene gameLogicInstance].mainMenuVisible = NO;
    
    // fade out background
    self.menu = (SKSpriteNode*)[[GameScene sceneInstance] childNodeWithName:@"mainMenu"];
    
    SKAction *fade = [SKAction fadeAlphaTo:0.0 duration: 1.5];
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[GameScene soundManagerInstance]
                                   selector:@selector(fadeOut:)
                                   userInfo:nil
                                    repeats:NO];
    
    SKAction *run = [SKAction runBlock:^{
        block();
    }];
    SKAction *sequence = [SKAction sequence:@[fade, run]];
    [[GameScene sceneInstance] runAction:sequence];
    return;
}*/

// scale main menu and run the given block
// this is used for exiting main menu when clicking "high score"
-(void)scaleMenuAndExec:(void (^)(void))block
{
    [GameScene gameLogicInstance].mainMenuVisible = NO;
    
    // fade out background and start game
    self.menu = (SKSpriteNode*)[[GameScene sceneInstance] childNodeWithName:@"mainMenu"];
    self.menu.zPosition = 1010;
    
    self.scaleSpeed = 0.14;
    
    ///    SKAction *scale = [SKAction scaleTo:0.5 duration: 1.5];
    //  [menu runAction:scale];
    [NSTimer scheduledTimerWithTimeInterval:0.02
     target:self
     selector:@selector(onScaleMenu:)
     userInfo:[NSNumber numberWithFloat:1.0]
     repeats:NO];
    
    //    [[GameScene soundManagerInstance] fadeOut:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[GameScene soundManagerInstance]
                                   selector:@selector(fadeOut:)
                                   userInfo:nil
                                    repeats:NO];
    
    SKAction *wait = [SKAction waitForDuration: 1.0];
    SKAction *run = [SKAction runBlock:^{
        block();
    }];
    SKAction *sequence = [SKAction sequence:@[wait, run]];
    [[GameScene sceneInstance] runAction:sequence];
    return;
}

// scale main menu and run the given block
// this is used for exiting main menu when clicking "high score"
-(void)scaleOutMenuAndExec:(void (^)(void))block
{
    [GameScene gameLogicInstance].mainMenuVisible = NO;

    // fade out background and start game
    self.menu = (SKSpriteNode*)[[GameScene sceneInstance] childNodeWithName:@"mainMenu"];
    self.menu.zPosition = 900;
    
  //  self.scaleSpeed = 0.14;
    
    ///    SKAction *scale = [SKAction scaleTo:0.5 duration: 1.5];
    //  [menu runAction:scale];
    [NSTimer scheduledTimerWithTimeInterval:0.02
                                     target:self
                                   selector:@selector(onScaleOutMenu:)
                                   userInfo:[NSNumber numberWithFloat:0.3]
                                    repeats:NO];
    
    //    [[GameScene soundManagerInstance] fadeOut:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[GameScene soundManagerInstance]
                                   selector:@selector(fadeIn:)
                                   userInfo:nil
                                    repeats:NO];
    
    SKAction *wait = [SKAction waitForDuration: 1.0];
    SKAction *run = [SKAction runBlock:^{
        block();
    }];
    SKAction *sequence = [SKAction sequence:@[wait, run]];
    [[GameScene sceneInstance] runAction:sequence];
    return;
}



-(void)onMainMenuExit:(NSTimer*)timer
{
    [self sniffOutFlames];
    
    [GameScene gameLogicInstance].mainMenuVisible = NO;

    // fade out background
    self.menu = (SKSpriteNode*)[[GameScene sceneInstance] childNodeWithName:@"mainMenu"];

    SKAction *fade = [SKAction fadeAlphaTo:0.0 duration: 1.5];
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[GameScene soundManagerInstance]
                                   selector:@selector(fadeOut:)
                                   userInfo:nil
                                    repeats:NO];
    
/*    SKAction *run = [SKAction runBlock:^{
        block();
    }];*/
    SKAction *run = [SKAction runBlock:^{

        // remove flames
        for (int x=0; x<[GameScene sceneInstance].firePixelColumns.count; x++) {
            NSMutableArray *column = [[GameScene sceneInstance].firePixelColumns objectAtIndex:x];
            for (int y=0; y<column.count; y++) {
                SKEmitterNode* fire = (SKEmitterNode*)[column objectAtIndex:y];
                [fire removeFromParent];
            }
        }
        [[GameScene sceneInstance].firePixelColumns removeAllObjects];
        
        // remove about background
        if ([GameScene sceneInstance].selectLevelBackground != nil) {
            [[GameScene sceneInstance].selectLevelBackground removeFromParent];
            [GameScene sceneInstance].selectLevelBackground = nil;
        }
        
        // remove main menu background
        if (self.menu != nil) { // check if menu really exists, as we might be running in debug mode
            [self.menu removeFromParent];
            self.menu = nil;
        }
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        Boolean helpShown = (Boolean)[defaults boolForKey:@"helpScreenShown"];
        [defaults setBool:YES forKey:@"helpScreenShown"];
        [defaults synchronize];
        
        if (helpShown == YES) {
            [[GameScene sceneInstance] initLevel:[GameScene gameLogicInstance].currentLevel];
            [[GameScene menuLogicInstance] showLevelIntroText];
            [[GameScene sceneInstance] showAllSprites];
            
            [NSTimer scheduledTimerWithTimeInterval:DELAY_BETWEEN_LEVELS
                                             target:[GameScene gameLogicInstance]
                                           selector:@selector(onLevelPrepareStart:)
                                           userInfo:nil
                                            repeats:NO];
        } else {
            [self showHelpScreen];
        }
        
    }];
    
    SKAction *sequence = [SKAction sequence:@[fade, run]];
    [[GameScene sceneInstance] runAction:sequence];
}

-(void)showHelpScreen
{
    if ([GameScene gameLogicInstance].helpScreenVisible == YES || self.helpScreen != nil) {
        return;
    }
    [GameScene gameLogicInstance].helpScreenVisible = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"helpScreenShown"];
    [defaults synchronize];

    float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;

    SKSpriteNode* helpScreen = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size: [GameScene sceneInstance].screenSize];
    helpScreen.size = [GameScene sceneInstance].screenSize;
    helpScreen.position = CGPointMake(helpScreen.size.width/2, helpScreen.size.height/2);
    helpScreen.zPosition = 8000;
    helpScreen.lightingBitMask = 0;
    helpScreen.alpha = 0.0;
    self.helpScreen = helpScreen;
    [[GameScene sceneInstance] addChild:helpScreen];
    
    SKSpriteNode* angle = [SKSpriteNode spriteNodeWithImageNamed:@"help_angle"];
    angle.position = CGPointMake(0, helpScreen.size.height*0.18);
    angle.zPosition = 8000;
    angle.lightingBitMask = 0;
    angle.alpha = 1.0;
    angle.scale = 0.75*screenScale;
    [helpScreen addChild:angle];

    SKLabelNode* title = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    title.alpha = 1.0;
    title.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    title.fontSize = 22*screenScale;
    title.fontColor = [UIColor whiteColor];
    title.position = CGPointMake(0, helpScreen.size.height * 0.43);
    title.text = NSLocalizedString(@"HOW TO PLAY", "Title for the help screen, how to play the game.");
    title.zPosition = 1101;
    [helpScreen addChild:title];

    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    label.alpha = 1.0;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label.fontSize = 20*screenScale;
    label.fontColor = [UIColor whiteColor];
    label.position = CGPointMake(0, helpScreen.size.height * 0.32);
    label.text = NSLocalizedString(@"Adjust gravity by tilting the device", "Instructions for the player to turn the device to adjust the gravity direction.");
    label.zPosition = 1101;
    [helpScreen addChild:label];

    SKLabelNode* label2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    label2.alpha = 1.0;
    label2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label2.fontSize = 15*screenScale;
    label2.fontColor = [UIColor whiteColor];
    label2.position = CGPointMake(-30, -helpScreen.size.height*0.28);
    label2.text = NSLocalizedString(@"Move the paddle with your finger", "Instructions how to move the paddle/bat.");
    label2.zPosition = 1101;
    [helpScreen addChild:label2];

    SKLabelNode* label3 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    label3.alpha = 1.0;
    label3.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label3.fontSize = 15*screenScale;
    label3.fontColor = [UIColor whiteColor];
    label3.position = CGPointMake(helpScreen.size.width*0.1, -helpScreen.size.height * 0.20);
    label3.text = NSLocalizedString(@"Swipe up the icon to activate bonuses", "Instructions for activating the bonus features by swiping the icon up with a finger.");
    label3.zPosition = 1101;
    [helpScreen addChild:label3];

/*    SKSpriteNode* arrowAnchor = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size: CGSizeMake(1,1)];
    arrowAnchor.position = CGPointMake(0, helpScreen.size.height*0.15);
    arrowAnchor.zPosition = 7999;
    [helpScreen addChild:arrowAnchor];
  */
    SKSpriteNode* arrow = [SKSpriteNode spriteNodeWithImageNamed:@"help_arrow"];
    arrow.position = CGPointMake(0, helpScreen.size.height*0.18 + arrow.size.width/8*screenScale);
    arrow.zPosition = 8002;
    arrow.lightingBitMask = 0;
    arrow.alpha = 1.0;
    arrow.scale = 0.75*screenScale;
    [helpScreen addChild:arrow];
   // [arrowAnchor addChild:arrow];
    self.helpArrow = arrow;

    
    SKSpriteNode* txt1 = [SKSpriteNode spriteNodeWithImageNamed:@"helptext_lines1"];
    txt1.position = CGPointMake(-10*screenScale, -helpScreen.size.height*0.32);
    txt1.zPosition = 8001;
    txt1.lightingBitMask = 0;
    txt1.alpha = 1.0;
    txt1.scale = screenScale;
    [helpScreen addChild:txt1];
    
    SKSpriteNode* txt2 = [SKSpriteNode spriteNodeWithImageNamed:@"helptext_lines2"];
    txt2.position = CGPointMake(80*screenScale, -helpScreen.size.height*0.25);
    txt2.zPosition = 8001;
    txt2.lightingBitMask = 0;
    txt2.alpha = 1.0;
    txt2.scale = screenScale;
    [helpScreen addChild:txt2];

    SKSpriteNode* b = [SKSpriteNode spriteNodeWithImageNamed:@"bonus_red"];
    b.position = CGPointMake(helpScreen.size.width*0.4, -helpScreen.size.height*0.45);
    b.zPosition = 8001;
    b.scale = 0.8*screenScale;
    b.lightingBitMask = 0;
    b.alpha = 1.0;
    [helpScreen addChild:b];
    
    [[GameScene factoryInstance] createBat:[GameScene sceneInstance].scene.size.width/2 withY:BAT_START_YPOS scale:0.6 spriteNode:nil];
    [GameScene sceneInstance].bat.zPosition = 20000;
    [GameScene sceneInstance].batSprite.zPosition = 20000;
    [GameScene sceneInstance].batSprite.lightingBitMask = 0;
    [GameScene sceneInstance].batSprite.shadowCastBitMask = 0;
    [GameScene sceneInstance].batSprite.shadowedBitMask = 0;
    [GameScene sceneInstance].batSprite.alpha = 0.0;
    
    SKSpriteNode* helpButton = [self createButton:0 withY:-helpScreen.size.height*0.1 target:helpScreen label:NSLocalizedString(@"OK", "Accept the dialog") color:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4] fontSize:-1];
    helpButton.name = @"helpOKButton";
    [GameScene sceneInstance].helpOKButton = helpButton;
    
    
    [GameScene sceneInstance].alpha = 1.0;
    SKAction *fadeInAction = [SKAction fadeAlphaTo:1.0 duration: 0.5];
    [helpScreen runAction:fadeInAction];
    
//    SKAction* wait = [SKAction waitForDuration:0.8];
  //  SKAction *fadeInAction2 = [SKAction fadeAlphaTo:1.0 duration: 0.2];
    [[GameScene sceneInstance].batSprite runAction:fadeInAction];
}

-(void)exitHelpScreen
{
    if ([GameScene gameLogicInstance].helpScreenVisible == NO) {
        return;
    }
    if ([GameScene gameLogicInstance].mainMenuVisible == YES) {
        [GameScene gameLogicInstance].helpScreenVisible = NO;
        
        SKAction *remove = [SKAction runBlock:^{
            [self.helpScreen removeFromParent];
            self.helpScreen = nil;
            [[GameScene sceneInstance].batSprite removeFromParent];
            [[GameScene sceneInstance].bat removeFromParent];
            
            [GameScene sceneInstance].batSprite = nil;
            [GameScene sceneInstance].bat = nil;
            
            [[GameScene sceneInstance].helpOKButton removeFromParent];
            [GameScene sceneInstance].helpOKButton = nil;
        }];
        SKAction *fadeOutAction = [SKAction fadeAlphaTo:0.0 duration: 0.5];
        [self.helpScreen runAction:[SKAction sequence:@[fadeOutAction, remove]]];
        [[GameScene sceneInstance].batSprite runAction:fadeOutAction];
        return;
    }
    
    [GameScene gameLogicInstance].helpScreenVisible = NO;
    SKAction *start = [SKAction runBlock:^{
        [self.helpScreen removeFromParent];
        self.helpScreen = nil;
        [GameScene sceneInstance].alpha = 0.0;
        
        [[GameScene sceneInstance].batSprite removeFromParent];
        [[GameScene sceneInstance].bat removeFromParent];
        
        [GameScene sceneInstance].batSprite = nil;
        [GameScene sceneInstance].bat = nil;
        
        [[GameScene sceneInstance].helpOKButton removeFromParent];
        [GameScene sceneInstance].helpOKButton = nil;
        
        [[GameScene sceneInstance] initLevel:[GameScene gameLogicInstance].currentLevel];
        [[GameScene menuLogicInstance] showLevelIntroText];
        [[GameScene sceneInstance] showAllSprites];
        
        [NSTimer scheduledTimerWithTimeInterval:DELAY_BETWEEN_LEVELS
                                         target:[GameScene gameLogicInstance]
                                       selector:@selector(onLevelPrepareStart:)
                                       userInfo:nil
                                        repeats:NO];
    }];
    SKAction *fadeOutAction = [SKAction fadeAlphaTo:0.0 duration: 0.5];
    [self.helpScreen runAction:[SKAction sequence:@[fadeOutAction,start]]];
    [[GameScene sceneInstance].batSprite runAction:fadeOutAction];
}

-(void)showLevelIntroText
{
#ifdef DISABLE_INTRO_TEXT
    return;
#endif
    
    if (self.levelIntroText == nil || self.levelIntroText.parent == nil) {
        self.levelIntroText = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        self.levelIntroText.alpha = 0.0;
        self.levelIntroText.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [[GameScene sceneInstance].scene addChild:self.levelIntroText];
    }
    
    self.levelIntroText.text = [NSString stringWithFormat:@"%@ %2d", NSLocalizedString(@"Level", @"The next stage of the game"), [GameScene gameLogicInstance].currentLevel];
    //self.levelIntroText.text = [NSString stringWithFormat:@"Level %2d", [GameScene gameLogicInstance].currentLevel];
    self.levelIntroText.fontColor = [UIColor whiteColor];
    self.levelIntroText.fontSize = 30;
    self.levelIntroText.zPosition = 1110;
    self.levelIntroText.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame)+50);
    self.levelIntroText.scale = 1.0;

    NSString *txt = [LevelData getLevelIntroText:[GameScene gameLogicInstance].currentLevel];
    
    self.levelIntroDesc = [self textToSprite:txt fontSize:20 paragraphSize: CGSizeMake([GameScene sceneInstance].screenSize.width*3/4, 160)];
    self.levelIntroDesc.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame)+10);
    self.levelIntroDesc.alpha = 0.0;
    
    [[GameScene sceneInstance].scene addChild:self.levelIntroDesc];
    
#ifndef DISABLE_SHADERS
    if (self.shaderContainer != nil) {
        self.shaderContainer.shader = nil;
        [self.shaderContainer removeFromParent];
        self.shaderContainer = nil;
    }
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        SKShader* shader = [LevelData getShaderForLevelIntro:[GameScene gameLogicInstance].currentLevel];
        if (shader != nil) {
            SKSpriteNode* shaderContainer = [SKSpriteNode spriteNodeWithImageNamed:@"EmptyBody"];
            shaderContainer.size = [GameScene sceneInstance].scene.size;
            shaderContainer.position = CGPointMake(shaderContainer.size.width/2, shaderContainer.size.height/2);
            shaderContainer.zPosition = 1100;
            shaderContainer.lightingBitMask = 0;
            shaderContainer.shader = shader;
            shaderContainer.alpha = 1.0;
            
            self.cTime = 0;
            shader.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)], [SKUniform uniformWithName:@"currentTimeUniform" float:self.cTime]];
            
            [[GameScene sceneInstance].scene addChild:shaderContainer];
            self.shaderContainer = shaderContainer;
        }
    }
#endif
    
    SKAction *wait0 = [SKAction waitForDuration:0.1];
    SKAction* run = [SKAction runBlock:^{
        [GameScene sceneInstance].view.alpha = 1.0; // show view again as it has been resized
    }];
    [[GameScene sceneInstance] runAction:[SKAction sequence:@[wait0, run]]];
    
    // fade in, wait, fade out
    SKAction *wait1 = [SKAction waitForDuration:1.0];
    SKAction *wait2 = [SKAction waitForDuration:2.0];
    SKAction *wait3 = [SKAction waitForDuration:3.0];
    
    SKAction *fadeInAction = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    SKAction *fadeOutAction = [SKAction fadeAlphaTo:0.0 duration: 1.0];

    SKAction *sequence1 = [SKAction sequence:@[wait0, fadeInAction, wait3, fadeOutAction]];
    SKAction *sequence2 = [SKAction sequence:@[wait0, wait1, fadeInAction, wait2, fadeOutAction]];
    [self.levelIntroText runAction:sequence1];
    [self.levelIntroDesc runAction:sequence2];
}


- (SKSpriteNode*) textToSprite: (NSString*) str
                   fontSize: (NSInteger) font_size
            paragraphSize: (CGSize) para_size
{
    SKSpriteNode* paragraph = [[SKSpriteNode alloc] initWithColor: [SKColor clearColor] size: para_size];
    
    paragraph.anchorPoint = CGPointMake(0,1);
    paragraph.zPosition = 1000;

    NSMutableArray* str_arr = [[NSMutableArray alloc] init];
    NSArray* word_arr = [str componentsSeparatedByString:@" "];
    
    float est_char_width = font_size * 0.70;
    NSInteger num_char_per_line = para_size.width / est_char_width;
    
    NSString* temp_str = @"";
    for (NSString* word in word_arr)
    {
        if ((NSInteger)word.length <= num_char_per_line - (NSInteger)temp_str.length)
        {
            temp_str = [NSString stringWithFormat:@"%@ %@", temp_str, word];
        }
        else
        {
            [str_arr addObject: temp_str];
            temp_str = word;
        }
    }
    [str_arr addObject: temp_str];
    
    for (int i = 0; i < str_arr.count; i++)
    {
        NSString* sub_str = [str_arr objectAtIndex: i];
        SKLabelNode* label = [self createLabelWithText: sub_str];
        label.fontSize = font_size;
        label.fontColor = [UIColor whiteColor];
        label.position = CGPointMake(0, -(i+1) * font_size);
        [paragraph addChild: label];
    }
    
    return paragraph;
}

- (SKLabelNode*)createLabelWithText:(NSString*) str
{
    enum alignment
    {
        CENTER,
        LEFT,
        RIGHT
    };
    
    SKLabelNode* label;
    label = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    label.name = @"label";
    label.text = str;
    label.zPosition = 1000;
    label.horizontalAlignmentMode = CENTER;
    return label;
}

-(void)showAbout
{
    if ([GameScene gameLogicInstance].aboutMenuVisible == YES) {
        return;
    }
    if ([GameScene gameLogicInstance].highScoresVisible == YES) {
        return;
    }
    [GameScene gameLogicInstance].aboutMenuVisible = YES;

    float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;

    if ([GameScene sceneInstance].menuBackground == nil) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"menu_background"];
        bg.name = @"menuBackground";
        bg.size = CGSizeMake([GameScene sceneInstance].screenSize.width*0.9, [GameScene sceneInstance].screenSize.height*0.85);
        bg.position = CGPointMake([GameScene sceneInstance].screenSize.width/2, [GameScene sceneInstance].screenSize.height - [GameScene sceneInstance].screenSize.height/2);
        bg.zPosition = 3000;
        //bg.blendMode = SKBlendModeReplace;
  
        
        int screenH = [GameScene sceneInstance].screenSize.height;
        
        
        
        SKShapeNode* mask1 = [SKShapeNode node];
        mask1.zPosition = 3002;
        [mask1 setPath:CGPathCreateWithRoundedRect(CGRectMake(-screenH/16, -screenH*0.04, screenH/8, screenH*0.08), 8, 8, nil)];
        [mask1 setFillColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2]];
        
        SKTexture* tex1 = [[GameScene sceneInstance].view textureFromNode:mask1];
        SKSpriteNode* helpButton = [SKSpriteNode spriteNodeWithTexture:tex1];
        helpButton.zPosition = 3002;
        helpButton.position = CGPointMake(0, -screenH*0.20);
        [bg addChild:helpButton];
        
        SKLabelNode *help = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        help.name = @"helpButton";
        help.text = NSLocalizedString(@"Help", "Shows help screen");
        help.color = [UIColor grayColor];
        help.fontSize = 25*screenScale;
        help.zPosition = 1001;
        help.position = CGPointMake(0, -10*screenScale);
        help.scale = 1.0;
        help.blendMode = SKBlendModeAlpha;
        help.alpha = 0.9;
        [helpButton addChild:help];
        
        [GameScene sceneInstance].aboutMenuHelpButton = helpButton;
        
        
        
        SKShapeNode* mask = [SKShapeNode node];
        mask.zPosition = 3002;
        [mask setPath:CGPathCreateWithRoundedRect(CGRectMake(-screenH/8, -screenH*0.05, screenH/4, screenH*0.1), 8, 8, nil)];
        [mask setFillColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4]];
        
        SKTexture* tex = [[GameScene sceneInstance].view textureFromNode:mask];
        SKSpriteNode* button = [SKSpriteNode spriteNodeWithTexture:tex];
        button.zPosition = 3002;
        button.position = CGPointMake(0, -screenH*0.35);
        [bg addChild:button];
        
        
        SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        s.name = @"startButton";
        s.text = NSLocalizedString(@"Back", "Go back to previous screen");
        s.color = [UIColor grayColor];
        s.fontSize = 25*screenScale;
        s.zPosition = 1001;
        s.position = CGPointMake(0, -10*screenScale); //PointMake([GameScene sceneInstance].screenSize.width/2 -panel.position.x, screenH*0.15 - 10 -panel.position.y);
        s.scale = 1.0;
        s.blendMode = SKBlendModeAlpha;
        s.alpha = 0.9;
        [button addChild:s];
        
        [GameScene sceneInstance].aboutMenuBackButton = button;

        
/*        SKLabelNode* back = [SKLabelNode labelNodeWithFontNamed:@"Papyrus"];
        back.alpha = 1.0;
        back.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        back.fontSize = 20;
        back.fontColor = [UIColor whiteColor];
        back.position = CGPointMake(-bg.size.width/2 + 40, bg.size.height/2 - 20);
        back.text = @"<- Back";
        back.zPosition = 3001;
        [bg addChild:back];*/

        NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        NSArray* txt = @[NSLocalizedString(@"BRIMSTONE", @"Meaning is the same as in 'Fire and Brimstone'"), [NSString stringWithFormat: @"%@: %@ (%@)", NSLocalizedString(@"Version", @"Application version"), appVersionString, appBuildString], @"", NSLocalizedString(@"Programming and design:", "Coding and graphical design/gameplay design"), @"   Janne Heinonen", @"", NSLocalizedString(@"Resource files licensed", "The beginning of 'Resource files licensed via Fotolia.com and AudioBlocks.com'"), NSLocalizedString(@"via Fotolia.com", "The middle part of of 'Resource files licensed via Fotolia.com and AudioBlocks.com'"), NSLocalizedString(@"and AudioBlocks.com", "The ending of 'Resource files licensed via Fotolia.com and AudioBlocks.com'")];
        for (int i=0; i<txt.count; i++)
        {
            SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
            s.name = @"menuLabel";
            s.text = [txt objectAtIndex:i];
            s.color = [UIColor whiteColor];
            s.fontSize = 18*screenScale;
            s.zPosition = 3001;
            s.position = CGPointMake(0, 110 -i*20*screenScale);
            s.scale = 1.0;
            
            [bg addChild:s];
        }
        
        [[GameScene sceneInstance].scene addChild:bg];
        [GameScene sceneInstance].menuBackground = bg;
    }
    self.smokeArr = [[NSMutableArray alloc] init];
    for (int i=0; i<10; i++) {
        NSString *smokeEmitterPath = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
        SKEmitterNode *smokeEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:smokeEmitterPath];
        smokeEmitter.position = CGPointMake(-[GameScene sceneInstance].menuBackground.size.width/2 + i*([GameScene sceneInstance].menuBackground.size.width/10), [GameScene sceneInstance].menuBackground.size.height/2-20);
        smokeEmitter.name = @"smokeEmitter";
        smokeEmitter.particleZPosition = 3001;
        smokeEmitter.particleBirthRate = 10;
        smokeEmitter.particlePositionRange = CGVectorMake([GameScene sceneInstance].menuBackground.size.width/10, 10);
        smokeEmitter.targetNode = [GameScene sceneInstance].menuPanel;
        [[GameScene sceneInstance].menuBackground addChild: smokeEmitter];
        [self.smokeArr addObject:smokeEmitter];
    }
    
    
    [GameScene sceneInstance].menuBackground.alpha = 0.0;

    [GameScene sceneInstance].menuBackground.zPosition = 3000;
    [GameScene sceneInstance].menuBackground.hidden = NO;


/*    SKAction* move = [SKAction moveToX:[GameScene sceneInstance].screenSize.width/2 duration:0.5];
    move.timingMode = SKActionTimingEaseIn;
    [[GameScene sceneInstance].menuBackground runAction:move];
  */
    SKAction* fade = [SKAction fadeAlphaTo:1.0 duration: 0.5];
    [[GameScene sceneInstance].menuBackground runAction:fade];
    
    // hide menus
/*    [GameScene sceneInstance].startButton.hidden = YES;
    for (int i=0; i<[GameScene sceneInstance].menuItems.count; i++) {
        ((SKLabelNode*)[[GameScene sceneInstance].menuItems objectAtIndex:i]).zPosition = 1;
    }*/
}

-(void)exitAbout
{
    [GameScene gameLogicInstance].aboutMenuVisible = NO;

    for (int i=0; i<self.smokeArr.count; i++) {
        SKEmitterNode* node = (SKEmitterNode*)[self.smokeArr objectAtIndex:i];
        if (node != nil) {
            [node removeFromParent];
        }
    }
    [self.smokeArr removeAllObjects];
    
   /* SKAction* move = [SKAction moveToX:-[GameScene sceneInstance].screenSize.width duration:0.5];
    move.timingMode = SKActionTimingEaseOut;
    [[GameScene sceneInstance].menuBackground runAction:move];
*/
    SKAction* fade = [SKAction fadeAlphaTo:0.0 duration: 0.5];
    [[GameScene sceneInstance].menuBackground runAction:fade];

//    [GameScene sceneInstance].menuBackground.zPosition = -1;
  //  [GameScene sceneInstance].menuBackground.hidden = YES;

    // show menus
  /*  [GameScene sceneInstance].startButton.hidden = NO;
    for (int i=0; i<[GameScene sceneInstance].menuItems.count; i++) {
        ((SKLabelNode*)[[GameScene sceneInstance].menuItems objectAtIndex:i]).hidden = NO;
    }*/
}

-(void)showHighscores
{
    if ([GameScene gameLogicInstance].highScoresVisible == YES) {
        return;
    }
    if ([GameScene gameLogicInstance].aboutMenuVisible == YES) {
        return;
    }
    if ([GameScene gameLogicInstance].selectLevelMenuVisible == YES) {
        return;
    }
    if ([GameScene gameLogicInstance].bonusScreenVisible == YES) {
        return;
    }
    [GameScene gameLogicInstance].highScoresVisible = YES;
    CGSize size = CGSizeMake([GameScene sceneInstance].scene.size.width, 101*60+100);
    SKSpriteNode* node = [[SKSpriteNode alloc] initWithColor: [SKColor blackColor] size: size];
    node.alpha = 0.0;
    self.node = node;

    SKSpriteNode* textContainer = [[SKSpriteNode alloc] initWithColor: [SKColor clearColor] size: size];
    textContainer.alpha = 0.0;
    self.textContainer = textContainer;
    [node addChild:textContainer];
    
//    SKSpriteNode *node = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake([GameScene sceneInstance].screenSize.width*3/2, 100*60)];
    node.position = CGPointMake([GameScene sceneInstance].scene.size.width/2, 0);
    node.zPosition = 1040;
#ifndef DISABLE_SHADERS
    
    if ([GameScene gameLogicInstance].LOW_PERFORMANCE_MODE == NO) {
        node.shader = [GameScene shaderInstance].fullscreenSmokeShader2;
        
        node.shader.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)],
                                 [SKUniform uniformWithName:@"position" floatVector3:GLKVector3Make(self.scrollIndex, 0, 0)]];
    }
#endif
    float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;
    
    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    label.alpha = 1.0;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label.fontSize = 30*screenScale;
    label.fontColor = [UIColor whiteColor];
    label.position = CGPointMake(0, [GameScene sceneInstance].screenSize.height - 70*screenScale);
    label.text = NSLocalizedString(@"BEST PLAYERS", "High score list");
    label.zPosition = 1101;
    [textContainer addChild:label];

    SKLabelNode* back = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    back.alpha = 1.0;
    back.name = @"backButton";
    back.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    back.fontSize = 20*screenScale;
    back.fontColor = [UIColor whiteColor];
    back.position = CGPointMake(-[GameScene sceneInstance].screenSize.width/2 + 40*screenScale, 20*screenScale);
    back.text = [NSString stringWithFormat: @"<-- %@", NSLocalizedString(@"Back", "Go back to previous screen")];
    back.zPosition = 1101;
    [textContainer addChild:back];

    NSMutableArray* arr = [self highscoreData];
    int pos = 160*screenScale;

    if ([GameScene menuLogicInstance].highscores.gameCenterIsDisabled == YES) {
        SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        label.alpha = 1.0;
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        label.fontSize = 25*screenScale;
        label.fontColor = [UIColor whiteColor];
        label.position = CGPointMake(0, [GameScene sceneInstance].screenSize.height - pos);
        
        label.text = NSLocalizedString(@"Enable Game Center to", @"First half of 'Enable Game Center to see the high scores'");
        label.zPosition = 1101;
        [textContainer addChild:label];

        pos = pos + 25*screenScale;
        
        SKLabelNode* label2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        label2.alpha = 1.0;
        label2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        label2.fontSize = 25*screenScale;
        label2.fontColor = [UIColor whiteColor];
        label2.position = CGPointMake(0, [GameScene sceneInstance].screenSize.height - pos);
        
        label2.text = NSLocalizedString(@"see the high scores", @"Second half of 'Enable Game Center to see the high scores'");
        label2.zPosition = 1101;
        [textContainer addChild:label2];
        
    } else {
        for (int i=1; i<=arr.count; i++) {
            GKScore* score = (GKScore*)[arr objectAtIndex:i-1];
            
            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
            label.alpha = 1.0;
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            label.fontSize = 25*screenScale;
            label.fontColor = [UIColor whiteColor];
            label.position = CGPointMake(20-[GameScene sceneInstance].scene.size.width/2, [GameScene sceneInstance].screenSize.height - pos);
            if (i == 3) {
                pos = pos + 20*screenScale;
            }
            pos = pos+50*screenScale;
            
            label.text = [NSString stringWithFormat:@"%d. %@     %d", i, score.player.displayName, (int)score.value ];
            label.zPosition = 1101;
            [textContainer addChild:label];
        }
    }
//    [self sniffOutFlames]; let's let the flames burn, commented out

    [self hideMenuLabelAndStartButton];
    // fade out menupanel a bit
    SKAction *menuFade = [SKAction fadeAlphaTo:0.5 duration: 1.0];
    [[GameScene sceneInstance].menuPanel runAction:menuFade];
    
    // fade in root node (with shader)
    SKAction *nodeFade = [SKAction fadeAlphaTo:0.9 duration: 2.0];
    [node runAction:nodeFade];
    
    [self scaleMenuAndExec:^{
        // fade in highscore texts
        [[GameScene sceneInstance].scene addChild:node];
        SKAction *fade = [SKAction fadeAlphaTo:1.0 duration: 1.0];
        [textContainer runAction:fade];

        [[GameScene soundManagerInstance] clearPlaylist:MENU_MUSIC];
        [[GameScene soundManagerInstance] setVolume:1.0 playerNum:MENU_MUSIC];
        [[GameScene soundManagerInstance] addToPlaylist:@"highscore" ofType:@"mp3" playerNum:MENU_MUSIC];
        [[GameScene soundManagerInstance] play:NO playerNum:MENU_MUSIC];
        
      //  SKAction *snd = [SKAction playSoundFileNamed:@"explosion.mp3" waitForCompletion:NO];
       // [[GameScene sceneInstance] runAction:snd];
    }];
}

-(void)exitHighscores
{
    if ([GameScene gameLogicInstance].highScoresVisible == NO) {
        return;
    }
    [GameScene gameLogicInstance].highScoresVisible = NO;

    // fade out root node (with shader)
    SKAction *nodeFade = [SKAction fadeAlphaTo:0.0 duration: 2.0];
    [self.node runAction:nodeFade];

    self.node.shader = nil;
    
    [self showMenuLabelAndStartButton];
     // fade in menupanel
    SKAction *menuFade = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    [[GameScene sceneInstance].menuPanel runAction:menuFade];
    
    SKAction *fade = [SKAction fadeAlphaTo:0.0 duration: 0.5];
    [self.textContainer runAction:fade];
    
    [self scaleOutMenuAndExec:^{
        // fade out highscore texts
        [self.node removeFromParent];
        self.textContainer = nil;
        self.node = nil;
        [GameScene gameLogicInstance].mainMenuVisible = YES;
        [[GameScene soundManagerInstance] clearPlaylist:2];
    }];
}

-(void)showBonusScreen
{
    if ([GameScene gameLogicInstance].aboutMenuVisible == YES) {
        return;
    }
    if ([GameScene gameLogicInstance].highScoresVisible == YES) {
        return;
    }
    if ([GameScene gameLogicInstance].selectLevelMenuVisible == YES) {
        return;
    }
    if ([GameScene gameLogicInstance].bonusScreenVisible == YES) {
        return;
    }
    [GameScene gameLogicInstance].bonusScreenVisible = YES;

    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"EmptyBody"];
    bg.name = @"bonusScreenBackground";

    bg.size = [GameScene sceneInstance].scene.size;
    bg.position = CGPointMake(bg.size.width/2, bg.size.height/2);

    bg.zPosition = 3000;
    bg.lightingBitMask = 0;
    
#ifndef DISABLE_SHADERS
/*    SKSpriteNode* shaderContainer = [SKSpriteNode spriteNodeWithImageNamed:@"EmptyBody"];
    shaderContainer.size = [GameScene sceneInstance].scene.size;
    shaderContainer.position = CGPointMake(shaderContainer.size.width/2, shaderContainer.size.height/2);
    shaderContainer.zPosition = 1100;
    shaderContainer.lightingBitMask = 0;
    shaderContainer.shader = [GameScene shaderInstance].fullscreenSmokeShader2;
    [[GameScene sceneInstance] addChild:shaderContainer];*/

/*    bg.shader = [GameScene shaderInstance].bigfireShader;
    bg.shader.uniforms = @[[SKUniform uniformWithName:@"resolution" floatVector3:GLKVector3Make([GameScene sceneInstance].scene.size.width, [GameScene sceneInstance].scene.size.height, 0)]];*/
#endif

    UIColor* fillCol = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4];
    
    //        int screenW = [GameScene sceneInstance].screenSize.width;
    int screenH = [GameScene sceneInstance].sceneSize.height;

    
    // retrieve best score for the level
    NSArray* scores = [self.levelHighScores valueForKey:[NSString stringWithFormat:@"%d", [GameScene gameLogicInstance].currentLevel]];
    
    int yourBestScore = -1;
    int globalHighScore = -1;
    int yourRanking = -1;
    NSString* highscoreOwner;
    if (scores != nil) {
        for (int i=0; i<scores.count; i++) {
            GKScore* score = [scores objectAtIndex:i];
            if (score.value > globalHighScore) {
                globalHighScore = (int)score.value;
                highscoreOwner = score.player.displayName;
            }
            if ([score.player.playerID isEqual:((GKPlayer*)[GKLocalPlayer localPlayer]).playerID]) {
                yourBestScore = (int)score.value;
                yourRanking = (int)score.rank;
            }
        }
    }
    NSArray * arr = [self highscoreData];
    GKScore *bestScore = nil;
    if (arr != nil && arr.count>0) {
        bestScore = (GKScore*)[arr objectAtIndex:0];
    }

    float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;

    SKLabelNode *label1 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    if ([GameScene gameLogicInstance].levelsCompleted > 0 &&
        [GameScene gameLogicInstance].gameIsOver == NO) {
        label1.text = [NSString stringWithFormat: @"%@: %d x %d = %d", NSLocalizedString(@"Levels Completed bonus", nil), [GameScene gameLogicInstance].levelsCompleted, POINTS_FOR_LEVEL_COMPLETE, [GameScene gameLogicInstance].levelsCompleted * POINTS_FOR_LEVEL_COMPLETE];
        label1.fontColor = [UIColor whiteColor];
        label1.fontSize = 18*screenScale;
        label1.zPosition = 1000;
        label1.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame) - screenH/8);
        label1.scale = 1.0;
        label1.alpha = 0.0;
        [[GameScene sceneInstance] addChild:label1];
        SKAction *w1 = [SKAction waitForDuration: 0.2];
        SKAction *fadeAction1 = [SKAction fadeAlphaTo:1.0 duration: 1.0];
        [label1 runAction:[SKAction sequence:@[w1,fadeAction1]]];
    }
    
    int perf = -1;
    int rank = -1;
    if (globalHighScore != -1) {
        perf = [GameScene gameLogicInstance].levelScore * 100 / globalHighScore;
        rank = yourRanking;
    }
    SKLabelNode *label2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    if (perf != -1) {
        label2.text = [NSString stringWithFormat: @"%@ %d%%", NSLocalizedString(@"Level Performance:",nil), perf];
    } else {
        label2.text = @"";
    }
    label2.fontColor = [UIColor whiteColor];
    label2.fontSize = 18*screenScale;
    label2.zPosition = 1000;
    label2.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame) - screenH/8 - 24);
    label2.scale = 1.0;
    label2.alpha = 0.0;
    [[GameScene sceneInstance] addChild:label2];
    
    SKAction *w2 = [SKAction waitForDuration: 0.2];
    SKAction *fadeAction2 = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    [label2 runAction:[SKAction sequence:@[w2,fadeAction2]]];
    
    SKAction *w = [SKAction waitForDuration: 0.2];
    SKAction *fadeAction = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    [label2 runAction:[SKAction sequence:@[w,fadeAction]]];

    

    SKLabelNode *label3 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    if ([GameScene gameLogicInstance].levelScore >= globalHighScore) {
        label3.fontSize = 24*screenScale;
        if (globalHighScore != -1) {
            label3.text = NSLocalizedString(@"New Level High Score!", "Player achieves the highest score ever in the level.");
        } else {
            label3.text = @"";
        }
    } else {
        if (rank != -1) {
            label3.text = [NSString stringWithFormat:@"%@ #%d", NSLocalizedString(@"Your best ranking:",nil), rank];
        } else {
            label3.text = @"";
        }
    }
    label3.fontColor = [UIColor whiteColor];
    label3.fontSize = 18*screenScale;
    label3.zPosition = 1000;
    label3.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame) - screenH/8 -48);
    label3.scale = 1.0;
    label3.alpha = 0.0;
    [[GameScene sceneInstance] addChild:label3];

    SKAction *w3 = [SKAction waitForDuration: 0.2];
    SKAction *fadeAction3 = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    [label3 runAction:[SKAction sequence:@[w3,fadeAction3]]];
    
    SKAction *w4 = [SKAction waitForDuration: 6.0];
    SKAction *fadeAction4 = [SKAction fadeAlphaTo:0.0 duration: 1.0];
    [label1 runAction:[SKAction sequence:@[w4,fadeAction4]]];
    [label2 runAction:[SKAction sequence:@[w4,fadeAction4]]];
    [label3 runAction:[SKAction sequence:@[w4,fadeAction4]]];

    SKAction *w5 = [SKAction waitForDuration: 7.0];
    SKAction *changeText = [SKAction runBlock:^{
        if ([GameScene gameLogicInstance].gameIsOver) {
            if (bestScore != nil) {
                int progress = [GameScene gameLogicInstance].score*100 / bestScore.value;
                if (progress >= 100) {
                    label1.text = NSLocalizedString(@"New High Score!", "Player got the best ever result in the game.");
                } else {
                    label1.text = [NSString stringWithFormat:@"%@ %d (%d%% %@)", NSLocalizedString(@"Final Score:",nil), [GameScene gameLogicInstance].score, progress, NSLocalizedString(@" of High Score", "Player's score is X percent of the High Score")];
                }
            } else {
                label1.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Final Score:",nil), [GameScene gameLogicInstance].score];
            }
        } else {
            label1.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Current Score: ",nil), [GameScene gameLogicInstance].score];
        }
    }];
    SKAction *changeText2 = [SKAction runBlock:^{
        if (bestScore != nil) {
            if ([GameScene gameLogicInstance].gameIsOver == YES) {
                if ([GameScene gameLogicInstance].score > bestScore.value) {
                    label2.text = NSLocalizedString(@"New High Score!", "Player got the best ever result in the game.");
                } else {
                    if (self.playerHighscoreRanking != 0) {
                        label2.text = [NSString stringWithFormat:@"%@ #%d", NSLocalizedString(@"Your best ranking:", "Player's best ranking in high score table."), self.playerHighscoreRanking];
                    } else {
                        int progress = [GameScene gameLogicInstance].score*100 / bestScore.value;
                        label2.text = [NSString stringWithFormat:@"%@ %d%%", NSLocalizedString(@"Percent of High Score:", nil), progress];
                    }
                }
            } else {
                if ([GameScene gameLogicInstance].score > bestScore.value) {
                    label2.text = NSLocalizedString(@"New High Score!", "Player got the best ever result in the game.");
                } else {
                    int progress = [GameScene gameLogicInstance].score*100 / bestScore.value;
                    label2.text = [NSString stringWithFormat:@"%@ %d%%", NSLocalizedString(@"Progress to High Score:", nil), progress];
                }
            }
        } else {
            label2.text = @"";
        }
    }];
    SKAction *changeText3 = [SKAction runBlock:^{
        label3.text = @"";
    }];
    
    SKAction *fadeAction5 = [SKAction fadeAlphaTo:0.0 duration: 1.0];
    SKAction *fadeAction6 = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    [label1 runAction:[SKAction sequence:@[w5,fadeAction5,changeText,fadeAction6]]];
    [label2 runAction:[SKAction sequence:@[w5,fadeAction5,changeText2,fadeAction6]]];
    [label3 runAction:[SKAction sequence:@[w5,fadeAction5,changeText3,fadeAction6]]];


    if ([GameScene gameLogicInstance].gameIsOver == YES) {
        SKShapeNode* mask = [SKShapeNode node];
        mask.zPosition = 3002;
        [mask setPath:CGPathCreateWithRoundedRect(CGRectMake(-screenH/8, -screenH*0.05, screenH/4, screenH*0.1), 8, 8, nil)];
        [mask setFillColor:fillCol];
        
        SKTexture* tex = [[GameScene sceneInstance].view textureFromNode:mask];
        SKSpriteNode* button = [SKSpriteNode spriteNodeWithTexture:tex];
        button.zPosition = 3002;
        button.position = CGPointMake(0, -screenH*0.3);
        button.alpha = 0.8;
        [bg addChild:button];
        
        SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        s.name = @"retryButton";
        s.text = NSLocalizedString(@"Retry level", "Try the level again");
        s.color = [UIColor grayColor];
        s.fontSize = 25;
        s.zPosition = 4001;
        s.position = CGPointMake(0, -10); //PointMake([GameScene sceneInstance].screenSize.width/2 -panel.position.x, screenH*0.15 - 10 -panel.position.y);
        s.scale = 1.0;
        s.blendMode = SKBlendModeAlpha;
        s.alpha = 1.0;
        [button addChild:s];
        
        [GameScene sceneInstance].bonusScreenBackButton = button;
        
        
        SKShapeNode* mask2 = [SKShapeNode node];
        mask2.zPosition = 3002;
        [mask2 setPath:CGPathCreateWithRoundedRect(CGRectMake(-screenH/8, -screenH*0.05, screenH/4, screenH*0.1), 8, 8, nil)];
        [mask2 setFillColor:fillCol];
        
        SKTexture* tex2 = [[GameScene sceneInstance].view textureFromNode:mask2];
        SKSpriteNode* button2 = [SKSpriteNode spriteNodeWithTexture:tex2];
        button2.zPosition = 3002;
        button2.position = CGPointMake(0, -screenH*0.3 -screenH*0.12);
        button2.alpha = 0.8;
        [bg addChild:button2];
        
        SKLabelNode *s2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        s2.name = @"menuButton";
        s2.text = NSLocalizedString(@"Main menu", "Go to main menu");
        s2.color = [UIColor grayColor];
        s2.fontSize = 25;
        s2.zPosition = 4003;
        s2.position = CGPointMake(0, -10); //PointMake([GameScene sceneInstance].screenSize.width/2 -panel.position.x, screenH*0.15 - 10 -panel.position.y);
        s2.scale = 1.0;
        s2.blendMode = SKBlendModeAlpha;
        s2.alpha = 1.0;
        [button2 addChild:s2];
        
        [GameScene sceneInstance].bonusScreenMainMenuButton = button2;
    } else {
        SKShapeNode* mask2 = [SKShapeNode node];
        mask2.zPosition = 3002;
        [mask2 setPath:CGPathCreateWithRoundedRect(CGRectMake(-screenH/8, -screenH*0.05, screenH/4, screenH*0.1), 8, 8, nil)];
        [mask2 setFillColor:fillCol];
        
        SKTexture* tex2 = [[GameScene sceneInstance].view textureFromNode:mask2];
        SKSpriteNode* button2 = [SKSpriteNode spriteNodeWithTexture:tex2];
        button2.zPosition = 3002;
        button2.position = CGPointMake(0, -screenH*0.3);
        button2.alpha = 0.8;
        [bg addChild:button2];
        
        SKLabelNode *s2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        s2.name = @"continueButton";
        s2.text = NSLocalizedString(@"Continue", "Continue game");
        s2.color = [UIColor grayColor];
        s2.fontSize = 25*screenScale;
        s2.zPosition = 3003;
        s2.position = CGPointMake(0, -10*screenScale);
        s2.scale = 1.0;
        s2.blendMode = SKBlendModeAlpha;
        s2.alpha = 1.0;
        [button2 addChild:s2];
        
        [GameScene sceneInstance].bonusScreenContinueButton = button2;
    }


    bg.alpha = 0.0;
    [[GameScene sceneInstance] addChild:bg];
    [GameScene sceneInstance].bonusScreenBackground = bg;

    SKAction* fade = [SKAction fadeAlphaTo:1.0 duration: 0.5];
    [bg runAction:fade];
}

-(SKSpriteNode*)createButton:(float)x withY:(float)y target:(SKSpriteNode*)bg label:(NSString*)label color:(UIColor*)color fontSize:(float)fontSize
{
    float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;
    
    if (fontSize <= 0) {
        fontSize = 25;
    }
    
    int screenH = [GameScene sceneInstance].screenSize.height;
    SKShapeNode* mask = [SKShapeNode node];
    mask.zPosition = 3002;
    [mask setPath:CGPathCreateWithRoundedRect(CGRectMake(-screenH/12, -screenH*0.0375, screenH/6, screenH*0.075), 8, 8, nil)];
    [mask setFillColor:color];

    SKTexture* tex = [[GameScene sceneInstance].view textureFromNode:mask];
    SKSpriteNode* button = [SKSpriteNode spriteNodeWithTexture:tex];
    button.zPosition = 3002;
    button.position = CGPointMake(x, y);
    [bg addChild:button];

    SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    s.name = label;
    s.text = label;
    s.color = [UIColor grayColor];
    s.fontSize = fontSize*screenScale;
    s.zPosition = 1001;
    s.position = CGPointMake(0, -10*screenScale);
    s.scale = 1.0;
    s.blendMode = SKBlendModeAlpha;
    s.alpha = 0.9;
    [button addChild:s];
    return button;
}

-(SKSpriteNode*)createSmallerButton:(float)x withY:(float)y target:(SKSpriteNode*)bg label:(NSString*)label color:(UIColor*)color fontSize:(float)fontSize
{
    float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;
    
    if (fontSize <= 0) {
        fontSize = 25;
    }
    
    int screenH = [GameScene sceneInstance].screenSize.height;
    SKShapeNode* mask = [SKShapeNode node];
    mask.zPosition = 3002;
    [mask setPath:CGPathCreateWithRoundedRect(CGRectMake(-screenH/8, -screenH*0.0225, screenH/4, screenH*0.045), 8, 8, nil)];
    [mask setFillColor:color];
 
    SKTexture* tex = [[GameScene sceneInstance].view textureFromNode:mask];
    SKSpriteNode* button = [SKSpriteNode spriteNodeWithTexture:tex];
    button.zPosition = 3002;
    button.position = CGPointMake(x, y);
    [bg addChild:button];
    
    SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    s.name = label;
    s.text = label;
    s.color = [UIColor grayColor];
    s.fontSize = fontSize*screenScale;
    s.zPosition = 1001;
    s.position = CGPointMake(0, -8*screenScale);
    s.scale = 1.0;
    s.blendMode = SKBlendModeAlpha;
    s.alpha = 0.9;
    [button addChild:s];
    return button;
}

// update per level high score data
-(void)updateScores
{
    if ([GameScene gameLogicInstance].selectLevelMenuVisible == NO) {
        return;
    }
    NSArray* scores = [self.levelHighScores valueForKey:[NSString stringWithFormat:@"%d", [GameScene gameLogicInstance].currentLevel]];
 
    float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;
    
    int level = [GameScene gameLogicInstance].currentLevel;
    int yourBestScore = -1;
    int globalHighScore = -1;
    int yourRanking = -1;
    NSString* highscoreOwner;

    if (scores != nil) {
        for (int i=0; i<scores.count; i++) {
            GKScore* score = [scores objectAtIndex:i];
            if (score.value > globalHighScore) {
                globalHighScore = (int)score.value;
                highscoreOwner = score.player.displayName;
               /* if (highscoreOwner != nil && [highscoreOwner length] > 18) {
                    highscoreOwner = @"";
                }*/
            }
            if ([score.player.playerID isEqual:((GKPlayer*)[GKLocalPlayer localPlayer]).playerID]) {
                yourBestScore = (int)score.value;
                yourRanking = (int)score.rank;
            }
        }
    }

    // remove old labels (ugly)
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for (int i=0; i<[GameScene sceneInstance].selectLevelBackground.children.count; i++) {
        SKNode* n = [[GameScene sceneInstance].selectLevelBackground.children objectAtIndex:i];
        if (n != nil && [n.name isEqualToString:@"menuLabel"]) {
            [arr addObject: n];
        }
    }
    for (int i=0; i<arr.count; i++) {
        [[arr objectAtIndex:i] removeFromParent];
    }
    arr = nil;
    // end of remove

    int ypos = -50*screenScale;
    for (int i=0; i<=3; i++)
    {
        SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        s.name = @"menuLabel";
        
        if (i == 0) {
            s.text = [NSString stringWithFormat: @"%@ %d", NSLocalizedString(@"Level:", "The current game level"), level];
            s.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
            s.fontSize = 24*screenScale;
            s.position = CGPointMake(0, ypos);
        } else if (i == 1) {
            
            if ([GameScene menuLogicInstance].highscores.gameCenterIsDisabled == YES) {
                s.text = NSLocalizedString(@"Enable Game Center to see the high scores", "Instructions for the player to enable Game Center in iOS settings");
                s.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                s.fontSize = 15*screenScale;
                s.position = CGPointMake(0, ypos);
                s.color = [UIColor whiteColor];
                s.zPosition = 3001;
                s.scale = 1.0;
                ypos = ypos - 25*screenScale;
                
                [[GameScene sceneInstance].selectLevelBackground addChild:s];
                break;
            }
            
            ypos = ypos - 20;
            s.text = NSLocalizedString(@"Your best score:", "Player's best score in the game");
            s.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            s.fontSize = 20*screenScale;
            s.position = CGPointMake(-150*screenScale, ypos);
            
            SKLabelNode *s2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
            s2.name = @"menuLabel";
            
            NSString* yourRankingStr = @"";
            if (yourRanking == -1) {
                yourRankingStr = @"";
            } else {
                yourRankingStr = [NSString stringWithFormat: @"(#%d)", yourRanking];
            }
            if (yourBestScore == -1) {
                s2.text = @"-";
            } else {
                s2.text = [NSString stringWithFormat: @"%d %@", yourBestScore, yourRankingStr];
            }
            s2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            s2.color = [UIColor whiteColor];
            s2.fontSize = 22*screenScale;
            s2.zPosition = 3001;
            s2.position = CGPointMake(150*screenScale, ypos);
            s2.scale = 1.0;
            [[GameScene sceneInstance].selectLevelBackground addChild:s2];
            
        } else if (i == 2) {
            s.text = NSLocalizedString(@"High score:", "The best ever score achieved in the game");
            s.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            s.fontSize = 20*screenScale;
            s.position = CGPointMake(-150*screenScale, ypos);
            
            SKLabelNode *s2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
            s2.name = @"menuLabel";
            
            if (globalHighScore == -1) {
                s2.text = @"-";
            } else {
                s2.text = [NSString stringWithFormat: @"%d",  globalHighScore];
            }
            s2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            s2.color = [UIColor whiteColor];
            s2.fontSize = 22*screenScale;
            s2.zPosition = 3001;
            s2.position = CGPointMake(150*screenScale, ypos);
            s2.scale = 1.0;
            [[GameScene sceneInstance].selectLevelBackground addChild:s2];
        } else if (i == 3) {
/*            s.text = NSLocalizedString(@"Your global ranking:", "Player's global ranking in the game");
            s.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            s.fontSize = 20*screenScale;
            s.position = CGPointMake(-150*screenScale, ypos);
  */
            SKLabelNode *s2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
            s2.name = @"menuLabel";
            if (highscoreOwner == nil) {
                s2.text = @"";
            } else {
                s2.text = [NSString stringWithFormat: @"%@", highscoreOwner];
            }
            s2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
            s2.color = [UIColor whiteColor];
            s2.fontSize = 22*screenScale;
            s2.zPosition = 3001;
            s2.position = CGPointMake(150*screenScale, ypos+10*screenScale);
            s2.scale = 1.0;
            [[GameScene sceneInstance].selectLevelBackground addChild:s2];
        }
        s.color = [UIColor whiteColor];
        s.zPosition = 3001;
        s.scale = 1.0;
        ypos = ypos - 35*screenScale;
        
        [[GameScene sceneInstance].selectLevelBackground addChild:s];
    }
}

// update inAppPurchase product info
-(void)updateProductInfo:(NSArray*)products
{
    for (SKProduct* product in products) {
        if ([product.productIdentifier isEqualToString:@"Brimstone_Full_Version"]) {
            self.inAppTitle = product.localizedTitle;
            self.inAppDesc = product.localizedDescription;
            self.inAppPrice = [InAppPurchase getFormattedPrice:product];
            [self updatePlaqueContents];
        }
    }
}

-(void)doInAppPurchase
{
    if (self.inAppPurchaseClicked == YES) {
        return;
    }
    self.inAppPurchaseClicked = YES;
    [[InAppPurchase instance] purchaseApp];
    
    if ([GameScene sceneInstance].inAppPurchaseButton  != nil) {
        [GameScene sceneInstance].inAppPurchaseButton.alpha = 0.2;
    }
}

-(void)restorePurchase
{
    if (self.restorePurchaseClicked == YES) {
        return;
    }
    self.restorePurchaseClicked = YES;
    [[InAppPurchase instance] restorePurchases];
    
    if ([GameScene sceneInstance].restorePurchaseButton  != nil) {
        [GameScene sceneInstance].restorePurchaseButton.alpha = 0.2;
    }
}

-(void)showSelectLevelMenu:(int)level
{
    Boolean levelLocked = NO;
    
    if (level >= IN_APP_PURCHASE_REQUIRED_FOR_LEVEL) {
        levelLocked = ([[InAppPurchase instance] isAppPurchased] == NO);
    }
    
    if ([GameScene gameLogicInstance].aboutMenuVisible == YES) {
        return;
    }
    if ([GameScene gameLogicInstance].highScoresVisible == YES) {
        return;
    }
    Boolean alreadyVisible = [GameScene gameLogicInstance].selectLevelMenuVisible;
    
    [GameScene gameLogicInstance].selectLevelMenuVisible = YES;
    [GameScene gameLogicInstance].mainMenuVisible = NO;

    float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;
    
    if (alreadyVisible == NO) {
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:[GameScene soundManagerInstance]
                                       selector:@selector(fadeOut:)
                                       userInfo:nil
                                        repeats:NO];
        
        [[GameScene soundManagerInstance] clearPlaylist:MENU_MUSIC];
        [[GameScene soundManagerInstance] setVolume:1.0 playerNum:MENU_MUSIC];
        [[GameScene soundManagerInstance] addToPlaylist:@"select_level" ofType:@"mp3" playerNum:MENU_MUSIC];
        [[GameScene soundManagerInstance] play:NO playerNum:MENU_MUSIC];
    }

    [self.highscores retrieveLevelHighScoreForPlayer:level+1]; // fetch data for the next level while showing current one
    
    if (level != [GameScene gameLogicInstance].currentLevel || [GameScene sceneInstance].selectLevelBackground == nil) {
        
        [GameScene gameLogicInstance].currentLevel = level;
        
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"menu_background"];
        bg.name = @"menuBackground";
        bg.size = CGSizeMake([GameScene sceneInstance].screenSize.width*0.95, [GameScene sceneInstance].screenSize.height*0.88);
        bg.position = CGPointMake([GameScene sceneInstance].screenSize.width/2, [GameScene sceneInstance].screenSize.height - [GameScene sceneInstance].screenSize.height/2);
        bg.zPosition = 3000;
        
  //      int w = [GameScene sceneInstance].screenSize.height/12;
        int h = [GameScene sceneInstance].screenSize.height*0.35;
 //       [self createButton:-w-5 withY:-h target:bg label:@"Prev" color:[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:0.4]];
        SKSpriteNode* button = [self createButton:0 withY:-h target:bg label:NSLocalizedString(@"OK", "Accept the dialog") color:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4] fontSize:-1];
   //     [self createButton:w+5 withY:-h target:bg label:@"Next" color:[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:0.4]];
        
        [GameScene sceneInstance].selectLevelBackButton = button;

        if (level > 1) {
            SKSpriteNode *prevButton = [SKSpriteNode spriteNodeWithImageNamed:@"Arrow"];
            prevButton.name = @"prevButton";
            prevButton.position = CGPointMake(-bg.size.width/4-40*screenScale, bg.size.width/4);
            prevButton.zPosition = 3001;
            prevButton.zRotation = M_PI;
            
            if ([GameScene sceneInstance].selectLevelPrevButton != nil) {
                [[GameScene sceneInstance].selectLevelPrevButton removeFromParent];
            }
            [GameScene sceneInstance].selectLevelPrevButton = prevButton;
            [bg addChild:prevButton];
        } else {
            [GameScene sceneInstance].selectLevelPrevButton = nil;
        }
        
        if (level < MAX_LEVEL) {
            SKSpriteNode *nextButton = [SKSpriteNode spriteNodeWithImageNamed:@"Arrow"];
            nextButton.name = @"nextButton";
            nextButton.position = CGPointMake(bg.size.width/4+40*screenScale, bg.size.width/4);
            nextButton.zPosition = 3001;
            if ([GameScene sceneInstance].selectLevelNextButton != nil) {
                [[GameScene sceneInstance].selectLevelNextButton removeFromParent];
            }
            [GameScene sceneInstance].selectLevelNextButton = nextButton;
            [bg addChild:nextButton];
        } else {
            [GameScene sceneInstance].selectLevelNextButton = nil;
        }
        
        if (levelLocked == YES) {
            SKSpriteNode* levelImage = [SKSpriteNode spriteNodeWithImageNamed: @"padlock"];
            levelImage.position = CGPointMake(0, levelImage.size.height/2+80*screenScale);
            levelImage.zPosition = 3001;
            levelImage.lightingBitMask = 0;
            levelImage.scale = 1.5*screenScale;
            [bg addChild:levelImage];
            self.levelImage = levelImage;
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                NSString *docsDir;
                NSArray *dirPaths;
                
                dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                docsDir = [dirPaths objectAtIndex:0];
                
                NSString* fname = [NSString stringWithFormat:@"level_%02d.jpg", level];
                NSString* levelPath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:fname]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage* img = [UIImage imageNamed:levelPath];
                    SKTexture *texture;
                    SKSpriteNode* levelImage = nil;
                    if (img != nil) {
                        texture = [SKTexture textureWithImage:img];
                        levelImage = [SKSpriteNode spriteNodeWithTexture:texture];
                        levelImage.size = CGSizeMake(bg.size.width/2, bg.size.height/2);
                    } else {
                        levelImage = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(bg.size.width/2, bg.size.height/2)];
                        
                        SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
                        s.name = @"questionmark";
                        s.text = @"?";
                        s.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                        s.fontSize = 72;
                        s.zPosition = 9005;
                        s.position = CGPointMake(0, -36);
                        [levelImage addChild:s];
                    }
                    levelImage.position = CGPointMake(0, levelImage.size.height/2-10*screenScale);
                    levelImage.zPosition = 3001;
                    levelImage.lightingBitMask = 0;
                    [bg addChild:levelImage];
                    self.levelImage = levelImage;
                });
                
            });
        }

        [[GameScene sceneInstance].scene addChild:bg];
        if ([GameScene sceneInstance].selectLevelBackground != nil) {
            [[GameScene sceneInstance].selectLevelBackground removeFromParent];
        }
        [GameScene sceneInstance].selectLevelBackground = bg;
        [self updateScores];
    }
    [GameScene sceneInstance].selectLevelBackground.zPosition = 3000;

    if (alreadyVisible == false) {
        [GameScene sceneInstance].selectLevelBackground.alpha = 0.0;
        
        [GameScene sceneInstance].selectLevelBackground.hidden = NO;
        
        SKAction* fade = [SKAction fadeAlphaTo:1.0 duration: 0.5];
        [[GameScene sceneInstance].selectLevelBackground runAction:fade];
    }

    [self sniffOutFlames];
}

-(void)createChain:(SKSpriteNode*)plaque isLeft:(Boolean)isLeft
{
    int ypos = plaque.position.y + plaque.size.height/2;
    
    SKSpriteNode *prev = nil;
    
    float scale = 1.0 * [GameScene sceneInstance].screenSize.height/667;
    
    SKSpriteNode *ob = nil;
    for (int i=0; i<=25; i++) {
        
        ob = [SKSpriteNode spriteNodeWithImageNamed: [NSString stringWithFormat:@"chain%d", ((i+1)%2+1)]];
        ob.name = @"chain";
        if (isLeft) {
            ob.position = CGPointMake([GameScene sceneInstance].screenSize.width/4, ypos);
        } else {
            ob.position = CGPointMake([GameScene sceneInstance].screenSize.width*3/4, ypos);
        }
        ob.scale = scale;
        ob.zPosition = 9001+((i+1)%2);
        ob.physicsBody = [SKPhysicsBody
                          bodyWithRectangleOfSize:
                          ob.size];
        ob.physicsBody.categoryBitMask = 0;
        ob.physicsBody.collisionBitMask = 0;
        ob.physicsBody.contactTestBitMask = 0;
        ob.physicsBody.dynamic = YES;
        ob.physicsBody.affectedByGravity = YES;
        ob.physicsBody.mass = 1;
        ob.physicsBody.linearDamping = 0.5f;
        ob.physicsBody.angularDamping = 0.5f;
        ob.physicsBody.restitution = 0.5f;
        ob.physicsBody.friction = 0.5;
        ob.physicsBody.allowsRotation = YES;
        [[GameScene sceneInstance] addChild:ob];
        
        if (i == 0) {
            CGPoint pos;
            if (isLeft == YES) {
                pos = CGPointMake(plaque.position.x - [GameScene sceneInstance].screenSize.width/4*0.95-5, ob.position.y - ob.size.height/2 + 3);
            } else {
                pos = CGPointMake(plaque.position.x + [GameScene sceneInstance].screenSize.width/4*0.95+5, ob.position.y - ob.size.height/2 + 3);
            }
            SKPhysicsJointPin* jointLast = [SKPhysicsJointPin jointWithBodyA:ob.physicsBody
                                                                       bodyB:plaque.physicsBody
                                                                      anchor:pos];
            [[GameScene sceneInstance].physicsWorld addJoint:jointLast];
        }
        
        if (isLeft) {
            [self.chain1 addObject:ob];
        } else {
            [self.chain2 addObject:ob];
        }

        SKPhysicsBody* bodyA;
        if (i == 0)
        {
            bodyA = plaque.physicsBody; //anchor.physicsBody;
        }
        else
        {
            bodyA = prev.physicsBody;
        }
        prev = ob;

        if (i == 25) {
            SKSpriteNode * anchor = [SKSpriteNode spriteNodeWithImageNamed:@"EmptyBody"];
            if (isLeft == YES) {
                anchor.position = CGPointMake([GameScene sceneInstance].screenSize.width/4, ypos); // [GameScene sceneInstance].screenSize.height+5);
                self.leftAnchor = anchor;
            } else {
                anchor.position = CGPointMake([GameScene sceneInstance].screenSize.width*3/4, ypos); //[GameScene sceneInstance].screenSize.height+5);
                self.rightAnchor = anchor;
            }
            anchor.size = CGSizeMake(1, 1);
            anchor.zPosition = 9001;
            anchor.physicsBody = [SKPhysicsBody
                                  bodyWithRectangleOfSize:
                                  anchor.size];
            anchor.physicsBody.affectedByGravity = NO;
            anchor.physicsBody.mass = 999999999;
            [[GameScene sceneInstance] addChild:anchor];
            
            SKPhysicsJointPin* joint = [SKPhysicsJointPin jointWithBodyA:ob.physicsBody bodyB:anchor.physicsBody anchor:CGPointMake(ob.position.x, ob.position.y - ob.size.height/2 - 3)];
            [[GameScene sceneInstance].physicsWorld addJoint:joint];
            
        }
        SKPhysicsJointPin* joint = [SKPhysicsJointPin jointWithBodyA:bodyA bodyB:ob.physicsBody anchor:CGPointMake(ob.position.x, ob.position.y - ob.size.height/2 - 3)];
        [[GameScene sceneInstance].physicsWorld addJoint:joint];
        
        ypos = ypos + ob.size.height-5;
        
        ob.alpha = 0.0;
        [ob runAction:[SKAction fadeAlphaTo:1.0 duration: 1.0]];
    }

    
}


-(void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    if ([GameScene gameLogicInstance].inAppPurchaseMenuVisible == NO) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[GameScene sceneInstance] convertPointFromView:touchLocation];
        
        self.touchStartPos = touchLocation;
        self.touchedNode = (SKSpriteNode *)[[GameScene sceneInstance] nodeAtPoint:touchLocation];
        if ([self.touchedNode.name isEqualToString:@"plaqueLabel"]) {
            self.touchedNode = (SKSpriteNode*)self.touchedNode.parent;
        }
        self.touchedNodePos = self.touchedNode.position;
        self.touchedNode.physicsBody.affectedByGravity = NO;
        self.touchedNode.physicsBody.dynamic = NO;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {

        float screenScale = 1.0 * [GameScene sceneInstance].screenSize.height/667;
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        if ([self.touchedNode.name isEqualToString:@"plaque"]) {
            float x = self.touchedNodePos.x + translation.x;
            float y = self.touchedNodePos.y + translation.y;
            
            float tx = x - [GameScene sceneInstance].screenSize.width/2;
            float ty = y - self.leftAnchor.position.y;
            float len = sqrtf(tx*tx+ty*ty);
            
            if (len >= [GameScene sceneInstance].screenSize.height/2+50*screenScale) {
                float div = len / ([GameScene sceneInstance].screenSize.height/2+50*screenScale);
                x = tx / div + [GameScene sceneInstance].screenSize.width/2;
                y = ty / div + self.leftAnchor.position.y;
            }
            self.touchedNode.position = CGPointMake(x, y);
            self.touchedNodePos = self.touchedNode.position;
        }
        float vx = translation.x*2200*screenScale;
        float vy = translation.y*2200*screenScale;
        if (fabs(vx) > 40000*screenScale) { // limit max velocity to avoid breaking the chains
            float div = vx/40000*screenScale;
            vx = 40000*screenScale;
            if (div == 0) {
                div = 0.1;
            }
            vy = vy/div;
        }
        if (fabs(vy) > 40000*screenScale) {
            float div = vy/40000*screenScale;
            vy = 40000*screenScale;
            if (div == 0) {
                div = 0.1;
            }
            vx = vx/div;
        }
        
        self.touchedNodeVelocity = CGVectorMake(vx, vy);
      //  NSLog(@"plaque velocity %f %f", vx, vy);
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.touchedNode.name isEqualToString:@"plaque"]) {
            self.touchedNode.physicsBody.affectedByGravity = YES;
            self.touchedNode.physicsBody.dynamic = YES;
            [self.touchedNode.physicsBody applyImpulse:self.touchedNodeVelocity];
        }
    }
}

-(void)updatePlaqueContents
{
    if ([GameScene gameLogicInstance].inAppPurchaseMenuVisible == NO || self.plaque == nil) {
        return;
    }
    SKLabelNode* p1 = (SKLabelNode*)[self.plaque childNodeWithName:@"plaqueLabel1"];
    if (p1 != nil) {
        p1.text = [NSString stringWithFormat: NSLocalizedString(@"To unlock all levels,", "The beginning of 'To unlock all levels, purchase ad-free Full Version'")];
    }

    SKLabelNode* p2 = (SKLabelNode*)[self.plaque childNodeWithName:@"plaqueLabel2"];
    if (p2 != nil) {
        p2.text = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"purchase ad-free", "Part of 'To unlock all levels, purchase ad-free Full Version'"), self.inAppTitle];
    }

    SKLabelNode* p3 = (SKLabelNode*)[self.plaque childNodeWithName:@"plaqueLabel3"];
    if (p3 != nil) {
        p3.text = [NSString stringWithFormat: @"%@", self.inAppPrice];
    }

    SKLabelNode* p4 = (SKLabelNode*)[self.plaque childNodeWithName:@"plaqueLabel4"];
    if (p4 != nil) {
        p4.text = @""; //15 additional levels"; //self.inAppDesc;
    }
}

-(void)showInAppPurchaseMenu
{
    if ([GameScene gameLogicInstance].inAppPurchaseMenuVisible == YES || self.plaque != nil)
    {
        return;
    }
    self.inAppPurchaseClicked = NO;
    self.restorePurchaseClicked = NO;
    
    float scale = 1.0 * [GameScene sceneInstance].screenSize.height/667;

    [GameScene gameLogicInstance].inAppPurchaseMenuVisible = YES;
    [GameScene sceneInstance].physicsWorld.speed = 2.0;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:[GameScene menuLogicInstance] action:@selector(handlePanGesture:)];
    [[GameScene sceneInstance].view addGestureRecognizer:self.panGesture];
    
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"plaque"];
    bg.name = @"plaque";
    float mult = [GameScene sceneInstance].screenSize.width*0.95/bg.size.width;
    bg.size = CGSizeMake(bg.size.width*mult, bg.size.height*mult);
    bg.position = CGPointMake([GameScene sceneInstance].screenSize.width/2, [GameScene sceneInstance].screenSize.height/2);
    bg.zPosition = 9002;
    bg.physicsBody = [SKPhysicsBody
                      bodyWithRectangleOfSize:
                      bg.size];
    bg.physicsBody.mass = 300;
    bg.physicsBody.categoryBitMask = 0;
    bg.physicsBody.collisionBitMask = 0;
    bg.physicsBody.contactTestBitMask = 0;
    bg.physicsBody.dynamic = YES;
    bg.physicsBody.affectedByGravity = YES;
    bg.physicsBody.linearDamping = 0.5f;
    bg.physicsBody.angularDamping = 0.5f;
    bg.physicsBody.restitution = 0.5f;
    bg.physicsBody.friction = 0.5;
    bg.physicsBody.allowsRotation = YES;
    
    SKLabelNode *s = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    s.name = @"plaqueLabel1";
  //  s.text = [NSString stringWithFormat: NSLocalizedString(@"To unlock all levels,", "The beginning of 'To unlock all levels, purchase Level Pack'")];
    s.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    s.fontSize = 18*scale;
    s.zPosition = 9005;
    s.position = CGPointMake(0, 62*scale);
    [bg addChild:s];
    
    SKLabelNode *s1 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    s1.name = @"plaqueLabel2";
    //s1.text = [NSString stringWithFormat: @"%@ %@", NSLocalizedString(@"purchase", "Part of 'To unlock all levels, purchase Level Pack'"), self.inAppTitle];
    s1.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    s1.fontSize = 18*scale;
    s1.zPosition = 9005;
    s1.position = CGPointMake(0, 42*scale);
    [bg addChild:s1];
    
    SKLabelNode *s2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    s2.name = @"plaqueLabel3";
    //s2.text = [NSString stringWithFormat: @"%@", self.inAppPrice];
    s2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    s2.fontSize = 20*scale;
    s2.zPosition = 9005;
    s2.position = CGPointMake(0, 15*scale);
    [bg addChild:s2];
    
    SKLabelNode *s3 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    s3.name = @"plaqueLabel4";
    //s3.text = self.inAppDesc;
    s3.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    s3.fontSize = 16*scale;
    s3.zPosition = 9005;
    s3.position = CGPointMake(0, -10*scale);
    [bg addChild:s3];
    bg.alpha = 0.0;
    
    [[GameScene sceneInstance] addChild:bg];
    
    self.chain1 = [[NSMutableArray alloc] init];
    self.chain2 = [[NSMutableArray alloc] init];
    self.plaque.anchorPoint = CGPointMake(self.plaque.position.x, self.plaque.position.y + self.plaque.size.height*0.1);
    [self createChain:bg isLeft:YES];
    [self createChain:bg isLeft:NO];
    
    bg.position = CGPointMake(bg.position.x, bg.position.y + 50);
    [bg runAction:[SKAction fadeAlphaTo:1.0 duration: 1.0]];

    self.plaque = bg;
    [self updatePlaqueContents]; // update texts
    
    // black overlay
    self.inAppOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake([GameScene sceneInstance].screenSize.width, [GameScene sceneInstance].screenSize.height)];
    self.inAppOverlay.name = @"overlay";
    self.inAppOverlay.position = CGPointMake([GameScene sceneInstance].screenSize.width/2, [GameScene sceneInstance].screenSize.height/2);
    self.inAppOverlay.zPosition = 7999;
    self.inAppOverlay.alpha = 0.0;
    [[GameScene sceneInstance] addChild:self.inAppOverlay];

    
    [self.inAppOverlay runAction:[SKAction fadeAlphaTo:0.8 duration: 2.0]];
    
    SKSpriteNode* inAppButton = [self createButton:[GameScene sceneInstance].screenSize.height/8 withY:-45*scale target:bg label:NSLocalizedString(@"OK", "Accept the dialog") color:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4] fontSize:-1];
    inAppButton.name = @"inAppButton";
    [GameScene sceneInstance].inAppPurchaseButton = inAppButton;

    SKSpriteNode* backButton = [self createButton:-[GameScene sceneInstance].screenSize.height/8 withY:-45*scale target:bg label:NSLocalizedString(@"Back", "Go back to previous screen") color:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4] fontSize:-1];
    backButton.name = @"inAppBackButton";
    [GameScene sceneInstance].inAppPurchaseBackButton = backButton;

    SKSpriteNode* restoreButton = [self createSmallerButton:0 withY:-100*scale target:bg label:NSLocalizedString(@"Restore purchases", "Restore purchases") color:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4] fontSize:18];
    restoreButton.name = @"restorePurchaseButton";
    [GameScene sceneInstance].restorePurchaseButton = restoreButton;
    
    self.lastPlaqueVelocity = self.plaque.physicsBody.velocity;
    self.chainTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                       target:[GameScene menuLogicInstance]
                                                     selector:@selector(checkIfChainMakesSound:)
                                                     userInfo:nil
                                                      repeats:NO];
}

-(void)exitInAppPurchaseMenu
{
    if ([GameScene gameLogicInstance].inAppPurchaseMenuVisible == NO) {
        return;
    };
    [GameScene gameLogicInstance].inAppPurchaseMenuVisible = NO;
    
    [[GameScene sceneInstance].view removeGestureRecognizer:self.panGesture];
    self.panGesture = nil;
    
    SKAction *block = [SKAction runBlock:^{
        for (int i=0; i<self.chain1.count; i++) {
            SKSpriteNode* node = [self.chain1 objectAtIndex:i];
            [node removeFromParent];
        }
        [self.chain1 removeAllObjects];
        for (int i=0; i<self.chain2.count; i++) {
            SKSpriteNode* node = [self.chain2 objectAtIndex:i];
            [node removeFromParent];
            node = nil;
        }
        [self.chain2 removeAllObjects];
        [self.plaque removeFromParent];
        [self.inAppOverlay removeFromParent];
        self.plaque = nil;
        self.inAppOverlay = nil;
        
        [GameScene sceneInstance].physicsWorld.speed = GAME_SPEED;
    }];

    [self.leftAnchor removeFromParent];
    [self.rightAnchor removeFromParent];
    
    SKAction* w = [SKAction waitForDuration:2.0];
    [[GameScene sceneInstance] runAction: [SKAction sequence:@[w,block]]];
    
    [self.inAppOverlay runAction:[SKAction fadeAlphaTo:0.0 duration: 2.0]];
}

-(void)exitSelectLevelMenu
{
    if ([GameScene gameLogicInstance].selectLevelMenuVisible == NO) {
        return;
    }
    
    if ([GameScene gameLogicInstance].currentLevel >= IN_APP_PURCHASE_REQUIRED_FOR_LEVEL && [[InAppPurchase instance] isAppPurchased] == NO)
    {
        if ([GameScene menuLogicInstance].plaque == nil) { // let's not show inappmenu if old plaque is still around
            [[GameScene soundManagerInstance] playSound:@"click.mp3"];
            [self showInAppPurchaseMenu];
        }
        return;
    }
    [[GameScene soundManagerInstance] playSound:@"click.mp3"];
    
    [GameScene gameLogicInstance].selectLevelMenuVisible = NO;
    [GameScene gameLogicInstance].mainMenuVisible = YES;
    
    SKAction* fade = [SKAction fadeAlphaTo:0.0 duration: 0.5];
    [[GameScene sceneInstance].selectLevelBackground runAction:fade];

    [[GameScene soundManagerInstance] clearPlaylist:2];
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[GameScene soundManagerInstance]
                                   selector:@selector(fadeIn:)
                                   userInfo:nil
                                    repeats:NO];
    [self reIgniteFlames];
}

-(void)checkIfChainMakesSound:(NSTimer*)timer
{
    if (self.plaque == nil) {
        return;
    }

    SKSpriteNode* prev = nil;
    for (int i=0; i<self.chain1.count; i++)
    {
        SKSpriteNode* link = [self.chain1 objectAtIndex:i];
        if (prev != nil) {
//            NSLog(@"%d: %f %f", i, link.position.x - prev.position.x, link.position.y - prev.position.y);
            
//            CGVector posDiff = CGVectorMake(link.position.x - prev.position.x, link.position.y - prev.position.y);
            float vx = link.position.x - prev.position.x;
            float vy = link.position.y - prev.position.y;
            float velo = sqrtf(vx*vx + vy*vy);
           // NSLog(@"%d: velo %f", i, velo);
            if (velo > 11.0) {
                if ([link.name isEqualToString:@"0"]) {
                    int rand = (arc4random()%3)+1;
                    link.name = @"1";
                    [[GameScene soundManagerInstance] playSound:[NSString stringWithFormat:@"chain-link%d.mp3", rand]];
                }
            } else if (velo < 10.0) {
                link.name = @"0";
            }
        }
        
        prev = link;
    }
    
//    NSLog(@"%f", self.lastPlaqueVelocity.dy);
    if (self.lastPlaqueVelocity.dy < -25.0 && self.plaque.physicsBody.velocity.dy > 0) {
        [[GameScene soundManagerInstance] playSound:@"chain-dropping.mp3"];
    }
    
    self.lastPlaqueVelocity = self.plaque.physicsBody.velocity;
    self.chainTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                       target:[GameScene menuLogicInstance]
                                                     selector:@selector(checkIfChainMakesSound:)
                                                     userInfo:nil
                                                      repeats:NO];
}

// for showing bonus messages
-(void)showInfoText:(CGPoint)pos text:(NSString*)text
{
    SKLabelNode* n = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    n.text = text;
    n.color = [UIColor yellowColor];
    n.fontSize = 20;
    n.zPosition = 1000;
    n.position = pos;
    n.scale = 1.0;
    n.alpha = 1.0;
    [[GameScene sceneInstance].scene addChild:n];
    
    float x = 0;
    if (n.position.x < 150) {
        x = 150 - n.position.x;
    }
    if (n.position.x > [GameScene sceneInstance].scene.size.width -150) {
        x = [GameScene sceneInstance].scene.size.width -150 -n.position.x;
    }
    float y = 40;
    if (n.position.y > [GameScene sceneInstance].scene.size.height - 60) {
        y = -40;
    }
    
    SKAction* move = [SKAction moveByX: x y: y duration:1.5];
    SKAction* scale = [SKAction scaleTo:2.0 duration:1.5];
    
    SKAction* w = [SKAction waitForDuration:1.5];
    SKAction* fade = [SKAction fadeAlphaTo: 0.0 duration: 0.5];
    SKAction* remove = [SKAction runBlock:^{
        [self removeFromParent];
    }];
    SKAction* seq = [SKAction sequence:@[w,fade,remove]];
    
    SKAction* group = [SKAction group:@[move,scale,seq]];
    [n runAction:group];
}

// for showing the score
-(void)showPointsInfoText:(CGPoint)pos text:(NSString*)text
{
    SKLabelNode* n = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    n.text = text;
    n.color = [UIColor whiteColor];
    n.fontSize = 12;
    n.zPosition = 1000;
    n.position = pos;
    n.scale = 1.0;
    n.alpha = 1.0;
    [[GameScene sceneInstance].scene addChild:n];
    
    SKAction* move = [SKAction moveByX:0 y:15 duration:1.0];

    SKAction* w = [SKAction waitForDuration:1.0];
    SKAction* fade = [SKAction fadeAlphaTo: 0.0 duration: 0.5];
    SKAction* remove = [SKAction runBlock:^{
        [self removeFromParent];
    }];
    SKAction* seq = [SKAction sequence:@[w,fade,remove]];
    
    SKAction* group = [SKAction group:@[move,seq]];
    [n runAction:group];
}

-(void)showError:(NSString*)error
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Error", "Error dialog title.")
                                          message:error
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"Accept the dialog")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    [alertController addAction:okAction];
    [[GameScene sceneInstance].view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
@end
