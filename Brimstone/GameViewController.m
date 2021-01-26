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


-(void)createAdBannerView
{
    int h = 50;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        h = 66;
    }
    if ([GameScene sceneInstance].bannerView == nil) {
        ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, h)];
        [GameScene sceneInstance].bannerView = adView;
    }
    [self.view addSubview:[GameScene sceneInstance].bannerView];
    [GameScene sceneInstance].bannerView.delegate = self;
    [GameScene sceneInstance].bannerView.hidden = YES;
    self.bannerIsVisible = NO;
}

-(void)removeAdBannerView
{
    [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
    [UIView setAnimationDuration:1.0];
    [GameScene sceneInstance].bannerView.alpha = 0.0;
    [UIView commitAnimations];

    SKAction *wait1 = [SKAction waitForDuration:1.0];
    SKAction* remove = [SKAction runBlock:^{
        [[GameScene sceneInstance].bannerView removeFromSuperview];
        [GameScene sceneInstance].bannerView.hidden = YES;
        self.bannerIsVisible = NO;
    }];
    [[GameScene sceneInstance] runAction:[SKAction sequence:@[wait1, remove]]];
}


-(void)bannerViewWillLoadAd:(ADBannerView *)banner NS_AVAILABLE_IOS(5_0)
{
    NSLog(@"Loading ad..");
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if ([GameScene sceneInstance].bannerView != nil && [GameScene sceneInstance].bannerView.hidden == YES)
    {
        if ([GameScene sceneInstance].bannerView.superview == nil)
        {
            [self.view addSubview:[GameScene sceneInstance].bannerView];
        }
        
        banner.alpha = 0.0;
        banner.hidden = NO;
        self.bannerIsVisible = YES;

        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        [UIView setAnimationDuration:1.0];
        banner.alpha = 1.0;
        [UIView commitAnimations];
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if ([GameScene sceneInstance].bannerView != nil) {
        [GameScene sceneInstance].bannerView.hidden = YES;
        self.bannerIsVisible = NO;
    }
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [[GameScene gameLogicInstance] pauseGame];
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[GameScene gameLogicInstance] resumeGame];
}



@end
