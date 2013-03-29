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

@interface ParticleLetterGroup : NSObject
{
	int		m_index;
	CGPoint m_attractionPosition;
	BOOL	m_attractorCommon;
	BOOL	m_goAway;
	float	m_size;
}

-(void)reset;

@property int m_index;
@property CGPoint m_attractionPosition;
@property BOOL m_attractorCommon;
@property BOOL m_goAway;
@property float m_size;

@end


@interface ParticleLetter : Particle 
{
	int				m_groupLetterIndex;
	CGPoint			m_attractorPosition;
	float			m_strengthAttractor;
	float			m_angle;
	bool			m_isDead;
	NSTimeInterval  m_timerPause;
	ParticleLetterGroup * m_particleLetterGroup;
	int				m_textureStick;
	
	PhysicPendulum * m_stick;
}

-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick groupIndex:(int)a_groupIndex;
-(id)initWithTexture:(int)a_texture textureStick:(int)a_textureStick groupIndex:(int)a_groupIndex initPosition:(CGPoint)a_position;

+(void)GlobalInit:(Animation *)a_animation 
			angle:(float)a_angle 
	 texturePause:(int)a_texturePause 
		 sizeWing:(float)a_sizeWing;

+(void)GlobalInit:(Animation *)a_animation
			angle:(float)a_angle
	 texturePause:(int)a_texturePause
		 sizeWing:(float)a_sizeWing
            block:(BOOL)a_block;

// update particles positions, put dead ones in the basket and get out new ones.
-(void)UpdateWithTimeInterval:(float)a_timeInterval;

// draw each partcicle as a circle
-(void)draw;

// computation of the force applied on the particle
-(CGPoint)AttractorsInfluenceOn;

// Set the position of the attractor of the letter.
-(void)SetAttractorPosition:(CGPoint)a_position;

-(void)SetStrenghtAttractor:(float)a_strength;

+(void)SetPosition:(CGPoint)a_position;

+(void)Space;

+(void)Terminate;
// Set the paramerters of a group.
+(BOOL)SetGroupStatus:(int)a_groupIndex attractionCommon:(BOOL)a_attractionCommon goAway:(BOOL)a_goAway;
// Set the common attraction point of a group.
+(BOOL)SetAttractionPoint:(int)m_groupIndex position:(CGPoint)a_position;
// Set the size of a group.
+(BOOL)SetSize:(float)a_size group:(int)a_group;
// reint each group.
+(void)Reset;

@end

;
