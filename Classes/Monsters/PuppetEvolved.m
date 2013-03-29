//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PuppetEvolved.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "ParticleLetter.h"
#import "ParticleManager.h"
#import "StateTheatre.h"

#define PUPPET_EVOLVED_ARM_LENGTH 0.15f
#define PUPPET_STICK_WIDTH (1.f / 80.f)
#define PUPPET_EVOLVED_STICK_LENGTH_HAND 1.4f
#define PUPPET_EV_STICK_FRICTION_HAND 7.f
#define PUPPET_EV_HIT_TIMER_UNIT 0.25f
#define PUPPET_EV_SENSIBILITY_Y 2.7f
#define PUPPET_EV_HEAD_ROTATION_LOST 90.f
#define PUPPET_EV_LEGS_LENGTH 0.09f
#define PUPPET_EV_LEGS_FRICTION 2.3f
#define VOLUME_CRAZINESS 0.3f

@implementation PuppetEvolved

-(id)InitWithTexturePuppet:(int)a_puppetTexture 
					 Stick:(int)a_stickTexture 
			  InitPosition:(CGPoint)a_positionInit 
			 PanelSequence:(NSArray *)a_sequenceArray
{	
	return nil;
}

-(id)InitWithTexturePuppet:(int)a_puppetTexture
				TextureArm:(int)a_textureArm
			  TextureSword:(int)a_textureSword
					 Stick:(int)a_stickTexture 
			   TextureHead:(int)a_textureHead
				TextureLeg:(int)a_textureLeg
			  InitPosition:(CGPoint)a_positionInit 
			 PanelSequence:(NSArray *)a_sequenceArray
{	
	m_armTexture = a_textureArm;
	m_swordTexture = a_textureSword;
	m_headTexture = a_textureHead;
	m_legTexture = a_textureLeg;
	m_speedSword = 0.f;
	m_swordPosition = CGPointMake(0.f, 0.f);
	m_handControlerPosition = CGPointMake(a_positionInit.x + 0.3, a_positionInit.y);
	m_bodyControlerPosition = a_positionInit;
	m_armAngleDegree = -45.f;
	m_hitTimer = 0.f;
	m_hitHeadRotation = 0.f;
	
	CGPoint l_pendulumPosition = CGPointMake(a_positionInit.x + PUPPET_EVOLVED_STICK_LENGTH_HAND / 2.f, a_positionInit.y - PUPPET_EVOLVED_STICK_LENGTH_HAND * 0.9f);
	
	// Creation of the head of the snake.
	m_pendulumArm = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition 
												  basePosition:a_positionInit 
														  mass:10.f 
											   angleSpeedLimit:-1.f
													   gravity:7.55
												  gravityAngle:M_PI / 5.f
													  friction:PUPPET_EV_STICK_FRICTION_HAND
												  addInTheList:NO
					   ];

	if(m_legTexture >= 0)
	{
		for(int i = 0; i < 2; i++)
		{
			l_pendulumPosition = CGPointMake(a_positionInit.x + PUPPET_EV_LEGS_LENGTH / 2.f + myRandom() * 0.1f * PUPPET_EV_LEGS_LENGTH, a_positionInit.y - PUPPET_EV_LEGS_LENGTH * 0.9f);

			m_pendulumLeg[i] = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition 
														basePosition:a_positionInit 
																mass:10.f 
													 angleSpeedLimit:1.f
															 gravity:.20 + myRandom() * 0.07f
														gravityAngle:((float)i -.5f) * 0.f//M_PI / 20.f
															friction:PUPPET_EV_LEGS_FRICTION
														addInTheList:YES
							 ];
		}
	}
	
	[super InitWithTexturePuppet:a_puppetTexture 
						   Stick:a_stickTexture 
					InitPosition:a_positionInit 
				   PanelSequence:a_sequenceArray 
					  StickAngle:-M_PI / 8.f 
					  PuppetSize:0.3f 
						  Marker:-1
					FlyingMarker:NO
                        IsStatic:NO
	 ];
	
	[self BlockRotation:YES];
	return self;
}

// Do not use it.
-(void)UpdateWithPosition:(CGPoint)a_position timeInterval:(NSTimeInterval)a_timeInterval
{
	printf("Don't use this method for evolved");
}

// used for evolved.
-(void)UpdateWithPosition:(CGPoint)a_positionBody positionHand:(CGPoint)a_positionHand timeInterval:(NSTimeInterval)a_timeInterval
{
	m_handControlerPosition = a_positionHand;
	[super UpdateWithPosition:a_positionBody timeInterval:a_timeInterval];
	
	[m_pendulumArm UpdateWithBasePosition:a_positionHand timeFrame:a_timeInterval];	
	if(m_legTexture >= 0)
	{
		for(int i = 0; i < 2; i++)
		{
			[m_pendulumLeg[i] UpdateWithBasePosition:m_stickEndPosition timeFrame:a_timeInterval];			
		}
	}
	m_hitTimer -= a_timeInterval;
	m_hitTimer = max(m_hitTimer, 0.f);
//	m_luluForcedDeformation = 1.f + 0.1 * m_hitTimer * cos(5.f * m_hitTimer * 2.f * M_PI);
//	m_luluForcedDeformation = m_luluForcedDeformation > 1.f ? 2.f - m_luluForcedDeformation : m_luluForcedDeformation;
//	m_luluForcedDeformation = m_luluForcedDeformation < -1.f ? -2.f - m_luluForcedDeformation : m_luluForcedDeformation;
	if(m_hitHeadRotation > PUPPET_EV_HEAD_ROTATION_LOST)
	{
		m_headPosition.y += 0.15f * a_timeInterval;
		[[[ApplicationManager sharedApplicationManager] GetState] Eventf1:0.f];
		if(m_headPosition.y > 0.3f)
		{
			[[[ApplicationManager sharedApplicationManager] GetState] Event2:0];
		}
		m_hitHeadRotation += 90.f * a_timeInterval;
		
		float l_pitch = min(1.f + 0.05f * ((m_hitHeadRotation / (float)PUPPET_EV_HEAD_ROTATION_LOST) - 1.f), 1.2f);
		m_crazyVolume += 1.f * a_timeInterval / l_pitch;

		[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"crazyness" Pitch:min(l_pitch, 1.2f)];
	}
	else if(m_hitTimer > 0.)
	{
		m_hitHeadRotation += 22.f * a_timeInterval + myRandom() * 4.f;
		m_crazyVolume += 1.f * a_timeInterval;
	}
	else
	{
		m_crazyVolume -= 0.2f * a_timeInterval;
		m_crazyVolume = clip(m_crazyVolume, 0.3 * VOLUME_CRAZINESS * m_hitHeadRotation / PUPPET_EV_HEAD_ROTATION_LOST, VOLUME_CRAZINESS);
	}

	m_crazyVolume = clip(m_crazyVolume, 0.f, VOLUME_CRAZINESS);
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"crazyness" Volume:m_crazyVolume];
	[self DrawArm:a_timeInterval];
}

-(void)DrawArm:(NSTimeInterval)a_timeInterval
{
	float l_armAngle;
	
	float l_angleStickRad = [m_pendulumArm m_angle];
	float l_angleStickDeg;
	float decayCoeff = 2.3;
	CGPoint l_positionStickHandEnd = CGPointMake(1.5 * m_handControlerPosition.x - 0.4f + PUPPET_EVOLVED_STICK_LENGTH_HAND * sin(l_angleStickRad) / (decayCoeff * 0.5f), PUPPET_EV_SENSIBILITY_Y * m_handControlerPosition.y - PUPPET_EVOLVED_STICK_LENGTH_HAND * cos(l_angleStickRad) / (decayCoeff * 0.5f));
	
	m_armAngleDegree = RADIAN_TO_DEDREE( atan((m_stickEndPosition.y - l_positionStickHandEnd.y) / (m_stickEndPosition.x - l_positionStickHandEnd.x)) );
	m_armAngleDegree += ((m_stickEndPosition.x - l_positionStickHandEnd.x) < 0) ? 0.f : -180.f;
	
	float l_distanceCenterHand = min(DistancePoint(m_stickEndPosition, l_positionStickHandEnd), PUPPET_EVOLVED_STICK_LENGTH_HAND / 2.f);
	//	if(l_distanceFingerCenter <=  PUPPET_EVOLVED_STICK_LENGTH_HAND + PUPPET_EVOLVED_ARM_LENGTH)
	//	{
	////		m_armAngleDegree = atan((m_stickEndPosition.y - m_handControlerPosition.y) / (m_stickEndPosition.x - m_handControlerPosition.x));
	////		m_armAngleDegree += ((m_stickEndPosition.x - m_handControlerPosition.x) < 0) ? 0.f : -M_PI;
	////		m_handControlerPosition = CGPointMake(cos(m_armAngleDegree) * (m_stickLength + PUPPET_EVOLVED_ARM_LENGTH), sin(m_armAngleDegree) * (m_stickLength + PUPPET_EVOLVED_ARM_LENGTH));
	////		l_distanceFingerCenter = (m_stickLength + PUPPET_EVOLVED_ARM_LENGTH) * 0.95;
	//	}
	//	m_armAngleDegree = acos(-((PUPPET_EVOLVED_STICK_LENGTH_HAND * PUPPET_EVOLVED_STICK_LENGTH_HAND) - (l_distanceFingerCenter * l_distanceFingerCenter) - (PUPPET_EVOLVED_ARM_LENGTH * PUPPET_EVOLVED_ARM_LENGTH)) / (2 * PUPPET_EVOLVED_ARM_LENGTH * l_distanceFingerCenter) );
	//	m_armAngleDegree = RADIAN_TO_DEDREE(m_armAngleDegree);
	
	// TEST END... .
	
	if(m_armAngleDegree < 0.f)
	{
		l_armAngle = Absf(m_luluTurnLastDeformation) * m_armAngleDegree + (Absf(m_luluTurnLastDeformation) - 1.f) * 90;
	}
	else
	{
		l_armAngle = Absf(m_luluTurnLastDeformation) * m_armAngleDegree - (Absf(m_luluTurnLastDeformation) - 1.f) * 90;//m_luluTurnLastDeformation < 0.f ? -m_armAngleDegree : m_armAngleDegree;
	}
	
	float l_angleRadianTotal = DEGREES_TO_RADIANS(l_armAngle);
	float l_angleRadianPart = acos(2.f * l_distanceCenterHand  / PUPPET_EVOLVED_STICK_LENGTH_HAND);
	float l_angleTotalPart1 = l_angleRadianTotal - l_angleRadianPart;
	float l_angleTotalPart2 = l_angleRadianTotal + l_angleRadianPart;
	
	float l_length = sqrt(pow(Absf(m_luluTurnLastDeformation) * cos(DEGREES_TO_RADIANS(m_armAngleDegree)), 2.f) + pow(Absf(m_luluTurnLastDeformation) * sin(DEGREES_TO_RADIANS(m_armAngleDegree)), 2.f));
	float l_widthOnHeight = pow(cos(DEGREES_TO_RADIANS(m_armAngleDegree)), 2.f) * m_luluTurnLastDeformation + pow(sin(DEGREES_TO_RADIANS(m_armAngleDegree)), 2.f) / m_luluTurnLastDeformation;
	CGPoint l_center1 = CGPointMake(m_stickEndPosition.x + m_luluTurnLastDeformation * PUPPET_EVOLVED_ARM_LENGTH * cos(l_angleTotalPart1), m_stickEndPosition.y + PUPPET_EVOLVED_ARM_LENGTH * sin(l_angleTotalPart1));
	CGPoint l_part1End = CGPointMake(m_stickEndPosition.x + 2.f * m_luluTurnLastDeformation * PUPPET_EVOLVED_ARM_LENGTH * cos(l_angleTotalPart1) * 0.9f, m_stickEndPosition.y + 2.f * PUPPET_EVOLVED_ARM_LENGTH * sin(l_angleTotalPart1) * 0.9f); 
	CGPoint l_lastSwordPosition = m_swordPosition;
	m_swordPosition = CGPointMake(l_part1End.x + m_luluTurnLastDeformation * PUPPET_EVOLVED_ARM_LENGTH * cos(l_angleTotalPart2) * 0.9f, l_part1End.y + 2.f * PUPPET_EVOLVED_ARM_LENGTH * sin(l_angleTotalPart2) * 0.9f * 0.5f); 
	m_speedSword = sqrt(pow((l_lastSwordPosition.x - m_swordPosition.x) / a_timeInterval, 2.f) + pow((l_lastSwordPosition.y - m_swordPosition.y) / a_timeInterval, 2.f));
	
	//voir si l'angle général est bien pris en compte, vérifier l'emplacement du deuxiéme bras, cliper la distance du baton.
	[[EAGLView sharedEAGLView] drawTextureIndex:m_armTexture
										   plan:PLAN_PENDULUM
										   size:l_length * PUPPET_EVOLVED_ARM_LENGTH / (4.f)
									  positionX:l_center1.x
									  positionY:l_center1.y
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE((m_luluTurnLastDeformation > 0.f ? l_angleTotalPart1 : -l_angleTotalPart1))
								rotationCenterX:l_center1.x
								rotationCenterY:l_center1.y
								   repeatNumber:1
								  widthOnHeight:4.f * l_widthOnHeight
									 nightBlend:NO
									deformation:0.f
									   distance:50.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:-1
										reverse:REVERSE_NONE
	];
	
	l_armAngle = RADIAN_TO_DEDREE(l_angleRadianTotal + l_angleRadianPart);
	[[EAGLView sharedEAGLView] drawTextureIndex:m_swordTexture
										   plan:PLAN_PENDULUM
										   size:l_length * PUPPET_EVOLVED_ARM_LENGTH / (4.f)
									  positionX:m_swordPosition.x
									  positionY:m_swordPosition.y
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE((m_luluTurnLastDeformation > 0.f ? l_angleTotalPart2 : -l_angleTotalPart2))
								rotationCenterX:m_swordPosition.x
								rotationCenterY:m_swordPosition.y
								   repeatNumber:1
								  widthOnHeight:4.f * l_widthOnHeight
									 nightBlend:NO
									deformation:0.f
									   distance:50.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:-1
										reverse:REVERSE_NONE
	 ];
	
	CGPoint l_centerStick;
	l_centerStick.x += m_luluTurnLastDeformation * PUPPET_EVOLVED_ARM_LENGTH * cos(l_angleRadianTotal) * 0.9f;
	l_centerStick.y += Absf(m_luluTurnLastDeformation) * PUPPET_EVOLVED_ARM_LENGTH * sin(l_angleRadianTotal) * 0.9f;

	CGPoint l_positionHandEnd = CGPointMake(m_swordPosition.x + m_luluTurnLastDeformation * PUPPET_EVOLVED_ARM_LENGTH * cos(l_angleTotalPart2) * 0.7f, m_swordPosition.y + 2.f * PUPPET_EVOLVED_ARM_LENGTH * sin(l_angleTotalPart2) * 0.7f * 0.5f); 
	l_angleStickDeg = RADIAN_TO_DEDREE(atan((m_handControlerPosition.x - l_positionHandEnd.x) / (l_positionHandEnd.y - m_handControlerPosition.y)));
	l_angleStickDeg += ((l_positionHandEnd.y - m_handControlerPosition.y) < 0) ? 0.f : -180.f;
	CGPoint l_positionStick = CGPointMake(l_positionHandEnd.x  - PUPPET_EVOLVED_STICK_LENGTH_HAND * 2.f * sin(DEGREES_TO_RADIANS( l_angleStickDeg)) /  decayCoeff, l_positionHandEnd.y + PUPPET_EVOLVED_STICK_LENGTH_HAND * 2.f * cos(DEGREES_TO_RADIANS( l_angleStickDeg )) / decayCoeff);
	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_stickTexture
										   plan:PLAN_PENDULUM
										   size:2.f * PUPPET_EVOLVED_STICK_LENGTH_HAND / decayCoeff
									  positionX:l_positionStick.x
									  positionY:l_positionStick.y
									  positionZ:0.
								  rotationAngle:l_angleStickDeg
								rotationCenterX:l_positionStick.x
								rotationCenterY:l_positionStick.y
								   repeatNumber:1
								  widthOnHeight:PUPPET_STICK_WIDTH / PUPPET_EVOLVED_STICK_LENGTH_HAND
									 nightBlend:false
									deformation:0.f
									   distance:50.f
	 ];
	

	float l_angleHead;
	float l_stickAngle = [m_pendulumStick m_angle];
	
	if(m_hitHeadRotation <= PUPPET_EV_HEAD_ROTATION_LOST)
	{
		m_headPosition = CGPointMake(m_stickEndPosition.x, m_stickEndPosition.y + 0.06);
		l_angleHead = RADIAN_TO_DEDREE(l_stickAngle + m_stickAngleConstant) + m_hitHeadRotation;
	}
	else
	{
		l_angleHead = m_hitHeadRotation;
	}

	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_headTexture
										   plan:PLAN_PENDULUM
										   size:m_puppetSize / 1.5f
									  positionX:m_headPosition.x
									  positionY:m_headPosition.y
									  positionZ:0.
								  rotationAngle:l_angleHead
								rotationCenterX:m_stickEndPosition.x
								rotationCenterY:m_stickEndPosition.y
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
	
	if(m_legTexture >= 0)
	{
		float l_pendulumAngle;
		for(int i = 0; i < 2; i++)
		{
			l_pendulumAngle = [m_pendulumLeg[i] m_angle];
			[[EAGLView sharedEAGLView] drawTextureIndex:m_legTexture + i
												   plan:PLAN_PENDULUM
												   size:PUPPET_EV_LEGS_LENGTH
											  positionX:m_stickEndPosition.x + 0.12 * sin(l_stickAngle + m_stickAngleConstant) + sin(l_pendulumAngle) * PUPPET_EV_LEGS_LENGTH * 0.9// + l_stickAngle * 0.1
											  positionY:m_stickEndPosition.y - 0.12 * cos(l_stickAngle + m_stickAngleConstant) - cos(l_pendulumAngle) * PUPPET_EV_LEGS_LENGTH * 0.9
											  positionZ:0.
										  rotationAngle:RADIAN_TO_DEDREE(l_pendulumAngle)
										rotationCenterX:m_stickEndPosition.x
										rotationCenterY:m_stickEndPosition.y
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
	}
}

-(void)Hit:(int)a_value
{
	m_hitTimer += (float)a_value * PUPPET_EV_HIT_TIMER_UNIT;
}


-(CGPoint)GetPositionControlerHand
{
	return m_handControlerPosition;
}

-(CGPoint)GetPositionControlerBody
{
	return m_bodyControlerPosition;
}

-(CGPoint)GetPositionSword
{
	return m_swordPosition;
}

-(CGPoint)GetPositionBody
{
	return m_stickEndPosition;
}

-(float)GetSpeedSword
{
	return m_speedSword;
}

-(oneway void)release
{
	// destroy the snake.
	[m_pendulumArm release];
	[super release];
}

@end

@implementation PuppetEvolvedPig

-(id)InitWithTexturePuppet:(int)a_puppetTexture
                TextureArm:(int)a_textureArm
              TextureSword:(int)a_textureSword
                TexturePig:(int)a_texturePig
                     Stick:(int)a_stickTexture 
               TextureHead:(int)a_textureHead
                TextureLeg:(int)a_textureLeg
              InitPosition:(CGPoint)a_positionInit 
             PanelSequence:(NSArray *)a_sequenceArray
{
    [self InitWithTexturePuppet:a_puppetTexture
                     TextureArm:a_textureArm
                   TextureSword:a_textureSword
                          Stick:a_stickTexture 
                    TextureHead:a_textureHead
                     TextureLeg:a_textureLeg
                   InitPosition:a_positionInit 
                  PanelSequence:a_sequenceArray];
    
    m_texturePig = a_texturePig;
    return self;
}

-(void)DrawArm:(NSTimeInterval)a_timeInterval
{
    [super DrawArm:a_timeInterval];
    m_time += a_timeInterval;
    m_movement += m_movementSpeed * a_timeInterval;
    float l_variation = [self GetVariation];
    [[EAGLView sharedEAGLView] drawTextureIndex:m_texturePig
										   plan:PLAN_PENDULUM
										   size:m_puppetSize / 1.1f
									  positionX:m_stickEndPosition.x + m_puppetSize / 14.f
									  positionY:m_stickEndPosition.y - m_puppetSize / (1.5f + l_variation * 0.2)
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE([m_pendulumStick m_angle] + m_stickAngleConstant + l_variation * M_PI / 22.f)
								rotationCenterX:m_stickEndPosition.x
								rotationCenterY:m_stickEndPosition.y
								   repeatNumber:1
								  widthOnHeight:m_luluTurnLastDeformation
									 nightBlend:NO
									deformation:0.f
									   distance:30.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:-1
										reverse:REVERSE_NONE
	 ];
}

-(void)SetSpeed:(float)a_speed
{
    m_movementSpeed = a_speed;
}

-(float)GetVariation
{
    return 0.25 * cos(m_movement * 20.f);
}

@end