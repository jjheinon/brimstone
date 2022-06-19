//
//  GameViewController.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import "GameViewController.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "MenuLogic.h"

@implementation GameViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView* skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;

    // Create and configure the scene.
    SKScene *scene = [GameScene unarchiveFromFile:@"MainScene"];
    scene.size = [[GameScene sceneInstance] screenSize];
    //scene.scaleMode = SKSceneScaleModeAspectFill;
//    scene.scaleMode = SKSceneScaleModeResizeFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [GameScene menuLogicInstance].gameViewController = self;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
