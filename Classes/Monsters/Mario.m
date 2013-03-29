//
//  Mario.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Mario.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"

#define GRAVITY 1.81
#define MARIO_SPEED_MAX 5.
#define SIZE 0.5f
#define DEFORMATION_FORCE 0.05
#define DEFORMATION_FRICTION 0.4
#define TIMER_BETWEEN_EYE_BLINKING 3.
#define TIMER_BETWEEN_EYE_BLINKING_VARIANCE 2.
#define BLINK_DURATION 0.1
#define EYES_SPEED 80.f

@implementation Mario

@synthesize m_position;
@synthesize m_speed;

// init.
-(id)init:(CGPoint)a_position 
				groundY:(float)a_groundY 
				animation:(Animation *)a_animation 
				bodyTexture:(int)a_bodyTexture
				fallTexture:(int)a_fallTexture
				fallSize:(float)a_fallSize				
{
	m_position = a_position;
	m_speed = CGPointMake(0., 0.f);
	m_groundY = a_groundY;
	m_animation = a_animation;
	m_bodyTexture = a_bodyTexture;
	[m_animation startAnimation];
	m_texture = a_fallTexture;
	m_fallTexture = a_fallTexture;
	m_fallSize = a_fallSize;
	m_widthOnHeight = 1.f;
	m_widthOnHeightGoal = 1.f;
	m_widthOnHeightSpeed = 0.f;
	
	m_eyesAngle = 0.f;
	m_eyesClosed = NO;
	m_eyesTimer = 0.;
	m_eyesNextBlink = 0.;
	m_eyesMoveTimer = 0.;
	m_eyesNextMove = 0.;
	
	m_oraTimer = 0.;
	
	if(a_position.y > a_groundY)
	{
		m_falling = YES;
	}
	m_deformation = 0.f;
	m_deformationSpeed = 0.2f;
	m_size = m_fallSize;
	m_block = NO;
	return [super init];
}

// update.
-(void)Update:(NSTimeInterval)a_timeInterval position:(CGPoint)a_nextPosition
{
	[self UpdateEyes:a_timeInterval];
	
	m_oraTimer += a_timeInterval;
	float previousPosition = m_position.x;
	if(m_position.y > m_groundY)
	{
		m_speed.y -= GRAVITY * a_timeInterval;
		m_position.x += m_speed.x * 0.1;
		m_position.y += m_speed.y * a_timeInterval;
		m_texture = m_fallTexture;
		m_size = SIZE * m_fallSize;
	}
	else if(a_nextPosition.x != m_position.x || m_falling)
	{
		if(m_falling)
		{
			[[[ApplicationManager sharedApplicationManager] GetState] Event2:0.f];
			m_falling = NO;
		}
		m_position.y = m_groundY;
		m_speed.y = 0.f;
		m_speed.x = (a_nextPosition.x - m_position.x) / a_timeInterval;
		m_speed.x = clip(m_speed.x, -MARIO_SPEED_MAX, MARIO_SPEED_MAX);
		m_position.x += m_speed.x * a_timeInterval;
		[m_animation setAnimationInterval:min(Absf(1. / m_speed.x), 1.)];
		if(Absf(m_speed.x) > EPSILON)
		{
			m_texture = [m_animation GetCurrentFrame];
		}

		m_size = SIZE;
	}
	else
	{
		m_speed = CGPointMake(m_speed.x > 0.f ? EPSILON : -EPSILON, 0.f);
	}
	
	m_deformationSpeed += -DEFORMATION_FORCE * (m_position.x - previousPosition + m_deformation * m_size) / (m_size * a_timeInterval);
	m_deformationSpeed *= 1.f - a_timeInterval * DEFORMATION_FRICTION;
	m_deformation += m_deformationSpeed * a_timeInterval;
	m_deformation = clip(m_deformation, -1.f, 1.f);
	
	m_widthOnHeightGoal = pow(m_size / clip((a_nextPosition.y - m_groundY), m_size / 1.5 , m_size * 3.f), 2.f);
	m_widthOnHeightSpeed = 9.f * (m_widthOnHeightGoal - m_widthOnHeight);
	m_widthOnHeight += m_widthOnHeightSpeed * a_timeInterval;
}

-(void)draw
{
	if(m_falling)
	{
		[[EAGLView sharedEAGLView] drawTextureIndex:m_fallTexture
											   plan:PLAN_PENDULUM
											   size:m_size
										  positionX:m_position.x
										  positionY:m_position.y
										  positionZ:0.
									  rotationAngle:0.
									rotationCenterX:m_position.x
									rotationCenterY:m_position.y
									   repeatNumber:1
									  widthOnHeight:1.f
										 nightBlend:false
										deformation:0.f
										   distance:-1.f
											 decayX:0.f
											 decayY:0.f
											  alpha:1.f
											 planFX:-1
											reverse:REVERSE_NONE
		 ];
		return;
	}
	ReverseType l_reverseType = (m_speed.x > 0) ? REVERSE_NONE : REVERSE_HORIZONTAL;
	m_sizeWithDeformation = m_size / sqrt(m_widthOnHeight);
	float l_positionY = m_position.y + 0.5 * (m_sizeWithDeformation - m_size);
	CGPoint l_position;
	float l_deformation = m_deformation - .3 * m_speed.x / MARIO_SPEED_MAX;
	
	if(m_block)
	{
		l_position = m_blockPosition;
	}
	else
	{
		l_position = m_position;
	}


	float l_coeff = 0.5f;
	float l_eyesSize = m_size + (m_sizeWithDeformation - m_size) * l_coeff * 0.7f;
	if(!m_eyesClosed)
	{
		float l_angle = l_reverseType == REVERSE_NONE ? m_eyesAngle : -m_eyesAngle;
		float l_xDecay = Absf(sin(DEGREES_TO_RADIANS(max(0.f, m_eyesAngle)))) * 0.5 * m_size;
		l_xDecay = l_reverseType == REVERSE_NONE ? l_xDecay : -l_xDecay;
		
		[[EAGLView sharedEAGLView] drawTextureIndex:[m_animation GetCurrentFrame]
									  plan:PLAN_PENDULUM
									  size:l_eyesSize
								 positionX:l_position.x + (l_xDecay - l_deformation * m_size * 0.5) * m_widthOnHeight
								 positionY:l_positionY + l_coeff * (l_positionY - m_position.y)
								 positionZ:0.
							 rotationAngle:l_angle
						   rotationCenterX:l_position.x
						   rotationCenterY:l_positionY + l_coeff * (l_positionY - m_position.y)
							  repeatNumber:1
							 widthOnHeight:1.f + (m_widthOnHeight - 1.f) * l_coeff
								nightBlend:false
								deformation:1.f + (m_speed.x > 0 ? (l_deformation - 1.f) : l_deformation - 3.f) * l_coeff
								  distance:-1.f
									decayX:0.f
									decayY:0.f
									 alpha:1.f
									planFX:-1
								   reverse:l_reverseType
		 ];
	}
	
//	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_LARVE_MARIO_ORA
//										   plan:PLAN_PENDULUM
//										   size:m_sizeWithDeformation
//									  positionX:l_position.x
//									  positionY:l_positionY
//									  positionZ:0.
//								  rotationAngle:0.f
//								rotationCenterX:l_position.x
//								rotationCenterY:l_position.x
//								   repeatNumber:1
//								  widthOnHeight:m_widthOnHeight
//									 nightBlend:false
//									deformation:l_deformation * 1.1
//									   distance:-1.f
//										 decayX:0.f
//										 decayY:0.f
//										  alpha:0.1 + (0.4 - 0.4 * Absf(cos(m_oraTimer)))
//										 planFX:-1
//										reverse:REVERSE_NONE
//	 ];
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_bodyTexture
										   plan:PLAN_PENDULUM
										   size:m_sizeWithDeformation
									  positionX:l_position.x
									  positionY:l_positionY
									  positionZ:0.
								  rotationAngle:0.
								rotationCenterX:l_position.x
								rotationCenterY:l_position.y
								   repeatNumber:1
								  widthOnHeight:m_widthOnHeight
									 nightBlend:false
									deformation:l_deformation
									   distance:-1.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:-1
										reverse:l_reverseType
	 ];
}

-(void)UpdateEyes:(NSTimeInterval)a_timeInterval
{
	m_eyesTimer += a_timeInterval;
	m_eyesMoveTimer += a_timeInterval;
	if(m_eyesTimer > m_eyesNextBlink)
	{
		if(m_eyesTimer > m_eyesNextBlink + BLINK_DURATION)
		{
			m_eyesClosed = NO;
			m_eyesTimer = 0.f;
			m_eyesNextBlink = TIMER_BETWEEN_EYE_BLINKING + myRandom() * TIMER_BETWEEN_EYE_BLINKING_VARIANCE;
		}
		else
		{
			m_eyesClosed = YES;
		}
	}

	if(m_eyesMoveTimer > m_eyesNextMove)
	{
		m_eyesMoveTimer = 0.f;
		m_eyesNextMove = TIMER_BETWEEN_EYE_BLINKING + myRandom() * TIMER_BETWEEN_EYE_BLINKING_VARIANCE;
		m_eyesAngle = myRandom() * 20.f;
	}
}

-(void)SetPosition:(CGPoint)a_position timeInterval:(NSTimeInterval)a_timeInterval
{
	m_speed.x = clip((a_position.x - m_position.x) / a_timeInterval, -MARIO_SPEED_MAX / 2.f, MARIO_SPEED_MAX / 2.f);
	m_speed.y = clip((a_position.y - m_position.y) / a_timeInterval, -MARIO_SPEED_MAX / 2.f, MARIO_SPEED_MAX / 2.f);
	m_position = a_position;
}

-(CGPoint)GetPositionShoulder
{
	return CGPointMake(m_position.x - m_deformation * m_size / 2.f, m_position.y + 0.7 * (m_sizeWithDeformation - m_size));	
}

-(CGPoint)GetPositionShoulderScreen
{
	return CGPointMake(m_blockPosition.x - m_deformation * m_size / 2.f, m_position.y + 0.7 * (m_sizeWithDeformation - m_size));		
}

-(void)Block:(BOOL)a_block
{
	m_block = a_block;
	m_blockPosition = m_position;
}

// update.
-(oneway void)release
{
	[m_animation release];
}

@end
