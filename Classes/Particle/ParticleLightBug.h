//
//  Particle.h
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"

@interface ParticleLightBug : Particle 
{
	// Definition of the particle
	// position : position of the particle in Gl Coord.
	// speed	: speed of the particle in Gl Coord.
	// size		: size and mass of the particle.
	// lifeTime	: Duration of the particle before dying.
	// id		: Index of the particle.
	// texture	: Texture of the particle.
	// m_groupIndexSelf : its group index.
	// m_groupIndexEnemy : group index of the enemy (attract this group).
	// m_groupIndexFood : group index of the food (attracted by this group).
	// m_visionLength : length of reactivity to self, enemy and then food.
	// m_force		: force applied by self group, enemy, food, and some element in the environnement.
	// next and prev : previous and next particle. nil if none.
	float			m_forceElementInit;
	float			m_timeIntervalBite;
	float			m_lastBite;	
	float			m_reproductionLevel;
	float			m_reproductionSpeed;
	float			m_angle;
	bool			m_isDead;
	CGPoint			m_decay;
}

// update particles positions, put dead ones in the basket and get out new ones.
-(void)UpdateWithTimeInterval:(float)a_timeInterval;

// draw each partcicle as a circle
-(void)draw;

// computation of the force applied on the particle
-(CGPoint)AttractorsInfluenceOn;

//	Computation of the strength applied on a particle by the snake.
-(CGPoint)SnakeInfluenceOn;	

//	Computation of the strength applied on a particle by the snake.
-(CGPoint)SnakeInfluenceOnAttractive;	

// display help.
-(void)CallHelp;

+(void)GlobalInit;

@end

@interface ParticleLightBugSpecial : ParticleLightBug
{
	
}
@end

@interface ParticleRose : ParticleLightBug
{
	float m_sizeCoeff;
	float m_distanceCoeff;
}

-(id)initWithTexture:(int)a_texture;
-(id)initWithTexture:(int)a_texture size:(float)a_size;
-(void)SetDistanceParticle:(float)a_heraticCoeff;
+(void)SetGroundY:(float)a_groundY;
+(void)SetHeraticCoeff:(float)a_heraticCoeff;
+(void)SetDistance:(float)a_distance;
+(void)SetXTranslate:(float)a_xTranslate;

@end

@interface ParticleLightBugNextGeneration : ParticleRose
{
	BOOL m_behind;
	BOOL m_isAfraid;
	
	CGPoint m_positionAttractor;
}

-(id)initWithTexture:(int)a_texture size:(float)a_size position:(CGPoint)a_position;
-(CGPoint)UpdateAttraction;
+(void)SetPositionTarget:(CGPoint)a_position;

@end
;
