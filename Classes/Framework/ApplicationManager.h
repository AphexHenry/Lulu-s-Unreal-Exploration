//
//  ApplicationManager.h
//  Particles
//
//  Created by Baptiste Bohelay on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "State.h"
#import "NoteBook.h"

@class ParticleManager;
@class PhysicPendulum;

// game state enumeration.
typedef enum EnumInGameButton
{ 
	BUTTON_BACK_TO_MENU,
	BUTTON_BACK_TO_GAME,
	BUTTON_INGAME_NUMBER
}InGameButton;

typedef enum EnumEndType
{
	END_TYPE_NONE = -1,
	END_TYPE_LOSE,
	END_TYPE_WIN_BY_EXTERMINATION,
	END_TYPE_WIN_BY_MUTATION,
}EndType;

typedef enum EnumUpdateType
{
	UPDATE_STATE,
	UPDATE_FADE_IN,
	UPDATE_FADE_OUT,
}UpdateType;

@interface ApplicationManager : NSObject 
{
	// Particle manager.
	ParticleManager		*m_ParticleManager;
	
    // saved level.
	NSInteger			m_savedLevel;
	
	// Timer informations.
	NSTimer				*animationTimer;
    NSTimeInterval		m_animationInterval;
	NSTimeInterval		m_timeAtLastUpdate;
	NSTimeInterval		m_timeFrame;
	NSTimeInterval		m_timerFading;

    // update state.
	UpdateType			m_updateType;
	
    // if true, the game is in pause.
	BOOL				m_pause;

    // pointors on the states.
	State				*m_currentState;
	State				*m_nextState;

    // Help informations.
	BOOL				m_baptisteClicked;
	BOOL				m_baptisteBlocked;
	NSTimeInterval		m_baptisteIsComingTimer;
	CGPoint				m_baptisteBackSpeed;
	CGPoint				m_baptisteBackPosition;
	
    // Note book state, to be loaded.
	NoteBook			*m_noteBook;
    // if true, we need to call the state extra init, mostly for the sounds.
    // Used if the level is loaded from the menu.
    BOOL                m_callExtraInit;
}

@property NSTimeInterval m_animationInterval;
@property int m_numberMaxParticleToLose;
@property int m_numberGenerationToMutate;
@property BOOL m_pause;
@property NSInteger m_savedLevel;

//
// the class is a singleton, we use this method to get the object
//
+(ApplicationManager*)sharedApplicationManager;

//
// init the application.
//
- (id)init;

//
// Update the application.
//
- (void)Update;

//
// update the Baptiste GUI.
//
-(void)UpdateBaptiste:(NSTimeInterval)a_timeInterval;

//
// Change and init new state.
//
-(void)ChangeState:(State * )a_newState;
-(void)ChangeStateFromMenu:(State * )a_newState;

//
// Apply the new state.
//
-(void)ApplyState;

//
// return the current state.
//
-(State *)GetState;

//
// ruturn a random name of a beast texture.
//
-(NSString *)GetABeastName;

//
// Close previous state.
//
-(void)ClosePreviousState;

//
// Init new state.
//
-(void)InitState;

//
// Close the application.
//
- (void)Finnish;

//
// Set a new timer for the update.
//
- (void)setTimer:(NSTimer *)newTimer;

//
// Block or not Baptiste.
//
-(void)SetBaptisteBlocked:(BOOL)a_baptisteBlocked;

//
// Simple click event.
//
-(void)SimpleClick:(CGPoint)a_touchLocation;

//
// Touch event.
//
-(void)Touch:(CGPoint)a_touchLocation;

//
// Multi touch event.
//
-(void)MultiTouch:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2;

//
// Touch moved event.
//
-(void)TouchMoved:(CGPoint)a_touchLocation;

//
// multi touch move event.
//
-(void)MultiTouchMove:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2;

//
// Touch ended.
//
-(void)TouchEnded:(CGPoint)a_touchLocation;

//
// Skip speaking.
//
-(void)SkipSpeaking;

//
// Shake.
//
-(void)Shake;

//
// Return to main menu.
//
-(void)BackToMenu;

//
// Set the stop state.
//
-(void)Stop:(BOOL)a_isStop;

//
// remove help.
//
-(void)RemoveHelp;

//
// Set the help message.
//
-(void)SetHelp:(NSString *)a_string;

//
// Set help position.w
//
-(void)SetHelpPositionPixel:(CGPoint)a_position;

//
// Save the given level.
//
-(void)SaveLevel:(int)a_level;

//
// return the version of the rating.
//
-(int)GetRated;

//
// Set the game rated.
//
-(void)SetRated:(int)a_rated;

@end
