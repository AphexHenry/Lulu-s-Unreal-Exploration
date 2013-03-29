//
//  Particle.m
//  Particles
//
//  Created by Baptiste Bohelay on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import			"ApplicationManager.h"
#import			"OpenALManager.h"
#import			"ParticleManager.h"
#import			"ParticleViewController.h"
#import			"PhysicPendulum.h"
#import			"EAGLView.h"
#import			"MathTools.h"
#import			"Particle.h"
#import			"ParticleLightBug.h"
#import			"ParticleCloud.h"

#define			NBMAXPARTICULE		300		// Total number of particles in the view.
#define			REPRODUCTION_LEVEL	100.f	// level of reproduction to reproduce.

@implementation ParticleManager

@synthesize m_activeparticlesBorders;

static ParticleManager* _sharedParticleManager = nil;

//
// initialize if not done yet and return the object
//
+(ParticleManager*)sharedParticleManager
{
	@synchronized([ParticleManager class])
	{
		if (!_sharedParticleManager)
			[[self alloc] init];
		return _sharedParticleManager;
	}
	return nil;
}

+(id)alloc
{
	@synchronized([ParticleManager class])
	{
		NSAssert(_sharedParticleManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedParticleManager = [super alloc];
		return _sharedParticleManager;
	}
	return nil;
}

//
//	initialization of all the variables
//
-(id)init
{
	[super init];

	ElementState * l_elementState = [[ElementState alloc] init];
	l_elementState.m_positionX = 0.7;
	l_elementState.m_positionY = 0.;
	m_timeFrame = 0.;

	[ParticleLightBug GlobalInit];
	
	m_activeparticlesBorders = nil;
	
	return self;
}

//
//	add a new particle in the basket.
//
-(void)AddParticle:(Particle *)a_newParticle
{
	a_newParticle.prev = NULL;
	a_newParticle.next = m_DeadParticlesBasket;
	if(m_DeadParticlesBasket != NULL)
	{
		m_DeadParticlesBasket.prev = a_newParticle;
	}
	m_DeadParticlesBasket = a_newParticle;
}

-(int)GetTextureWithPosition:(CGPoint)a_position
{
	Particle	*l_currentParticle, *l_nextParticle;
	l_currentParticle = m_activeparticlesBorders;
	while (l_currentParticle != NULL)
	{
		l_nextParticle = l_currentParticle.next;
		if(DistancePointSquare(a_position, l_currentParticle.m_position) < (4. * l_currentParticle.m_size * l_currentParticle.m_size))
		{
			return l_currentParticle.m_texture;
		}
		l_currentParticle = l_nextParticle;
	}
	return -1;
}

-(Particle *)GetParticleWithPosition:(CGPoint)a_position distanceMin:(float)a_distanceMin
{
	Particle	*l_currentParticle, *l_nextParticle;
	l_currentParticle = m_activeparticlesBorders;
	while (l_currentParticle != NULL)
	{
		l_nextParticle = l_currentParticle.next;
		if(DistancePointSquare(a_position, [l_currentParticle GetDisplayPosition]) < a_distanceMin)
		{
			return l_currentParticle;
		}
		l_currentParticle = l_nextParticle;
	}
	return nil;
}

// Kill all particles.
-(void)KillParticles
{
	[self ActiveDeadParticles];
	Particle	*l_currentParticle, *l_nextParticle;
	// Remove dead  bubbles Particles
	l_currentParticle = m_activeparticlesBorders;
	while (l_currentParticle != NULL)
	{
		l_nextParticle = l_currentParticle.next;
		[l_currentParticle release];
		l_currentParticle = l_nextParticle;
	}
	m_activeparticlesBorders = nil;
}

//
//	take the dead particles in the basket and reinitialize them
//	if the number exceeds the limite (see constants), we stop the rescue
//
-(void)ActiveDeadParticlesFromGroup:(ParticleGroup)a_group
{
	if(m_DeadParticlesBasket == nil)
	{
		return;
	}
	Particle *particle	= m_DeadParticlesBasket;
	Particle *nextparticle;	// point the next particle in the basket
	Particle *prevparticle;	// point the next particle in the basket
	Particle *particleFirst;	// point the first particle of the active container
	
	while(particle != nil)
	{
		if([particle m_group] != a_group)
		{
			particle = particle.next;
			continue;
		}
		nextparticle = particle.next;
		prevparticle = particle.prev;
		
		[particle init];
		
		particleFirst = m_activeparticlesBorders;
		
		if (nextparticle)
			nextparticle.prev = prevparticle;
		
		if (prevparticle)
			prevparticle.next = nextparticle;
		
		m_DeadParticlesBasket = nextparticle;
		
		particle.prev = nil;
		particle.next = particleFirst;
		if (particleFirst)
			particleFirst.prev = particle;
		m_activeparticlesBorders = particle;
		particle = nextparticle;
		if(particle == nil)
			break;
	}
}

//
//	take the dead particles in the basket and reinitialize them
//	if the number exceeds the limite (see constants), we stop the rescue
//
-(void)ActiveDeadParticles
{
	if(m_DeadParticlesBasket == nil)
	{
		return;
	}
	Particle *particle	= m_DeadParticlesBasket;
	Particle *nextparticle;	// point the next particle in the basket
	Particle *particleFirst;	// point the first particle of the active container
	
	while(particle != nil)
	{
		nextparticle = particle.next;
		
		[particle init];
		
		particleFirst = m_activeparticlesBorders;
		
		if (nextparticle)
			nextparticle.prev = NULL;
		m_DeadParticlesBasket = nextparticle;
		
		particle.prev = nil;
		particle.next = particleFirst;
		if (particleFirst)
			particleFirst.prev = particle;
		m_activeparticlesBorders = particle;
		particle = nextparticle;
		if(particle == nil)
			break;
	}
}

//
//	take the dead particles in the basket and reinitialize them
//	if the number exceeds a_num (see constants), we stop the rescue
//
-(void)ActiveDeadParticles:(int)a_num
{
	if(m_DeadParticlesBasket == nil)
	{
		return;
	}
	Particle *particle	= m_DeadParticlesBasket;
	Particle *nextparticle;	// point the next particle in the basket
	Particle *particleFirst;	// point the first particle of the active container
	
	while(particle != nil && (a_num > 0))
	{
		nextparticle = particle.next;
		
		[particle init];
		
		particleFirst = m_activeparticlesBorders;
		
		if (nextparticle)
			nextparticle.prev = NULL;
		m_DeadParticlesBasket = nextparticle;
		
		particle.prev = nil;
		particle.next = particleFirst;
		if (particleFirst)
			particleFirst.prev = particle;
		m_activeparticlesBorders = particle;
		particle = nextparticle;
		if(particle == nil)
			break;
		a_num--;
	}
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateParticlesWithTimeInterval:(float)a_timeInterval
{
	Particle	*currentparticle	= nil; 	// we point on the first element of the chain
	Particle	*nextparticle		= nil;
	m_timeFrame = a_timeInterval;
	SpacieStateCurrent l_groupState;
	
	// Remove dead particles

	currentparticle = m_activeparticlesBorders;
	while (currentparticle != NULL)
	{
		[currentparticle UpdateWithTimeInterval:a_timeInterval];
		nextparticle = currentparticle.next;

		if (currentparticle.m_lifetime < 0.f)
			[self PutItInTheBasket:currentparticle];
		currentparticle = nextparticle;
	}
	
	// Update of the alive particles.
	// initialization of the counts for this group.
	l_groupState.m_quantity = 0;
	l_groupState.m_generationMax = 0;
	l_groupState.m_numberOfGenerationMaxElement = 0;
	
	currentparticle = m_activeparticlesBorders;
}

//
//	put the dead particles in a trash.
// 
-(void)PutItInTheBasket:(Particle*)deadparticle
{	
	// Chained list insertion.
	Particle *particleNext = deadparticle.next;
	Particle *particlePrev = deadparticle.prev;
	
	if (particleNext)
		particleNext.prev = particlePrev;
	if (particlePrev)
		particlePrev.next = particleNext;
	if(particlePrev == NULL)
		m_activeparticlesBorders = particleNext;

	deadparticle.prev = NULL;	
	deadparticle.next = m_DeadParticlesBasket;
	if (m_DeadParticlesBasket)
		m_DeadParticlesBasket.prev = deadparticle;
	
	m_DeadParticlesBasket = deadparticle;
}

//
// particles drawing.
//
-(void)drawself
{
	Particle	*currentparticle	= nil; // point the first particle in the active container
	
	currentparticle = m_activeparticlesBorders;
	while(currentparticle != NULL)
	{
		[currentparticle draw];
		currentparticle = currentparticle.next;
	}
}

-(CGPoint)GetParticlesCenterFromGroup:(int)a_groupIndex
{
	Particle	*currentparticle	= nil; // point the first particle in the active container
	int l_count = 0;
	CGPoint l_position = CGPointMake(0.f, 0.f);
	
	currentparticle = m_activeparticlesBorders;
	while(currentparticle != NULL)
	{
		if(currentparticle.m_group == a_groupIndex)
		{
			l_count++;
			l_position.x += currentparticle.m_position.x;
			l_position.y += currentparticle.m_position.y;
		}
		currentparticle = currentparticle.next;
	}
	
	l_position.x = l_position.x / (float)l_count;
	l_position.y = l_position.y / (float)l_count;
	
	return l_position;
}

-(int)GetCountFromGroup:(int)a_groupIndex
{
	int l_count = 0;
	Particle	*currentparticle	= nil; // point the first particle in the active container
	currentparticle = m_activeparticlesBorders;
	while(currentparticle != NULL)
	{
		if(currentparticle.m_group == a_groupIndex)
		{
			l_count++;
		}
		currentparticle = currentparticle.next;
	}
	
	return l_count;
}

// dealloc.
- (void)dealloc 
{
	Particle * l_currentParticle;
	Particle * l_nextParticle;
	// Free dead  bubbles Particles
	l_currentParticle = m_activeparticlesBorders;
	while (l_currentParticle != NULL)
	{
		l_nextParticle = l_currentParticle.next;
		free(l_currentParticle);
		l_currentParticle = l_nextParticle;
	}
	// Free dead  bubbles Particles
	l_currentParticle = m_DeadParticlesBasket;
	while (l_currentParticle != NULL)
	{
		l_nextParticle = l_currentParticle.next;
		free(l_currentParticle);
		l_currentParticle = l_nextParticle;
	}
	
    [super dealloc];
}

@end
