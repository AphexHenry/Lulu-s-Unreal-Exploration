//
//  StateParticleFight.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "State.h"
#import "PhysicPendulum.h"
#import "BigMonster.h"

#define PARTICLE_FLASH_COUNT 54

// texture enumeration
typedef enum TexturParticleFight
{ 
	TEXTURE_PF_BACKGROUND_FRONT = TEXTURE_COUNT,
	TEXTURE_PF_BACKGROUND_BACK,
	TEXTURE_PF_FOREST_FRONT,
	TEXTURE_PF_LUCIOLE,
	TEXTURE_PF_SNAKE_BODY,
	TEXTURE_PF_FOREST_BACK,
	TEXTURE_PF_BEAST_FRAME_0,
	TEXTURE_PF_BIG_MONSTER_ARM,
	TEXTURE_PF_FLASH,
	TEXTURE_PF_FLASH_1,
	TEXTURE_PF_WHITE,
	TEXTURE_PF_CLOUD_STORM,
	TEXTURE_PF_COUNT
}TextureParticleFight;

@interface StateParticleFight : State
{

	CGPoint m_skyDecay;     // world scrolling.
	float m_cloudDecay;     // cloud scrolling.
	
	BOOL m_closeState;      // if true, the beast is dead and we should close the state.
	
	// pointor to the head of the pendulum.
	PhysicPendulum * m_pendulumHead;
	PhysicPendulum * m_pendulumStick;
	
	NSTimeInterval		m_stateTimer;   // timer.
	float				m_breaks;       // break coefficient, due to flashs.
	float				m_breaksTouch;  // break due to finger.
		
	CGPoint				m_fingerPosition;           // position of the finger.
	CGPoint				m_fingerPositionPrevious;   // last position of the fingers.
	CGPoint				m_cameraTransformation;     // position of the virtual camera (because of the scrolling).
	
	CGPoint				m_positionInTranslateWorld; // virtual position in the world.
	float				m_xDecayView;               // visual scrolling.
	CGPoint				m_viewPosition;             
	float				m_speed;                    // speed of the scrolling.
	
	NSTimeInterval		m_flashTimer;               // flash timer.
	NSTimeInterval		m_flashTimerAgainstMonster; // last monster hurt.
   
    // TODO: put everything in a struct.
	NSTimeInterval		m_particleElectrizedTimer[PARTICLE_FLASH_COUNT];   // timer for each elecricity particle.
	float				m_heraticFlashAngle[PARTICLE_FLASH_COUNT];         // angle for each electricity particle.
	CGPoint				m_heraticFlashPosition[PARTICLE_FLASH_COUNT];      // position for each electricity particle.
	float				m_particleElectrizedSize[PARTICLE_FLASH_COUNT];    // size of each electricity particle.
	NSTimeInterval		m_heraticFlashTimer[PARTICLE_FLASH_COUNT];         // noise timer of each electricity particle.
	int					m_heraticFlashTexture[PARTICLE_FLASH_COUNT];       // texture timer of each electricity particle.
	
	CGPoint				m_particlesCenter;
	
	BigMonster			*m_bigMonster;
	int					m_monsterHurtCount;
}

// init pendulum.
-(void)InitSnake;
// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval;
// update the flash sequence.
-(void)UpdateFlashSequence:(NSTimeInterval)a_timeInterval;
// update the flash sequence against the monster.
-(void)UpdateFlashSequenceAgainstMonster:(NSTimeInterval)a_timeInterval;
// update the particles electrization.
-(void)UpdateParticleElectrized:(NSTimeInterval)a_timeInterval;
// display help.
-(void)FadeOutMusic;

@end
