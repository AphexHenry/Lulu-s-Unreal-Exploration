//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleBug2.h"
#import	"MathTools.h"

#define SIZE 0.15
#define SIZE_VAR 0.05
#define STRENGTH 1.5
#define COEFF_MOVE 1.2

@implementation ParticleBugSleep

static float			s_groundY;

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture size:(float)a_size plan:(int)a_plan position:(CGPoint)aPosition
{
	[super init];
	
	m_position	= aPosition;
    mPositionAttractor = aPosition;
    
    m_texture = a_texture;
	m_speed.x		= 0.f;
	m_speed.y		= 0.f;
	m_lifetime		= m_lifeTimeInit * (myRandom() + 1.4f) / 2.f;
	m_size			= a_size;
	m_distance = 0.f;
    m_rotation = myRandom() * 180.f;
	m_group = PARTICLE_GROUP_LUCIOLE;
	m_particleId = (int)((myRandom() + 1.f) * 500.f);
    m_behind = (myRandom() < 0.f);
	return [super init];
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
//
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
    m_position.x += m_speed.x * a_timeInterval;
    m_position.y += m_speed.y * a_timeInterval;
    m_speed.x += (STRENGTH * (mPositionAttractor.x - m_position.x) + COEFF_MOVE * myRandom()) * a_timeInterval;
    m_speed.y += (STRENGTH * (mPositionAttractor.y - m_position.y) + COEFF_MOVE * myRandom()) * a_timeInterval;
    m_speed.x *= 0.95f;
    m_speed.y *= 0.95f;
    
    m_rotation += m_rotationSpeed * a_timeInterval;
    m_rotationSpeed += myRandom() * 190. * a_timeInterval;
}

-(void)draw
{
	PlanIndex l_planIndex;
    PlanIndex l_planFX;
    if(	m_plan > -1)
    {
        l_planIndex = m_plan;
        l_planFX = m_plan;
    }
    else
    {
       l_planIndex = m_behind ? PLAN_PENDULUM : PLAN_BACKGROUND_MIDDLE;
        l_planFX = PLAN_BACKGROUND_CLOSE;
    }

	float l_yPos = max(s_groundY + m_size * 2.5, m_position.y);
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture
										   plan:l_planIndex
										   size:m_size
									  positionX:m_position.x
									  positionY:l_yPos
									  positionZ:0.5
								  rotationAngle:m_rotation
								rotationCenterX:m_position.x
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:-1.
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:l_planFX
										reverse:REVERSE_NONE
	 ];
}

+(void)SetGroundY:(float)a_groundY
{
    s_groundY = a_groundY;
}


@end


