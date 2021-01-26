//
//  Highscores.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Highscores.h"
#import "GameScene.h"
#import "MenuLogic.h"

@implementation Highscores

-(void)retrieveTopTenScores
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.identifier = @"brimstone_highscores_id";
        leaderboardRequest.range = NSMakeRange(1,100);
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil)
            {
                // Handle the error.
            }
            if (scores != nil)
            {
                [GameScene menuLogicInstance].highscoreData = [[NSMutableArray alloc] init];
                // Process the score information.
                for (int i=0; i<scores.count; i++) {
                    GKScore* score = (GKScore*)[scores objectAtIndex:i];
                    if (score.rank == i+1) {
                        [[GameScene menuLogicInstance].highscoreData addObject:score.copy];
                    }
                    if ([score.player.playerID isEqual:((GKPlayer*)[GKLocalPlayer localPlayer]).playerID]) {
                        [GameScene menuLogicInstance].playerHighscoreRanking = (int)score.rank;
/*                        if (i >=10) {
                            return; // we already have top 10 items, skip the rest
                        }*/
                    }
                }
            }
        }];
    }
}

-(void)loadLeaderboardSets
{
    [GKLeaderboardSet loadLeaderboardSetsWithCompletionHandler:^(NSArray *leaderboardSets, NSError *error) {
        self.leaderboardSets = leaderboardSets;
        
        [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
            self.leaderboards = leaderboards;
        }];
    }];
}

-(void)retrieveLevelHighScoreForPlayer:(int)level
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.identifier = [NSString stringWithFormat:@"brimstone_highscores_level_%d",level];
        leaderboardRequest.range = NSMakeRange(1,100); // fetch top 100
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil)
            {
                // Handle the error.
            }
            if (scores != nil)
            {
                if ([GameScene menuLogicInstance].levelHighScores == nil) {
                    [GameScene menuLogicInstance].levelHighScores = [[NSMutableDictionary alloc] init];
                }
                [GameScene menuLogicInstance].levelHighScores[[NSString stringWithFormat:@"%d", level]] = scores.copy;
                [[GameScene menuLogicInstance] updateScores]; // update scores UI in case the level selector is visible but scores not loaded yet
            }
        }];
    }
}


-(void)reportScore:(int64_t)score levelScore:(int64_t)levelScore forLevel:(int)level reportLevelScoreOnly:(Boolean)reportLevelScoreOnly
{
 /*   if (reportLevelScoreOnly == YES) {
        GKScore *levelScoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: [NSString stringWithFormat:@"brimstone_highscores_level_%d", level]];
        levelScoreReporter.value = levelScore;
        levelScoreReporter.context = 0;

        NSArray *scores = @[levelScoreReporter];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
             // retry
        }];
        return;
    }*/
    
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: @"brimstone_highscores_id"];
    scoreReporter.value = score;
    scoreReporter.context = 0;

    GKScore *levelScoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: [NSString stringWithFormat:@"brimstone_highscores_level_%d", level]];
    levelScoreReporter.value = levelScore;
    levelScoreReporter.context = 0;
//    scoreReporter.shouldSetDefaultLeaderboard = YES;
    
    NSArray *scores = @[scoreReporter, levelScoreReporter];
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {

        if (error) {
            NSLog(@"Game Center Error: %@", [error localizedDescription]);
        }
        // retry in 5 seconds
        SKAction *w = [SKAction waitForDuration:5.0];
        SKAction *retry = [SKAction runBlock:^{
            [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            }];
        }];
        [[GameScene sceneInstance] runAction:[SKAction sequence:@[w,retry]]];
    }];
}

- (void)authenticateLocalUser
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    __weak __typeof__(self) weakSelf = self;
    if (!localPlayer.authenticateHandler) {
        [localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError* error) {
            if (error) {
                NSLog(@"Game Center Error: %@", [error localizedDescription]);
            }

            if (viewcontroller) {
                [weakSelf presentGameCenterController:viewcontroller];
            }
            else if ([[GKLocalPlayer localPlayer] isAuthenticated]) {
                // Enable GameKit features
                NSLog(@"Player already authenticated");
                self.gameCenterIsDisabled = NO;
                [self retrieveTopTenScores];
                [self retrieveLevelHighScoreForPlayer:1];
            }
            else {
                // Disable GameKit features
                NSLog(@"Player not authenticated");
                self.gameCenterIsDisabled = YES;
            //    [[GameScene menuLogicInstance] showError:@"Game Center is disabled, high scores are not updating."];
            }
        })];
    }
    else {
        NSLog(@"Authentication Handler already set");
    }
}

- (void)testForGameCenterDismissal
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        /*if (self.presentedViewController) {
            NSLog(@"Still presenting game center login");
            [self testForGameCenterDismissal];
        }
        else {
            NSLog(@"Done presenting, clean up");
            [self gameCenterViewControllerCleanUp];
        }*/
    });
}

- (void)presentGameCenterController:(UIViewController*)viewController
{
    BOOL testForGameCenterDismissalInBackground = YES;
    if ([viewController isKindOfClass:[GKGameCenterViewController class]]) {
        [(GKGameCenterViewController*)viewController setGameCenterDelegate:self];
        testForGameCenterDismissalInBackground = NO;
    }
    
  //  UIViewController *vc = self.view.window.rootViewController;
    [[GameScene sceneInstance].view.window.rootViewController presentViewController:viewController animated:YES completion:^{
        if (testForGameCenterDismissalInBackground) {
            [self testForGameCenterDismissal];
        }
    }];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController
{
    [self gameCenterViewControllerCleanUp];
}

- (void)gameCenterViewControllerCleanUp
{
    // Do whatever needs to be done here, resume game etc
}
@end
