//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatreLarveOut.h"
#import "StateSpiral.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleBeast.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "Puppet.h"
#import "ParticleLetter.h"

#define STICK_LENGTH 1.
#define GROUND_Y -0.6f
#define TIME_BEFORE_OPEN_CURTAINS 2.f
#define SPEED_LULU_TURN .3f
#define SPEED_LULU_WALK .06f
#define TIMER_BEFORE_HEAD_FALL 8.f
#define TIME_MIN_BEFORE_QUIT 5.f

@implementation StateTheatreLarveOut

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
	m_levelData.m_arraySize = TEXTURE_T_LARVEOUT_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"luluTitleBack.png"];
	m_levelData.m_textureArray[TEXTURE_T_LARVEOUT_SHADOW_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_T_LARVEOUT_PUPPET_MARIO] = [[NSString alloc] initWithString:@"puppetMario.png"];
	m_levelData.m_textureArray[TEXTURE_T_LARVEOUT_PUPPET_MARIO_OPEN_MOUTH] = [[NSString alloc] initWithString:@"puppetMarioOpenMouth.png"];
	m_levelData.m_textureArray[TEXTURE_T_LARVEOUT_PUPPET_SNAKE] = [[NSString alloc] initWithString:@"puppetSnakeDecomposed.png"];	
	m_levelData.m_textureArray[TEXTURE_T_LARVEOUT_SNAKE_HEAD] = [[NSString alloc] initWithString:@"puppetSnakeHead.png"];	
	
	m_skyDecay = CGPointMake(0., 0.);
	m_time = 0.f;
	m_headFall = NO;
	m_headEaten = NO;
	m_sequenceStart = NO;
	m_headDeformation = 1.f;
		
	m_fingerPosition[0] = CGPointMake(0.7f, 0.8f) ;
	m_fingerPosition[1] = CGPointMake(-0.8f, 0.8f);
	m_headSpeed = CGPointMake(1.f, 1.f);
	m_headPosition = CGPointMake(0.f, 0.f);
	m_mappingFingerZeroToPuppet = 0;
	
	[ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_THEATRE_WING_0 lastFrame:TEXTURE_THEATRE_WING_1 duration:0.07]
						 angle:(M_PI / 2.5) * 180 / M_PI
				  texturePause:TEXTURE_THEATRE_WING_0
					  sizeWing:1.7f
	 ];
	
	m_puppet[0] = [[Puppet alloc] InitWithTexturePuppet:TEXTURE_T_LARVEOUT_PUPPET_MARIO 
												  Stick:TEXTURE_THEATRE_STICK 
										   InitPosition:m_fingerPosition[0]
										  PanelSequence:nil
				   ];
	
	m_puppet[1] = [[Puppet alloc] InitWithTexturePuppet:TEXTURE_T_LARVEOUT_PUPPET_SNAKE 
												  Stick:TEXTURE_THEATRE_STICK 
										   InitPosition:m_fingerPosition[1]
										  PanelSequence:nil
				   ];

	return [super StateInit];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	if(m_sequenceStart)
	{
		m_time += a_timeInterval;
	}
	// this is just to have a clearer code.
	if(![self UpdatePuppet:a_timeInterval])
	{
		return;
	}
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
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
							  distance:30.f
	 ];
	
	m_skyDecay.x += !m_headEaten ? 0.f : -a_timeInterval * SPEED_LULU_WALK;
	
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
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_LARVEOUT_SHADOW_FRONT
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
	
	[super UpdateWithTimeInterval:a_timeInterval];
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval
{
	float l_puppetDeformation = 1.f;
	
	[m_puppet[0] UpdateWithPosition:m_fingerPosition[m_mappingFingerZeroToPuppet] timeInterval:a_timeInterval];
	[m_puppet[1] UpdateWithPosition:m_fingerPosition[(m_mappingFingerZeroToPuppet + 1) % 2] timeInterval:a_timeInterval];
	
	if(m_time > TIMER_BEFORE_HEAD_FALL)
	{
		if(!m_headFall)
		{
			[m_puppet[0] SetTexture:TEXTURE_T_LARVEOUT_PUPPET_MARIO_OPEN_MOUTH];
			m_headFall = YES;
		}
		
		m_headSpeed.y -= 1.f * a_timeInterval;
		m_headPosition.x += m_headSpeed.x * a_timeInterval;
		m_headPosition.y += m_headSpeed.y * a_timeInterval;
		m_headPosition.y = max(m_headPosition.y, GROUND_Y);
		m_headSpeed.x *= 1.f - 2.f * a_timeInterval;
		if((m_headPosition.y - EPSILON < GROUND_Y) && (DistancePoint([m_puppet[0] GetPosition], m_headPosition) < 0.4) && !m_headEaten)
		{
			NSArray * l_sequenceMario = [[NSArray alloc] initWithObjects:[[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_HAPPY begin:0. end:5. ] autorelease],
										 nil
										 ];
			
			[m_puppet[0] SetSequence:l_sequenceMario];
			m_headEaten = YES;
			m_go = YES;
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"crok" Volume:0.7f];
		}
	}
	else
	{
		m_headPosition = [m_puppet[1] GetPosition];
		m_headSpeed = CGPointMake(m_headPosition.x > 0.f ? -.4f : 0.4f, 0.5f);
		l_puppetDeformation = [m_puppet[1] GetDeformation];
	}
	
	if(m_headEaten)
	{
		m_headDeformation = max(m_headDeformation - 2.f * a_timeInterval, 0.f);
	}

	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_T_LARVEOUT_SNAKE_HEAD
										   plan:PLAN_PENDULUM
										   size:0.1
									  positionX:m_headPosition.x + l_puppetDeformation * 0.2f
									  positionY:m_headPosition.y
									  positionZ:0.
								  rotationAngle:0.f
								rotationCenterX:0.f
								rotationCenterY:0.f
								   repeatNumber:1
								  widthOnHeight:l_puppetDeformation * m_headDeformation
									 nightBlend:true
									deformation:0.f
									   distance:50.f
	 ];
	return YES;
}

-(void)LaunchSequence
{
	if(!m_sequenceStart)
	{  
		NSArray * l_sequenceSnake = [[NSArray alloc] initWithObjects:[[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_HAPPY begin:1. end:6.] autorelease],
									 [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_PRESENT begin:TIMER_BEFORE_HEAD_FALL - 2.f end:TIMER_BEFORE_HEAD_FALL + 3.f] autorelease],
									 nil
									 ];
		
		[m_puppet[1] SetSequence:l_sequenceSnake]; 
		
		NSArray * l_sequenceMario = [[NSArray alloc] initWithObjects:[[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_POKER_FACE begin:1. end:5. ] autorelease],
									 [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_SURPRISE begin:TIMER_BEFORE_HEAD_FALL - 1.f end:TIMER_BEFORE_HEAD_FALL + 5.f] autorelease],
									 nil
									 ];
		
		[m_puppet[0] SetSequence:l_sequenceMario];
		m_sequenceStart = YES;
	}	
}

// Multi touch event.
-(void)Touch:(CGPoint)a_touchLocation
{
	int l_newMapping;
	if(DistancePoint(a_touchLocation, m_fingerPosition[m_mappingFingerZeroToPuppet]) > DistancePoint(a_touchLocation, m_fingerPosition[(m_mappingFingerZeroToPuppet + 1) % 2]))
	{
		l_newMapping = 1;
	}
	else
	{
		l_newMapping = 0;
	}
	
	if(m_mappingFingerZeroToPuppet != l_newMapping)
	{
		m_fingerPosition[1] = m_fingerPosition[0];
		m_fingerPosition[0] = a_touchLocation;
	}
	m_mappingFingerZeroToPuppet = l_newMapping;

	[self LaunchSequence];
	
	return;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	m_fingerPosition[0] = a_touchLocation;
	if(m_go && m_fingerPosition[0].x > .9f)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateSpiral alloc] init]];
		[[OpenALManager sharedOpenALManager] FadeWithKey:@"morvan" duration:2.f volume:0.f stopEnd:YES];
	}
	
	return;
}

// Multi touch event.
-(void)MultiTouch:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	int l_newMapping;
	if(DistancePoint(a_touchLocation1, m_fingerPosition[m_mappingFingerZeroToPuppet]) > DistancePoint(a_touchLocation1, m_fingerPosition[(m_mappingFingerZeroToPuppet + 1) % 2]))
	{
		l_newMapping = 1;
	}
	else
	{
		l_newMapping = 0;
	}
	
	if(m_mappingFingerZeroToPuppet != l_newMapping)
	{
		m_fingerPosition[1] = a_touchLocation2;
		m_fingerPosition[0] = a_touchLocation1;
	}
	m_mappingFingerZeroToPuppet = l_newMapping;
	
	[self LaunchSequence];
	
	return;
}

// Multi touch event.
-(void)MultiTouchMove:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	m_fingerPosition[0] = a_touchLocation1;
	m_fingerPosition[1] = a_touchLocation2;
	
	if(m_go && (m_time > TIME_MIN_BEFORE_QUIT) && (a_touchLocation1.x > .9f || a_touchLocation2.x > .9f))
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateSpiral alloc] init]];
	}
	return;
}

-(void)Terminate
{
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"music2"];
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	[m_puppet[0] release];
	[m_puppet[1] release];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

-(id)GetNoteBook
{
	return [[NoteBook alloc] InitWithString:@"The blue scutigerus seems to have morphed,_ more entropic_££££££££ethereal maybe. A dark jelly thing made the scutigerus fall££££glide down from a tree. Wild creatures are very mysterious. L."
								MusicToFade:@"morvan"
			];
}


@end
