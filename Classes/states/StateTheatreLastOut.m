//
//  StateTheatreLastOut.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "StateIntro.h"
#import "StateTheatreLastOut.h"
#import "StateTheatreRateIt.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleBeast.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "Puppet.h"
#import "ParticleLetter.h"

#define TIME_MIN_BEFORE_QUIT 3.f
#define STATE_FLY_OUT_TIME_TO_FADE 10.f

@implementation StateTheatreLastOut

-(void)StateInit
{
	m_index = STATE_LARVE;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_T_FLYOUT_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"ForestBack.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLYOUT_SHADOW_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLYOUT_PUPPET_MESSAGE] = [[NSString alloc] initWithString:@"panel.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLYOUT_PUPPET_SNAKE] = [[NSString alloc] initWithString:@"puppetSnakeDecomposed.png"];	
	
	m_skyDecay = CGPointMake(0., 0.);
	m_time = 0.f;
	m_sequenceStart = NO;
	
	m_fingerPosition[0] = CGPointMake(0.7f, 0.8f) ;
	m_fingerPosition[1] = CGPointMake(-0.8f, 0.8f);
	
	[ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_THEATRE_WING_0 lastFrame:TEXTURE_THEATRE_WING_1 duration:0.07]
						 angle:(M_PI / 2.5) * 180 / M_PI
				  texturePause:TEXTURE_THEATRE_WING_0
					  sizeWing:1.7f
	 ];
	
	m_puppet = [[Puppet alloc] InitWithTexturePuppet:TEXTURE_T_FLYOUT_PUPPET_SNAKE 
												  Stick:TEXTURE_THEATRE_STICK 
										   InitPosition:m_fingerPosition[1]
										  PanelSequence:nil
				   ];
	
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"treeFriction" duration:2. volume:0.1f stopEnd:NO];

	return [super StateInit];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	m_time += a_timeInterval;

	if(m_time > 20.)
	{
		m_go = YES;
	}
	// this is just to have a clearer code.
	if(![self UpdatePuppet:a_timeInterval])
	{
		return;
	}
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_size	 = m_levelData.m_size;
	m_skyDecay.x += 0.5 * a_timeInterval;
	
	// draw background.
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
							  distance:30.f
	 ];

	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:l_size
							 positionX:0.f
							 positionY:-1.1f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:m_skyDecay.x * 0.5
								decayY:0.f
	 
	 ];
	
	// draw background.
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_T_FLYOUT_PUPPET_MESSAGE
										   plan:PLAN_SKY_SHADOW
										   size:l_size * 1.3f
									  positionX:0.
									  positionY:-1.
									  positionZ:0.
								  rotationAngle:m_time * 27.
								rotationCenterX:0.
								rotationCenterY:0.
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:-1.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_STICKERS
										reverse:REVERSE_NONE
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_FLYOUT_SHADOW_FRONT
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 1.2
							 positionX:0.f
							 positionY:-0.5f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:m_skyDecay.x
								decayY:0.f
	 
	 ];
	
	[super UpdateWithTimeInterval:a_timeInterval];
	
	float a_introCoeff = pow(min(m_time / STATE_FLY_OUT_TIME_TO_FADE, 1.f), 2.f);
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"grind" Volume:a_introCoeff * 1.5f];
	[l_sharedEAGLView SetLuminosity:a_introCoeff];
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval
{	
	[m_puppet UpdateWithPosition:CGPointMake(m_fingerPosition[0].x, max(m_fingerPosition[0].y + 0.5, 0.5)) timeInterval:a_timeInterval];

	return YES;
}

-(void)LaunchSequence
{
	if(!m_sequenceStart)
	{  
		NSArray * l_sequenceSnake = [[NSArray alloc] initWithObjects:[[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_HAPPY begin:1. end:9.] autorelease],
									 nil
									 ];
		
		[m_puppet SetSequence:l_sequenceSnake]; 
		
		m_sequenceStart = YES;
	}	
}

//
// Touch event.
//
-(void)Touch:(CGPoint)a_touchLocation
{
	[self LaunchSequence];
	
	return;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	m_fingerPosition[0] = a_touchLocation;
	
	if((m_time > TIME_MIN_BEFORE_QUIT) && m_fingerPosition[0].x > 1.05f)
	{
		BOOL l_isConnected = [StateTheatreRateIt connectedToNetwork];
		
		if(([[ApplicationManager sharedApplicationManager] GetRated] == [StateTheatreRateIt GetVersion]) || !l_isConnected)
		{
			[[ApplicationManager sharedApplicationManager] ChangeState:[[StateIntro alloc] init]];
		}
		else
		{
			[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreRateIt alloc] init]];
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"treeFriction" Volume:0.f];
			[[OpenALManager sharedOpenALManager] FadeWithKey:@"treeFriction" duration:1.5f volume:0.2f stopEnd:NO];
		}
	}
	
	return;
}

//
// Multi touch event.
//
-(void)MultiTouch:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{	
	[self LaunchSequence];
	
	return;
}

// Multi touch event.
-(void)MultiTouchMove:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	m_fingerPosition[0] = a_touchLocation1;
	m_fingerPosition[1] = a_touchLocation2;
	
	if((m_time > TIME_MIN_BEFORE_QUIT) && (a_touchLocation1.x > .9f || a_touchLocation2.x > .9f))
	{
		if([[ApplicationManager sharedApplicationManager] GetRated] == 1)
		{
			[[ApplicationManager sharedApplicationManager] ChangeState:[[StateIntro alloc] init]];
		}
		else
		{
			[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreRateIt alloc] init]];
		}
	}
	return;
}

-(void)Terminate
{
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"musicAphex" duration:2. volume:0.f stopEnd:YES];
	
	[m_puppet release];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

-(id)GetNoteBook
{
	return [[NoteBook alloc] InitWithString:[NSString stringWithString:@"My exploration is done, for now._ There runs a mouse; whosoever catches it, may make himself a big fur cap out of it. L."]
								MusicToFade:@"SeaStateNormal"
			];
		
}

@end
