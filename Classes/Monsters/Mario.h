//
//  Mario.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Animation.h"


@interface Mario : NSObject 
{
	CGPoint m_position;
	CGPoint	m_speed;
	float	m_groundY;
	Animation * m_animation;
	int		m_texture;
	float	m_size;
	float	m_sizeWithDeformation;
	
	int		m_bodyTexture;
	int		m_fallTexture;
	float	m_fallSize;
	
	BOOL	m_block;
	CGPoint	m_blockPosition;
	
	float	m_eyesAngle;
	NSTimeInterval m_eyesMoveTimer;
	NSTimeInterval m_eyesNextMove;
	BOOL m_eyesClosed;
	NSTimeInterval m_eyesTimer;
	NSTimeInterval m_eyesNextBlink;
	
	NSTimeInterval		m_oraTimer;
	
	float m_deformation;
	float m_deformationSpeed;
	
	float m_widthOnHeight;
	float m_widthOnHeightSpeed;
	float m_widthOnHeightGoal;
	
	BOOL m_falling;
}

@property CGPoint m_position;
@property CGPoint m_speed;

// init.
-(id)init:(CGPoint)a_position 
  groundY:(float)a_groundY 
animation:(Animation *)a_animation 
bodyTexture:(int)a_bodyTexture
fallTexture:(int)a_fallTexture
 fallSize:(float)a_fallSize;

// update.
-(void)Update:(NSTimeInterval)a_timeInterval position:(CGPoint)a_nextPosition;
// update eyes blinking and position.
-(void)UpdateEyes:(NSTimeInterval)a_timeInterval;

-(void)SetPosition:(CGPoint)a_position timeInterval:(NSTimeInterval)a_timeInterval;

-(void)Block:(BOOL)a_block;

// return the position of the shoulder in non blocked world.
-(CGPoint)GetPositionShoulder;
// return the displayed position of the shoulder.
-(CGPoint)GetPositionShoulderScreen;

-(void)draw;

@end
