//
//  Mario.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Animation.h"
#import "PhysicPendulum.h"


@interface BigMister : NSObject 
{
	CGPoint m_position;
	float	m_widthOnHeight;
	int		m_texture;
	float	m_size;
	float	m_step;
    BOOL    m_disapear;
    BOOL    m_dead;
    float   m_alpha;
    float   m_ySpeed;
    NSTimeInterval	m_timer;
	
	NSTimeInterval m_moveTimer;
	
	BOOL	m_isMoving;
}

// init.
-(id)initWithPosition:(CGPoint)a_position 
			  texture:(int)a_texture
		widthOnHeight:(float)a_widthOnHeight
				 size:(float)a_size
				 step:(float)a_step;

// update.
-(void)Update:(NSTimeInterval)a_timeInterval;

// return the position of the mister
-(CGPoint)GetPosition;

// make the monster disapear at the next step.
-(void)SetDisapear:(BOOL)a_disapear;

// Set the transparency of the mister.
-(void)SetAlpha:(float)a_alpha;

// Kill it.
-(void)SetDead;

// set the world translate.
+(void)SetDecay:(float)a_position;

+(void)SetPositionEnemy:(float)a_positionX;

@end

@interface BigMisterWithEye : BigMister 
{
	int		m_textureEye;
	CGPoint	m_positionEye;
	BOOL	m_idle;
	float	m_transition;
	
	int		m_awayCount;
	CGPoint m_positionExtension;
    CGPoint m_positionTongue;
    BOOL    m_openMouth;
    float   m_openMouthCoeff;
    float   m_tonguePositionRelative;
    
    BOOL    m_hit;
    
    NSTimeInterval m_moveDelay;
    PhysicPendulum * m_tonguePendulum;
}

-(id)initWithPosition:(CGPoint)a_position 
			  texture:(int)a_texture
		widthOnHeight:(float)a_widthOnHeight
				 size:(float)a_size
				 step:(float)a_step
		   textureEye:(int)a_textureEye;

// return the position of the eye.
-(CGPoint)GetPositionEye;
// Set idle.
-(void)SetIdle:(BOOL)a_value;
// Set the transition coefficient.
-(void)SetTransition:(float)a_transition;
// return the position of the thing we have to follow.
-(CGPoint)GetPositionExtention;
// return the position of the tongue.
-(CGPoint)GetPositionTongue;
// Open the mouth.
-(void)OpenMouth:(BOOL)a_openMouth;
// hit the mister.
-(void)Hit;

@end