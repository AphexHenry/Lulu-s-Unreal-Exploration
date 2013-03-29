//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleLetter.h"
#import	"MathTools.h"
#import	"AttractorsPositions.h"
#import "Animation.h"
#import "OpenALManager.h"
#import "ApplicationManager.h"
#import "ParticleLetter.h"
#import "PhysicPendulum.h"
#import "StateMenu.h"

#define STICK_LENGTH_LETTER 2.f 
#define ATTRACTOR_COEFF 0.001
#define	TIMER_BETWEEN_PAUSE 5.f

@implementation ParticleLetterGroup

@synthesize m_goAway;
@synthesize m_index;
@synthesize m_attractionPosition;
@synthesize m_attractorCommon;
@synthesize m_size;

-(id)init
{
	[super init];
    [self reset];
	return self;
}

-(void)reset
{
   	m_attractionPosition = CGPointMake(0.f, 0.f);
	m_attractorCommon = NO;
	m_goAway = NO;
	m_size = 0.06;
}

@end

@implementation ParticleLetter

static CGPoint			s_currentPosition;			// Current character position.
static float			s_decay;
static float			s_sizeWing;
static Animation		*s_animation = nil;
static int				s_texturePause;
static float			s_angle;
static BOOL             s_block;
static 	NSMutableArray *s_arrayGroup;

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick groupIndex:(int)a_groupIndex
{
	[super init];
	
	m_position.x	= s_currentPosition.x + myRandom() * 0.25f - 0.2f;
	m_position.y	= s_currentPosition.y + myRandom() * 0.25f;
	m_speed.x		= 0.f;
	m_speed.y		= 0.f;
	m_texture = a_texture;
	m_textureStick = a_textureStick;
	m_distance = 0.f;
    m_strengthAttractor = 1.f;
	m_group = PARTICLE_GROUP_LUCIOLE;
	m_isDead = false;
	m_particleId = (int)((myRandom() + 1.f) * 500.f);
	m_angle = myRandom() * 180.;
	m_lifetime = 10.f;
	m_attractorPosition = CGPointMake(s_currentPosition.x, s_currentPosition.y);
	s_currentPosition.x += s_decay;
	m_distance = 1.f;
	m_timerPause = TIMER_BETWEEN_PAUSE * (0.8 + 0.2 * (myRandom() + 1.f) / 2.f);
	m_groupLetterIndex = a_groupIndex;
	bool l_isNewGroup = TRUE;
	ParticleLetterGroup * l_group;
	for(int i = 0; i < [s_arrayGroup count]; i++)
	{
		l_group = [s_arrayGroup objectAtIndex:i];
		if(l_group.m_index == m_groupLetterIndex)
		{
			m_particleLetterGroup = l_group;
			l_isNewGroup	= NO;
			break;
		}
	}
	if(l_isNewGroup)
	{
		m_particleLetterGroup = [[ParticleLetterGroup alloc] init];
		m_particleLetterGroup.m_index = m_groupLetterIndex;
		[s_arrayGroup addObject:m_particleLetterGroup];
	}
	
	CGPoint l_pendulumPosition = CGPointMake(m_position.x, m_position.y > 0.f ? m_position.y + STICK_LENGTH_LETTER : m_position.y - STICK_LENGTH_LETTER);
	m_stick = [[PhysicPendulum alloc]	initWithPosition:l_pendulumPosition 
											   basePosition:m_position 
													   mass:10.f 
											angleSpeedLimit:-1.f
													gravity:0.5
											   gravityAngle:m_position.y > 0.f ? M_PI : 0.f
												   friction:1.5
											   addInTheList:YES];
	
	return self;
}

//
// initialization of a particle
//
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick groupIndex:(int)a_groupIndex initPosition:(CGPoint)a_position
{
	[self initWithTexture:a_texture textureStick:a_textureStick groupIndex:a_groupIndex];
	m_position = CGPointMake(a_position.x + myRandom() * 0.5f, a_position.y + myRandom() * 0.5f);

	return self;
}

+(void)GlobalInit:(Animation *)a_animation
			angle:(float)a_angle
	 texturePause:(int)a_texturePause
		 sizeWing:(float)a_sizeWing
		 block:(BOOL)a_block
{
    s_block = a_block;
    s_sizeWing = a_sizeWing;
	s_decay = 0.06 * 2.5;
	s_currentPosition = CGPointMake(0.f, 0.f);
	if(s_animation)
	{
		[s_animation release];
	}
	s_animation = a_animation;
	[s_animation startAnimation];
	s_angle = a_angle;
	s_texturePause = a_texturePause;
    if(!s_arrayGroup)
    {
        s_arrayGroup = [[NSMutableArray alloc] init];
    }
}

+(void)GlobalInit:(Animation *)a_animation
			angle:(float)a_angle 
	 texturePause:(int)a_texturePause 
		 sizeWing:(float)a_sizeWing
{
    [ParticleLetter GlobalInit:a_animation
        angle:a_angle
        texturePause:a_texturePause
        sizeWing:a_sizeWing
        block:YES
     ];
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{	
	CGPoint		attractorForce; 
	m_timerPause -= a_timeInterval;
	
	float l_heraticX = myRandom() * 0.04 * m_distance;
	float l_heraticY = myRandom() * 0.04 * m_distance;
		m_position.x += (m_speed.x + l_heraticX) * a_timeInterval;
	m_position.y += (m_speed.y + l_heraticY) * a_timeInterval;
	
	if((((m_position.x * m_position.x) + (m_position.y * m_position.y)) > 4.f) && s_block)
	{
		m_position.x *= 0.9;
		m_position.y *= 0.9;
		m_speed.x = m_speed.y = 0.f;
	}
	
	attractorForce	= [self AttractorsInfluenceOn];

	if(m_particleLetterGroup.m_goAway)
	{
		m_speed.x	+= ((attractorForce.x) / 0.05); 
		m_speed.y	+= ((attractorForce.y) / 0.05);
	}
	else
	{
		l_heraticX = myRandom() * 0.0007 * m_distance;
		l_heraticY = myRandom() * 0.0007 * m_distance;
		m_speed.x	+=     ((attractorForce.x + l_heraticX) / 0.05);
		m_speed.y	+=     ((attractorForce.y + l_heraticY) / 0.05);
		
		m_speed.x = m_speed.x * 0.979;
		m_speed.y = m_speed.y * 0.979;			
	}
    [m_stick UpdateWithBasePosition:m_position timeFrame:a_timeInterval];	
}

//
//	Computation of the strength applied on a particle by the attractors
//
-(CGPoint)AttractorsInfluenceOn
{	
	float l_xdistanceTemp, l_ydistanceTemp;
	float AbsDistance = 20.f;
	float l_xforce = 0.;
	float l_yforce = 0.;
	
	float l_xAttractor, l_yAttractor;

	l_xAttractor = m_attractorPosition.x;
	l_yAttractor = m_attractorPosition.y;
	
	if(m_particleLetterGroup.m_attractorCommon)
	{
		l_xAttractor = m_particleLetterGroup.m_attractionPosition.x;
		l_yAttractor = m_particleLetterGroup.m_attractionPosition.y;
		l_xdistanceTemp		=	m_position.x - l_xAttractor;
		l_ydistanceTemp		=	m_position.y - l_yAttractor;
		AbsDistance			=	sqrt(l_xdistanceTemp*l_xdistanceTemp + l_ydistanceTemp*l_ydistanceTemp);
		l_xforce			+=	-1.45 * ATTRACTOR_COEFF * l_xdistanceTemp / AbsDistance;   
		l_yforce			+=	-1.45 * ATTRACTOR_COEFF * l_ydistanceTemp / AbsDistance;  
	}
	else if(m_particleLetterGroup.m_goAway)
	{
		l_xAttractor = m_attractorPosition.x;
		l_yAttractor = m_attractorPosition.y;
		l_xdistanceTemp		=	m_position.x - l_xAttractor;
		l_ydistanceTemp		=	m_position.y - l_yAttractor;
		l_xdistanceTemp		=	m_position.x - l_xAttractor;
		l_ydistanceTemp		=	m_position.y - l_yAttractor;
		//		AbsDistance			=	l_xdistanceTemp*l_xdistanceTemp + l_ydistanceTemp*l_ydistanceTemp;
		l_xforce			+=	-10.45 * ATTRACTOR_COEFF * Absf(l_xdistanceTemp);   
		l_yforce			+=	1.45 * ATTRACTOR_COEFF * l_ydistanceTemp;  
	}
	else
	{
		l_xAttractor = m_attractorPosition.x;
		l_yAttractor = m_attractorPosition.y;
		l_xdistanceTemp		=	m_position.x - l_xAttractor;
		l_ydistanceTemp		=	m_position.y - l_yAttractor;
		AbsDistance			=	l_xdistanceTemp*l_xdistanceTemp + l_ydistanceTemp*l_ydistanceTemp;
		AbsDistance = (AbsDistance < 0.01) ? 7.525 : AbsDistance;
		l_xforce			+=	-0.45 * ATTRACTOR_COEFF * l_xdistanceTemp;   
		l_yforce			+=	-0.45 * ATTRACTOR_COEFF * l_ydistanceTemp;  
	}

	return Vector2DMake(m_strengthAttractor * l_xforce, m_strengthAttractor * l_yforce);
}

-(void)draw
{
	PlanIndex l_planIndex = PLAN_PARTICLE_FRONT;//(m_attractorPosition.y < 0) ? PLAN_PARTICLE_FRONT : PLAN_PARTICLE_BEHIND;
	m_size = m_particleLetterGroup.m_size;
	
	CGPoint l_stickPosition = [m_stick GetPosition];
	CGPoint l_position;
	l_position = CGPointMake(m_position.x + (l_stickPosition.x - m_position.x) / 2.3, 
							 m_position.y + (l_stickPosition.y - m_position.y) / 2.3);
	float l_angle	   = [m_stick m_angle];
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_textureStick
										   plan:l_planIndex
										   size:	STICK_LENGTH_LETTER / 2.3
									  positionX:l_position.x
									  positionY:l_position.y
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE(l_angle) + 180.
								rotationCenterX:l_stickPosition.x
								rotationCenterY:l_stickPosition.y
								   repeatNumber:1
								  widthOnHeight:1.f / 60.f
									 nightBlend:false
									deformation:0.f
									   distance:50.f
                                         decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_SHADOW
										reverse:REVERSE_NONE
	 ];
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
										   plan:l_planIndex 
										   size:m_size * 1.4
									  positionX:m_position.x
									  positionY:m_position.y
									  positionZ:0.5
								  rotationAngle:0.
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:45.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_SHADOW
										reverse:REVERSE_NONE
	 ];
	
	int l_texture;
	if(m_timerPause < 0.)
	{
		if(m_timerPause < -2.f)
		{
			m_timerPause = TIMER_BETWEEN_PAUSE * (0.8 + 0.2 * (myRandom() + 1.f) / 2.f);
		}
			
		l_texture = s_texturePause;
	}
	else
	{
		l_texture = [s_animation GetCurrentFrame];
	}

	[[EAGLView sharedEAGLView] drawTextureIndex:l_texture
										   plan:l_planIndex 
										   size:m_size * s_sizeWing
									  positionX:m_position.x
									  positionY:m_position.y
									  positionZ:0.5
								  rotationAngle:s_angle
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:45.f
										 decayX:0.f
										 decayY:0.f
										  alpha:0.6f
										 planFX:PLAN_BACKGROUND_SHADOW
										reverse:REVERSE_NONE
	 ];
}

-(void)SetAttractorPosition:(CGPoint)a_position
{
    m_attractorPosition = a_position;
}

-(void)SetStrenghtAttractor:(float)a_strength
{
    m_strengthAttractor = a_strength;
}

+(void)Terminate
{
    [ParticleLetter Reset];
	[s_animation stopAnimation];
}

+(void)SetPosition:(CGPoint)a_position
{
	s_currentPosition = a_position;
}

+(void)Reset
{
    for(int i = 0; i < [s_arrayGroup count]; i++)
	{
        [[s_arrayGroup objectAtIndex:i] reset];
    }
}

+(BOOL)SetAttractionPoint:(int)a_groupIndex position:(CGPoint)a_position
{
	BOOL l_error = YES;
	ParticleLetterGroup * l_group;
	for(int i = 0; i < [s_arrayGroup count]; i++)
	{
		l_group = [s_arrayGroup objectAtIndex:i];
		if([l_group m_index] == a_groupIndex)
		{
			l_group.m_attractionPosition = a_position;
			l_error = NO;
		}
	}
	
	return !l_error;
}

+(BOOL)SetGroupStatus:(int)a_groupIndex attractionCommon:(BOOL)a_attractionCommon goAway:(BOOL)a_goAway
{
	BOOL l_error = YES;
	ParticleLetterGroup * l_group;
	for(int i = 0; i < [s_arrayGroup count]; i++)
	{
		l_group = [s_arrayGroup objectAtIndex:i];
		if([l_group m_index] == a_groupIndex)
		{
			l_group.m_attractorCommon = a_attractionCommon;
			l_group.m_goAway = a_goAway;
			l_error = NO;
		}
	}
	
	return !l_error;
}

+(BOOL)SetSize:(float)a_size group:(int)a_group
{
	BOOL l_error = YES;
	ParticleLetterGroup * l_group;
	for(int i = 0; i < [s_arrayGroup count]; i++)
	{
		l_group = [s_arrayGroup objectAtIndex:i];
		if([l_group m_index] == a_group)
		{
			l_group.m_size = a_size;
			l_error = NO;
		}
	}
	
	return !l_error;
}

+(void)Space
{
	s_currentPosition.x += s_decay;
}

@end