//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleMonsterTheatreFlower.h"
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
#define VOLUME_HIT 0.5f

@implementation ParticleMonsterTheatreFlower

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick
{
	[super initWithTexture:a_texture textureStick:a_textureStick];
	m_timer = TIMER_BETWEEN_PAUSE * (0.8 + 0.2 * (myRandom() + 1.f) / 2.f);
	m_wind = 0.f;
	m_killed = NO;
	m_rotationAngle = 0.f;
	m_rotationAngleSpeed = 0.f;
	
	return self;
}

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick initPosition:(CGPoint)a_position
{
	[self initWithTexture:a_texture textureStick:a_textureStick];
	m_position = CGPointMake(a_position.x + myRandom() * 0.2f, a_position.y + myRandom() * 0.05f);
	m_lifetime = 10.f;
	m_size = 0.07 + myRandom() * 0.01;
	
	return self;
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	CGPoint l_killForce;
	float l_heraticX;
	float l_heraticY;
	[m_stick UpdateWithBasePosition:m_position timeFrame:a_timeInterval];	
	
	m_hitRotationCurrent += m_hitRotationCurrentSpeed * a_timeInterval;
	m_hitRotationCurrentSpeed += 0.6 * (m_hitRotationGoal - m_hitRotationCurrent) * a_timeInterval;
	m_hitRotationCurrentSpeed *= 1.f - 0.9 * a_timeInterval;
	
	m_rotationAngle += m_rotationAngleSpeed * a_timeInterval;
	
	m_wind += myRandom() * a_timeInterval;
	m_wind = clip(m_wind, -1.f, 1.f);
	m_timer -= a_timeInterval;
	
	m_position.x += m_speed.x * a_timeInterval;
	m_position.y += m_speed.y * a_timeInterval;
	
	if((m_position.y < -4.f) && m_killed)
	{
		m_lifetime = -10.f;
	}
	
	if(m_killed)
	{
		l_killForce	= [self KillInfluenceOn];

		l_heraticX = myRandom() * 0.007 * m_distance;
		l_heraticY = myRandom() * 0.007 * m_distance;
		m_speed.x	+= ((l_killForce.x * a_timeInterval + l_heraticX)); 
		m_speed.y	+= ((l_killForce.y * a_timeInterval + l_heraticY));
	}
		
	m_speed.x = m_speed.x * (1.f - FRICTION_MONSTER * a_timeInterval);
	m_speed.y = m_speed.y * (1.f - FRICTION_MONSTER * a_timeInterval);	
}


//
//	Computation of the strength applied on a particle when it is dead
//
-(CGPoint)KillInfluenceOn
{	
	
	float l_xforce = cos(m_timer * 0.7) * 0.2;
	float l_yforce = 0.;
	
	if(m_killed)
	{
		l_yforce -= 1.31;
	}
	
	return Vector2DMake(l_xforce, l_yforce);
}

-(void)draw
{
	PlanIndex l_planIndex = PLAN_PARTICLE_BEHIND;//(m_attractorPosition.y < 0) ? PLAN_PARTICLE_FRONT : PLAN_PARTICLE_BEHIND;
	CGPoint l_position = [ParticleMonsterTheatre GetPosition];
	CGPoint l_positionVisual1 = CGPointMake(m_position.x - l_position.x, m_position.y - l_position.y);	
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
										   plan:l_planIndex 
										   size:m_size * 1.
									  positionX:l_positionVisual1.x
									  positionY:l_positionVisual1.y
									  positionZ:0.5
								  rotationAngle:m_speed.x * 30.f + m_rotationAngle
								rotationCenterX:l_positionVisual1.x 
								rotationCenterY:l_positionVisual1.y
								   repeatNumber:1
								  widthOnHeight:cos(m_hitRotationCurrent + m_wind)
									 nightBlend:FALSE
									deformation:m_wind
									   distance:m_wind * 20.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_PARTICLE_BEHIND
										reverse:REVERSE_NONE
	 ];
}

-(void)HitWithStrength:(float)a_strength
{
	if(!m_killed)
	{
		printf("Kill flower\n");
		a_strength = clip(a_strength, 0.f, 4.f);
		m_speed.x = a_strength * 0.1f + myRandom() * 0.10f;
		m_speed.y = a_strength *  0.3f + myRandom() * 0.15f;
		
		m_hitRotationCurrentSpeed = 2.f + myRandom();
		m_hitRotationGoal += M_PI * 4.f;
		m_rotationAngleSpeed = myRandom() * 380.f;
		m_killed = YES;	
		[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"treeFriction" Volume:0.5];
		[[OpenALManager sharedOpenALManager] FadeWithKey:@"treeFriction" duration:0.5f volume:0.f stopEnd:NO];
	}
}

@end