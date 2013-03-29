//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleSea.h"
#import	"MathTools.h"
#import "ApplicationManager.h"

#define			WIND_FORCE					.06f
#define			ELASTICITY_FORCE			.2f
#define			PUPPET_FORCE				0.01f
#define			SIZE						(PARTICULE_SIZE_MIN + PARTICULE_SIZE_MAX) * 0.5f // Relative size of the particles
#define			SIZE_VAR					SIZE * 0.2f	// Variance of this size
#define			POSITION_VAR_Y				0.12f


@implementation ParticleSea

static float			s_groundY;
static float			s_distance = -1.f;
static float			s_xTranslate = 0.f;
static float			s_positionWave = 0.f;
static float			s_amplitudeWave = 0.f;
static float			s_positionPuppet = 0.f;

-(id)initWithTexture:(int)a_texture size:(float)a_size position:(float)a_position widthOnHeight:(float)a_widthOnHeight
{
	[super init];
	m_speed.x		= 0.f;
	m_speed.y		= 0.f;
	m_lifeTimeInit	= 10.f;
	m_lifetime		= 10.f;
	
	m_distance = 2.f - a_position + myRandom() * 0.02;
	m_group = PARTICLE_GROUP_LUCIOLE;
	m_particleId = (int)((myRandom() + 1.f) * 500.f);
	float l_variation = myRandom();
	m_position = CGPointMake(a_position, s_groundY + l_variation * POSITION_VAR_Y);
	
	m_mass			= l_variation > 0.f ? 2.f - l_variation : 1.f - l_variation;
	
	m_size = a_size * (1.f - 0.2 * l_variation);
	if(m_position.y > s_groundY + 0.05f)
	{
		m_plan = PLAN_PARTICLE_BEHIND;
	}
	else
	{
		m_plan = PLAN_PARTICLE_FRONT;
	}

	m_texture = a_texture;

	m_angle = 0.f;
	m_deformation = 0.f;
	m_deformationSpeed = 0.f;
	m_widthOnHeight = a_widthOnHeight;
	m_lastTranslate = 0.f;
	
	return self;
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	m_deformationSpeed += clip( 1.f / ((m_position.x + s_xTranslate) - s_positionWave), -7.f, 7.f ) * a_timeInterval * WIND_FORCE * s_amplitudeWave / m_mass;
	m_deformationSpeed += -m_deformation * a_timeInterval * ELASTICITY_FORCE * s_amplitudeWave / m_mass;

	if((m_position.y > s_groundY - POSITION_VAR_Y / 2.f) && (m_position.y < s_groundY + POSITION_VAR_Y / 2.f)
	   && Absf((m_position.x + s_xTranslate) - s_positionPuppet) < 0.1f)
	{
		float l_scrollingSpeed = (s_xTranslate - m_lastTranslate) / a_timeInterval;
		m_lastTranslate = s_xTranslate;
		m_deformationSpeed += PUPPET_FORCE * l_scrollingSpeed * clip( 1.f / clip(Absf(((m_position.x + s_xTranslate) - s_positionPuppet)), 0.1f, 0.2f), -5.f, 5.f ) * a_timeInterval / m_mass;
	}

	m_deformationSpeed *= 1.f - a_timeInterval;
	
	m_deformation += m_deformationSpeed;
	
	if(m_position.x + s_xTranslate < -1.5f)
	{
		m_position.x = -s_xTranslate + 1.6f + myRandom() * 0.12f;
	}
}

// call help.
-(void)CallHelp
{
	[[ApplicationManager sharedApplicationManager] SetHelp:@"helpShake.png"];
}

-(void)draw
{
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
										   plan:m_plan
										   size:m_size / m_widthOnHeight
									  positionX:m_position.x + s_xTranslate - m_deformation * 0.08f
									  positionY:m_position.y + m_deformation * 0.1f
									  positionZ:0.5
								  rotationAngle:m_angle
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:m_widthOnHeight
									 nightBlend:NO
									deformation:2.f * clip(m_deformation, -2.f, 2.f)
									   distance:m_distance
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_SHADOW
										reverse:REVERSE_NONE
	 ];
}

+(void)SetGroundY:(float)a_groundY
{
	s_groundY = a_groundY;
}

+(void)SetPositionPuppet:(float)a_position
{
	s_positionPuppet = a_position;
}

+(void)SetDistance:(float)a_distance
{
	s_distance = a_distance;
}

+(void)SetXTranslate:(float)a_xTranslate
{
	s_xTranslate = a_xTranslate;
}

+(void)SetWavePosition:(float)a_xPosition
{
	s_positionWave = a_xPosition;
}

+(void)SetWaveAmplitude:(float)a_amplitude
{
	s_amplitudeWave = clip(a_amplitude, 0.f, 0.8f);
}

@end

@implementation ParticleSeaFlower

-(id)initWithTexture:(int)a_texture size:(float)a_size position:(float)a_position widthOnHeight:(float)a_widthOnHeight
{
    [super initWithTexture:a_texture size:a_size position:a_position widthOnHeight:a_widthOnHeight];
    m_position = CGPointMake(a_position, s_groundY + myRandom() * POSITION_VAR_Y * 0.7);
    return self;
}

-(void)draw
{	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
										   plan:m_plan
										   size:m_size / m_widthOnHeight
									  positionX:m_position.x + s_xTranslate - m_deformation * 0.08f
									  positionY:m_position.y + m_deformation * 0.1f + 0.01f
									  positionZ:0.5
								  rotationAngle:2.f * clip(m_deformation, -2.f, 2.f) * 25.f
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:m_widthOnHeight
									 nightBlend:FALSE
									deformation:0.f
									   distance:m_distance
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_SHADOW
										reverse:REVERSE_NONE
	 ];
}

@end




