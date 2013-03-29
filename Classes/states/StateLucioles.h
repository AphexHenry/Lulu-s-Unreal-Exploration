//
//  StateLucioles.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "State.h"
#import "PhysicPendulum.h"

// plan enumeration
typedef enum TextureLucioles
{ 
	TEXTURE_BACKGROUND_AROUND = TEXTURE_COUNT,
	TEXTURE_CLOUD,
	TEXTURE_LUCIOLE_1,
	TEXTURE_LUCIOLE_2,
	TEXTURE_LUCIOLE_3,
	TEXTURE_LUCIOLES_STICK,
	TEXTURE_SNAKE_BODY,
	TEXTURE_SNAKE_HEAD_OPEN_MOUTH,
	TEXTURE_SNAKE_HEAD_CLOSE_MOUTH,
	TEXTURE_LUCIOLES_COUNT
}TextureLucioles;

@interface StateLucioles : State 
{
	// Current position of the pendulum base.
	CGPoint m_pendulumBasePositionScaleCurrent;
	
	bool m_isIntro;
	BOOL m_canEat;
	BOOL m_specialEaten;
	BOOL m_closeState;
	
	// pointor to the head of the pendulum.
	PhysicPendulum * m_pendulumHead;
	
	// position of the finger on the screen.
	CGPoint				m_basePosition;	
	CGPoint				m_basePositionPrevious;	
	NSTimeInterval		m_changeSnakeGravityTimer;
	
	CGPoint				m_lastHeratic;
	float				m_lastBlur;
	float				m_lastLuminosity;
	
	float				m_sizeAroundIntro;				// size of the around element for the intro.
	float				m_aroundTextureDeformation;
	float				m_aroundTextureDeformationFrequency;
	
	CGPoint				m_skyDecay;
	
	float				m_sizeMoon;
	
//	NSMutableArray *    m_stickArray;
}

-(void)InitSnake;

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval;

-(void)ActiveOtherParticles;

@end
