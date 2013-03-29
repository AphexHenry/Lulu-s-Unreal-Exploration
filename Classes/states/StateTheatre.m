//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatre.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"
#import "ParticleManager.h"
#import	"OpenALManager.h"

#define THEATRE_STICK_LENGTH 1.
#define THEATRE_GROUND_Y -1.6f
#define THEATRE_SPEED_LULU_TURN .3f
#define THEATRE_SPEED_LULU_WALK .06f
#define ARROW_IDLE_DURATION 6.

@implementation StateTheatre

-(void)StateInit
{	
	m_fingerCount = 0;
	
    // init texture.
	m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_HAPPY] = [[NSString alloc] initWithString:@"panelHappy.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_POKER_FACE] = [[NSString alloc] initWithString:@"panelPokerFace.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_PRESENT] = [[NSString alloc] initWithString:@"panelPresent.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_SURPRISE] = [[NSString alloc] initWithString:@"panelSurprise.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_SCARED] = [[NSString alloc] initWithString:@"panelScared.png"];
    m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_CIRCLE] = [[NSString alloc] initWithString:@"panelCircle.png"];
    m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_EGUAL] = [[NSString alloc] initWithString:@"panelEgual.png"];
    m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_SQUARE] = [[NSString alloc] initWithString:@"panelSquare.png"];
    m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_YOKAI] = [[NSString alloc] initWithString:@"panelYokai.png"];
    m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_UP] = [[NSString alloc] initWithString:@"panelUp.png"];
    m_levelData.m_textureArray[TEXTURE_THEATRE_PANEL_DOWN] = [[NSString alloc] initWithString:@"panelDown.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_WING_0] = [[NSString alloc] initWithString:@"wings0.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_WING_1] = [[NSString alloc] initWithString:@"wings1.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_FINGER_GUI] = [[NSString alloc] initWithString:@"finger.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_ARROW] = [[NSString alloc] initWithString:@"arrow.png"];
	
    // Set openGL.
	EAGLView *l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView SetCameraUpdatable:YES];
	[l_sharedEAGLView initLevel:m_levelData];
	[l_sharedEAGLView SetCamera:CAMERA_CLOSE];
	[l_sharedEAGLView SetBlur:0.];
	[l_sharedEAGLView SetScale:1.3 force:YES];
	[l_sharedEAGLView SetTranslate:CGPointMake(0.f, -0.1f) forType:CAMERA_CLOSE force:NO];
	[l_sharedEAGLView SetCameraUpdatable:NO];
	
    // block help.
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:YES];
	
	m_go = NO;
	m_goTimer = 0.;
	m_moonDistance[0] = 0.f;
	m_moonDistance[1] = 0.f;
	m_luminosityFluctuationCoeff = 2.f;
	
	CGPoint l_basePosition = CGPointMake(0.f, 0.f);
	CGPoint l_pendulumPosition = CGPointMake(-.4f, 0.f);
	
	m_goPendulum = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition 
								basePosition:l_basePosition 
										mass:10.f 
							 angleSpeedLimit:-1.f
									 gravity:0.07
								gravityAngle:0.
									friction:0.3f
								addInTheList:YES
	 ];
	[[ParticleManager sharedParticleManager] ActiveDeadParticles];
	
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"grind" Volume:0.f];
	
	return [super StateInit];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	[[ParticleManager sharedParticleManager] UpdateParticlesWithTimeInterval:a_timeInterval];
	[[ParticleManager sharedParticleManager] drawself];
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	//low pass the luminosity variation.
	m_moonDistance[0] = (m_moonDistance[0] + myRandom() * m_luminosityFluctuationCoeff) * 0.5f;
	m_moonDistance[1] = (m_moonDistance[0] + m_moonDistance[1]) * 0.5f;
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_MOON
										   plan:PLAN_BACKGROUND_STICKERS
										   size:8.6
									  positionX:0.2
									  positionY:.8
									  positionZ:0.
								   repeatNumber:1
								  widthOnHeight:1.
									   distance:m_moonDistance[1]
	 ];
	
	if(m_go)
	{
		m_goTimer += a_timeInterval;
		float l_xPosition = max((m_goTimer - ARROW_IDLE_DURATION) * 0.5, 0.f);
		[m_goPendulum UpdateWithBasePosition:CGPointMake(l_xPosition, 0.f) timeFrame:a_timeInterval];
		float l_angle = [m_goPendulum m_angle] - M_PI / 2.f;
		float l_size = 0.3f;
		float l_height = 0.5f;
		[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_THEATRE_ARROW
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
		
		[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"grind" Volume:1.f / (l_xPosition + 1.f)];
	}
}

-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval
{
	return YES;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{

	return;
}

-(void)Terminate
{
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
	
	[[ParticleManager sharedParticleManager] KillParticles];
	
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"grind"];
}

@end
