//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateIntro.h"
#import "StateMenu.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleBeast.h"
#import "ApplicationManager.h"
#import "ParticleLetter.h"
#import	"OpenALManager.h"
#import "Puppet.h"

#define STICK_LENGTH 1.
#define GROUND_Y -1.6f
#define TIME_BEFORE_OPEN_CURTAINS 2.f
#define SPEED_LULU_TURN .3f
#define SPEED_LULU_WALK .06f

@implementation StateIntro

-(void)StateInit
{
	m_index = STATE_INTRO;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_INTRO_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"luluTitleBack.png"];
	m_levelData.m_textureArray[TEXTURE_INTRO_SHADOW_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_INTRO_CURTAIN_RIGHT] = [[NSString alloc] initWithString:@"introCurtainRight.png"];
	m_levelData.m_textureArray[TEXTURE_INTRO_CURTAIN_LEFT] = [[NSString alloc] initWithString:@"introCurtainLeft.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_INTRO_LULU] = [[NSString alloc] initWithString:@"luluIntro.png"];
	m_levelData.m_textureArray[TEXTURE_INTRO_THANKS] = [[NSString alloc] initWithString:@"thanks.png"];
	m_levelData.m_textureArray[TEXTURE_INTRO_TITLE] = [[NSString alloc] initWithString:@"title.png"];
	m_levelData.m_textureArray[TEXTURE_INTRO_ARROW_ENTER] = [[NSString alloc] initWithString:@"TitleDirection.png"];
	m_levelData.m_textureArray[TEXTURE_INTRO_MARKER] = [[NSString alloc] initWithString:@"marker.png"];

	m_curtainOpenTimer = 0.;
	m_curtainOpened = NO;
	
	m_luluTurnSpeed = 0.f;
	m_luluTurnLast = 1.f;

	m_skyDecay = CGPointMake(0., 0.);
	
	m_helpPosition = CGPointMake(0.f, 2.f);
	m_helpSpeed = CGPointMake(0.f, 0.f);
	
	OpenALManager * l_soundManager = [OpenALManager sharedOpenALManager];
	[l_soundManager StopAll];
	
	[l_soundManager playSoundWithKey:@"string" Volume:4.f];
	
	[ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_THEATRE_WING_0 lastFrame:TEXTURE_THEATRE_WING_1 duration:0.07]
						 angle:(M_PI / 2.5) * 180 / M_PI
				  texturePause:TEXTURE_THEATRE_WING_0
					  sizeWing:1.7f
	 ];
	
	m_fingerPosition[0] = CGPointMake(-0.8, .6f);

    // init the puppet.
	m_puppet = [[Puppet alloc] InitWithTexturePuppet:TEXTURE_INTRO_LULU 
                                               Stick:TEXTURE_THEATRE_STICK 
                                        InitPosition:m_fingerPosition[0] 
                                       PanelSequence:nil
                                          StickAngle:0.f
                                          PuppetSize:0.25
                                              Marker:TEXTURE_INTRO_MARKER
                                        FlyingMarker:YES
                                            IsStatic:NO
				];
	
	[self InitStick];
	return [super StateInit];
}


//
//  Update.
//
-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	// this is just to have a clearer code.
	if(![self UpdatePuppet:a_timeInterval])
	{
		return;
	}
	if(![self UpdateTitle:a_timeInterval])
	{
		return;
	}
	m_curtainOpenTimer += a_timeInterval;
	
	if(m_curtainOpenTimer > 20.f && m_titleSpeed.y > 0.1f)
	{
		m_goTimer += a_timeInterval;
		float l_xPosition = 0.5f;//max((m_goTimer - ARROW_IDLE_DURATION) * 0.5, 0.f);
		[m_goPendulum UpdateWithBasePosition:CGPointMake(l_xPosition, 0.f) timeFrame:a_timeInterval];
		float l_angle = [m_goPendulum m_angle] - M_PI / 2.f;
		float l_size = 0.3f;
		float l_height = 0.5f;
		[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_INTRO_ARROW_ENTER
											   plan:PLAN_PENDULUM
											   size:0.2f
										  positionX:l_size * cos(l_angle) + l_xPosition
										  positionY:l_size * sin(l_angle) + l_height
										  positionZ:0.
									  rotationAngle:RADIAN_TO_DEDREE(l_angle) + 90.
									rotationCenterX:0.f
									rotationCenterY:0.f
									   repeatNumber:1
									  widthOnHeight:1.f
										 nightBlend:false
										deformation:0.f
										   distance:-1.f
											 decayX:0.f
											 decayY:0.f
											  alpha:1.f
											 planFX:-1
											reverse:REVERSE_VERTICAL
		 ];
		
		[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_THEATRE_STICK
											   plan:PLAN_PENDULUM
											   size:.2f
										  positionX:0.f + (l_size / 2.f) * cos(l_angle) + l_xPosition
										  positionY:l_height + (l_size / 2.f) * sin(l_angle)
										  positionZ:0.
									  rotationAngle:RADIAN_TO_DEDREE(l_angle) + 90
									rotationCenterX:0.f
									rotationCenterY:0.f
									   repeatNumber:1
									  widthOnHeight:1.f / 10.f
										 nightBlend:false
										deformation:0.f
										   distance:50.f
											 decayX:0.f
											 decayY:0.f
											  alpha:1.f
											 planFX:-1
											reverse:REVERSE_NONE
		 ];
		
		[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"grind" Volume:1.f / (2.f * l_xPosition + 1.f)];
	}
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_currentAroundDeformation =  clip(0.3 * (m_curtainOpenTimer - TIME_BEFORE_OPEN_CURTAINS), 0.f, 0.5f);
	float l_currentCurtainPosition =  pow(l_currentAroundDeformation, 2) * 6.f;
	
	float l_size	 = m_levelData.m_size;

	// draw the head.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_THEATRE_BACKGROUND_AROUND
								  plan:PLAN_BACKGROUND_SHADOW
								  size:	l_size
							 positionX:0.f
							 positionY:0.f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.8
							nightBlend:false
						   deformation:0.f
							  distance:-1.f + l_currentAroundDeformation * 80.f
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_INTRO_CURTAIN_LEFT
								  plan:PLAN_BACKGROUND_CLOSE
								  size:	l_size
							 positionX:-l_currentCurtainPosition + 0.15f
							 positionY:0.f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.
							nightBlend:false
						   deformation:l_currentAroundDeformation
							  distance:-1.f
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_INTRO_CURTAIN_RIGHT
								  plan:PLAN_BACKGROUND_CLOSE
								  size:	l_size
							 positionX:l_currentCurtainPosition
							 positionY:0.f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.
							nightBlend:false
						   deformation:-l_currentAroundDeformation
							  distance:-1.f
	 ];
	
    // update the scrolling.
	m_skyDecay.x += -a_timeInterval * SPEED_LULU_WALK;
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:-m_skyDecay.x / 1.5
								decayY:0.f
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_INTRO_SHADOW_FRONT
								  plan:PLAN_SKY_SHADOW
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:-m_skyDecay.x
								decayY:0.f
	 
	 ];

	[l_sharedEAGLView drawTextureIndex:TEXTURE_THEATRE_ARROW
								  plan:PLAN_SKY_SHADOW
								  size:0.2f
							 positionX:m_skyDecay.x * l_size * 2.6f + 5.f
							 positionY:-0.55f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:.9
							  distance:-1.f
								decayX:0.f
								decayY:0.f
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_THEATRE_STICK
								  plan:PLAN_SKY_SHADOW
								  size:0.2f
							 positionX:m_skyDecay.x * l_size * 2.6f + 5.f
							 positionY:-0.7f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:.9
							  distance:-1.f
								decayX:0.f
								decayY:0.f
	 ];
	
    [self  UpdateHelpPanel:a_timeInterval];
	[super UpdateWithTimeInterval:a_timeInterval];
}

// Update help panel.
-(void)UpdateHelpPanel:(NSTimeInterval)a_timeInterval
{
    EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
    float l_size	 = m_levelData.m_size;
    m_helpPosition.y +=  m_helpSpeed.y *a_timeInterval;
	m_helpPosition.y = clip(m_helpPosition.y, -0.1f, 2.f);
    
	// display the thanks panel.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_INTRO_THANKS
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 0.6
							 positionX:m_helpPosition.x
							 positionY:m_helpPosition.y
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:0.f
								decayY:0.f
	 
	 ];	
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_THEATRE_STICK
								  plan:PLAN_SKY_SHADOW
								  size:0.3
							 positionX:m_helpPosition.x + 0.4f
							 positionY:m_helpPosition.y + l_size * 0.6
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1. / 20.
							  distance:-1.f
								decayX:0.f
								decayY:0.f
	 
	 ];	
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_THEATRE_STICK
								  plan:PLAN_SKY_SHADOW
								  size:0.3
							 positionX:m_helpPosition.x - 0.4f
							 positionY:m_helpPosition.y + l_size * 0.6
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1. / 20.
							  distance:-1.f
								decayX:0.f
								decayY:0.f
	 
	 ];	
}

// init pendulum.
-(void)InitStick
{
	// init the snake.
	CGPoint l_basePosition;
	CGPoint l_pendulumPosition;
	
	m_titleSpeed = CGPointMake(0.f, 0.f);
	m_titlePosition = CGPointMake(0.f, 1.3f);
	l_basePosition = m_titlePosition;
	l_pendulumPosition = CGPointMake(l_basePosition.x + STICK_LENGTH * 0.1, l_basePosition.y - STICK_LENGTH * 0.78f);
	
	m_pendulumTitle = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition 
												  basePosition:l_basePosition 
														  mass:10.f 
											   angleSpeedLimit:-1.f
													   gravity:0.07
												  gravityAngle:0.
													  friction:0.03f
												  addInTheList:YES
					   ];
}

// Update title panel.
-(BOOL)UpdateTitle:(NSTimeInterval)a_timeInterval
{
	m_titlePosition.y += m_titleSpeed.y * a_timeInterval;
	[m_pendulumTitle UpdateWithBasePosition:m_titlePosition timeFrame:a_timeInterval];
	
	CGPoint l_stickPosition = [m_pendulumTitle GetPosition];
	CGPoint l_stickEndPosition = CGPointMake(m_titlePosition.x + (l_stickPosition.x - m_titlePosition.x) * 1.6, m_titlePosition.y + (l_stickPosition.y - m_titlePosition.y) * 1.6);
	float l_angle = [m_pendulumTitle m_angle];
	
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_INTRO_TITLE
										   plan:PLAN_PENDULUM
										   size:0.5
									  positionX:l_stickEndPosition.x
									  positionY:l_stickEndPosition.y
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE(l_angle)
								rotationCenterX:l_stickPosition.x
								rotationCenterY:l_stickPosition.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:true
									deformation:0.f
									   distance:50.f
	 ];
	
	CGPoint l_position;
	l_position = CGPointMake(m_titlePosition.x + (l_stickPosition.x - m_titlePosition.x) / 1.6, 
							 m_titlePosition.y + (l_stickPosition.y - m_titlePosition.y) / 1.6);
	
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_THEATRE_STICK
										   plan:PLAN_PENDULUM
										   size:	STICK_LENGTH / 2.3
									  positionX:l_position.x
									  positionY:l_position.y - 0.05
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE(l_angle)
								rotationCenterX:l_stickPosition.x
								rotationCenterY:l_stickPosition.y
								   repeatNumber:1
								  widthOnHeight:1.f / 16.f
									 nightBlend:false
									deformation:0.f
									   distance:50.f
	 ];
	
	return YES;
}

// updtate the puppet.
-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval
{
	[m_puppet UpdateWithPosition:m_fingerPosition[0] timeInterval:a_timeInterval];
	return YES;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	m_luluLeft = a_touchLocation.x < m_fingerPosition[0].x;
	m_fingerPosition[0] = a_touchLocation;
	if(m_fingerPosition[0].x > 0.9f)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateMenu alloc] init]];
	}
	else if(m_fingerPosition[0].x < -.9f)
	{
		m_helpSpeed = CGPointMake(0.f, -1.f);
	}
	else
	{
		m_helpSpeed = CGPointMake(0.f, 1.f);
	}

	m_titleSpeed.y = 1.f;
	
	return;
}

-(NSArray *)GetSoundArray
{
    return [NSArray arrayWithObjects:@"wind", @"string", @"grind", nil];
}

-(void)Terminate
{
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];

	[m_puppet release];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

@end
