//
//  GameLogic.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "GameScene.h"
#import "GameLogic.h"
#import "MenuLogic.h"
#import "SoundManager.h"
#import "Ball.h"
#import "Bat.h"
#import "Highscores.h"
#import "BonusFeatures.h"

@implementation GameLogic


-(void)onLevelPrepareStart:(NSTimer *)timer {
    
    // init stats
    self.levelComplete = NO;
//    [GameScene gameLogicInstance].mainMenuVisible = NO;
   // [[GameScene menuLogicInstance] showLevelIntroText];
    
    if ([GameScene menuLogicInstance].shaderContainer != nil) {
        [GameScene menuLogicInstance].shaderContainer.shader = nil;
        [[GameScene menuLogicInstance].shaderContainer removeFromParent];
        [GameScene menuLogicInstance].shaderContainer = nil;
    }
    if ([GameScene menuLogicInstance].levelIntroText != nil) {
        [[GameScene menuLogicInstance].levelIntroText removeFromParent];
        [GameScene menuLogicInstance].levelIntroText = nil;
    }
    if ([GameScene menuLogicInstance].levelIntroDesc != nil) {
        [[GameScene menuLogicInstance].levelIntroDesc removeFromParent];
        [GameScene menuLogicInstance].levelIntroDesc = nil;
    }
    
    self.theScreenshotImage = nil;
    self.levelStarted = NO;
    
    [[GameScene gameLogicInstance] resumeGame];

  //  [GameScene sceneInstance].scene.alpha = 1.0; // reset alpha back to normal setting

    [GameScene sceneInstance].firePixelColumns = [[NSMutableArray alloc] init]; // clear array
    
    for (int i=0; i<6; i++) { // TODO: fix the forever looping sounds for AVQueuePlayer and remove this
        [[GameScene soundManagerInstance] addToPlaylist:@"fire-wood-crackle" ofType:@"mp3" playerNum:BACKGROUND_MUSIC];
    }

    [[GameScene menuLogicInstance].levelIntroText removeFromParent];
    [[GameScene menuLogicInstance].levelIntroDesc removeFromParent];


    SKLabelNode* n = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    n.text = @"Get Ready!";
    n.color = [UIColor whiteColor];
    n.fontSize = 20;
    n.zPosition = 1000;
    n.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame)-20);
    n.scale = 1.0;
    n.alpha = 0.0;
    [[GameScene sceneInstance].scene addChild:n];
    
    SKAction *fadeAction = [SKAction fadeAlphaTo:1.0 duration: 0.5];
    SKAction *wait1 = [SKAction waitForDuration:1.0];
    SKAction *fadeAction2 = [SKAction fadeAlphaTo:0.0 duration: 0.5];
    SKAction *sequence1 = [SKAction sequence:@[fadeAction, wait1, fadeAction2]];
    [n runAction:sequence1];
    
    
#ifndef LIGHTS_DISABLED
    for (int i=0; i<[GameScene sceneInstance].ballFireEmitter.count; i++) {
        SKEmitterNode* fire = [[GameScene sceneInstance].ballFireEmitter objectAtIndex:i];
        SKLightNode* light = (SKLightNode*)[fire childNodeWithName:@"light"];
        light.falloff = 4.0;
        light.ambientColor = [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:0.0];
        light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.8];
        light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.35];
    }
#endif

    [[GameScene soundManagerInstance] playSound:@"sizzle.mp3"];
    
#ifndef DISABLE_SPARKLING
    for (int i=0; i<[GameScene sceneInstance].ball.count; i++) {
        SKSpriteNode* ball = [[GameScene sceneInstance].ball objectAtIndex:i];
        
        SKEmitterNode* spark = [[GameScene factoryInstance] createSpark:ball.position.x withY:ball.position.y color:nil];
        spark.particleBirthRate = 50;
        spark.numParticlesToEmit = (int)50*3.5; // 3.5s long sample
        spark.hidden = NO;
        [[GameScene sceneInstance] addChild:spark];
    }

//    SKAction *snd = [SKAction playSoundFileNamed:@"sizzle.mp3" waitForCompletion:NO];
/*    SKAction *snd = [SKAction runBlock:^{
        [[GameScene soundManagerInstance] playSound:@"sizzle.mp3"];
    }];*/
    SKAction *wait = [SKAction waitForDuration:3.5];
//    [[GameScene sceneInstance].scene runAction:snd];

//    SKAction *group = [SKAction group:@[snd, wait]];
    [[GameScene sceneInstance].scene runAction:wait completion:^{
#ifndef LIGHTS_DISABLED
    for (int i=0; i<[GameScene sceneInstance].ballFireEmitter.count; i++) {
        SKEmitterNode* fire = [[GameScene sceneInstance].ballFireEmitter objectAtIndex:i];
        
        SKLightNode* light = (SKLightNode*)[fire childNodeWithName:@"light"];
        light.ambientColor = [[UIColor alloc] initWithRed:0.2 green:0.2 blue:0.2 alpha:0.03];
        light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.01];
    }
#endif
    } ];

    SKAction *wait3 = [SKAction waitForDuration:5.0];
    SKAction *runLevelStart = [SKAction runBlock:^{
        [self onLevelStart:nil];
    }];
    [[GameScene sceneInstance].scene runAction:[SKAction sequence:@[wait3,runLevelStart]]];
/*    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(onLevelStart:)
                                   userInfo:nil
                                    repeats:NO];*/
#else
    SKAction *wait3 = [SKAction waitForDuration:1.0];
    SKAction *runLevelStart = [SKAction runBlock:^{
        [self onLevelStart:nil];
    }];
    [[GameScene sceneInstance].scene runAction:[SKAction sequence:@[wait3,runLevelStart]]];
    
/*    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(onLevelStart:)
                                   userInfo:nil
                                    repeats:NO];
  */
#endif

    //DEBUG
  /*  NSLog(@"Finishing game in 10s");
    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:self
                                   selector:@selector(onLevelCompleted:)
                                   userInfo:nil
                                    repeats:NO];
*/
}

-(void)onLevelStart:(NSTimer *)timer {
    
    if (self.levelComplete == YES || self.gameIsOver == YES) {
        return;
    }
    [GameScene sceneInstance].view.alpha = 1.0;
    [[GameScene menuLogicInstance].bonusFeatures reCreate];
    
    for (int i=0; i<[GameScene sceneInstance].ball.count; i++) {
        SKSpriteNode* ball = [[GameScene sceneInstance].ball objectAtIndex:i];
        // if we died, move the ball to safe area so we won't die immediately after continuing the game
        if (ball.position.y < -BOTTOM_PIT_DEPTH+BALL_REBIRTH_SAFE_DISTANCE) {
            ball.position = CGPointMake(ball.position.x + i*20, -BOTTOM_PIT_DEPTH+BALL_REBIRTH_SAFE_DISTANCE+i*20);
        }
    }
    // change status
    self.playerDied = NO;
    self.levelScore = 0;

    // fade alpha back to normal
    SKAction *fadeAction = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    [[GameScene sceneInstance] runAction:fadeAction];

    for (int i=0; i<6; i++) { // TODO: fix the forever looping sounds for AVQueuePlayer and remove this
        [[GameScene soundManagerInstance] addToPlaylist:@"fire-wood-crackle" ofType:@"mp3" playerNum:BACKGROUND_MUSIC];
    }
    
    // enable physics on ball:
    
    [[GameScene soundManagerInstance] playSound:@"fireball_launch.mp3"];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(onLevelStarted:)
                                   userInfo:nil
                                    repeats:NO];
    
    for (int i=0; i<[GameScene sceneInstance].ball.count; i++) {
        Ball* ball = [[GameScene sceneInstance].ball objectAtIndex:i];
        
#ifndef DISABLE_BALL_MOVEMENTS
        [ball enableMovements];
        
        self.gameRunning = YES;
        
        float multiplier = 1.0;
        if (self.lives < MAX_LIVES && ball.position.y < 0) {
            multiplier = 1.6; // faster launch if ball outside of screen or it won't get high enough
        }
        [ball.physicsBody applyImpulse:CGVectorMake(((arc4random()%2)-0.5f)*(20.0f+(arc4random()%HORIZ_LAUNCH_VELOCITY)), VERTICAL_LAUNCH_VELOCITY*multiplier)];
#endif
        [ball ignite];
    }
}

-(void)onLevelStarted:(NSTimer *)timer {
    self.levelStarted = YES;
    
//    [[GameScene soundManagerInstance] setVolume:0.1 playerNum:BACKGROUND_MUSIC]; // zero volume
    [[GameScene soundManagerInstance] play:NO playerNum:BACKGROUND_MUSIC]; // fire burning
    [[GameScene gameLogicInstance] checkBurningObjectsCount]; // update volume for burning sound
    [self updateStatusBar];

    SKAction* w = [SKAction waitForDuration:10.0];
    SKAction* takeScreenshot = [SKAction runBlock:^{
        
        if (self.gameIsOver == YES) {
            return;
        }
        if (self.gameRunning == NO) {
            return;
        }
        if (self.playerDied == YES) {
            return;
        }
        if (self.levelComplete == YES) {
            return;
        }

        UIGraphicsBeginImageContextWithOptions([GameScene sceneInstance].view.bounds.size, [GameScene sceneInstance].view.opaque, [UIScreen mainScreen].scale);
        [[GameScene sceneInstance].view drawViewHierarchyInRect:[GameScene sceneInstance].view.bounds afterScreenUpdates:YES];
//        [[GameScene sceneInstance].view.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.theScreenshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }];
    [[GameScene sceneInstance] runAction:[SKAction sequence:@[ w, takeScreenshot ]]];
    
    self.statusBarTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateStatusBarReally:)
                                   userInfo:nil
                                    repeats:YES];
    
}

-(void)updateStatusBar {
    self.statusBarDirty = YES;
}

-(void)updateStatusBarReally:(NSTimer*)timer {
    if (self.statusBarDirty == NO || self.gameIsOver == YES) {
        return;
    }

    if (self.statusBarLives == nil || self.statusBarLives.parent == nil) {
        self.statusBarLives = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        self.statusBarLives.fontColor = [UIColor orangeColor];
        self.statusBarLives.fontSize = 20;
        self.statusBarLives.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.statusBarLives.zPosition = 1000;
        self.statusBarLives.position = CGPointMake(10, [GameScene sceneInstance].scene.frame.size.height-20);
        self.statusBarLives.scale = 1.0;
        self.statusBarLives.alpha = 0.0;
        [[GameScene sceneInstance].scene addChild:self.statusBarLives];

        self.statusBarLevel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        self.statusBarLevel.fontColor = [UIColor orangeColor];
        self.statusBarLevel.fontSize = 20;
        self.statusBarLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.statusBarLevel.zPosition = 1000;
        self.statusBarLevel.position = CGPointMake([GameScene sceneInstance].scene.frame.size.width-100, [GameScene sceneInstance].scene.frame.size.height-20);
        self.statusBarLevel.scale = 1.0;
        self.statusBarLevel.alpha = 0.0;
        [[GameScene sceneInstance].scene addChild:self.statusBarLevel];

        self.statusBarScore = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        self.statusBarScore.fontColor = [UIColor orangeColor];
        self.statusBarScore.fontSize = 20;
        self.statusBarScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        self.statusBarScore.zPosition = 1000;
        self.statusBarScore.position = CGPointMake([GameScene sceneInstance].scene.frame.size.width/2-65, [GameScene sceneInstance].scene.frame.size.height-20);
        self.statusBarScore.scale = 1.0;
        self.statusBarScore.alpha = 0.0;
        [[GameScene sceneInstance].scene addChild:self.statusBarScore];
        
        SKAction *fadeInAction = [SKAction fadeAlphaTo:1.0 duration: 1.0];
        [self.statusBarLives runAction:fadeInAction];
        [self.statusBarLevel runAction:fadeInAction];
        [self.statusBarScore runAction:fadeInAction];
    }
    self.statusBarLives.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"Lives:", "Status bar title, number of lives left"), self.lives];
    self.statusBarLevel.text = [NSString stringWithFormat:@"%@ %2d", NSLocalizedString(@"Level:", "The current game level"), self.currentLevel];
    self.statusBarScore.text = [NSString stringWithFormat:@"%@ %05d", NSLocalizedString(@"Score:", "Status bar title, the current points of the player"), self.score];
    
    self.statusBarDirty = NO;
}

-(void)saveScreenshot // save captured level screenshot (to be used in select level menu)
{
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString* fname = [NSString stringWithFormat:@"level_%02d.jpg", self.currentLevel];
    NSString *screenshotPath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:fname]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:screenshotPath]) {
        //   NSLog(@"File was found, didn't take a screenshot");
        //    return;
    }
    if (self.theScreenshotImage != nil) {
        UIImage* scaledImage = [UIImage imageWithCGImage:[self.theScreenshotImage CGImage]
                                                   scale:(self.theScreenshotImage.scale * 0.5)
                                             orientation:(self.theScreenshotImage.imageOrientation)];
        NSData* theImageData = UIImageJPEGRepresentation(scaledImage, 0.8);
        [theImageData writeToFile:screenshotPath atomically:YES];
        
        self.theScreenshotImage = nil;
        scaledImage = nil;
    }
    
}

-(void)onLevelCompleted:(NSTimer *)timer {
    if (self.gameIsOver == YES && self.levelComplete == NO) {
        return;
    }
    self.levelComplete = YES;

    [GameScene gameLogicInstance].levelsCompleted += 1;
    [GameScene gameLogicInstance].score += POINTS_FOR_LEVEL_COMPLETE * [GameScene gameLogicInstance].levelsCompleted;
    [GameScene gameLogicInstance].levelScore += POINTS_FOR_LEVEL_COMPLETE * [GameScene gameLogicInstance].levelsCompleted;
    [self updateStatusBar];
    [self updateStatusBarReally:nil];
    
    [[GameScene menuLogicInstance].bonusFeatures hideBonusFeatures];

    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    label.text = NSLocalizedString(@"Light for Victory!", "Level completed. Player succeeds in lighting up the light sources and the darkness is banished.");
    label.fontColor = [UIColor whiteColor];
    label.fontSize = 48;
    label.zPosition = 1000;
    label.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame));
    label.scale = 0.5;
    [[GameScene sceneInstance] addChild:label];
    
    SKAction *fadeAction = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    SKAction *scaleAction = [SKAction scaleTo:1.0 duration: 5.0];
    
    SKAction *group = [SKAction group:@[fadeAction, scaleAction]];
    [label runAction:group];
    
    
    [[GameScene soundManagerInstance] playSound:@"leveldone.mp3"];

    for (int i=0; i<[GameScene sceneInstance].ball.count; i++) {
        
        Ball* ball = [[GameScene sceneInstance].ball objectAtIndex:i];
        ball.physicsBody.affectedByGravity = NO;
        
        UIColor* col = nil;
        if (ball.isSuperHot == YES) {
            col = [UIColor whiteColor];
        }
        
        // show some sparks when ball vanishes
        SKEmitterNode* spark = [[GameScene factoryInstance] createSpark:ball.position.x withY:ball.position.y color:col];
        spark.particleBirthRate = 150;
        spark.numParticlesToEmit = 75;
        spark.emissionAngle = vectorToAngle(ball.physicsBody.velocity);
        spark.emissionAngleRange = 0.5;
        //spark.particleSpeed = sqrt(ball.physicsBody.velocity.dx * ball.physicsBody.velocity.dx + ball.physicsBody.velocity.dy * ball.physicsBody.velocity.dy)/5.0;
        spark.particleLifetime = 2.0;
        spark.particleLifetimeRange = 0.5;
        [ball addChild:spark];
        
        SKAction* w = [SKAction waitForDuration:1.0];
        SKAction* remove = [SKAction runBlock:^{
            [ball removeFromParent];
        }];
        [ball.smokeEmitter removeFromParent];
        ball.physicsBody.categoryBitMask = 0; // no collisions
        ball.physicsBody.collisionBitMask = 0; // no collisions
        ball.physicsBody.contactTestBitMask = 0; // no collisions
        
        if ([GameScene sceneInstance].isLowPerfMode == NO) {
            ball.zPosition = -1;
            [ball.fireEmitter removeFromParent];
            [ball runAction:[SKAction sequence:@[w,remove]]];
        } else {
            // if in low perf mode, just move the ball to outside screen so the ball's ambient light does not vanish, as on low perf devices beacons do not light the scene -> all lights missing looks ugly as it turns off the shadows and lighting completely
            ball.physicsBody.dynamic = NO;
            ball.physicsBody.velocity = CGVectorMake(0,0);
            ball.position = CGPointMake(100, -BOTTOM_PIT_DEPTH+BALL_REBIRTH_SAFE_DISTANCE);
        }
    }
        
    [[GameScene menuLogicInstance].highscores reportScore:self.score levelScore:self.levelScore forLevel:self.currentLevel reportLevelScoreOnly:NO];

    SKAction *w2 = [SKAction waitForDuration:3.0];
    SKAction *showBonuses = [SKAction runBlock:^{
        [self pauseGame];
        [[GameScene menuLogicInstance] showBonusScreen];
        [self saveScreenshot];
    }];
    [[GameScene sceneInstance].scene runAction:[SKAction sequence:@[w2,showBonuses]]];
    
    if (self.statusBarTimer != nil) {
        [self.statusBarTimer invalidate];
        self.statusBarTimer = nil;
    }
    
    // TODO: pause the game here or something, should not register level score anymore after level has been declared completed
}

CGFloat vectorToAngle(CGVector vec) {
    return atan2f(vec.dy, vec.dx);
}

-(void)pauseGame
{
    NSLog(@"Pause game");
    [GameScene sceneInstance].physicsWorld.speed = 0.0;
    [GameScene gameLogicInstance].gameRunning = NO;
}

-(void)resumeGame
{
    if (self.gameRunning == YES) {
        return;
    }
    NSLog(@"Resume game");
    [GameScene sceneInstance].physicsWorld.speed = GAME_SPEED;
    
    if ([GameScene gameLogicInstance].lives > 0) {
        [GameScene gameLogicInstance].gameRunning = YES;
    } else {
        NSLog(@"Lives <= 0, cannot resume game");
    }
}

-(void)death {
    if (self.playerDied == YES) {
        return;
    }
    if (self.gameRunning == NO) {
        return;
    }
    if (self.gameIsOver == YES) {
        return;
    }
    self.playerDied = YES;
    self.lives = self.lives-1;
    self.levelStarted = NO;
    
    [self updateStatusBar];
    
    NSLog(@"DEATH. lives = %d", self.lives);
    
    if (self.lives <= 0) {
        [self gameOver];
    } else {
        
        [[GameScene soundManagerInstance] playSound:@"death.mp3"];

        SKSpriteNode* ball = [[GameScene sceneInstance].ball objectAtIndex:0];
        ball.position = CGPointMake([GameScene sceneInstance].sceneSize.width/2,-BOTTOM_PIT_DEPTH+BALL_REBIRTH_SAFE_DISTANCE);
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self
                                       selector:@selector(onLevelStart:)
                                       userInfo:nil
                                        repeats:NO];
    }
}


-(void)gameOver
{
    if (self.levelComplete == YES) {
        return;
    }
    [self updateStatusBar];
    [self updateStatusBarReally:nil]; // force update
    
    self.gameRunning = NO;
    self.gameIsOver = YES;
    
    GameScene* s = [GameScene sceneInstance];
    if (s.levelCompleteTimer != nil) {
        [s.levelCompleteTimer invalidate];
        s.levelCompleteTimer = nil;
    }

    [[GameScene menuLogicInstance].bonusFeatures removeBonusFeatures];
    [[GameScene menuLogicInstance].bonusFeatures hideBonusFeatures];
    
    // shut down lights
    // "Darkness prevails
    for (int i=0; i<s.beacons.count; i++) {
        GameObject* beacon = [s.beacons objectAtIndex:i];
//        SKLightNode* light = beacon.light; //(SKLightNode*)[beacon childNodeWithName:@"light"];
        
        // turn down light
        beacon.light.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.0];
    }

    SKSpriteNode* ball = [[GameScene sceneInstance].ball objectAtIndex:0];

    ball.physicsBody.affectedByGravity = NO;
    ball.physicsBody.dynamic = NO;
    ball.position = CGPointMake([GameScene sceneInstance].sceneSize.width/2, -BOTTOM_PIT_DEPTH+BALL_REBIRTH_SAFE_DISTANCE);
    
    /*   SKLightNode* ballLight = (SKLightNode*)([self.ballFireEmitter childNodeWithName:@"light"]);
     ballLight.falloff = 5;
     ballLight.lightColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.1];
     */
    self.label = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    self.label.fontColor = [UIColor redColor];
    self.label.text = NSLocalizedString(@"Darkness prevails", "Game ends and the player fails to light up the light sources, so the darkness still reigns supreme.");
    self.label.fontSize = 40;
    self.label.zPosition = 1000;
    self.label.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame));
    self.label.scale = 0.5;
    [s addChild:self.label];
    
    SKAction *scaleAction = [SKAction scaleTo:1.0 duration: 5.0];
    [self.label runAction:scaleAction];
    
    [[GameScene soundManagerInstance] clearPlaylist:BEACON_POWER_UP]; // stop possible beacon sound
    
    [[GameScene soundManagerInstance] playSound:@"gameover.mp3"];
    
    self.label2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    self.label2.text = NSLocalizedString(@"Game Over", "The game ends.");
    self.label2.color = [UIColor whiteColor];
    self.label2.fontSize = 22;
    self.label2.zPosition = 1000;
    self.label2.position = CGPointMake(CGRectGetMidX([GameScene sceneInstance].frame), CGRectGetMidY([GameScene sceneInstance].frame)-50);
    self.label2.scale = 0.7;
    self.label2.alpha = 0.0;
    [[GameScene sceneInstance] addChild:self.label2];
    
    SKAction *w1 = [SKAction waitForDuration:4.0];
    SKAction *fadeAction = [SKAction fadeAlphaTo:1.0 duration: 1.0];
    SKAction *scaleAction2 = [SKAction scaleTo:1.0 duration: 3.0];
    SKAction *group1 = [SKAction group:@[fadeAction, scaleAction2]];
    [self.label2 runAction:[SKAction sequence:@[w1,group1]]];
    
    [[GameScene menuLogicInstance].highscores reportScore:self.score levelScore:self.levelScore forLevel:self.currentLevel reportLevelScoreOnly:NO];
    
    SKAction *w = [SKAction waitForDuration:5.0];
    SKAction *showBonuses = [SKAction runBlock:^{
        [self pauseGame];
        [[GameScene menuLogicInstance] showBonusScreen];
    }];
    [s.scene runAction:[SKAction sequence:@[w,showBonuses]]];
    
    if (self.statusBarTimer != nil) {
        [self.statusBarTimer invalidate];
        self.statusBarTimer = nil;
    }
    [self saveScreenshot];
}

-(void)nextLevel
{
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[GameScene soundManagerInstance]
                                   selector:@selector(fadeOut:)
                                   userInfo:nil
                                    repeats:NO];
    
    [[GameScene menuLogicInstance].gameViewController removeAdBannerView];
    
    SKAction *w = [SKAction waitForDuration:1.0];
    SKAction *run1 = [SKAction runBlock:^{
        [[GameScene soundManagerInstance] stopAll];
    }];
    [[GameScene sceneInstance] runAction:[SKAction sequence:@[w,run1]]];

    GameScene *s = [GameScene sceneInstance];
    if (s.levelCompleteTimer != nil) { // cancel beacon timers to prevent levelcomplete when 
        [s.levelCompleteTimer invalidate];
        s.levelCompleteTimer = nil;
    }
    
    // level completed, start next level
    SKAction *fadeAction = [SKAction fadeAlphaTo:0.0 duration: 1.0];
    
    SKAction *run = [SKAction runBlock:^{
        [[GameScene sceneInstance] initLevel:[GameScene gameLogicInstance].currentLevel+1];

        [[GameScene gameLogicInstance] pauseGame];
        [[GameScene menuLogicInstance] showLevelIntroText];
        [[GameScene sceneInstance] showAllSprites];
        
        NSLog(@"Starting next level %d", self.currentLevel);
        [NSTimer scheduledTimerWithTimeInterval:DELAY_BETWEEN_LEVELS
                                         target:[GameScene gameLogicInstance]
                                       selector:@selector(onLevelPrepareStart:)
                                       userInfo:nil
                                        repeats:NO];
    }];
    SKAction *sequence = [SKAction sequence:@[fadeAction, run]];
    [[GameScene sceneInstance] runAction:sequence];
}

-(void)retryLevel
{
    if (self.lives > 0) {
        return;
    }
    if (self.label != nil) {
        [self.label removeFromParent];
    }
    if (self.label2 != nil) {
        [self.label2 removeFromParent];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:[GameScene soundManagerInstance]
                                   selector:@selector(fadeOut:)
                                   userInfo:nil
                                    repeats:NO];


    SKAction *w = [SKAction waitForDuration:1.0];
    SKAction *run1 = [SKAction runBlock:^{
        [[GameScene soundManagerInstance] stopAll];
    }];
    [[GameScene sceneInstance] runAction:[SKAction sequence:@[w,run1]]];
    
    // restore lives and reset score, retry current level
    NSLog(@"Retrying level %d", self.currentLevel);
    self.gameIsOver = NO;
    self.lives = MAX_LIVES;
    self.score = 0;
    self.levelScore = 0;
    self.levelsCompleted = 0;
    [GameScene sceneInstance].beaconCount = 0;
    
    self.gameRunning = YES;
    for (int i=0; i<[GameScene sceneInstance].ball.count; i++) {
        SKSpriteNode* ball = [[GameScene sceneInstance].ball objectAtIndex:i];
        ball.physicsBody.velocity = CGVectorMake(0,0);
    }

    // retry level, first fade out to black
    SKAction *fadeAction = [SKAction fadeAlphaTo:0.0 duration: 0.5];
    
    SKAction *run = [SKAction runBlock:^{
        [[GameScene sceneInstance] initLevel:self.currentLevel];
        [[GameScene sceneInstance] showAllSprites];

        NSLog(@"Retrying level %d", self.currentLevel);
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(onLevelStart:)
                                       userInfo:nil
                                        repeats:NO];
    }];
    SKAction *sequence = [SKAction sequence:@[fadeAction, run]];
    [[GameScene sceneInstance] runAction:sequence];
    
    [[GameScene soundManagerInstance] clearPlaylist:BEACON_POWER_UP];
    
    [[GameScene menuLogicInstance].gameViewController removeAdBannerView];

    [self resumeGame];

}

// call each burning object and trigger fire to grow / advance
-(void)onFireGrows:(NSTimer *)timer {
    @synchronized(self) {
        if ([GameScene sceneInstance].burningObjects.count == 0) {
            return;
        }
        self.updateIndex = self.updateIndex + 1;
        if (self.updateIndex >= [GameScene sceneInstance].burningObjects.count) {
            self.updateIndex = 0;
        }
        //    for (int i=0; i<[GameScene sceneInstance].burningObjects.count; i++) {
        // update only one item per round, to prevent framerate drops
        [[[GameScene sceneInstance].burningObjects objectAtIndex:self.updateIndex] onBurn];
    }
    //    }
  /*  [GameScene sceneInstance].burnTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                                           target:self
                                                                         selector:@selector(onFireGrows:)
                                                                         userInfo:nil
                                                                          repeats:NO];
    */
}

-(void)checkBurningObjectsCount
{
    long burningBallCount = [GameScene sceneInstance].ballFireEmitter.count;
    long batFireCount = ((Bat*)([GameScene sceneInstance].batSprite)).batFires.count;
    
    float vol = ([GameScene sceneInstance].burningObjects.count+ burningBallCount + batFireCount) / 20.0;
    if (vol < 0.2) {
        vol = 0.2;
    }
    if (vol >= 1.0) {
        vol = 1.0;
    }
    [[GameScene soundManagerInstance] setVolume:vol playerNum:BACKGROUND_MUSIC];
}

-(void)addScore:(int)score pos:(CGPoint)position {
    if (self.gameIsOver == YES || self.mainMenuVisible == YES) {
        return; // no points after gameover
    }
    
    [GameScene gameLogicInstance].score += score;
    [GameScene gameLogicInstance].levelScore += score;
    [[GameScene menuLogicInstance] showPointsInfoText:position text:[NSString stringWithFormat:@"%d", score]];
}


@end
