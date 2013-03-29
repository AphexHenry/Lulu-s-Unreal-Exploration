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
typedef enum TextureLarve
{ 
	TEXTURE_LARVE_BACKGROUND_AROUND = TEXTURE_COUNT,
	TEXTURE_LARVE_BACKGROUND_CLOSE,
	TEXTURE_LARVE_MIST,
	TEXTURE_LARVE_LUCIOLE,
	TEXTURE_LARVE_SNAKE_BODY,
	TEXTURE_LARVE_SNAKE_HEAD_OPEN_MOUTH,
	TEXTURE_LARVE_SNAKE_HEAD_CLOSE_MOUTH,
	TEXTURE_LARVE_SNAKE_HEAD_PROFILE,
	TEXTURE_LARVE_MARIO_BODY,
	TEXTURE_LARVE_MARIO_EYES,
	TEXTURE_LARVE_MARIO_FALL,
	TEXTURE_LARVE_MARIO_ORA,
	TEXTURE_GLOW_LIGHT,
	TEXTURE_LARVE_STICK,
	TEXTURE_LARVE_PANEL,
	TEXTURE_LARVE_PAYSAGE,
	TEXTURE_LARVE_BEAST_FRAME_0,
	TEXTURE_LARVE_COUNT
}TextureLarve;

@interface StateLarve : State
{
	// Current position of the pendulum base.
	CGPoint m_pendulumBasePositionScaleCurrent;
	CGPoint m_pendulumBaseSpeedScaleCurrent;

    // Panel datas.
	CGPoint m_panelPosition;
	CGPoint m_panelSpeed;
	float	m_panelAngle;
    // if true, the thing took the panel.
	BOOL m_panelTaken;
    
    // if true, the light in on the stick.
	BOOL m_lightTaken;
    // if true, the scutigerus can eat the light.
	BOOL m_canEat;
    // if true, we update the thing.
	BOOL m_updateMario;
    // if true, the thing has falled.
	BOOL m_hasFalled;
    // if true, the snake is falling.
	BOOL m_snakeFall;
    // if true, the stick is released by the thing.
	BOOL m_stickCanBeStuck;
	
	// pointor to the head of the pendulum.
	PhysicPendulum * m_pendulumHead;
	PhysicPendulum * m_pendulumStick;
	
    // position of the light.
	CGPoint				m_lightGlowPosition;
    // position of the end of the stick.
	CGPoint				m_stickEndPosition;
    // position of the finger on the screen.
	CGPoint				m_fingerPosition;
    // poisition of the center of the stick.
	CGPoint				m_stickPosition;

	NSTimeInterval		m_beattleFallTimer;
    // timer for the final rush.
	NSTimeInterval		m_finalRush;
    // timer of the deformation of the glow.
	NSTimeInterval		m_glowDeformation;
    // timer for the stick.
	NSTimeInterval		m_stickTimer;
	// deformation of the background.
	float				m_aroundTextureDeformation;
    // deformation frequency of the background.
	float				m_aroundTextureDeformationFrequency;
	// number of time the snake bite the light.
	int					m_biteCount;
	// decay of the clouds
	CGPoint				m_skyDecay;
	// The black thing.
	Mario				*m_mario;
}

// init pendulum.
-(void)InitStick;
-(void)InitSnake;

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval;

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateStick:(NSTimeInterval)a_timeInterval;

// updtate the glow light.
-(void)UpdateGlow:(NSTimeInterval)a_timeInterval;
// display help.
-(void)CallHelp;
// Set the camera focused on the light.
-(void)CameraGoToLight;
// return the camera to the snake.
-(void)CameraReturnToSnake;

@end
