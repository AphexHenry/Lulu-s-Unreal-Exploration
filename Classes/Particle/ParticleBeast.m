//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import	"MathTools.h"
#import "ParticleBeast.h"
#import	"StateLarve.h"
#import "Animation.h"

@implementation ParticleBeast

//
// initialization of a particle
//
-(id)initWith
{
	[super init];
	float a = myRandom();
	
	m_position.x	= -3.f;
	m_position.y	= 0.5f + myRandom() * 0.4f;
	m_speed.x		= myRandom() * 0.04 +  0.15f;
	m_speed.y		= myRandom() * 0.015f;
	
	if(a < 0.f)
	{
		m_position.x = -m_position.x;
		m_speed.x = -m_speed.x;
	}

	m_distance		= -1.f;
	m_group = PARTICLE_GROUP_BEAST;
	m_lifetime = myRandom() * 20.f + 100.f;
	m_size = 0.1 + myRandom() * 0.01f;
	m_deformation = 0.f;
	m_deformationFrequency = 0.1f + myRandom();
	
	return self;
}

-(void)SetAnimation:(int)a_frame
{
	m_texture = a_frame;
}


//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
//
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	m_lifetime -= a_timeInterval;
	if(m_lifetime < 0)
	{
		[self init];
	}
	m_position.x += m_speed.x * a_timeInterval;
	m_position.y += (m_speed.y + 0.2 * m_deformation) * a_timeInterval;
	m_deformation = 0.4f * cos(m_lifetime);
}

-(void)draw
{
	ReverseType l_reverseType;
	if(m_speed.x < 0)
	{
		l_reverseType = REVERSE_HORIZONTAL;
	}
	else
	{
		l_reverseType = REVERSE_NONE;		
	}

		
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture
										   plan:PLAN_SKY_SHADOW 
										   size:m_size
									  positionX:m_position.x
									  positionY:m_position.y
									  positionZ:0.5
								  rotationAngle:0
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:m_deformation
									   distance:-1.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:-1
										reverse:l_reverseType
	 ];
}


@end
