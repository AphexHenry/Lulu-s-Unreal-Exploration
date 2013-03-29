//
//  StateLucioles.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "State.h"
#import "PhysicPendulum.h"
#import "Mario.h"

// plan enumeration
typedef enum TexturSpiral
{ 
	TEXTURE_SPIRAL_BACKGROUND_FRONT = TEXTURE_COUNT,
	TEXTURE_SPIRAL_BACKGROUND_BACK,
	TEXTURE_SPIRAL_LUCIOLE,
	TEXTURE_SPIRAL_SNAKE_BODY,
	TEXTURE_SPIRAL_MARIO_BODY,
	TEXTURE_SPIRAL_MARIO_EYES,
	TEXTURE_SPIRAL_MARIO_FALL,
	TEXTURE_SPIRAL_MARIO_ORA,
	TEXTURE_SPIRAL_LIGHT,
	TEXTURE_SPIRAL_MIST,
	TEXTURE_SPIRAL_BIG_MONSTER,
	TEXTURE_SPIRAL_BEAST_FRAME_0,
	TEXTURE_SPIRAL_COUNT
}TextureSpiral;

@interface StateSpiral : State
{
//	// Current position of the pendulum base.
	CGPoint m_pendulumBasePositionScaleCurrent;
	CGPoint m_pendulumBaseSpeedScaleCurrent;
	// decay position of the clouds.
	CGPoint m_skyDecay;
	// if true, we have to close the state.
	BOOL m_closeState;
    // if true, let's break the black thing.
	BOOL m_marioBreaks;
	
	// pointor to the head of the pendulum.
	PhysicPendulum * m_pendulumHead;
	PhysicPendulum * m_pendulumStick;
	
	// position of the finger on the screen.
	CGPoint				m_lightGlowPosition;
    // position of the end of the stick.
	CGPoint				m_stickEndPosition;
    // position of the finger.
	CGPoint				m_fingerPosition;
    // timer of the state.
	NSTimeInterval		m_stateTimer;
    // previous position of the finger.
	CGPoint				m_fingerPositionPrevious;
	// rotation of the world.
	float				m_worldRotationDegree;
    // virtual position of the thing.
	float				m_positionInTranslateWorld;
	// the thing.
	Mario				*m_mario;
}

// init pendulum
-(void)InitSnake;

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval;

// fade out the music.
-(void)FadeOutMusic;

// draw the environment.
-(void)DrawBackground;

@end
