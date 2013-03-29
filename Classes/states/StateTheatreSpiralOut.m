//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatreSpiralOut.h"
#import "StateParticleFight.h"
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

@implementation StateTheatreSpiralOut

-(void)StateInit
{
	m_index = STATE_SPIRAL;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_T_SPIRALOUT_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"luluTitleBack.png"];
	m_levelData.m_textureArray[TEXTURE_T_SPIRALOUT_SHADOW_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_T_SPIRALOUT_BIG_ARM] = [[NSString alloc] initWithString:@"bigMonsterArm.png"];
	m_levelData.m_textureArray[TEXTURE_T_SPIRALOUT_BIG_MONSTER] = [[NSString alloc] initWithString:@"bigMonster.png"];
	m_levelData.m_textureArray[TEXTURE_T_SPIRALOUT_PUPPET_MARIO_DEAD] = [[NSString alloc] initWithString:@"puppetMarioDead.png"];
	m_levelData.m_textureArray[TEXTURE_T_SPIRALOUT_PUPPET_SNAKE] = [[NSString alloc] initWithString:@"puppetSnakeDecomposed.png"];	
	
	m_skyDecay = CGPointMake(0., 0.);
	m_time = 0.f;
	m_sequenceStart = YES;
	m_headDeformation = 1.f;
		
	m_fingerPosition[0] = CGPointMake(0.7f, 0.8f) ;

	m_mappingFingerZeroToPuppet = 0;

	CGPoint l_basePosition = CGPointMake(0.f, 0.f);
	CGPoint l_pendulumPosition = CGPointMake(l_basePosition.x + 0.1, l_basePosition.y - 0.4);
	m_marioDead = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition basePosition:l_basePosition mass:2.f angleSpeedLimit:5.f  gravity:0.05 gravityAngle:0.f friction:0. addInTheList:YES];
	
	[ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_THEATRE_WING_0 lastFrame:TEXTURE_THEATRE_WING_1 duration:0.07]
						 angle:(M_PI / 2.5) * 180 / M_PI
				  texturePause:TEXTURE_THEATRE_WING_0
					  sizeWing:1.7f
	 ];
	
	NSArray * l_sequencePuppet = [[NSArray alloc] initWithObjects:[[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_SURPRISE begin:2. end:5. ] autorelease],
													[[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_SCARED begin:5. end:120. ] autorelease],
													nil
								 ];
	
	m_puppet = [[Puppet alloc] InitWithTexturePuppet:TEXTURE_T_SPIRALOUT_PUPPET_SNAKE 
												  Stick:TEXTURE_THEATRE_STICK 
										   InitPosition:m_fingerPosition[0]
										  PanelSequence:l_sequencePuppet
				   ];
	
	return [super StateInit];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	if(m_sequenceStart)
	{
		m_time += a_timeInterval;
	}
	
	if(m_time > 5.f)
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
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_SPIRALOUT_SHADOW_FRONT
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
	m_fingerPosition[0].x = max(-0.2f, m_fingerPosition[0].x);
	[m_puppet UpdateWithPosition:m_fingerPosition[m_mappingFingerZeroToPuppet] timeInterval:a_timeInterval];
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	[m_marioDead UpdateWithBasePosition:CGPointMake(0.f, 0.f) timeFrame:a_timeInterval];
	float l_angle = [m_marioDead m_angle];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_SPIRALOUT_PUPPET_MARIO_DEAD
										   plan:PLAN_PENDULUM
										   size:0.8f
									  positionX:-0.5
									  positionY:0.3f
									  positionZ:0.
								  rotationAngle:RADIAN_TO_DEDREE(l_angle) + 20.f
								rotationCenterX:0.f
								rotationCenterY:0.f
								   repeatNumber:1
								  widthOnHeight:0.25
									 nightBlend:NO
									deformation:0.f
									   distance:50.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:-1
										reverse:REVERSE_NONE
	 ];
	
	[l_sharedEAGLView SetBlur:.3f];
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_SPIRALOUT_BIG_MONSTER
								  plan:PLAN_SKY_SHADOW
								  size:0.7f
							 positionX:-1.f
							 positionY:-0.4f
							 positionZ:0.
						 rotationAngle:RADIAN_TO_DEDREE(l_angle /  2.f)
					   rotationCenterX:0.f
					   rotationCenterY:0.f
						  repeatNumber:1
						 widthOnHeight:1.f
							nightBlend:NO
						   deformation:0.f
							  distance:50.f
								decayX:0.f
								decayY:0.f
								 alpha:1.f
								planFX:-1
							   reverse:REVERSE_NONE
	 
	 ];
	
	[l_sharedEAGLView SetBlur:0.f];	

	return YES;
}

// Multi touch event.
-(void)Touch:(CGPoint)a_touchLocation
{
	m_fingerPosition[0] = a_touchLocation;
	
	return;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	m_fingerPosition[0] = a_touchLocation;
	if(m_fingerPosition[0].x > 1.0f)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateParticleFight alloc] init]];
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
	
	return;
}

// Multi touch event.
-(void)MultiTouchMove:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	m_fingerPosition[0] = a_touchLocation1;
	m_fingerPosition[1] = a_touchLocation2;
	
	if(a_touchLocation1.x > 1.0f || a_touchLocation2.x > 1.0f)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateParticleFight alloc] init]];
	}
	return;
}

-(void)Terminate
{
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"morvan"];
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	[m_puppet release];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

-(id)GetNoteBook
{
	return [[NoteBook alloc] InitWithString:@"Am I dreaming? _Everything is so confusing!£._ A spiral_££££££££I've lost sight of the jelly thing. Something seems to have snatched it. I'm happy I'm not flavorful today. L."
								MusicToFade:@"musicTripouille"];
}

@end
