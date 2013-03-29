//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "ParticleLightBug.h"
#import	"MathTools.h"
#import	"AttractorsPositions.h"
#import "PhysicPendulum.h"
#import "OpenALManager.h"
#import "StateLucioles.h"
#import "StateLarve.h"
#import "ApplicationManager.h"

#define			PARTICULE_SIZE_MIN			0.02f
#define			PARTICULE_SIZE_MAX			0.03f
#define			SPEED_COEFF					1.f			// Module of the speed vector
#define			SPEED_VAR					0.15f		// carreful! this variance is used as a percentage of the speed
#define			LIFE_TIME					120.		// Relative value of the initial life time of the particles
#define			LIFE_TIME_VAR				10.5		// Variance of the particles's life time
#define			SIZE						(PARTICULE_SIZE_MIN + PARTICULE_SIZE_MAX) * 0.5f // Relative size of the particles
#define			SIZE_VAR					SIZE * 0.2f	// Variance of this size
#define			TIME_INTERVAL_BITE			1.7f		// Time interval between two bite.
#define			ATTRACTOR_COEFF				.0015		// value of the attractor force applied on particles
#define			TIME_BEFORE_CLOSE_STATE		7.f
#define			TIME_BETWEEN_CROK   0.5f		// Time between two crok from the pendulum.


@implementation ParticleLightBug

static CGPoint			*s_AttractorArray;			// container for attractor Positions.
static int				s_numAttractor;				// number of attractors.
static NSTimeInterval	s_pendulumCanEatAtTime = 0;
static NSTimeInterval	s_timeSinceNoMoreNormalParticle = 0;
static BOOL				s_transformation = false;

//
// initialization of a particle
//
-(id)init
{
	[super init];
	
	m_position.x	= myRandom() * 2.5;
	m_position.y	= myRandom() * 1.5;
	m_speed.x		= 0.f;
	m_speed.y		= 0.f;
	m_lifeTimeInit = LIFE_TIME + myRandom() * LIFE_TIME_VAR;
	m_lifetime		= m_lifeTimeInit * (myRandom() + 1.4f) / 2.f;
	m_size			= SIZE + myRandom() * SIZE_VAR;
	m_timeIntervalBite = m_timeIntervalBite + myRandom() * m_timeIntervalBite * 0.1f;
	m_lastBite			= 0;
	m_reproductionLevel = (myRandom() + 1.) * 15.;
	m_texture = TEXTURE_LUCIOLE_1;
	m_distance = 0.f;
	m_group = PARTICLE_GROUP_LUCIOLE;
	m_isDead = false;
	m_particleId = (int)((myRandom() + 1.f) * 500.f);
	m_angle = myRandom() * 180.;
	m_decay = CGPointMake(0.f, 0.f);
	return self;
}

+(void)GlobalInit
{
	s_numAttractor = 0;
	s_transformation = NO;
	s_pendulumCanEatAtTime = 0;
	s_timeSinceNoMoreNormalParticle = 0;
	
	for(int i = 0; i < width * height; i++)
	{
		if(Luli[i] == 0)
		{
			s_numAttractor++;
		}
	}
	
	int l_attracorArrayIndex = 0;
	s_AttractorArray = (CGPoint*)malloc(s_numAttractor * sizeof(CGPoint));
	float l_heraticX = 0.f;
	float l_heraticY = 0.f;
	for(int iy = 0; iy < height ; iy++)
	{
		for(int ix = 0; ix < width; ix++)
		{
			if(Luli[iy * width + ix] == 0)
			{
				l_heraticX = myRandom() * 0.04f;
				l_heraticY = myRandom() * 0.04f;
				
				// TODO :  set the 1.5 with EAGL repére.
				s_AttractorArray[l_attracorArrayIndex].x = ((((float)ix / (float)width) * 3.f) - 1.5f) + l_heraticX;
				s_AttractorArray[l_attracorArrayIndex].y = -((((float)iy / (float)height) * 2.f) - 1.f) + l_heraticY;
				l_attracorArrayIndex ++;
			}
		}
	}	
}


//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	CGPoint		attractorForce; 
	CGPoint		l_snakeForce; 
	m_lifetime -= s_transformation ? 8.f * a_timeInterval : a_timeInterval;
	if((m_lifetime < 0.f) && (m_texture == TEXTURE_LUCIOLE_2) && !s_transformation)
	{
		[self performSelector:@selector(CallHelp) withObject:nil afterDelay:12.];
	}
	
	if(s_transformation && (m_lifetime <= 0))
	{
		m_isDead = true;
		m_lifetime = 3000.f;
		[[OpenALManager sharedOpenALManager] playSoundWithKey:@"eclosion" Volume:.5f];
	}
	
	if(m_distance <= 1.f)
	{
		m_distance += a_timeInterval / 8.f;	
	}

	float l_heraticSize = 4.f * a_timeInterval * m_size * myRandom();
	m_size			=	m_size + l_heraticSize;
	m_size = max(m_size, PARTICULE_SIZE_MIN);
	m_size = min(m_size, PARTICULE_SIZE_MAX);
		
		float l_heraticX = myRandom() * 0.1 * m_distance;
		float l_heraticY = myRandom() * 0.1 * m_distance;
		m_position.x += (m_speed.x + l_heraticX) * a_timeInterval;
		m_position.y += (m_speed.y + l_heraticY) * a_timeInterval;
		
		if(((m_position.x * m_position.x) + (m_position.y * m_position.y)) > 15.f)
		{
			m_position.x = m_position.x / 1.3f;
			m_position.y = m_position.y / 1.3f;
			m_speed.x = m_speed.y = 0.f;
		}
		
		if(s_transformation && m_isDead)
		{
			attractorForce				= CGPointMake(0.f, 0.f);
			l_snakeForce				= [self SnakeInfluenceOnAttractive];
		}
		else
		{
			s_timeSinceNoMoreNormalParticle = [NSDate timeIntervalSinceReferenceDate];
			attractorForce				= [self AttractorsInfluenceOn];
			l_snakeForce				= [self SnakeInfluenceOn];
		}
	
		if(s_timeSinceNoMoreNormalParticle < [NSDate timeIntervalSinceReferenceDate] - TIME_BEFORE_CLOSE_STATE)
		{
			[[[ApplicationManager sharedApplicationManager] GetState] Event3:0];
		}
		
		l_heraticX = myRandom() * 0.002 * m_distance;
		l_heraticY = myRandom() * 0.002 * m_distance;
		m_speed.x	+= ((attractorForce.x + l_snakeForce.x + l_heraticX) / m_size); 
		m_speed.y	+= ((attractorForce.y + l_snakeForce.y + l_heraticY) / m_size);
		
		m_speed.x = m_speed.x * 0.976;
		m_speed.y = m_speed.y * 0.976;
		m_lastBite += a_timeInterval;
}

// call help.
-(void)CallHelp
{
	[[ApplicationManager sharedApplicationManager] SetHelp:@"helpShake.png"];
}

//
//	Computation of the strength applied on a particle by the attractors
//
-(CGPoint)AttractorsInfluenceOn
{	
	float l_xdistance, l_xdistanceTemp, l_ydistance, l_ydistanceTemp, l_tempAbsDistance;
	float AbsDistance = 20.f;
	float l_xforce = 0.;
	float l_yforce = 0.;
	
	float l_xAttractor, l_yAttractor;
	for(int i = 0; i < s_numAttractor; i++)
	{
		l_xAttractor = s_AttractorArray[i].x;
		l_yAttractor = s_AttractorArray[i].y;
		l_xdistanceTemp		=	m_position.x - l_xAttractor;
		l_ydistanceTemp		=	m_position.y - l_yAttractor;
		l_tempAbsDistance	=	l_xdistanceTemp*l_xdistanceTemp + l_ydistanceTemp*l_ydistanceTemp;
		if(l_tempAbsDistance < AbsDistance)
		{
			l_xdistance = l_xdistanceTemp;
			l_ydistance = l_ydistanceTemp;
			AbsDistance = l_tempAbsDistance;
			
		}
	}
	
	AbsDistance = (AbsDistance < 0.025) ? 0.025 : AbsDistance;
	l_xforce			+=	-0.45 * ATTRACTOR_COEFF * l_xdistance * pow(m_distance, 3.) / AbsDistance;   
	l_yforce			+=	-0.45 * ATTRACTOR_COEFF * l_ydistance * pow(m_distance, 3.)/ AbsDistance;  
	
	return Vector2DMake(l_xforce, l_yforce);
}

//
//	Computation of the strength applied on a particle by the snake
//
-(CGPoint)SnakeInfluenceOnAttractive
{	
	PhysicPendulum		*l_currentPendulum;// = nil;
	NSMutableArray * l_snakeArray = [PhysicPendulum GetList];
	int	l_arraySize = [l_snakeArray count];
	float xdistance, ydistance, l_absDistance;
	float xforce = 0.;
	float yforce = 0.;
	CGPoint l_position;
	int i = (m_particleId % (l_arraySize - 1)) + 1;
	
	l_currentPendulum = [l_snakeArray objectAtIndex:i];
	l_position = [l_currentPendulum GetPosition];
	xdistance		=	m_position.x - l_position.x + m_decay.x;
	ydistance		=	m_position.y - l_position.y + m_decay.y;

	l_absDistance		=	xdistance*xdistance + ydistance*ydistance;
	// DEBUG
	l_absDistance = clip(l_absDistance, 0.23, 1.f);
	
	if(l_absDistance > 0.15)
	{
		xforce -= (1.47f * ATTRACTOR_COEFF * xdistance) /pow(l_absDistance, 1.); 
		yforce -= (1.47f * ATTRACTOR_COEFF * ydistance) /pow(l_absDistance, 1.); 
	}
	return Vector2DMake(xforce, yforce);
}

//
//	Computation of the strength applied on a particle by the snake
//
-(CGPoint)SnakeInfluenceOn
{	
	PhysicPendulum		*l_currentPendulum;// = nil;
	NSMutableArray * l_snakeArray = [PhysicPendulum GetList];
	int	l_arraySize = [l_snakeArray count];
	float xdistance, ydistance, l_absDistance;
	float xforce = 0.;
	float yforce = 0.;
	CGPoint l_position;
	int i = 1;
	
	l_currentPendulum = [l_snakeArray objectAtIndex:i];
	l_position = [l_currentPendulum GetPosition];
	xdistance		=	m_position.x - l_position.x;
	ydistance		=	m_position.y - l_position.y;
	l_absDistance		=	xdistance*xdistance + ydistance*ydistance;
	NSTimeInterval l_timeSinceReference = [NSDate timeIntervalSinceReferenceDate];
	if(l_absDistance < 0.25f)
	{
		if((l_absDistance < (0.05f)) && (s_pendulumCanEatAtTime < l_timeSinceReference))
		{
			m_lifetime = -1.;
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"crok" Volume:0.7f];
			[[[ApplicationManager sharedApplicationManager] GetState] Event1:0];
			if(m_texture == TEXTURE_LUCIOLE_2)
			{
				[[[ApplicationManager sharedApplicationManager] GetState] Event2:0];
				s_transformation = true;
			}
			s_pendulumCanEatAtTime = [NSDate timeIntervalSinceReferenceDate] + TIME_BETWEEN_CROK;
		}

		xforce += (2.05f * ATTRACTOR_COEFF * xdistance) /pow(l_absDistance, 1.); 
		yforce += (2.05f * ATTRACTOR_COEFF * ydistance) /pow(l_absDistance, 1.); 
	}
	else if(s_pendulumCanEatAtTime < l_timeSinceReference)
	{
		[[[ApplicationManager sharedApplicationManager] GetState] Event1:1];
	}
	i += 3;
	
	while (i < l_arraySize) 
	{
		l_currentPendulum = [l_snakeArray objectAtIndex:i];
		l_position = [l_currentPendulum GetPosition];
		xdistance		=	m_position.x - l_position.x;
		ydistance		=	m_position.y - l_position.y;
		l_absDistance		=	xdistance*xdistance + ydistance*ydistance;
		if(l_absDistance < 0.25f)
		{
			l_absDistance = (l_absDistance < 0.01) ? 0.01 : l_absDistance;
			xforce += (5.75f * ATTRACTOR_COEFF * xdistance) /pow(l_absDistance, 1.); 
			yforce += (5.75f * ATTRACTOR_COEFF * ydistance) /pow(l_absDistance, 1.); 
		}
		i += 3;
	}
	
	return Vector2DMake(xforce, yforce);
}

-(void)draw
{
	PlanIndex l_planIndex = (m_speed.x < 0) ? PLAN_PARTICLE_FRONT : PLAN_PARTICLE_BEHIND;
	
	if(s_transformation && m_isDead)
	{
		m_texture = TEXTURE_LUCIOLE_3;
	}

	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
										   plan:l_planIndex 
										   size:m_size * 3.5f / (m_distance + EPSILON)
									  positionX:m_position.x / (m_distance + EPSILON)
									  positionY:m_position.y / (m_distance + EPSILON)
									  positionZ:0.5
								  rotationAngle:m_angle
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:-1.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_PARTICLE_BEHIND
										reverse:REVERSE_NONE
	 ];
}

@end


@implementation ParticleLightBugSpecial

-(id)init
{
	[super init];
	
	m_position.x	= myRandom() * 1.;
	m_position.y	= myRandom() * 1.;
	m_speed.x		= 0.f;
	m_speed.y		= 0.f;
	m_lifeTimeInit = LIFE_TIME + myRandom() * LIFE_TIME_VAR;
	m_lifetime		= m_lifeTimeInit * (myRandom() + 1.4f) / 2.f;
	m_size			= 2.2 * SIZE + myRandom() * SIZE_VAR / 2.f;
	m_timeIntervalBite = m_timeIntervalBite + myRandom() * m_timeIntervalBite * 0.1f;
	m_lastBite			= 0;
	m_reproductionLevel = (myRandom() + 1.) * 15.;
	m_angle = myRandom() * 180.;
	m_texture = TEXTURE_LUCIOLE_2;
	m_distance = 0.f;
	m_group = PARTICLE_GROUP_LUCIOLE_SPECIAL;
	m_isDead = false;

	return self;
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	[super UpdateWithTimeInterval:a_timeInterval];
	float l_distance = DistancePoint(m_position, [[[PhysicPendulum GetList] objectAtIndex:1] GetPosition]);
	
	if(l_distance < 1.)
	{
		m_speed.x *= 0.9;
		m_speed.y *= 0.9;
	}
}

-(void)draw
{
	PlanIndex l_planIndex = (m_speed.x < 0) ? PLAN_PARTICLE_FRONT : PLAN_PARTICLE_BEHIND;
	
	if(s_transformation && m_isDead)
	{
		m_texture = TEXTURE_LUCIOLE_3;
	}
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
										   plan:l_planIndex 
										   size:m_size * 6.f / (m_distance + EPSILON)
									  positionX:m_position.x / (m_distance + EPSILON)
									  positionY:m_position.y / (m_distance + EPSILON)
									  positionZ:0.5
								  rotationAngle:m_angle
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:-1.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_PARTICLE_BEHIND
										reverse:REVERSE_NONE
	 ];
}

@end

@implementation ParticleRose

static float			s_groundY;
static float			s_heraticCoeff = 1.f;
static float			s_distance = -1.f;
static float			s_xTranslate = 0.f;

-(id)init
{
	return self;
}

-(id)initWithTexture:(int)a_texture
{
	return [self initWithTexture:a_texture size:1.f];
}

-(id)initWithTexture:(int)a_texture size:(float)a_size
{
	[super init];
	m_distance = 1.f;
	m_position = CGPointMake( -1.1f + 0.3 * myRandom(), 1.1f + 0.7 * myRandom() );
	m_texture = a_texture;
	m_decay.x = myRandom() * 0.15;
	m_decay.y = -0.08 + myRandom() * 0.15;
	m_sizeCoeff = a_size;
	m_distanceCoeff = 1.f;
	return self;
}

-(void)draw
{
	PlanIndex l_planIndex = (m_speed.x < 0) ? PLAN_PARTICLE_FRONT : PLAN_PARTICLE_BEHIND;
	
	float l_yPos = max(s_groundY + m_size * 3.5, m_position.y);
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture
										   plan:l_planIndex 
										   size:m_size * 3.5 * m_sizeCoeff
									  positionX:m_position.x + s_xTranslate
									  positionY:l_yPos
									  positionZ:0.5
								  rotationAngle:m_angle
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:s_distance * m_distanceCoeff
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_CLOSE
										reverse:REVERSE_NONE
	 ];
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	CGPoint		l_snakeForce; 
	
	float l_heraticSize = 4.f * a_timeInterval * m_size * myRandom();
	m_size			=	m_size + l_heraticSize;
	m_size = max(m_size, PARTICULE_SIZE_MIN);
	m_size = min(m_size, PARTICULE_SIZE_MAX);
	
	float l_heraticX = myRandom() * 0.1 * m_distance;
	float l_heraticY = myRandom() * 0.1 * m_distance;
	m_position.x += (m_speed.x + l_heraticX) * a_timeInterval;
	m_position.y += (m_speed.y + l_heraticY) * a_timeInterval;
	
	l_snakeForce				= [self SnakeInfluenceOnAttractive];
	
	l_heraticX = myRandom() * 0.002 * s_heraticCoeff * m_distance;
	l_heraticY = myRandom() * 0.002 * s_heraticCoeff * m_distance;
	m_speed.x	+= ((l_snakeForce.x + l_heraticX) / m_size); 
	m_speed.y	+= ((l_snakeForce.y + l_heraticY) / m_size);
	
	m_speed.x = m_speed.x * 0.97;
	m_speed.y = m_speed.y * 0.97;
	m_lastBite += a_timeInterval;
}

+(void)SetGroundY:(float)a_groundY
{
	s_groundY = a_groundY;
}

+(void)SetHeraticCoeff:(float)a_heraticCoeff
{
	s_heraticCoeff = a_heraticCoeff;
}

-(void)SetDistanceParticle:(float)a_heraticCoeff
{
	m_distanceCoeff = a_heraticCoeff;
}

+(void)SetDistance:(float)a_distance
{
	s_distance = a_distance;
}

+(void)SetXTranslate:(float)a_xTranslate
{
	s_xTranslate = a_xTranslate;
}

@end


@implementation ParticleLightBugNextGeneration

static CGPoint			s_positionTarget;
static int				s_indexChosen;

-(id)initWithTexture:(int)a_texture size:(float)a_size position:(CGPoint)a_position
{
	[super init];
	[super initWithTexture:a_texture size:a_size];
	m_position = a_position;
	m_position.y += Absf(myRandom()) * 0.2;
	m_positionAttractor = m_position;
	m_behind = (myRandom() < 0.f);
	m_isAfraid = NO;
	s_indexChosen = m_particleId;
	
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"craquement mystérieux" Volume:0.f];
	
	return self;
}

-(void)draw
{
	PlanIndex l_planIndex = m_behind ? PLAN_PENDULUM : PLAN_BACKGROUND_MIDDLE;
	
	float l_yPos = max(s_groundY + m_size * 2.5, m_position.y);
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture
										   plan:l_planIndex 
										   size:m_size * m_sizeCoeff
									  positionX:m_position.x - s_xTranslate
									  positionY:l_yPos
									  positionZ:0.5
								  rotationAngle:m_angle
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:s_distance * m_distanceCoeff
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_CLOSE
										reverse:REVERSE_NONE
	 ];
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{
	CGPoint		l_force; 
	
	float l_heraticSize = 4.f * a_timeInterval * m_size * myRandom();
	m_size			=	m_size + l_heraticSize;
	m_size = max(m_size, PARTICULE_SIZE_MIN);
	m_size = min(m_size, PARTICULE_SIZE_MAX);
	
	if(!m_isAfraid)
	{
		if(s_indexChosen == m_particleId)
		{
			[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"craquement mystérieux" Volume:0.7f * clip(1.f - 0.5 * Absf((m_position.x - s_xTranslate)), 0.f, 1.f)];
		}
		
		if(DistancePoint(m_position, CGPointMake(s_positionTarget.x + s_xTranslate, s_positionTarget.y)) < 0.8f)
		{
			m_isAfraid = YES;  
			m_speed.x += 0.5 * myRandom();
			m_speed.y += 0.5 * Absf(myRandom());
			if(s_indexChosen == m_particleId)
			{
				[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"treeFriction" Volume:0.6f];
				[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"treeFriction" Pitch:1.1f];
				[[OpenALManager sharedOpenALManager] FadeWithKey:@"craquement mystérieux" duration:1. volume:0.f stopEnd:YES];
				[[OpenALManager sharedOpenALManager] FadeWithKey:@"treeFriction" duration:1.5 volume:0.f stopEnd:NO];
			}
		}
		l_force				= [self SnakeInfluenceOnAttractive];
	}
	else
	{
		l_force				= [self UpdateAttraction];
	}
	
	float l_heraticX = myRandom() * 0.05 * m_distance * s_heraticCoeff;
	float l_heraticY = myRandom() * 0.05 * m_distance * s_heraticCoeff;
	m_position.x += (m_speed.x + l_heraticX) * a_timeInterval;
	m_position.y += (m_speed.y + l_heraticY) * a_timeInterval;
	
	if(m_position.y > 1.5f)
	{
		m_lifetime = -10.f;
	}
	
	l_heraticX = myRandom() * 0.002 * s_heraticCoeff * m_distance;
	l_heraticY = myRandom() * 0.002 * s_heraticCoeff * m_distance;
	m_speed.x	+= ((l_force.x * a_timeInterval + l_heraticX) / m_size); 
	m_speed.y	+= ((l_force.y * a_timeInterval + l_heraticY) / m_size);
	
	m_speed.x = m_speed.x * 0.97;
	m_speed.y = m_speed.y * 0.97;
	m_lastBite += a_timeInterval;
}

-(CGPoint)UpdateAttraction
{
	return CGPointMake(0.f, .01f);
}

//
//	Computation of the strength applied on a particle by the snake
//
-(CGPoint)SnakeInfluenceOnAttractive
{	
	float xforce = 0.;
	float yforce = 0.;
	CGPoint	l_position = m_positionAttractor;
	
	l_position = m_positionAttractor;
	float xdistance		=	m_position.x - l_position.x;
	float ydistance		=	m_position.y - l_position.y;
	
	float l_absDistance		=	xdistance*xdistance + ydistance*ydistance;
	// DEBUG
	l_absDistance = clip(l_absDistance, 0.23, 1.f);
	
	if(l_absDistance > 0.15)
	{
		xforce -= (1.47f * ATTRACTOR_COEFF * xdistance) /pow(l_absDistance, 1.); 
		yforce -= (1.47f * ATTRACTOR_COEFF * ydistance) /pow(l_absDistance, 1.); 
	}
	return Vector2DMake(xforce, yforce);
}

+(void)SetPositionTarget:(CGPoint)a_position
{
	s_positionTarget = a_position;
}

@end


