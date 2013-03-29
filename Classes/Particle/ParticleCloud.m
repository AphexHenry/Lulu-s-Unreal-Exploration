//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleCloud.h"
#import	"MathTools.h"
#import "StateLucioles.h"

@implementation ParticleCloud

static CGPoint			s_decay;

//
// initialization of a particle
//
-(id)init
{
	[super init];
	
//	GroupGlobalVariable l_groupGlobalVariables = m_groupMapping[a_groupIndex];
	m_position.x	= myRandom() * 2.9;
	m_position.y	= myRandom() * 2.3;
	m_speed.x		= 0.2f;
	m_speed.y		= 0.01f;
	m_distance		= -3.f - myRandom() * 3.f;
	m_texture		= TEXTURE_CLOUD;
	m_group = PARTICLE_GROUP_CLOUD;
	m_lifetime = 1.f;
	m_size = 0.4 + myRandom() * 0.15f;
	m_plan = PLAN_SKY_SHADOW;
	return self;
}


//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
//
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	
	if(m_distance <= 5.f)
	{
		m_distance += a_timeInterval / 1.f;	
	}

	m_position.x += m_speed.x * a_timeInterval;
	m_position.y += m_speed.y * a_timeInterval;
		
	if(Absf(m_position.x * m_position.y) > 100.f)
	{
		m_position.x = -m_speed.x * 100. + myRandom() * 3.f;
		m_position.y =  -m_position.y * 100. + myRandom() * 2.f;
	}
}

-(void)draw
{
	if(m_distance >= 0.)
	{
		[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
											   plan:m_plan 
											   size:m_size * 3.5f / (m_distance + EPSILON)
										  positionX:(m_position.x + s_decay.x) / (m_distance + EPSILON)
										  positionY:(m_position.y + s_decay.y) / (m_distance + EPSILON)
										  positionZ:0.5
									  rotationAngle:0.f
									rotationCenterX:m_position.x 
									rotationCenterY:m_position.y
									   repeatNumber:1
									  widthOnHeight:1.f
										 nightBlend:FALSE
										deformation:0.f
										   distance:m_distance
		 ];
	}
}

+(void)SetDecay:(CGPoint)a_decay
{
	s_decay = a_decay;
}

@end
