//
//  Particle.h
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// CAMERA_CLOSE : Camera close to the snake.
// CAMERA_GLOBAL : Camera wich takes the bigest space.
// CAMERA_LOSE : Camera when we lose.
// CAMERA_PAUSE : Camera when pause.
// CAMERA_NUMBE : number of camera.
typedef enum EnumParticleGroup
{ 
	PARTICLE_GROUP_LUCIOLE,
	PARTICLE_GROUP_LUCIOLE_SPECIAL,
	PARTICLE_GROUP_LUCIOLE_NEXT_GENERATION,
	PARTICLE_GROUP_CLOUD,
	PARTICLE_GROUP_BEAST,
	PARTICLE_GROUP_MONSTER_THEATRE,
	PARTICLE_GROUP_COUNT
}ParticleGroup;

@interface Particle : NSObject 
{
	@public
	ParticleGroup   m_group;
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
	int				m_plan;
	float			m_distance;
	CGPoint			m_position;
	CGPoint			m_speed;
	float			m_size;
	NSTimeInterval	m_lifetime;
	NSTimeInterval	m_lifeTimeInit;
	int				m_texture;
	Particle		*next;
	Particle		*prev;	
	
	int				m_particleId;
}

@property (nonatomic, retain) Particle			*next;
@property (nonatomic, retain) Particle			*prev;
@property					  NSTimeInterval	m_lifetime;
@property					  ParticleGroup		m_group;
@property					  CGPoint			m_position;
@property					  int				m_texture;
@property					  float				m_size;

// update particles positions, put dead ones in the basket and get out new ones.
-(void)UpdateWithTimeInterval:(float)a_timeInterval;

// draw each partcicle as a circle
-(void)draw;

-(CGPoint)GetDisplayPosition;

-(void)kill;

@end
