//
//  StateTheatreNextGeneration.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "State.h"
#import "PhysicPendulum.h"
#import "PuppetEvolved.h"
#import "BigMister.h"
#import "BigMonster.h"

// State enum
typedef enum StateStateSea
{
    STATE_INIT,
	STATE_NORMAL,
    STATE_NORMAL_EXIT,
	STATE_TRANSITION_TO_EYE_1,
	STATE_TRANSITION_TO_EYE_2,
	STATE_EYE,
	STATE_TANSITION_TO_NORMAL,
    STATE_PRE_NORMAL,
    STATE_NORMAL_WITH_SNAKE,
}StateStateSea;

// plan enumeration
typedef enum TextureStateSea
{ 
	TEXTURE_SEA_FRONT = TEXTURE_COUNT,
	TEXTURE_SEA_BACKGROUND_DOWNHILL,
	TEXTURE_SEA_STICK,
	TEXTURE_SEA_PUPPET_BODY,
	TEXTURE_SEA_PUPPET_HEAD,
	TEXTURE_SEA_PUPPET_ARM,
	TEXTURE_SEA_PUPPET_SWORD,
	TEXTURE_SEA_PUPPET_PIG,
	TEXTURE_SEA_BIG_HEAD,
    TEXTURE_SEA_BIG_HEAD_DOWN,
    TEXTURE_SEA_BIG_HEAD_BODY,
    TEXTURE_SEA_BIG_HEAD_TONGUE,
    TEXTURE_SEA_BIG_HEAD_TONGUE_HEAD,
	TEXTURE_SEA_BIG_ARM,
	TEXTURE_SEA_BIG_EYE_BACKGROUND,
	TEXTURE_SEA_BIG_EYE_BACKGROUND_FRONT,
	TEXTURE_SEA_BIG_EYE_BACKGROUND_EXTENSION,
	TEXTURE_SEA_BIG_EYE_BACKGROUND_PART,
	TEXTURE_SEA_BIG_EYE_BACKGROUND_PART_2,
	TEXTURE_SEA_BIG_EYE_BACKGROUND_PART_3,
	TEXTURE_SEA_GEAR,
	TEXTURE_SEA_LIGHTBUG,
	TEXTURE_SEA_DEAD_THING,
	TEXTURE_SEA_MOUSSE,
	TEXTURE_SEA_BEAST,
	TEXTURE_SEA_FLOWER,
	TEXTURE_SEA_GRASS_BLADE,
	TEXTURE_SEA_GRASS_BLADE_2,
	TEXTURE_SEA_GRASS_BACK,
	TEXTURE_SEA_GRASS_BACK_UNI,
	TEXTURE_SEA_SNAKE_HEAD,
	TEXTURE_SEA_SNAKE_BODY,
	TEXTURE_SEA_COUNT,
}TextureStateSea;

@interface StateSea : State
{
    // the positions of the two fingers.
	CGPoint				m_fingerPosition[2];

    // State in the state.
	StateStateSea		m_state;
	
	// Current position of the pendulum base.
	CGPoint m_headPosition;
	CGPoint m_headSpeed;
	
    // deformation of the puppet.
	float	m_headDeformation;
    
    // deformation of the environment. 
	float	m_aroundTextureDeformationFrequency;
	float	m_aroundTextureDeformation;
	
    // if true, the finger 1 is mapped to the puppet 0.
	BOOL		m_multiTouchMondayToTuesday;
    
    // if true, the puppet is crazy, and we can't switch to the victory state.
	BOOL		m_isCrazy;
	
    // camera settings, use of a physics behaviour.
	float		m_scale;
	float		m_scaleSpeed;
	CGPoint		m_cameraTranslate;
	CGPoint		m_cameraSpeed;
    
	float		m_eyeTransition;
	
    // pig puppet.
	PuppetEvolvedPig * m_puppet;
	
	CGPoint				m_skyDecay;
	NSTimeInterval		m_time;
	float				m_grassWave;
	
	BigMisterWithEye			*m_bigHead;
	BigMister			*m_bigArm;
    NSTimeInterval      m_timeSinceHit;
	
	CGPoint				m_positionExtension;
	BigMonster			*m_bigMonster;
	
	float m_puppetSpeed;
    float m_soundCoeff;
    float   m_luminositySky;
    
	CGPoint		m_pendulumBasePositionScaleCurrent;
    CGPoint     m_snakeDrawDecay;
	PhysicPendulum * m_pendulumHead;
    // position of the pendulum at the end.
    CGPoint     m_positionPendulumAtEnd;
	int			m_fingerMoved;
    // if true, the big mister is dead.
    BOOL        m_misterDead;
    // limit to quit the state when big mister is dead.
    float       m_skyDecayToQuit;
}

//
//  Init the snake.
//
-(void)InitSnake;

//
//  Update the fight.
//
-(BOOL)UpdateKilling:(NSTimeInterval)a_timeInterval;

//
//  Udate the puppet.
//
-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval;

//
//  Update the snake.
//
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval;

//
//  Draw everything related to the real world.
//
-(void)DrawGrassThings:(NSTimeInterval)a_timeInterval;

@end
