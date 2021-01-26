
//
//  Constants.h
//  Brimstone
//
//  Constants for game play
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_Constants_h
#define Brimstone_Constants_h

#define DISABLE_MAINSCREEN_SMOKE // smoke shader for the whole screen

#ifdef DEBUG
// debug
//#define DISABLE_SHADERS

//#define LIGHTS_DISABLED   // enables ambient lighting, removes darkness

//#define DISABLE_MAIN_MENU // skips main menu

//#define DISABLE_SPARKLING // disables ball sparkling

//#define DISABLE_INTRO_TEXT // disables level intro text

//#define DISABLE_FIREBALL // no flaming ball
//#define DISABLE_BALL_MOVEMENTS // ball won't move
//#define ENABLE_TOUCH_TO_DESTROY_OBJECTS // destroy stuff by touching (debug)

//#define DISABLE_PARTICLES

//#define ENABLE_SMOKE // smoke shader for the whole screen

#endif


// In game
#define IN_APP_PURCHASE_REQUIRED_FOR_LEVEL 6
#define MAX_LEVEL 20

#define START_LEVEL 1
#define MAX_LIVES 3  // number of lives (bats/paddles)

#define BAT_START_YPOS 80   // y coordinate of the bat
#define BALL_START_YPOS 130 // y coordinate of the ball at level start

#define BOTTOM_PIT_DEPTH 500 // depth of the bottom pit (# of points below screen)
#define BALL_REBIRTH_SAFE_DISTANCE 240 // how far away from bottom we rebirth the ball if outside zone

#define DELAY_BETWEEN_LEVELS 5.0 // seconds

#define BONUS_PROBABILITY 4 // probability 1:N


// Physics
#define GRAVITY 1.0   // world gravity multiplier
#define GAME_SPEED 0.5 // speed of the physics

#define BAT_SPEED 300 // points per second

#define VERTICAL_LAUNCH_VELOCITY 2500.0f // at level start, how fast the ball is launched (vertical speed)
#define HORIZ_LAUNCH_VELOCITY 250        // at level start, how fast the ball is launched (horiz speed)
#define BAT_BOUNCE_VELOCITY 1500.0f       // how springy the bat is
#define WALL_BOUNCE_FACTOR 40            // how springy the walls are

#define MIN_VELOCITY_TO_PLAY_SFX 50    // how fast the impact should be at least to play sound fx (to disable series of sfx when touching)


#define BAT_FIRE_REGIONS 5 // how many separate fire emitters for bat


//#define GAME_FONT @"SanFranciscoRounded-Thin"
#define GAME_FONT @"Papyrus"
// Rendering

// Lights


// Scoring
#define POINTS_FOR_TREE_DESTROYED 10
#define POINTS_FOR_CRATE_DESTROYED 10
#define POINTS_FOR_WOODBRICK_DESTROYED 10
#define POINTS_FOR_WALLBRICK_DESTROYED 10
#define POINTS_FOR_OILBARREL_DESTROYED 10
#define POINTS_FOR_WATERBARREL_DESTROYED 10
#define POINTS_FOR_ICECUBE_DESTROYED 10

#define POINTS_FOR_BONUS 200
#define POINTS_FOR_BEACON_POWERUP 1000
#define POINTS_FOR_LEVEL_COMPLETE 500

// Collision masks
#define ballCategory 1
#define batCategory 2
#define brickCategory 4
#define edgeCategory 8    // screen borders
#define beaconCategory 16
#define barrelCategory 32
#define treeTopCategory 64
#define treeTrunkCategory 128
#define bonusCategory 256
#define woodShardCategory 512

// this one is a special category. After brick(crate) is about to get destroyed, it changes category so the ball does not have physics engine contact with it, but contact tests are still done -> next time the ball hits the crate the shards will be created and collide with the ball, but the crate does not hinder the ball's trajectory -> crate explodes to pieces. All other game objects need to have physics tests against this category as well but not the ball.
#define brickCategoryButNoCollisionWithBall 1024

#define chainCategory 2048

#endif
