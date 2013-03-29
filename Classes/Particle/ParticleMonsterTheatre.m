//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleMonsterTheatre.h"
#import "ApplicationManager.h"
#import	"MathTools.h"
#import "Animation.h"
#import "PhysicPendulum.h"
#import "OpenALManager.h"

#define STICK_LENGTH 2.f 
#define STICK_WIDTH_ON_HEIGHT 1.f / 90.f 
#define ATTRACTOR_COEFF 0.6
#define FRICTION_MONSTER 0.8
#define TIMER_BETWEEN_PAUSE 2.
#define TIMER_BETWEEN_BITE 1.
#define MONSTER_TURN_SPEED 3.f;
#define ROTATION_AMPLITUDE 21.f

@implementation ParticleMonsterTheatre

static CGPoint			s_currentPosition;			// Current character position.
static CGPoint			s_targetPosition;			// Current character position.

static Animation		*s_animation = nil;
static int				s_texturePause;
static float			s_angle;

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick
{
	[super init];
	
	m_position.x	= s_currentPosition.x + myRandom() * 0.25f - 0.2f;
	m_position.y	= s_currentPosition.y + myRandom() * 0.25f;
	m_speed.x		= 0.f;
	m_speed.y		= 0.f;
	m_texture = a_texture;
	m_textureStick = a_textureStick;
	m_distance = 0.f;
	m_group = PARTICLE_GROUP_MONSTER_THEATRE;
	m_particleId = (int)((myRandom() + 1.f) * 500.f);
	m_angle = myRandom() * 180.;
	m_size = 0.15f;
	m_lifetime = 1.f;
	m_attractorPosition = CGPointMake(s_currentPosition.x, s_currentPosition.y);
	m_distance = 1.f;
	m_killed = NO;
	m_hitRotationGoal = 0.f;
	m_hitRotationCurrent = 0.f;
	m_hitRotationCurrentSpeed = 0.f;
	m_nextBiteTimer = 0.f;
	m_rotationTurn = 1.f;
	
	CGPoint l_pendulumPosition = CGPointMake(m_position.x, m_position.y > 0.f ? m_position.y + STICK_LENGTH : m_position.y - STICK_LENGTH);
	m_stick = [[PhysicPendulum alloc]	initWithPosition:l_pendulumPosition 
											   basePosition:m_position 
													   mass:10.f 
											angleSpeedLimit:-1.f
													gravity:0.5
											   gravityAngle:m_position.y > 0.f ? M_PI : 0.f
												   friction:1.5
											   addInTheList:YES
			   ];
	
	return self;
}

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick initPosition:(CGPoint)a_position
{
	return self;
}

+(void)GlobalInit:(Animation *)a_animation angle:(float)a_angle texturePause:(int)a_texturePause
{
	s_currentPosition = CGPointMake(0.f, 0.f);
	if(s_animation)
	{
		[s_animation release];
	}
	s_animation = a_animation;
	[s_animation startAnimation];
	s_angle = a_angle;
	s_texturePause = a_texturePause;
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{

}

//
//	Computation of the strength applied on a particle by the attractors
//
-(CGPoint)AttractorsInfluenceOn
{	
	return CGPointMake(0.f, 0.f);
}

//
//	Computation of the strength applied on a particle when it is dead
//
-(CGPoint)KillInfluenceOn
{	
	return CGPointMake(0.f, 0.f);
}

-(void)draw
{

}

-(CGPoint)GetDisplayPosition
{
	return CGPointMake(m_position.x - s_currentPosition.x, m_position.y - s_currentPosition.y);
}

-(void)HitWithStrength:(float)a_strength
{
}

+(void)SetTargetPosition:(CGPoint)a_position
{
	s_targetPosition = a_position;
}

+(CGPoint)GetTargetPosition
{
	return s_targetPosition;
}

+(void)SetPosition:(CGPoint)a_position
{
	s_currentPosition = a_position;
}

+(CGPoint)GetPosition
{
	return s_currentPosition;
}

+(void)Terminate
{
	[s_animation stopAnimation];
}

@end