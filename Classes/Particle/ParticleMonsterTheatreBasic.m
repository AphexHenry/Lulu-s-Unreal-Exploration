//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleMonsterTheatreBasic.h"
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

@implementation ParticleMonsterTheatreBasic

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick
{
	[super initWithTexture:a_texture textureStick:a_textureStick];
	m_timer = TIMER_BETWEEN_PAUSE * (0.8 + 0.2 * (myRandom() + 1.f) / 2.f);
	m_secondTextureAngle = 0.f;
	
	return self;
}

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick initPosition:(CGPoint)a_position
{
	[self initWithTexture:a_texture textureStick:a_textureStick];
	m_position = CGPointMake(a_position.x + myRandom() * 0.5f, a_position.y + myRandom() * 0.5f);
	m_position2 = m_position;
	m_lifetime = 7.f + myRandom() * 4.f;

	return self;
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	[m_stick UpdateWithBasePosition:m_position timeFrame:a_timeInterval];	
	
	CGPoint		attractorForce = CGPointMake(0.f, 0.f);
	CGPoint		l_killForce = attractorForce;
	
	m_hitRotationCurrent += m_hitRotationCurrentSpeed * a_timeInterval;
	m_hitRotationCurrentSpeed += 0.6 * (m_hitRotationGoal - m_hitRotationCurrent) * a_timeInterval;
	m_hitRotationCurrentSpeed *= 1.f - 0.9 * a_timeInterval;
	
	m_timer -= a_timeInterval;
	m_nextBiteTimer -= a_timeInterval;
	m_secondTextureAngle = cos(m_timer * 2.f) * ROTATION_AMPLITUDE;
	
	float l_heraticX = myRandom() * 0.04 * m_distance;
	float l_heraticY = myRandom() * 0.04 * m_distance;
	float l_previousPosition = m_position.x;
	m_position.x += (m_speed.x + l_heraticX) * a_timeInterval;
	m_position.y += (m_speed.y + l_heraticY) * a_timeInterval;
	m_position2.x += (m_speed2.x + l_heraticX) * a_timeInterval;
	m_position2.y += (m_speed2.y + l_heraticY) * a_timeInterval;
	
	if(!m_killed)
	{
		if((m_position.x - l_previousPosition) < 0.f)
		{
			m_rotationTurn += a_timeInterval * MONSTER_TURN_SPEED;
		}
		else
		{
			m_rotationTurn -= a_timeInterval * MONSTER_TURN_SPEED;
		}
		m_rotationTurn = clip(m_rotationTurn, -1.f, 1.f);
	}
	
	if((m_position.y < -4.f) && (m_position2.y < -4.f) && m_killed)
	{
		m_lifetime = -10.f;
	}
	
	if(!m_killed)
	{
		attractorForce	= [self AttractorsInfluenceOn];
	}
	else
	{	
		l_killForce	= [self KillInfluenceOn];
	}

	l_heraticX = myRandom() * 0.007 * m_distance;
	l_heraticY = myRandom() * 0.007 * m_distance;
	m_speed.x	+= (((attractorForce.x + l_killForce.x) * a_timeInterval + l_heraticX)); 
	m_speed.y	+= (((attractorForce.y + l_killForce.y) * a_timeInterval + l_heraticY));
	
	m_speed2.x	+= (((attractorForce.x - l_killForce.x) * a_timeInterval + l_heraticX)); 
	m_speed2.y	+= (((attractorForce.y + l_killForce.y) * a_timeInterval + l_heraticY));
		
	m_speed.x = m_speed.x * (1.f - FRICTION_MONSTER * a_timeInterval);
	m_speed.y = m_speed.y * (1.f - FRICTION_MONSTER * a_timeInterval);
	
	m_speed2.x = m_speed2.x * (1.f - FRICTION_MONSTER * a_timeInterval);
	m_speed2.y = m_speed2.y * (1.f - FRICTION_MONSTER * a_timeInterval);
	
	CGPoint l_position = [ParticleMonsterTheatre GetPosition];
	CGPoint l_positionTarget = [ParticleMonsterTheatre GetTargetPosition];
	if(!m_killed && (m_nextBiteTimer < 0.f) && DistancePoint(CGPointMake(l_position.x + l_positionTarget.x, l_position.y + l_positionTarget.y), m_position) < 0.15)
	{
		m_nextBiteTimer = TIMER_BETWEEN_BITE;
		[[[ApplicationManager sharedApplicationManager] GetState] Event1:1 * (int)TIMER_BETWEEN_BITE];
	}
}

//
//	Computation of the strength applied on a particle by the attractors
//
-(CGPoint)AttractorsInfluenceOn
{	
	float l_xforce = 0.;
	float l_yforce = 0.;

	CGPoint l_position = [ParticleMonsterTheatre GetPosition];
	CGPoint l_positionTarget = [ParticleMonsterTheatre GetTargetPosition];
	if(Absf(m_position.x - l_position.x) < 2.f)
	{
		l_xforce -= (m_position.x - (l_position.x + l_positionTarget.x)) * ATTRACTOR_COEFF;
		l_yforce -= (m_position.y - (l_position.y + l_positionTarget.y)) * ATTRACTOR_COEFF;
	}

	return Vector2DMake(l_xforce, l_yforce);
}

//
//	Computation of the strength applied on a particle when it is dead
//
-(CGPoint)KillInfluenceOn
{	
	float l_xforce = 0.;
	float l_yforce = 0.;
	
	if(m_killed)
	{
		l_yforce -= 1.31;
	}
	
	return Vector2DMake(l_xforce, l_yforce);
}

-(void)draw
{
	PlanIndex l_planIndex = PLAN_PARTICLE_FRONT;//(m_attractorPosition.y < 0) ? PLAN_PARTICLE_FRONT : PLAN_PARTICLE_BEHIND;
	
	CGPoint l_position = [ParticleMonsterTheatre GetPosition];
	float	l_stickAngle = [m_stick m_angle];
	CGPoint l_positionVisual1 = CGPointMake(m_position.x - l_position.x, m_position.y - l_position.y);
	CGPoint l_positionVisual2 = CGPointMake(m_position2.x - l_position.x, m_position2.y - l_position.y);
	CGPoint l_positionCenterStick;
	l_positionCenterStick = CGPointMake(l_positionVisual1.x - sin(l_stickAngle) * STICK_LENGTH / 2.3, 
										l_positionVisual1.y + cos(l_stickAngle) * STICK_LENGTH / 2.3);
	
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_textureStick
										   plan:PLAN_PENDULUM
										   size:	STICK_LENGTH / 2.3
									  positionX:l_positionCenterStick.x
									  positionY:l_positionCenterStick.y
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE(l_stickAngle) + 180.
								rotationCenterX:l_positionCenterStick.x
								rotationCenterY:l_positionCenterStick.y
								   repeatNumber:1
								  widthOnHeight:STICK_WIDTH_ON_HEIGHT
									 nightBlend:false
									deformation:0.f
									   distance:50.f
	 ];
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
										   plan:l_planIndex 
										   size:m_size * 1.
									  positionX:l_positionVisual1.x
									  positionY:l_positionVisual1.y
									  positionZ:0.5
								  rotationAngle:-m_secondTextureAngle / 2.f
								rotationCenterX:l_positionVisual1.x 
								rotationCenterY:l_positionVisual1.y
								   repeatNumber:1
								  widthOnHeight:cos(m_hitRotationCurrent) * m_rotationTurn
									 nightBlend:FALSE
									deformation:0.f
									   distance:45.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_PARTICLE_BEHIND
										reverse:REVERSE_NONE
	 ];
	
	l_positionCenterStick = CGPointMake(l_positionVisual2.x - sin(l_stickAngle) * STICK_LENGTH / 2.3, 
										l_positionVisual2.y + cos(l_stickAngle) * STICK_LENGTH / 2.3);
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_textureStick
										   plan:PLAN_PENDULUM
										   size:	STICK_LENGTH / 2.3
									  positionX:l_positionCenterStick.x
									  positionY:l_positionCenterStick.y
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE(l_stickAngle) + 180.
								rotationCenterX:l_positionCenterStick.x
								rotationCenterY:l_positionCenterStick.y
								   repeatNumber:1
								  widthOnHeight:STICK_WIDTH_ON_HEIGHT
									 nightBlend:false
									deformation:0.f
									   distance:50.f
	 ];
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture + 1
										   plan:l_planIndex 
										   size:m_size * 1.
									  positionX:l_positionVisual2.x
									  positionY:l_positionVisual2.y
									  positionZ:0.5
								  rotationAngle:m_secondTextureAngle / 2.f
								rotationCenterX:l_positionVisual2.x 
								rotationCenterY:l_positionVisual2.y
								   repeatNumber:1
								  widthOnHeight:cos(m_hitRotationCurrent) * m_rotationTurn
									 nightBlend:FALSE
									deformation:0.f
									   distance:45.f
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
		if(m_lifetime - a_strength < 0.f)
		{
			printf("Kill\n");
			m_speed.x = 0.2f + myRandom() * 0.15f;
			m_speed2.x = -0.15f + myRandom() * 0.1f;
			
			m_speed.y = 0.7f + myRandom() * 0.15f;
			m_speed2.y = 0.7f + myRandom() * 0.15f;
			
			m_hitRotationCurrentSpeed = 0.f;
			m_hitRotationGoal = m_hitRotationCurrent;
			m_killed = YES;	
			if(![[OpenALManager sharedOpenALManager] isPlayingSoundWithKey:@"guadaStick2"])
			{
				[[OpenALManager sharedOpenALManager] playSoundWithKey:@"guadaStick2" Volume:VOLUME_HIT];
				[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"guadaStick2" Pitch:0.9f + myRandom() * 0.1f];
			}
		}
		else
		{
			if(Absf(m_hitRotationGoal - m_hitRotationCurrent) < M_PI)
			{
				m_lifetime -= a_strength;
				m_speed.x = m_speed2.x = 0.4f + myRandom() * 0.1f;
				m_hitRotationGoal += (float)(floor(a_strength / 2.) + 1) * M_PI * 2.f;
				m_hitRotationCurrentSpeed = m_hitRotationGoal / 2.f;
				
				OpenALManager * l_openALManager = [OpenALManager sharedOpenALManager];
				BOOL l_1playing = [l_openALManager isPlayingSoundWithKey:@"guadaStick1"];

				if(!l_1playing)
				{
					[l_openALManager playSoundWithKey:@"guadaStick1" Volume:VOLUME_HIT];
					[l_openALManager SetPitchWithKey:@"guadaStick1" Pitch:.9f + myRandom() * 0.05f];
				}

			}
		}
	}
}

@end