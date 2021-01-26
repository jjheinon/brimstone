//
//  Highscores.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Highscores_h
#define Brimstone_Highscores_h

#import <GameKit/GameKit.h>

@interface Highscores: NSObject
<GKGameCenterControllerDelegate>

-(void)retrieveTopTenScores;
-(void)reportScore:(int64_t)score levelScore:(int64_t)levelScore forLevel:(int)level reportLevelScoreOnly:(Boolean)reportLevelScoreOnly;
-(void)authenticateLocalUser;
-(void)retrieveLevelHighScoreForPlayer:(int)level;

-(void)testForGameCenterDismissal;
-(void)presentGameCenterController:(UIViewController*)viewController;


-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController;

@property UIViewController* presentGameCenterController;

@property NSArray* leaderboardSets;
@property NSArray* leaderboards;

@property Boolean gameCenterIsDisabled;

@end

#endif
