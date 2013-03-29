//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateLarve.h"
#import "StateIntro.h"
#import "StateTheatreLarveOut.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleManager.h"
#import "ParticleBeast.h"
#import "ApplicationManager.h"
#import "ParticleLightBug.h"
#import	"OpenALManager.h"
#import "Animation.h"

#define NB_PARTICLE 75
#define STICK_LENGTH 2.2
#define GROUND_Y -1.5f
#define TIME_BEFORE_FINAL_RUSH 14.f
#define TIME_BEFORE_CAMERA_GO_TO_LIGHT 3.
#define TIME_BEFORE_HELP 12.
#define SNAKE_DISTANCE 30.f
#define SNAKE_CAMERA_POSITION CGPointMake(1.2, -1.2)
#define TIME_TO_NULL_GRAVITY 140.f
#define TIME_BEFORE_SPIT_MARIO 6.f
#define LARVE_PENDULUM_FRICTION 0.04f
#define LARVE_PENDULUM_GRAVITY 0.2f

@implementation StateLarve

-(void)StateInit
{
	m_index = STATE_LARVE;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 2.f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_LARVE_COUNT;
	m_finalRush = 0.;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"nightSky.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"larveAround.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_BACKGROUND_CLOSE] = [[NSString alloc] initWithString:@"larveBack.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_MIST] = [[NSString alloc] initWithString:@"mist.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_SNAKE_BODY] = [[NSString alloc] initWithString:@"LuluBody.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_SNAKE_HEAD_OPEN_MOUTH] = [[NSString alloc] initWithString:@"LuluHeadLookAhead.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_SNAKE_HEAD_CLOSE_MOUTH] = [[NSString alloc] initWithString:@"LuluHeadCloseMouth.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_SNAKE_HEAD_PROFILE] = [[NSString alloc] initWithString:@"LuluHeadProfile.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_LUCIOLE] = [[NSString alloc] initWithString:@"roseThing.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"wallSulpiceShadow.png"];
	m_levelData.m_textureArray[TEXTURE_GLOW_LIGHT] = [[NSString alloc] initWithString:@"lightGlow.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_PANEL] = [[NSString alloc] initWithString:@"panel.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_PAYSAGE] = [[NSString alloc] initWithString:@"paysage.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_BEAST_FRAME_0] = [[NSString alloc] initWithString:[[ApplicationManager sharedApplicationManager] GetABeastName]];
	
	m_levelData.m_textureArray[TEXTURE_LARVE_MARIO_BODY] = [[NSString alloc] initWithString:@"marioBody.png"];
	m_levelData.m_textureArray[TEXTURE_LARVE_MARIO_EYES] = [[NSString alloc] initWithString:@"marioEyes.png"];	
	m_levelData.m_textureArray[TEXTURE_LARVE_MARIO_FALL] = [[NSString alloc] initWithString:@"marioFall.png"];	
	m_levelData.m_textureArray[TEXTURE_LARVE_MARIO_ORA] = [[NSString alloc] initWithString:@"marioOra.png"];
	
	m_aroundTextureDeformationFrequency = 1.f;
	m_panelTaken = NO;
	m_hasFalled = NO;
	m_snakeFall = NO;

	m_fingerPosition = CGPointMake(1.f, -1.f);
	m_skyDecay = CGPointMake(0., 0.);
	m_beattleFallTimer = 0.;
	m_updateMario = NO;
	m_lightTaken = NO;
	m_stickCanBeStuck = NO;
	m_glowDeformation = 0.f;
	m_lightGlowPosition = CGPointMake(1.2f, (m_levelData.m_size / 1.5f));
	m_biteCount = 0;
	m_stickTimer = 0.f;
	
    // Init Opengl.
	EAGLView *l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView SetCamera:CAMERA_CLOSE];
	[l_sharedEAGLView SetCameraUpdatable:YES];
	[l_sharedEAGLView initLevel:m_levelData];
	[l_sharedEAGLView SetBlur:0.];
	[l_sharedEAGLView SetScale:1.1 force:YES];
	[l_sharedEAGLView SetTranslate:SNAKE_CAMERA_POSITION forType:CAMERA_CLOSE force:YES];
	[l_sharedEAGLView SetCameraUpdatable:FALSE];
	
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"wind" Volume:0.8f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"noiseGrass" Volume:0.f];
	
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	for (int i = 0; i < NB_PARTICLE - 1; i++)
	{
		[l_particleManager AddParticle:[[ParticleRose alloc] initWithTexture:TEXTURE_LARVE_LUCIOLE]];
	}

	for (int i = 0; i < 16; i++)
	{
		[l_particleManager AddParticle:[[ParticleRose alloc] initWithTexture:TEXTURE_LARVE_SNAKE_BODY]];
	}
	[ParticleRose SetDistance:SNAKE_DISTANCE];
    [ParticleRose SetXTranslate:0.f];
	
	ParticleBeast * l_particleBeast = [[ParticleBeast alloc] init];
	[l_particleBeast SetAnimation:TEXTURE_LARVE_BEAST_FRAME_0];
	[l_particleManager AddParticle:l_particleBeast];
	[l_particleManager ActiveDeadParticlesFromGroup:PARTICLE_GROUP_BEAST];
	[l_particleManager ActiveDeadParticles:120];
	
	m_mario = [[Mario alloc] init:
						CGPointMake(-8.2f, GROUND_Y) 
						groundY:GROUND_Y 
						animation:[[Animation alloc] initWithFirstFrame:TEXTURE_LARVE_MARIO_EYES lastFrame:TEXTURE_LARVE_MARIO_EYES duration:10.4] 
						bodyTexture:TEXTURE_LARVE_MARIO_BODY
						fallTexture:TEXTURE_LARVE_MARIO_FALL
						 fallSize:0.2
			   ];
	
	[ParticleRose SetGroundY:GROUND_Y - 0.3];
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:YES];
	
	[self performSelector:@selector(CameraGoToLight) withObject:nil afterDelay:TIME_BEFORE_CAMERA_GO_TO_LIGHT];
	
	[self performSelector:@selector(CallHelp) withObject:nil afterDelay:TIME_BEFORE_HELP];
	
	[self InitSnake];
	[self InitStick];
	return [super StateInit];
}

-(id)InitFromMenu
{
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"wind"];
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"string2"];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"string2" duration:0.7f volume:0.f stopEnd:YES];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"music2" Volume:0.f];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"music2" duration:2.f volume:0.55f stopEnd:NO];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"ambientSwamp" Volume:0.9f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"craquement mystérieux" Volume:0.2f];
	return [self init];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	[self UpdateGlow:a_timeInterval];	
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_currentAroundDeformation =  0.074 * cos(m_aroundTextureDeformation);
	m_aroundTextureDeformationFrequency += myRandom() * a_timeInterval * 0.3;
	m_aroundTextureDeformationFrequency = clip(m_aroundTextureDeformationFrequency, 0.2, 5.);
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	m_aroundTextureDeformation += m_aroundTextureDeformationFrequency * a_timeInterval;
	m_skyDecay.x += -a_timeInterval * 0.01;
	m_skyDecay.y += a_timeInterval * 0.003;
	
	[l_particleManager UpdateParticlesWithTimeInterval:a_timeInterval];
	
	int l_repeatNumber = m_levelData.m_duplicate;
	float l_size	 = m_levelData.m_size;
	
	m_beattleFallTimer += a_timeInterval;

	if(m_beattleFallTimer > TIME_BEFORE_SPIT_MARIO)
	{
		if(!m_updateMario)
		{
			if(!m_hasFalled)
			{
				m_fingerPosition = CGPointMake(0.9f, -2.f);
			}
			m_hasFalled = YES;
		}

			if(	m_finalRush > TIME_BEFORE_FINAL_RUSH)
			{
				// saving the level
				[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreLarveOut alloc] init]];
				[[ApplicationManager sharedApplicationManager] SaveLevel:3];
			}
			[m_mario Update:a_timeInterval position:CGPointMake(m_fingerPosition.x - 1.f, m_fingerPosition.y)];
			[m_mario draw];
			CGPoint l_marioSpeed = [m_mario m_speed];

			[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"noiseGrass" Volume:0.04f + .1f * Absf(l_marioSpeed.x)];
		[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"noiseGrass" Pitch: .8f + 0.1f * Absf(l_marioSpeed.x)];
		
		if(!m_panelTaken)
		{
			m_updateMario = YES;
			if(m_hasFalled)
			{
				[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:NO];
				[[OpenALManager sharedOpenALManager] playSoundWithKey:@"crok" Volume:0.7f];
				[[OpenALManager sharedOpenALManager] FadeWithKey:@"music2" duration:9.f volume:0.f stopEnd:YES];
				[l_sharedEAGLView SetCameraUpdatable:TRUE];
				[l_sharedEAGLView SetScale:0.75 force:NO];
				[l_sharedEAGLView SetTranslate:CGPointMake(0., -2.5) forType:CAMERA_CLOSE force:NO];
				m_hasFalled = NO;
			}
			
			m_canEat = YES;
		}
	}
	
	// this is just to have a clearer code.
	if(!([self UpdateSnake:a_timeInterval] && [self UpdateStick:a_timeInterval]))
	{
		return;
	}


	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND
								  size:l_size * 2.f
							 positionX:0.f
							 positionY:0.f
							 positionZ:-1.
						  repeatNumber:l_repeatNumber
						 widthOnHeight:1.f
							  distance:-1.f
	 
	 ];
	
	// draw background.
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_MOON
										   plan:PLAN_BACKGROUND_STICKERS
										   size:1.9
									  positionX:-1.6
									  positionY:.7
									  positionZ:0.
								  rotationAngle:0.
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
	
	float distance = -1.f;//35. + 35. * clip(cos(m_skyDecay.x * (100.f + myRandom() * 50.f)), -1.f, -0.5f);
	
	// draw the head.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_LARVE_BACKGROUND_CLOSE
								  plan:PLAN_SKY_SHADOW
								  size:	l_size
							 positionX:0.f
							 positionY:0.f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.
							nightBlend:false
						   deformation:l_currentAroundDeformation
							  distance:distance
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_LARVE_MIST
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 0.8f
							 positionX:0.f
							 positionY:-1.3f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:3.
							  distance:distance
								decayX:m_skyDecay.x * 1.3f
								decayY:0.f
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_LARVE_PAYSAGE
								  plan:PLAN_SKY_SHADOW
								  size:	l_size
							 positionX:0.f
							 positionY:0.f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.
							nightBlend:false
						   deformation:0.
							  distance:distance
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_LARVE_MIST
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 0.7f
							 positionX:0.f
							 positionY:-0.5f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:3.
							  distance:distance
								decayX:m_skyDecay.x * 1.f
								decayY:0.f
	 ];
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 2.f
							 positionX:0.f 
							 positionY:0.f
							 positionZ:0.f
						 rotationAngle:0.f
					   rotationCenterX:0.f
					   rotationCenterY:0.f
						  repeatNumber:2
						 widthOnHeight:1.
							nightBlend:NO
						   deformation:0.
							  distance:distance
								decayX:m_skyDecay.x
								decayY:m_skyDecay.y
								 alpha:0.7f
								planFX:-1
							   reverse:REVERSE_HORIZONTAL
	 ];
	

	[l_sharedEAGLView drawTextureIndex:TEXTURE_LARVE_MIST
								  plan:PLAN_PARTICLE_BEHIND
								  size:l_size * 0.5f
							 positionX:0.f
							 positionY:-1.5f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:4.
							  distance:-1
								decayX:m_skyDecay.x * 2.f
								decayY:0.f
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_LARVE_BACKGROUND_AROUND
								  plan:PLAN_BACKGROUND_CLOSE
								  size:	l_size
							 positionX:0.f
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
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_LARVE_MIST
								  plan:PLAN_BACKGROUND_CLOSE
								  size:l_size * 0.3f
							 positionX:0.f
							 positionY:-1.7f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:6.
							  distance:-1
								decayX:m_skyDecay.x * 3.5f
								decayY:0.f
	 ];
	
	[l_particleManager drawself];
}

// updtate the glow light.
-(void)UpdateGlow:(NSTimeInterval)a_timeInterval
{
	m_glowDeformation += a_timeInterval * 1.4f;
	float l_deformation = cos(m_glowDeformation);
	float l_currentAroundDeformation =  0.074 * cos(m_aroundTextureDeformation);
	float l_widtgOnHeight = 0.5f / (0.75 + 0.25 * l_deformation * l_deformation);
	float l_size = 0.4f / l_widtgOnHeight;
	CGPoint l_position = CGPointMake(m_lightGlowPosition.x - l_currentAroundDeformation * 2.f, m_lightGlowPosition.y + l_currentAroundDeformation * 0.3f);
	
	if(DistancePointSquare(m_stickEndPosition, l_position) < 0.3)
	{
		if(!m_lightTaken)
		{
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"siurp" Volume:1.f];
		}
		m_lightTaken = YES;
	}
	
	// draw the head.
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_GLOW_LIGHT
								  plan:PLAN_PENDULUM
								  size:l_size
							 positionX:l_position.x
							 positionY:l_position.y
							 positionZ:0.
						 rotationAngle:-l_deformation * 15.f
					   rotationCenterX:2.2f - l_currentAroundDeformation * 2.f
					   rotationCenterY:m_levelData.m_size + l_size
						  repeatNumber:1
						 widthOnHeight:l_widtgOnHeight
							nightBlend:false
						   deformation:l_currentAroundDeformation
							  distance:-1.f
	 ];
}

// init pendulum.
-(void)InitSnake
{
	// init the snake.
	m_pendulumBasePositionScaleCurrent = CGPointMake(0.f, 0.f);
	CGPoint l_basePosition = CGPointMake(0., 0.);
	CGPoint l_pendulumPosition = CGPointMake(l_basePosition.x, l_basePosition.y + 0.01);
	float l_length = m_levelData.m_snakeLengthBetweenHeadAndBody;
	
	// Creation of the head of the snake.
	m_pendulumHead = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition basePosition:l_basePosition mass:150.f angleSpeedLimit:-1.f gravity:.05 gravityAngle:0.f friction:0.25 addInTheList:YES];
	PhysicPendulum * l_currentPendulum = m_pendulumHead; 
	PhysicPendulum * l_childPendulum = nil;
	
	// Creation of the elmeents of the snake.
	for(int i = 0; i < m_levelData.m_snakePartQuantity; i++)
	{
		l_childPendulum = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition basePosition:l_basePosition mass:2.f angleSpeedLimit:5.f  gravity:.05 gravityAngle:0.f friction:0.25 addInTheList:YES];
		[l_currentPendulum AddChild:l_childPendulum];
		l_currentPendulum = l_childPendulum;
		l_basePosition = l_pendulumPosition;
		l_pendulumPosition.y += l_length;
		l_length = m_levelData.m_snakeLengthBetweenParts;
	}
}

// init pendulum.
-(void)InitStick
{
	// init the snake.
	m_pendulumBasePositionScaleCurrent = CGPointMake(0.f, 0.f);
	CGPoint l_basePosition = CGPointMake(1.2, GROUND_Y - 0.5f);
	CGPoint l_pendulumPosition = CGPointMake(l_basePosition.x + STICK_LENGTH, l_basePosition.y);
	
	// Creation of the head of the snake.
	m_pendulumStick = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition 
												  basePosition:l_basePosition 
														  mass:10.f 
											   angleSpeedLimit:-1.f
													   gravity:LARVE_PENDULUM_GRAVITY
													   gravityAngle:0.f
													  friction:LARVE_PENDULUM_FRICTION
												  addInTheList:NO
					   ];
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateStick:(NSTimeInterval)a_timeInterval
{
	m_stickTimer += a_timeInterval;
	CGPoint l_marioPosition;
	CGPoint l_marioPositionNoXDeformation;
	CGPoint l_position;
	float 	l_angle;
	CGPoint l_stickPosition;
	
	if(m_panelTaken)
	{
		l_marioPosition = [m_mario GetPositionShoulder];
		l_marioPositionNoXDeformation = CGPointMake([m_mario m_position].x, l_marioPosition.y);
		[m_pendulumStick UpdateWithBasePosition:l_marioPositionNoXDeformation timeFrame:a_timeInterval];	
	}

	l_angle	   = [m_pendulumStick m_angle];
	l_stickPosition = [m_pendulumStick GetPosition];
	
	float l_frictionCoeff = (cos(l_angle) < -0.91) ? 1.f : LARVE_PENDULUM_FRICTION;
	l_frictionCoeff = (cos(l_angle) > -0.3) ? 0.f : l_frictionCoeff;
	[m_pendulumStick SetFriction:l_frictionCoeff];
	
	if(cos(l_angle) > 0)
	{
		m_lightTaken = NO;
	}
		
	l_position = CGPointMake(l_marioPosition.x + (l_stickPosition.x - l_marioPosition.x) / 2., 
								 l_marioPosition.y + (l_stickPosition.y - l_marioPosition.y) / 2.f);
		
	m_stickEndPosition = CGPointMake(l_position.x + sin(l_angle) * STICK_LENGTH / 2.3f, 
									 l_position.y - cos(l_angle) * STICK_LENGTH / 2.3f);
	
	if(m_lightTaken)
	{
	   int l_texture;
	   float l_size;
	   
	   l_texture = TEXTURE_GLOW_LIGHT;
	   l_size = 0.2;
		
	   [[EAGLView sharedEAGLView] drawTextureIndex:l_texture
											   plan:PLAN_PENDULUM
											   size:l_size
										  positionX:m_stickEndPosition.x
										  positionY:m_stickEndPosition.y
										  positionZ:0.
									  rotationAngle:RADIAN_TO_DEDREE(l_angle)
									rotationCenterX:m_stickEndPosition.x
									rotationCenterY:m_stickEndPosition.y
									   repeatNumber:1
									  widthOnHeight:1.f 
										 nightBlend:true
										deformation:0.f
										   distance:-1
		 ];
	}
	
	if(m_panelTaken)
	{
		[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_LARVE_STICK
									  plan:PLAN_PENDULUM
									  size:	STICK_LENGTH * 0.5f
								 positionX:l_position.x
								 positionY:l_position.y
								 positionZ:0.
								rotationAngle:RADIAN_TO_DEDREE(l_angle)
						   rotationCenterX:l_position.x
						   rotationCenterY:l_position.y
							  repeatNumber:1
							 widthOnHeight:1.f / 26.f
								nightBlend:false
							   deformation:0.f
								  distance:-1
		 ];
	}
	
	return YES;
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval
{
	CGPoint l_pendulePosition;
	CGFloat l_penduleAngle;
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_currentAroundDeformation =  -0.30 * cos(m_aroundTextureDeformation);
	// smooth the base speed.
	NSTimeInterval l_animationInterval = [ApplicationManager sharedApplicationManager].m_animationInterval;
	
	if(m_snakeFall)
	{
		m_finalRush += a_timeInterval;
		m_pendulumBaseSpeedScaleCurrent.y -= 0.1 * a_timeInterval;
		m_pendulumBasePositionScaleCurrent.x += m_pendulumBaseSpeedScaleCurrent.x * a_timeInterval;
		m_pendulumBasePositionScaleCurrent.y += m_pendulumBaseSpeedScaleCurrent.y * a_timeInterval;
		m_pendulumBasePositionScaleCurrent.y = max(GROUND_Y + 0.1, m_pendulumBasePositionScaleCurrent.y);
	}
	else
	{
		m_pendulumBasePositionScaleCurrent.x = -1.8 + l_currentAroundDeformation;//m_pendulumBasePositionScaleCurrent.x + l_xSpeed * l_animationInterval * l_xSign;
		m_pendulumBasePositionScaleCurrent.y = 0.84 * m_levelData.m_size;//m_pendulumBasePositionScaleCurrent.y + l_ySpeed * l_animationInterval * l_ySign;
	}
	[m_pendulumHead UpdateWithBasePosition:m_pendulumBasePositionScaleCurrent timeFrame:l_animationInterval];
	NSMutableArray * l_pendulumArray = [PhysicPendulum GetList];
	int l_arraySize = [l_pendulumArray count];
	
	// we decrease the size of the snake parts to give it a good shape.
	float l_pendulumBodySizeCoeff = 0.4f;
	
	l_pendulePosition = [[l_pendulumArray objectAtIndex:1] GetPosition];
	l_penduleAngle = [[l_pendulumArray objectAtIndex:1] m_angle];
	
	if(!m_snakeFall)
	{
		[l_sharedEAGLView drawTextureIndex:TEXTURE_LARVE_SNAKE_BODY
									  plan:PLAN_BACKGROUND_SHADOW
									  size:	m_levelData.m_snakeSizeBody * l_pendulumBodySizeCoeff * 1.4
								 positionX:l_pendulePosition.x + 0.05
								 positionY:l_pendulePosition.y - 0.05
								 positionZ:0.
							 rotationAngle:RADIAN_TO_DEDREE(l_penduleAngle) / 2.
						   rotationCenterX:l_pendulePosition.x
						   rotationCenterY:l_pendulePosition.y
							  repeatNumber:1
							 widthOnHeight:1.f
								nightBlend:false
							   deformation:0.f
								  distance:SNAKE_DISTANCE
									decayX:0.f
									decayY:0.f
									 alpha:1.f
									planFX:PLAN_BACKGROUND_CLOSE
								   reverse:REVERSE_NONE
		 ];
	}
	
	if(m_snakeFall)
	{
		l_pendulePosition = m_pendulumBasePositionScaleCurrent;
		l_penduleAngle = 0.3 * M_PI * cos(m_glowDeformation);
	}
	else
	{
		l_pendulePosition = [[l_pendulumArray objectAtIndex:l_arraySize - 1] GetPosition];
		l_penduleAngle = [[l_pendulumArray objectAtIndex:l_arraySize - 1] m_angle];
	}

	// draw the head.
	int l_headTexture = m_canEat ? TEXTURE_LARVE_SNAKE_HEAD_OPEN_MOUTH : TEXTURE_LARVE_SNAKE_HEAD_CLOSE_MOUTH;
	l_headTexture = m_snakeFall ? TEXTURE_LARVE_SNAKE_HEAD_PROFILE : l_headTexture;
	int l_reverse = REVERSE_NONE;
	if(m_snakeFall)
	{
		l_reverse = ([m_mario m_position].x > l_pendulePosition.x) ? REVERSE_NONE : REVERSE_HORIZONTAL;
	}
	[l_sharedEAGLView drawTextureIndex:l_headTexture
								  plan:PLAN_PENDULUM
								  size:	m_levelData.m_snakeSizeHead// * (1.f + (0.2 * (float)m_specialEaten))
							 positionX:l_pendulePosition.x
							 positionY:l_pendulePosition.y
							 positionZ:0.
						 rotationAngle:RADIAN_TO_DEDREE(l_penduleAngle) / 2.
					   rotationCenterX:l_pendulePosition.x
					   rotationCenterY:l_pendulePosition.y
						  repeatNumber:1
						 widthOnHeight:1.f
							nightBlend:false
						   deformation:0.f
							  distance:SNAKE_DISTANCE - 1.f
								decayX:0.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_CLOSE
							   reverse:l_reverse
	 ];
	
	[[ApplicationManager sharedApplicationManager] SetHelpPositionPixel:GLToPixel([m_mario GetPositionShoulder])];
	
	if(m_lightTaken)
	{
		m_canEat = YES;
		if(DistancePointSquare(l_pendulePosition, m_stickEndPosition) < 0.2)
		{	m_lightTaken = NO;
			m_canEat = NO;
			m_biteCount++;
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"crok" Volume:0.7f];
			if (m_biteCount > 0 && !m_snakeFall)
			{
				[[OpenALManager sharedOpenALManager] playSoundWithKey:@"morvan" Volume:0.f];
				[[OpenALManager sharedOpenALManager] FadeWithKey:@"morvan" duration:5.f volume:1.f stopEnd:NO];
				//[PhysicPendulum SetGravityDegree:70.];
				[ParticleRose SetHeraticCoeff:3.f];
				m_snakeFall = YES;
				[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:YES];
				m_pendulumBasePositionScaleCurrent = [[l_pendulumArray objectAtIndex:l_arraySize - 1] GetPosition];
			}
		}
	}
	else
	{
		m_canEat = NO;
	}
	
	return YES;
}

// Set the camera focused on the light.
-(void)CameraGoToLight
{
	if(!m_hasFalled)
	{
		EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
		[l_sharedEAGLView SetCameraUpdatable:TRUE];
		[l_sharedEAGLView SetScale:1.0 force:NO];
		[l_sharedEAGLView SetTranslate:CGPointMake(0.3, 0.8) forType:CAMERA_CLOSE force:NO];
		//[self performSelector:@selector(CameraReturnToSnake) withObject:nil afterDelay:2.f];
	}
}

-(void)CameraReturnToSnake
{
		EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
		[l_sharedEAGLView SetCameraUpdatable:TRUE];
		[l_sharedEAGLView SetScale:1. force:NO];
		[l_sharedEAGLView SetTranslate:CGPointMake(-1.2, 1.2) forType:CAMERA_CLOSE force:NO];
}

-(void)CallHelp
{
	[[ApplicationManager sharedApplicationManager] SetHelp:@"helpEatGlow.png"];
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	if(!m_panelTaken && m_updateMario)
	{
		[[EAGLView sharedEAGLView] SetScale:0.55 force:NO];
		[[EAGLView sharedEAGLView] SetTranslate:CGPointMake(0., -1.) forType:CAMERA_CLOSE force:NO];
		[m_pendulumStick SetAngleSpeed:2.f];
		m_panelTaken = YES;
		m_canEat = NO;
	}
	m_fingerPosition = a_touchLocation;
	return;
}

-(void)Event1:(int)a_value
{
	if(a_value > 0)
	{
		m_canEat = true;
	}
	else
	{
		m_canEat = false;
	}

	return;
}

-(void)Event2:(int)a_value
{
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"shock" Volume:1.f];
	return;
}

-(void)Terminate
{
	[m_mario release];

	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"music2"];
	[super Terminate];
	
	// destroy all the particles.
	[[ParticleManager sharedParticleManager] KillParticles];

	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
	[m_pendulumStick release];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(CallHelp) object:nil];
}

-(NSArray *)GetSoundArray
{
    return [NSArray arrayWithObjects:@"music2", @"wind", @"shock", @"ambientSwamp", @"craquement mystérieux", @"crok", @"morvan", @"siurp", @"noiseGrass", nil];
}

-(id)GetNoteBook
{
	return [[NoteBook alloc] InitWithString:@"Here begins my exploration. Seems I'm lucky.££££££££££££££££I already met one creature; a blue flying Scutigerus, _with no creepy leg. It ate a red light bug, and_£££then££££££. And everything turned so strange. The moon_££££££££I need to follow it! _Lulu_£££."
								MusicToFade:@"music2"];
}

@end
