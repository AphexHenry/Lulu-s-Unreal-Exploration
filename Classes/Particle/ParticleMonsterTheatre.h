//
//  Particle.h
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Particle.h"
#import "Animation.h"
#import "PhysicPendulum.h"

@interface ParticleMonsterTheatre : Particle 
{
	CGPoint			m_attractorPosition;
	float			m_angle;
	int				m_textureStick;
	
	BOOL			m_killed;
	float			m_hitRotationGoal;
	float			m_hitRotationCurrent;
	float			m_hitRotationCurrentSpeed;
	float			m_rotationTurn;
	
	NSTimeInterval m_nextBiteTimer;
	NSTimeInterval  m_timer;
	
	PhysicPendulum * m_stick;
}

-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick;
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick initPosition:(CGPoint)a_position;

+(void)GlobalInit:(Animation *)a_animation angle:(float)a_angle texturePause:(int)a_texturePause;

// update particles positions, put dead ones in the basket and get out new ones.
-(void)UpdateWithTimeInterval:(float)a_timeInterval;

// draw each partcicle as a circle
-(void)draw;

// computation of the force applied on the particle
-(CGPoint)AttractorsInfluenceOn;

//
//	Computation of the strength applied on a particle when it is dead
//
-(CGPoint)KillInfluenceOn;

-(void)HitWithStrength:(float)a_strength;

+(void)SetPosition:(CGPoint)a_position;
+(CGPoint)GetPosition;

+(void)SetTargetPosition:(CGPoint)a_position;
+(CGPoint)GetTargetPosition;

+(void)Terminate;

@end
