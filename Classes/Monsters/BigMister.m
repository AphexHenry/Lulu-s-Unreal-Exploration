//
//  BigMister.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BigMister.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"
#import "OpenALManager.h"

#define SPEED 1.3f
#define DELAY_TO_MOVE 0.7
#define TONGUE_SPEED 0.85f

@implementation BigMister

static float s_decayX;
static float s_positionEnemy;


// init.
-(id)initWithPosition:(CGPoint)a_position 
			  texture:(int)a_texture
		widthOnHeight:(float)a_widthOnHeight
				 size:(float)a_size
				 step:(float)a_step
{
	m_position = a_position;
	m_widthOnHeight = a_widthOnHeight;
	m_texture = a_texture;
	m_isMoving = NO;
	m_size = a_size;
	m_step = a_step;
    m_disapear = NO;
    m_timer = 0.;
    m_alpha = 1.f;
    m_dead = NO;
    m_ySpeed = 0.f;
	
	return [super init];
}

// update.
-(void)Update:(NSTimeInterval)a_timeInterval
{
	float l_positionY = 0.f;
    m_timer += a_timeInterval;
   // float l_alpha = m_disapear ? 0.2f + 0.4f * cos(m_timer) : 1.f;
	if(!m_isMoving && (Absf(m_position.x + s_decayX - s_positionEnemy) < m_step))
	{
		m_isMoving = YES;
        [[OpenALManager sharedOpenALManager] playSoundWithKey:@"shock" Volume:0.3];
        [[OpenALManager sharedOpenALManager] SetPitchWithKey:@"shock" Pitch:0.8 + myRandom() * 0.1f];
	}

	if(m_isMoving)
	{
		m_moveTimer += a_timeInterval * SPEED;
		m_position.x += a_timeInterval * SPEED * 1.5f;
		l_positionY = 0.2f * sin(m_moveTimer * M_PI);
        
		if(l_positionY < 0.f)
		{
			m_isMoving = NO;
			m_moveTimer = 0.f;
            [[OpenALManager sharedOpenALManager] playSoundWithKey:@"shock" Volume:0.3];
		}
	}
    
    if(m_dead)
    {
        m_ySpeed -= a_timeInterval;
        m_position.y += m_ySpeed * a_timeInterval;
    }
	
	// draw background.
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView drawTextureIndex:m_texture
								  plan:PLAN_BACKGROUND_MIDDLE
								  size:m_size
							 positionX:m_position.x + s_decayX
							 positionY:m_position.y + l_positionY
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:m_widthOnHeight
							nightBlend:false
						   deformation:0.f
							  distance:1.f
								decayX:0.f
								decayY:0.f
								 alpha:m_alpha
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
}

// return the position of the mister
-(CGPoint)GetPosition
{
    return CGPointMake(m_position.x + s_decayX, m_position.y + 0.2f * sin(m_moveTimer * M_PI));
}

+(void)SetDecay:(float)a_decay
{
	s_decayX = a_decay;
}

+(void)SetPositionEnemy:(float)a_positionX
{
	s_positionEnemy = a_positionX;
}

// make the monster disapear at the next step.
-(void)SetDisapear:(BOOL)a_disapear
{
    m_disapear = a_disapear;
}

-(void)SetAlpha:(float)a_alpha
{
    m_alpha = a_alpha;
}

-(void)SetDead
{
    m_dead = YES;
}

@end

@implementation BigMisterWithEye

-(id)initWithPosition:(CGPoint)a_position 
			  texture:(int)a_texture
		widthOnHeight:(float)a_widthOnHeight
				 size:(float)a_size
				 step:(float)a_step
		   textureEye:(int)a_textureEye
{
	m_textureEye = a_textureEye;
	m_positionEye = a_position;
    m_positionTongue = a_position;
    m_positionExtension = a_position;
	m_idle = NO;
	m_transition = 0.f;
    m_moveDelay = 0.;
    m_openMouthCoeff = 0.f;
    m_openMouth = NO;
    m_awayCount = 4;
    m_tonguePendulum = [[PhysicPendulum alloc] initWithPosition:m_positionEye basePosition:CGPointMake(m_positionEye.x + 0.4, m_positionEye.y) mass:1.f angleSpeedLimit:-1.f gravity:2.f gravityAngle:M_PI / 2.f + myRandom() * M_PI / 10.f friction:.4 addInTheList:NO];
    m_hit = NO;
    m_timer = 0.;
    m_disapear = NO;
    m_alpha = 1.f;
	
	[super initWithPosition:a_position 
					texture:a_texture
			  widthOnHeight:a_widthOnHeight
					   size:a_size
					   step:a_step
	 ];
	
	return self;
}

// update.
-(void)Update:(NSTimeInterval)a_timeInterval
{
	m_timer += a_timeInterval;
	float l_positionY = 0.f;
//    float l_alpha = m_disapear ? 0.2f + 0.4f * cos(m_timer) : 1.f;
    
    if(m_dead)
    {
        m_ySpeed -= 0.5 * a_timeInterval;
        m_position.y += m_ySpeed * a_timeInterval;
    }
    
    if(m_openMouth)
    {
        m_openMouthCoeff += TONGUE_SPEED * a_timeInterval;
        if(m_openMouthCoeff > 1.7f)
        {
            m_openMouthCoeff = 1.f;
            [self OpenMouth:NO];
        }
    }
    else
    {
        m_openMouthCoeff -= TONGUE_SPEED * a_timeInterval;
        if(m_openMouthCoeff < 0.f)
        {
            if(m_hit)
            {
                [[[ApplicationManager sharedApplicationManager] GetState] Event1:0];
                m_hit = NO;
            }
            m_openMouthCoeff = 0.f;
        }
    }
    
    if(Absf(m_position.x + s_decayX - s_positionEnemy) < (m_step * 1.5f))
    {
        m_moveDelay += a_timeInterval;
    }
    
    float l_delayToMove = (m_awayCount > 1) ? DELAY_TO_MOVE : DELAY_TO_MOVE / 2.f;
	if(!m_isMoving && !m_idle &&!m_openMouth && !m_hit && (m_moveDelay > l_delayToMove))
	{
		m_awayCount--;
		if(m_awayCount <= 0)
		{
            [self OpenMouth:YES];
            [[OpenALManager sharedOpenALManager] playSoundWithKey:@"slarp" Volume:0.1f];
            m_awayCount = arc4random() % 3 + 2;
		}
		else
		{
			m_isMoving = YES;
            m_moveDelay = 0.;
		}
	}
	
	if(m_isMoving)
	{
		m_moveTimer += a_timeInterval * SPEED * 0.5f;
		m_position.x += a_timeInterval * SPEED * 1.5f * m_step;
		l_positionY = 0.2f * sin(m_moveTimer * M_PI);
		if(l_positionY < 0.f)
		{
			m_isMoving = NO;
			m_moveTimer = 0.f;
		}
	}
	
	// draw head up.
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView drawTextureIndex:m_texture
								  plan:PLAN_PARTICLE_FRONT
								  size:m_size
							 positionX:m_position.x + s_decayX
							 positionY:m_position.y + l_positionY - m_ySpeed / 2.f
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:m_widthOnHeight
							nightBlend:false
						   deformation:0.f
							  distance:1.f
								decayX:0.f
								decayY:0.f
								 alpha:clip(1.f - 5.f * m_transition, 0.f, 1.f) * m_alpha
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
    
    // draw head down.
    float l_openRealCoeff = clip(sqrt(m_openMouthCoeff), 0.f, 1.f);
    [l_sharedEAGLView drawTextureIndex:m_texture + 1
								  plan:PLAN_PARTICLE_FRONT
								  size:m_size
							 positionX:m_position.x + s_decayX
							 positionY:m_position.y + l_positionY - 0.2 * l_openRealCoeff
							 positionZ:0.f
						 rotationAngle:l_openRealCoeff * M_PI / 8.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:m_widthOnHeight
							nightBlend:false
						   deformation:0.f
							  distance:1.f
								decayX:0.f
								decayY:0.f
								 alpha:clip(1.f - 5.f * m_transition, 0.f, 1.f) * m_alpha
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
    
    float l_tongueSize = m_size / 2.f;
    m_tonguePositionRelative = l_openRealCoeff * -0.6f + 0.5f - l_tongueSize * 0.7f;
    CGPoint l_positionTongueBig = CGPointMake(m_position.x + s_decayX + m_tonguePositionRelative, m_position.y + l_positionY - l_tongueSize * 1.f);
    
    [m_tonguePendulum UpdateWithBasePosition:CGPointMake(l_positionTongueBig.x - s_decayX, l_positionTongueBig.y) timeFrame:a_timeInterval];
    float l_tongueAngle = [m_tonguePendulum m_angle];
    
    [l_sharedEAGLView drawTextureIndex:m_texture + 3 // tongue
								  plan:PLAN_PARTICLE_FRONT
								  size:l_tongueSize
							 positionX:l_positionTongueBig.x
							 positionY:l_positionTongueBig.y
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.f
					   rotationCenterY:0.f
						  repeatNumber:1
						 widthOnHeight:2.f
							nightBlend:false
						   deformation:0.f
							  distance:1.f
								decayX:0.f
								decayY:0.f
								 alpha:clip(1.f - 5.f * m_transition, 0.f, 1.f) * m_alpha
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
    
    [l_sharedEAGLView drawTextureIndex:m_texture + 4// tongue head
								  plan:PLAN_PARTICLE_FRONT
								  size:l_tongueSize
							 positionX:l_positionTongueBig.x + l_tongueSize * sin(l_tongueAngle) * l_openRealCoeff
							 positionY:l_positionTongueBig.y + l_tongueSize * -cos(l_tongueAngle)
							 positionZ:0.
						 rotationAngle:RADIAN_TO_DEDREE(l_tongueAngle) + 90.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.f
							nightBlend:false
						   deformation:0.f
							  distance:1.f
								decayX:0.f
								decayY:0.f
								 alpha:clip(1.f - 5.f * m_transition, 0.f, 1.f) * m_alpha
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
    m_positionTongue.x = l_positionTongueBig.x + l_tongueSize * sin(l_tongueAngle) * l_openRealCoeff * 1.8f;
    m_positionTongue.y = l_positionTongueBig.y + l_tongueSize * -cos(l_tongueAngle) * 1.8f;
    
    [l_sharedEAGLView drawTextureIndex:m_texture + 2
								  plan:PLAN_PARTICLE_FRONT
								  size:m_size
							 positionX:m_position.x + s_decayX + 0.5f
							 positionY:m_position.y + l_positionY - 0.35f
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:m_widthOnHeight
							nightBlend:false
						   deformation:0.f
							  distance:1.f
								decayX:0.f
								decayY:0.f
								 alpha:clip(1.f - 5.f * m_transition, 0.f, 1.f) * m_alpha
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	m_positionEye = CGPointMake(m_position.x + s_decayX - 0.22f, m_position.y + l_positionY + 0.15f);
	float l_size = (m_size * (1.f + pow(m_transition, 2.f) * 5.f)) / 3.5f;
	float l_positionX = m_position.x + s_decayX - pow(m_transition, 2.f) * 0.26;
	float l_alphaEye = m_disapear ? 0.f : 1.f;
    
	[l_sharedEAGLView drawTextureIndex:m_textureEye
								  plan:PLAN_BACKGROUND_MIDDLE
								  size:l_size
							 positionX:l_positionX
							 positionY:m_position.y + l_positionY + 0.05f + pow(m_transition, 2.f) * 0.07
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							nightBlend:false
						   deformation:0.f
							  distance:1.f
								decayX:0.f
								decayY:0.f
								 alpha:1.f * l_alphaEye
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];	
	
	[l_sharedEAGLView drawTextureIndex:m_textureEye + 1
								  plan:PLAN_PARTICLE_FRONT
								  size:l_size
							 positionX:l_positionX
							 positionY:m_position.y + l_positionY + 0.05f + pow(m_transition, 2.f) * 0.07
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							nightBlend:false
						   deformation:0.f
							  distance:1.f
								decayX:0.f
								decayY:0.f
								 alpha:1.f * l_alphaEye
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	if(m_transition > 0.1)
	{
		float l_sizeExtention = 0.3f;
		m_positionExtension = CGPointMake(l_positionX + l_size * (1.9 + 4.f * l_sizeExtention), m_position.y + l_positionY + 0.05f + pow(m_transition, 2.f) * 0.07);
		[l_sharedEAGLView drawTextureIndex:m_textureEye + 2
									  plan:PLAN_PARTICLE_FRONT
									  size:l_size / 3.f
								 positionX:m_positionExtension.x
								 positionY:m_positionExtension.y
								 positionZ:0.
							 rotationAngle:0.f
						   rotationCenterX:0.
						   rotationCenterY:0.
							  repeatNumber:1
							 widthOnHeight:4.f + 0.07 * cos(m_timer)
								nightBlend:false
							   deformation:0.f + 0.1 * cos(m_timer * 0.5f)
								  distance:1.f
									decayX:0.f
									decayY:0.f
									 alpha:1.f * l_alphaEye
									planFX:PLAN_BACKGROUND_SHADOW
								   reverse:REVERSE_NONE
		 ];	
	}
}

-(oneway void)release
{
    [m_tonguePendulum release];
    [super release];
    
}

-(CGPoint)GetPositionEye
{
	return m_positionEye;
}

-(CGPoint)GetPositionExtention
{
	return m_positionExtension;
}

-(void)SetIdle:(BOOL)a_value
{
	m_idle = a_value;
}

-(void)SetTransition:(float)a_transition
{
	m_transition = a_transition;
}

-(void)OpenMouth:(BOOL)a_openMouth
{
    m_openMouth = a_openMouth;
    [m_tonguePendulum SetGravityDegree:90.f + myRandom() * 10.f];
}

-(CGPoint)GetPositionTongue
{
    return m_positionTongue;
}

-(void)Hit
{
    [m_tonguePendulum SetGravityDegree:125.f];
    m_hit = YES;
    m_openMouth = NO;
}

@end

