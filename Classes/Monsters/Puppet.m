//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Puppet.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "ParticleLetter.h"
#import "ParticleManager.h"
#import "StateTheatre.h"

#define STICK_LENGTH 1.5
#define PUPPET_STICK_FRICTION 7.59f
#define PUPPET_STICK_WIDTH (1.f / 23.f)
#define SPEED_LULU_TURN .23f
#define SPEED_LULU_WALK .06f
#define PUPPET_SIZE	0.25f
#define PUPPET_PANEL_SIZE 0.12f
#define PUPPET_POSITION_Y_MAX (2.f - STICK_LENGTH)
#define PUPPET_POSITION_Y_DECAY 0.2f

@implementation PanelEvent

@synthesize	m_triggerTimer;
@synthesize	m_endTimer;
@synthesize	m_texture;

-(id)InitTexture:(int)a_texture begin:(NSTimeInterval)a_triggerTimer end:(NSTimeInterval)a_endTimer
{
	m_texture = a_texture;
	m_triggerTimer = a_triggerTimer; 
	m_endTimer = a_endTimer;
	
	return [super init];
}

@end

@implementation Puppet

-(id)InitWithTexturePuppet:(int)a_puppetTexture 
					 Stick:(int)a_stickTexture 
			  InitPosition:(CGPoint)a_positionInit 
			 PanelSequence:(NSArray *)a_sequenceArray
{
	return [self InitWithTexturePuppet:a_puppetTexture 
								 Stick:a_stickTexture 
						  InitPosition:a_positionInit 
						 PanelSequence:a_sequenceArray
							StickAngle:0.f
							PuppetSize:PUPPET_SIZE
								Marker:-1
						  FlyingMarker:YES
                              IsStatic:NO
			];
}

-(id)InitWithTexturePuppet:(int)a_puppetTexture 
					 Stick:(int)a_stickTexture 
			  InitPosition:(CGPoint)a_positionInit 
			 PanelSequence:(NSArray *)a_sequenceArray
				StickAngle:(float)a_stickAngle
				PuppetSize:(float)a_puppetSize
					Marker:(int)a_markerTexture
			  FlyingMarker:(BOOL)a_flyingMarker
                  IsStatic:(BOOL)a_isStatic
{
	a_positionInit.y += PUPPET_POSITION_Y_DECAY;
	a_positionInit.y = max(a_positionInit.y, PUPPET_POSITION_Y_MAX);
	m_lastPosition = a_positionInit;
	m_luluTurnSpeed = 0.f;
	m_luluTurnLast = 1.f;
	m_luluTurnLastDeformation = 0.f;
	m_panelTexture = -1;
	m_panelSpeedY = 0.f;
	m_panelPositionY = STICK_LENGTH;
	m_sequenceTimer = 0.f;
	m_sequenceIndex = 0;
	m_panelWidthOnHeight = 1.f;
	m_luluLeft = NO;
	m_stickAngleConstant = a_stickAngle;
	m_blockRotation = NO;
	m_puppetSize = a_puppetSize;
	m_luluForcedDeformation = 1.f;
	m_markerTexture = a_markerTexture;
	m_flyingMarker = a_flyingMarker;
	m_isStatic = a_isStatic;
    
	m_sequenceArray = a_sequenceArray;
	if(!m_sequenceArray)
	{
		m_sequenceState = SEQUENCE_STATE_END;
	}
	else
	{
		m_sequenceState = SEQUENCE_STATE_WAIT_FOR_BEGIN;
	}
	
	m_stickTexture = a_stickTexture;
	m_puppetTexture = a_puppetTexture;
	m_stickLength = STICK_LENGTH + myRandom() * 0.05;
	CGPoint l_pendulumPosition = CGPointMake(a_positionInit.x + m_stickLength / 5.f, a_positionInit.y - m_stickLength * 0.9f);
	
	// Creation of the head of the snake.
	m_pendulumStick = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition 
												  basePosition:a_positionInit 
														  mass:10.f 
											   angleSpeedLimit:-1.f
													   gravity:0.55
												  gravityAngle:m_stickAngleConstant
													  friction:PUPPET_STICK_FRICTION
												  addInTheList:NO
					   ];
	
	// Creation of the head of the snake.
	m_pendulumStickPanel = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition 
													   basePosition:a_positionInit
															   mass:10.f
													angleSpeedLimit:-1.f
															gravity:0.55
													   gravityAngle:0.f
														   friction:PUPPET_STICK_FRICTION * .5
													   addInTheList:NO
							];
	
	if(m_flyingMarker)
	{
		[ParticleLetter SetPosition:CGPointMake(a_positionInit.x + 0.07, 0.34f)];
		ParticleManager * l_particleManager =  [ParticleManager sharedParticleManager];
		[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_THEATRE_FINGER_GUI textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
		[ParticleLetter SetSize:0.06 group:0];
	}
	//[ParticleLetter SetGroupStatus:0 attractionCommon:NO goAway:NO];
	
	m_moved = NO;
	
	return [self init];
	
}

-(void)UpdateWithPosition:(CGPoint)a_position timeInterval:(NSTimeInterval)a_timeInterval
{		
	if(!m_moved && m_flyingMarker)
	{
		if(Absf(a_position.x - m_lastPosition.x) > 0.01)
		{
			[ParticleLetter SetGroupStatus:0 attractionCommon:NO goAway:YES];
			m_moved = YES;
		}
	}
	
	if(m_lastPosition.x != a_position.x && !m_blockRotation)
	{
		m_luluLeft = m_lastPosition.x > a_position.x;
	}
	
	m_lastPosition = a_position;
	m_lastPosition.y += PUPPET_POSITION_Y_DECAY;
	m_lastPosition.y = max(m_lastPosition.y, PUPPET_POSITION_Y_MAX);
	
	float l_goal = m_luluLeft ? -1.f : 1.f;
	l_goal = m_changeTexture ? 0.f : l_goal;
	float l_luluTurnLast = m_luluTurnLast;
	m_luluTurnSpeed += -SPEED_LULU_TURN * (m_luluTurnLast - l_goal);
	m_luluTurnLast += m_luluTurnSpeed * a_timeInterval;
	if(m_changeTexture && l_luluTurnLast * m_luluTurnLast < 0.f)
	{
		m_puppetTexture = m_nextTexture;
		m_changeTexture = NO;
	}
	m_luluTurnLastDeformation = m_luluTurnLast > 1.f ? 2.f - m_luluTurnLast : m_luluTurnLast;
	m_luluTurnLastDeformation = m_luluTurnLastDeformation < -1.f ? -2.f - m_luluTurnLast  : m_luluTurnLastDeformation;
	m_luluTurnLastDeformation *= m_luluForcedDeformation;
	m_luluTurnSpeed *= 1.f - 2. * a_timeInterval;
	
	[self UpdateSequence:a_timeInterval];
	[self UpdatePuppet:a_timeInterval];
	if(m_panelTexture > 0)
	{
		[self UpdatePanel:a_timeInterval];
	}
}

-(void)UpdateSequence:(NSTimeInterval)a_timeInterval
{
	m_sequenceTimer += a_timeInterval;
	PanelEvent * l_panelEvent;
	m_panelPositionY += m_panelSpeedY * a_timeInterval;
	m_panelPositionY = clip(m_panelPositionY, 0.f, STICK_LENGTH);
	
	switch(m_sequenceState)
	{
        case RESET_SEQUENCE:
            l_panelEvent = [m_sequenceArray objectAtIndex:m_sequenceIndex];
			if(m_sequenceTimer > [l_panelEvent m_triggerTimer])
			{
                m_sequenceState = SEQUENCE_STATE_WAIT_FOR_BEGIN;
                m_panelSpeedY = -2.f;
            }
            else
            {
                m_panelSpeedY = 2.f;
            }
            break;
		case SEQUENCE_STATE_WAIT_FOR_BEGIN:
			l_panelEvent = [m_sequenceArray objectAtIndex:m_sequenceIndex];
			if(m_sequenceTimer > [l_panelEvent m_triggerTimer])
			{
				m_panelSpeedY = -2.f;
				m_sequenceState = SEQUENCE_STATE_CHANGE_PANEL;
				m_panelChangeTimer = 0.f;
				m_panelTexturePrevious = m_panelTexture;
			}
			break;
		case SEQUENCE_STATE_CHANGE_PANEL:
			l_panelEvent = [m_sequenceArray objectAtIndex:m_sequenceIndex];
			m_panelChangeTimer += 2.5 * a_timeInterval;
			m_panelWidthOnHeight = Absf(cos(m_panelChangeTimer));
			if(m_panelChangeTimer > M_PI / 2.f)
			{
				m_panelTexture = [l_panelEvent m_texture];
				if (m_panelChangeTimer > M_PI)
				{
					m_panelWidthOnHeight = 1.f;
					m_sequenceState = SEQUENCE_STATE_WAIT_FOR_END;
				}
			}
			else
			{
				m_panelTexture = m_panelTexturePrevious;
			}
			break;
		case SEQUENCE_STATE_WAIT_FOR_END:
			l_panelEvent = [m_sequenceArray objectAtIndex:m_sequenceIndex];
			if(m_sequenceTimer > [l_panelEvent m_endTimer])
			{
				m_sequenceState = SEQUENCE_STATE_WAIT_FOR_BEGIN;
				m_sequenceIndex++;
				if(m_sequenceIndex >= [m_sequenceArray count])
				{
					m_sequenceState = SEQUENCE_STATE_END;
                    break;
				}
                if((m_sequenceTimer + 0.5f) < [[m_sequenceArray objectAtIndex:m_sequenceIndex] m_triggerTimer])
                {
                    m_panelSpeedY = 2.f;
                }
			}
			break;
        case SEQUENCE_STATE_END:
            m_panelSpeedY = 2.f;    
            break;
		default:
			break;
	}
	
}

-(void)UpdatePuppet:(NSTimeInterval)a_timeInterval
{
	[m_pendulumStick UpdateWithBasePosition:m_lastPosition timeFrame:a_timeInterval];	
	
	CGPoint l_stickPosition = [m_pendulumStick GetPosition];
	m_stickEndPosition = CGPointMake(m_lastPosition.x + (l_stickPosition.x - m_lastPosition.x) / 1.2, m_lastPosition.y + (l_stickPosition.y - m_lastPosition.y) / 1.2);
	float l_angle = [m_pendulumStick m_angle];
    
	if(cos(l_angle) > 0.7)
	{
		[m_pendulumStick SetFriction:1.f];
	}
	else
	{
		[m_pendulumStick SetFriction:PUPPET_STICK_FRICTION];
	}
    
    l_angle = m_isStatic ? 0.f : RADIAN_TO_DEDREE(l_angle + m_stickAngleConstant);
	CGPoint l_puppetPosition = m_isStatic ? CGPointMake(m_lastPosition.x, m_lastPosition.y - STICK_LENGTH * 0.7f) : m_stickEndPosition;
    
    if(m_puppetTexture >= 0)
    {
        [[EAGLView sharedEAGLView] drawTextureIndex:m_puppetTexture
                                               plan:PLAN_PENDULUM
                                               size:m_puppetSize
                                          positionX:l_puppetPosition.x
                                          positionY:l_puppetPosition.y
                                          positionZ:0.
                                      rotationAngle:l_angle
                                    rotationCenterX:l_stickPosition.x
                                    rotationCenterY:l_stickPosition.y
                                       repeatNumber:1
                                      widthOnHeight:m_luluTurnLastDeformation
                                         nightBlend:NO
                                        deformation:0.f
                                           distance:50.f
                                             decayX:0.f
                                             decayY:0.f
                                              alpha:1.f
                                             planFX:-1
                                            reverse:REVERSE_NONE
         ];
    }
	
	CGPoint l_position;
	
    l_angle	   = [m_pendulumStick m_angle];
    l_position = CGPointMake(m_stickEndPosition.x - sin(l_angle) * m_stickLength / 2.f, 
                             m_stickEndPosition.y + cos(l_angle) * m_stickLength / 2.f);
    l_angle = m_isStatic ? 0.f : l_angle;
    
    if(!m_isStatic)
    {
        
        [[EAGLView sharedEAGLView] drawTextureIndex:m_stickTexture
                                               plan:PLAN_PENDULUM
                                               size:	m_stickLength / 2.
                                          positionX:l_position.x
                                          positionY:l_position.y
                                          positionZ:0.
                                      rotationAngle:RADIAN_TO_DEDREE(l_angle)
                                    rotationCenterX:l_stickPosition.x
                                    rotationCenterY:l_stickPosition.y
                                       repeatNumber:1
                                      widthOnHeight:PUPPET_STICK_WIDTH / STICK_LENGTH
                                         nightBlend:false
                                        deformation:0.f
                                           distance:50.f
         ];
    }
	
	if(m_markerTexture >= 0)
	{
		l_position = CGPointMake(l_position.x - sin(l_angle) * m_stickLength / 4.f, 
								 l_position.y + cos(l_angle) * m_stickLength / 4.f);
		
		[[EAGLView sharedEAGLView] drawTextureIndex:m_markerTexture
											   plan:PLAN_PENDULUM
											   size:	0.12f
										  positionX:l_position.x
										  positionY:l_position.y
										  positionZ:0.
									  rotationAngle:RADIAN_TO_DEDREE(l_angle)
									rotationCenterX:l_stickPosition.x
									rotationCenterY:l_stickPosition.y
									   repeatNumber:1
									  widthOnHeight:m_luluTurnLastDeformation
										 nightBlend:false
										deformation:0.f
										   distance:50.f
		 ];	
	}
}

-(void)UpdatePanel:(NSTimeInterval)a_timeInterval
{
	CGPoint l_panelPosition = CGPointMake(m_lastPosition.x + (m_luluTurnLastDeformation * (m_puppetSize + PUPPET_PANEL_SIZE / 2.f)), m_lastPosition.y + m_puppetSize + PUPPET_PANEL_SIZE + m_panelPositionY);
	[m_pendulumStickPanel UpdateWithBasePosition:l_panelPosition timeFrame:a_timeInterval];	
	
	CGPoint l_stickPosition = [m_pendulumStickPanel GetPosition];
	CGPoint l_panelStickEndPosition = CGPointMake(l_panelPosition.x + (l_stickPosition.x - l_panelPosition.x) / 1.1, l_panelPosition.y + (l_stickPosition.y - l_panelPosition.y) / 1.1);
	float l_angle = [m_pendulumStickPanel m_angle];
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_panelTexture
										   plan:PLAN_PENDULUM
										   size:PUPPET_PANEL_SIZE
									  positionX:l_panelStickEndPosition.x
									  positionY:l_panelStickEndPosition.y
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE(l_angle)
								rotationCenterX:l_stickPosition.x
								rotationCenterY:l_stickPosition.y
								   repeatNumber:1
								  widthOnHeight:m_luluTurnLastDeformation *  m_panelWidthOnHeight
									 nightBlend:true
									deformation:0.f
									   distance:50.f
	 ];
	
	CGPoint l_position;
	
	l_position = CGPointMake(l_panelPosition.x + (l_stickPosition.x - l_panelPosition.x) / 2.3, 
							 l_panelPosition.y + (l_stickPosition.y - l_panelPosition.y) / 2.3);
	l_angle	   = [m_pendulumStickPanel m_angle];
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_stickTexture
										   plan:PLAN_PENDULUM
										   size:	m_stickLength / 2.3
									  positionX:l_position.x
									  positionY:l_position.y
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE(l_angle)
								rotationCenterX:l_stickPosition.x
								rotationCenterY:l_stickPosition.y
								   repeatNumber:1
								  widthOnHeight:PUPPET_STICK_WIDTH / STICK_LENGTH
									 nightBlend:false
									deformation:0.f
									   distance:50.f
	 ];	
}

-(CGPoint)GetPosition
{
	return m_stickEndPosition;
}

-(float)GetDeformation
{
	return m_luluTurnLastDeformation;
}

-(void)SetSequence:(NSArray *)a_newSequence
{
	[m_sequenceArray release];
	m_sequenceArray = a_newSequence;
	m_sequenceTimer = 0.f;
	m_sequenceIndex = 0;
	if(a_newSequence == nil)
	{
		m_sequenceState = SEQUENCE_STATE_END;
	}
	else
	{
		m_sequenceState = RESET_SEQUENCE;
	}
}

-(void)SetTexture:(int)a_newTexture
{
	m_changeTexture = YES;
	m_nextTexture = a_newTexture;
}

-(void)BlockRotation:(BOOL)a_blockRotation
{
	m_blockRotation = a_blockRotation;
	m_luluLeft = NO;
}

-(oneway void)release
{
	// destroy the snake.
	[m_pendulumStick release];
	[m_pendulumStickPanel release];
	[m_sequenceArray release];
	[super release];
}
@end