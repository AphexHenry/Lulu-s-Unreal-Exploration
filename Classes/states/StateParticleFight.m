//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateParticleFight.h"
#import "StateTheatreNextGeneration.h"
#import "StateTheatreFlyOutGameOver.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleManager.h"
#import "ParticleBeast.h"
#import "ApplicationManager.h"
#import "ParticleLightBug.h"
#import	"OpenALManager.h"
#import "BigMonster.h"

#define TIME_BEFORE_STOP_MUSIC 3.f
#define NB_PARTICLE 30
#define GROUND_Y -1.1f
#define FINGER_SENSIBILITY 1.5f
#define SENSIBLE_SPEED 0.15
#define SPEED_MAX 35.f
#define SPEED_MIN_FOR_FLY 10.f
#define SPEED_MIN_ERASE_FRONT_DISPLAY 15.f
#define MAX_HIGH 25.f
#define GRAVITY 8.f
#define ACCELERATION_X 1.f
#define PARTICLE_ELECTRIZED_DURATION 5.
#define PARTICLE_DISTANCE_MAX 30.f
#define MONSTER_HURT_COUNT_TO_KILL 2

@implementation StateParticleFight

-(void)StateInit
{
	m_index = STATE_PARTICLE_FIGHT;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 15.f;
	m_levelData.m_snakePartQuantity = 10;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_PF_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"nightSky.png"];
	m_levelData.m_textureArray[TEXTURE_PF_BACKGROUND_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_PF_BACKGROUND_BACK] = [[NSString alloc] initWithString:@"luluTitleBack.png"];
	m_levelData.m_textureArray[TEXTURE_PF_FOREST_BACK] = [[NSString alloc] initWithString:@"ForestBack.png"];
	m_levelData.m_textureArray[TEXTURE_PF_CLOUD_STORM] = [[NSString alloc] initWithString:@"cloudStorm.png"];
	m_levelData.m_textureArray[TEXTURE_PF_FOREST_FRONT] = [[NSString alloc] initWithString:@"ForestFront.png"];
	m_levelData.m_textureArray[TEXTURE_PF_SNAKE_BODY] = [[NSString alloc] initWithString:@"LuluBody.png"];
	m_levelData.m_textureArray[TEXTURE_PF_LUCIOLE] = [[NSString alloc] initWithString:@"roseThing.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"wallSulpiceShadow.png"];
	m_levelData.m_textureArray[TEXTURE_PF_BIG_MONSTER_ARM] = [[NSString alloc] initWithString:@"bigMonsterArm.png"];
	m_levelData.m_textureArray[TEXTURE_PF_FLASH] = [[NSString alloc] initWithString:@"flash.png"];
	m_levelData.m_textureArray[TEXTURE_PF_FLASH_1] = [[NSString alloc] initWithString:@"flash1.png"];
	m_levelData.m_textureArray[TEXTURE_PF_WHITE] = [[NSString alloc] initWithString:@"white.png"];
	m_levelData.m_textureArray[TEXTURE_PF_BEAST_FRAME_0] = [[NSString alloc] initWithString:[[ApplicationManager sharedApplicationManager] GetABeastName]];
	
	m_levelData.m_size = 2.f;
	
	m_fingerPosition = CGPointMake(0.f, GROUND_Y - 0.5f);
	m_fingerPositionPrevious = m_fingerPosition;
	m_positionInTranslateWorld = CGPointMake(0.f, 0.f);;
	m_viewPosition = CGPointMake(0.f, 0.f);
	m_speed = 0.f;
	m_stateTimer = 0.;
	m_closeState = NO;
	m_skyDecay = CGPointMake(0.f, 0.f);
	m_cloudDecay = 0.f;
	m_xDecayView = 0.f;
	
	m_particlesCenter = CGPointMake(0.f, 0.f);
	
	EAGLView *l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView initLevel:m_levelData];
	[l_sharedEAGLView SetCamera:CAMERA_CLOSE];
	[l_sharedEAGLView SetBlur:0.];
	[l_sharedEAGLView SetScale:0.6 force:NO];
	[l_sharedEAGLView SetTranslate:CGPointMake(0.f, 0.0f) forType:CAMERA_CLOSE force:NO];
	[l_sharedEAGLView SetCameraUpdatable:YES];
	
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"electricity" Volume:0.f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"wind" Volume:0.23f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"noiseGrass" Volume:0.f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"treeFriction" Volume:0.f];
	
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	for (int i = 0; i < NB_PARTICLE - 1; i++)
	{
		[l_particleManager AddParticle:[[ParticleRose alloc] initWithTexture:TEXTURE_PF_LUCIOLE]];
	}

	for (int i = 0; i < 7; i++)
	{
		[l_particleManager AddParticle:[[ParticleRose alloc] initWithTexture:TEXTURE_PF_SNAKE_BODY]];
	}
	
	ParticleBeast * l_particleBeast = [[ParticleBeast alloc] init];
	[l_particleBeast SetAnimation:TEXTURE_PF_BEAST_FRAME_0];
	[l_particleManager AddParticle:l_particleBeast];
	[l_particleManager ActiveDeadParticlesFromGroup:PARTICLE_GROUP_BEAST];
	[l_particleManager ActiveDeadParticles:120];
	
	[ParticleRose SetGroundY:GROUND_Y - 0.3];
	[ParticleRose SetDistance:PARTICLE_DISTANCE_MAX];
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:NO];
	
	[self performSelector:@selector(FadeOutMusic) withObject:nil afterDelay:TIME_BEFORE_STOP_MUSIC];
	
	m_bigMonster = [[BigMonster alloc] initWithPosition:CGPointMake(-2.f, 0.f) groundY:-1.f texture:TEXTURE_PF_BIG_MONSTER_ARM];
	m_flashTimer = 0.;
	m_flashTimerAgainstMonster = 0.;
	m_monsterHurtCount = 1;
	
    // init the electricity particles.
	for(int i = 0; i < PARTICLE_FLASH_COUNT; i++)
	{
		m_particleElectrizedTimer[i] = PARTICLE_ELECTRIZED_DURATION / m_monsterHurtCount;
		m_heraticFlashTimer[i] = 0.;
		m_heraticFlashAngle[i] = 0.f;
		m_heraticFlashPosition[i] = CGPointMake(0.f, 0.f);
		m_particleElectrizedSize[i] = 0.f;
		m_heraticFlashTexture[i] = TEXTURE_PF_FLASH;
	}
	
	[self InitSnake];
	return [super StateInit];
}

// play the sound files.
-(id)InitFromMenu
{
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"string2"];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"string2" duration:0.7f volume:0.f stopEnd:YES];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"musicTripouille" Volume:0.f];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"musicTripouille" duration:2.f volume:0.2f stopEnd:NO];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"ambientSwamp" Volume:0.9f];
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"craquement mystérieux"];
	return [self init];
}

// Update.
-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	m_stateTimer += a_timeInterval;
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	
	m_skyDecay.x += 0.01 * a_timeInterval;
	m_skyDecay.y += 0.001 * a_timeInterval;
	
	int l_repeatNumber = m_levelData.m_duplicate;
	float l_size	 = m_levelData.m_size;

	m_fingerPosition.x *= (1.f - m_breaks * 0.4 * a_timeInterval);
	m_speed *= (1.f - m_breaks * 0.12 * a_timeInterval);
	
	m_speed += ACCELERATION_X * ( 1.1f - 1.f * (m_speed / SPEED_MAX)) * m_fingerPosition.x * FINGER_SENSIBILITY * a_timeInterval * (1.f + m_speed / 10.f);
	m_speed = clip(m_speed, -SPEED_MAX, SPEED_MAX) ;
	m_positionInTranslateWorld.x += m_speed * a_timeInterval;
	m_positionInTranslateWorld.y = (MAX_HIGH / 2.f) * (m_fingerPosition.y) * max(0.f, ((Absf(m_speed) - SPEED_MIN_FOR_FLY) / SPEED_MAX));
	m_positionInTranslateWorld.y += GRAVITY * min((Absf(m_speed) - SPEED_MIN_FOR_FLY) / SPEED_MAX, 0.f) * a_timeInterval;
	
	[l_particleManager UpdateParticlesWithTimeInterval:a_timeInterval];
	m_particlesCenter = [l_particleManager GetParticlesCenterFromGroup:PARTICLE_GROUP_LUCIOLE];
	m_positionInTranslateWorld.y = clip(m_positionInTranslateWorld.y, GROUND_Y, MAX_HIGH * 0.8);
	float l_viewDecay = (m_positionInTranslateWorld.x + (m_particlesCenter.x - m_positionInTranslateWorld.x) * 0.95f) - m_viewPosition.x;
	m_viewPosition.x += l_viewDecay;	
	m_viewPosition.y = m_particlesCenter.y * 1.f;

	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"treeFriction" Volume:clip(1.f - 0.7f * Absf(m_particlesCenter.y - 2.9f), 0.f, 1.f)];
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"wind" Volume:3.f * Absf(m_speed) / SPEED_MAX];
	[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"wind" Pitch:0.8f + 0.7f * (m_positionInTranslateWorld.y / MAX_HIGH)];
	
	m_xDecayView += l_viewDecay;
	m_cloudDecay += l_viewDecay;
	float l_warp = 70.f / SENSIBLE_SPEED;
	if(m_xDecayView > l_warp)
	{
		m_xDecayView -= l_warp;
	}
	
	[ParticleRose SetXTranslate:-m_viewPosition.x];
	[l_particleManager drawself];
	
	[l_sharedEAGLView SetCameraUpdatable:YES];
	m_cameraTransformation = CGPointMake(0.f, -max(0.f, m_viewPosition.y));
	[l_sharedEAGLView SetTranslate:m_cameraTransformation forType:CAMERA_CLOSE force:YES];
	float l_scale = 0.6 - 0.3f * m_particlesCenter.y / MAX_HIGH;	
	[l_sharedEAGLView SetScale:l_scale force:YES];
	[l_sharedEAGLView SetCameraUpdatable:NO]; 
	
	if(m_stateTimer > 6.)
	{
		[m_bigMonster SetDecayDraw:CGPointMake(-m_viewPosition.x, 0.f)];
		[m_bigMonster Update:a_timeInterval position:m_particlesCenter];	
		
		CGPoint l_killPosition = [m_bigMonster GetKillPosition];
		if(DistancePointSquare(l_killPosition , m_particlesCenter) < 1.)
		{
			ParticleRose * l_particleToKill = (ParticleRose *)[l_particleManager GetParticleWithPosition:l_killPosition distanceMin:0.13f];
			if(l_particleToKill)
			{
				[l_particleToKill kill];
				[[OpenALManager sharedOpenALManager] playSoundWithKey:@"eclosion" Volume:.3f];
				if([l_particleManager GetCountFromGroup:PARTICLE_GROUP_LUCIOLE] < 2)
				{
					[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreFlyOutGameOver alloc] init]];
					[[OpenALManager sharedOpenALManager] playSoundWithKey:@"bicycle" Volume:.5f];
				//	[[OpenALManager sharedOpenALManager] FadeWithKey:@"bicycle" duration:1.f volume:0.5f stopEnd:NO];
				}
			}
		}
	}
	
	// this is just to have a clearer code.
	if(![self UpdateSnake:a_timeInterval])
	{
		return;
	}
	
	[self UpdateParticleElectrized:a_timeInterval];
	[self UpdateFlashSequence:a_timeInterval];
	[self UpdateFlashSequenceAgainstMonster:a_timeInterval];
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND
								  size:l_size * 1.f
							 positionX:0.f
							 positionY:0.f
							 positionZ:-1.
						  repeatNumber:l_repeatNumber
						 widthOnHeight:1.f
							  distance:-1.f
	 
	 ];
	
	// draw background.
	float l_distanceMoon = -1.f;
	if(m_particleElectrizedTimer[0] < PARTICLE_ELECTRIZED_DURATION / m_monsterHurtCount)
	{
		l_distanceMoon = 20.f - 30.f * pow(cos(m_particleElectrizedTimer[0] * 30.f + myRandom() * 0.5), 3.f) 
						* clip(1. - (m_particleElectrizedTimer[0] / (PARTICLE_ELECTRIZED_DURATION / m_monsterHurtCount)), 0., 1.);
	}
		[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_MOON
										   plan:PLAN_BACKGROUND_STICKERS
										   size:4.8
									  positionX:.1
									  positionY:.8f
									  positionZ:0.
								  rotationAngle:0.
								rotationCenterX:0.
								rotationCenterY:0.
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
									   distance:l_distanceMoon
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_STICKERS
										reverse:REVERSE_NONE
	 
	 ];
	
	
	// draw clouds.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:3.f * l_size
							 positionX:0.f
							 positionY:1.f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.f
							nightBlend:FALSE
						   deformation:0.f
							  distance:-1.f
								decayX:m_skyDecay.x + SENSIBLE_SPEED * m_cloudDecay / 36.f 
								decayY:m_skyDecay.y
								 alpha:.5f
								planFX:PLAN_BACKGROUND_STICKERS
							   reverse:REVERSE_NONE
	 
	 ];
	
	if(Absf(m_speed < SPEED_MIN_ERASE_FRONT_DISPLAY))
	{
		[l_sharedEAGLView drawTextureIndex:TEXTURE_PF_BACKGROUND_FRONT
									  plan:PLAN_BACKGROUND_CLOSE
									  size:l_size
								 positionX:0.f
								 positionY:0.3f
								 positionZ:0.
							  repeatNumber:1
							 widthOnHeight:2.
								  distance:-1.f
									decayX:SENSIBLE_SPEED * m_xDecayView  / 1.
									decayY:0.f
		 
		 ];
	}
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_PF_FOREST_BACK
								  plan:PLAN_PARTICLE_BEHIND
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:50.f
								decayX:SENSIBLE_SPEED * m_xDecayView / 3.
								decayY:0.f
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_PF_FOREST_FRONT
								  plan:PLAN_BACKGROUND_CLOSE
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							nightBlend:FALSE
						   deformation:0.f
							  distance:-1.f
								decayX:SENSIBLE_SPEED * m_xDecayView / 3.
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_PARTICLE_BEHIND
							   reverse:REVERSE_NONE
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_PF_CLOUD_STORM
								  plan:PLAN_BACKGROUND_CLOSE
								  size:l_size
							 positionX:0.f
							 positionY:0.18 * MAX_HIGH
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							nightBlend:FALSE
						   deformation:0.f
							  distance:-1.f
								decayX:SENSIBLE_SPEED * m_xDecayView / 3.
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND
							   reverse:REVERSE_NONE
	 
	 ];
	
}

-(void)UpdateParticleElectrized:(NSTimeInterval)a_timeInterval
{	
	ParticleRose * l_particleHead = (ParticleRose *)[[ParticleManager sharedParticleManager] m_activeparticlesBorders];
	ParticleRose * l_particleCurrent = l_particleHead;
	float l_angle = 0.f;
	float l_sin = 0.f;
	float l_size = 0.f;
	CGPoint l_lastPosition = m_particlesCenter;
	for(int i = 0; i < PARTICLE_FLASH_COUNT; i++)
	{
		if(l_particleCurrent.m_group == PARTICLE_GROUP_LUCIOLE)
		{
			m_particleElectrizedSize[i] += myRandom() * 0.02;
			m_particleElectrizedSize[i] = clip(m_particleElectrizedSize[i], -0.1f, 0.1f);
			l_sin = (l_particleCurrent.m_position.y - l_lastPosition.y);
			l_angle = RADIAN_TO_DEDREE( atan(-(l_particleCurrent.m_position.x - l_lastPosition.x) / ((l_sin == 0.f) ? 0.01 : l_sin)));
			l_size = clip(DistancePoint(l_particleCurrent.m_position, l_lastPosition) / 4.f, 0.015, 0.2) + m_particleElectrizedSize[i];
			m_particleElectrizedTimer[i] += a_timeInterval * (1.4 + myRandom() * 0.6);
			m_heraticFlashTimer[i] += a_timeInterval;
			
			if(m_heraticFlashTimer[i] > 0.)
			{
				m_heraticFlashTimer[i] = -0.13 + myRandom() * 0.03;
				m_heraticFlashAngle[i] = pow(myRandom(), 2.f) * 40.f;
				m_heraticFlashPosition[i] = CGPointMake(myRandom() * .6f, pow(myRandom(), 1.5) * myRandom() * 0.3f);
				m_heraticFlashTexture[i] = arc4random() % 2 + TEXTURE_PF_FLASH;
			}
			
			[[EAGLView sharedEAGLView] drawTextureIndex:m_heraticFlashTexture[i]
										  plan:(l_sin > 0.f) ? PLAN_PARTICLE_BEHIND : PLAN_PARTICLE_FRONT
										  size:l_size//m_particleElectrizedSize[i]
									 positionX:(l_particleCurrent.m_position.x + l_lastPosition.x) * 0.5 - m_viewPosition.x + m_heraticFlashPosition[i].x
									 positionY:(l_particleCurrent.m_position.y + l_lastPosition.y) * 0.5 + m_heraticFlashPosition[i].y
									 positionZ:0.
								 rotationAngle:l_angle + m_heraticFlashAngle[i]
							   rotationCenterX:0.
							   rotationCenterY:0.
								  repeatNumber:1
								 widthOnHeight:1.f * min(1.f / l_size, 0.5f)
									nightBlend:NO
								   deformation:0.f
									  distance:-1.f
										decayX:0.f
										decayY:0.f
										alpha:pow(cos(m_particleElectrizedTimer[i] * 30.f + myRandom() * 0.5), 3.f) * clip(1. - pow((m_particleElectrizedTimer[i] / PARTICLE_ELECTRIZED_DURATION / m_monsterHurtCount), 2.f), 0., 1.)
										planFX:PLAN_BACKGROUND_CLOSE
									   reverse:REVERSE_NONE
			 
			 ];
			
			if(m_particleElectrizedTimer[i] < PARTICLE_ELECTRIZED_DURATION /  m_monsterHurtCount)
			{
				[l_particleCurrent SetDistanceParticle:.75f - 0.4f * pow(cos(m_particleElectrizedTimer[i] * 20.f + myRandom() * 0.5), 3.f) * clip(1. - pow((m_particleElectrizedTimer[i] / (PARTICLE_ELECTRIZED_DURATION / m_monsterHurtCount)), 2.f), 0., 1.)];
			}
			else
			{
				[l_particleCurrent SetDistanceParticle:1.f];
			}

			
			l_lastPosition = l_particleCurrent.m_position;
		}
		l_particleCurrent = (ParticleRose *)l_particleCurrent.next;
		if(!l_particleCurrent)
		{
			l_particleCurrent = l_particleHead;
		}
	}
}

-(void)UpdateFlashSequence:(NSTimeInterval)a_timeInterval
{
	if(m_particlesCenter.y > 0.6 * MAX_HIGH)
	{
		if(m_flashTimer < EPSILON)
		{
			int l_index = arc4random() % 2;
			[[OpenALManager sharedOpenALManager] playSoundWithKey:[NSString stringWithFormat:@"thunder%d", l_index] Volume:.2f];
		}
		for(int i = 0; i < PARTICLE_FLASH_COUNT; i++)
		{
			m_particleElectrizedTimer[i] = myRandom();
		}
		m_flashTimer += a_timeInterval;
		m_breaks = 10.5f;
		
		if(m_flashTimer < 0.5)
		{
			//[ParticleRose SetDistance:PARTICLE_DISTANCE_MAX - pow(cos(m_flashTimer * 20.f + myRandom() * 0.5), 2.f) * PARTICLE_DISTANCE_MAX];
			[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_PF_FLASH
										  plan:PLAN_SKY_SHADOW
										  size:2.5
									 positionX:1.f
									 positionY:m_particlesCenter.y / 2.f - 1.3
									 positionZ:0.
								 rotationAngle:0.
							   rotationCenterX:0.
							   rotationCenterY:0.
								  repeatNumber:1
								 widthOnHeight:.8f
									nightBlend:FALSE
								   deformation:0.f
									  distance:-1.f
										decayX:0.f
										decayY:0.f
										 alpha:pow(cos(m_flashTimer * 20.f + myRandom() * 0.5), 3.f)
										planFX:-1
									   reverse:REVERSE_NONE
			 
			 ];
			
			[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_PF_WHITE
												   plan:PLAN_BACKGROUND_STICKERS
												   size:m_levelData.m_size * 4.f
											  positionX:0.f
											  positionY:m_particlesCenter.y / 2.f - 0.5
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
												  alpha:0.8f * pow(cos(m_flashTimer * 20.f + myRandom() * 0.5), 4.f)
												 planFX:-1
												reverse:REVERSE_NONE
			 
			 ];
		}
	}
	else
	{
		m_breaks = m_breaksTouch;
		m_flashTimer = 0.;
	}

	
}

-(void)UpdateFlashSequenceAgainstMonster:(NSTimeInterval)a_timeInterval
{	
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"electricity" Volume:1.f * clip(1.f - (m_particleElectrizedTimer[0] / PARTICLE_ELECTRIZED_DURATION), 0.f, 1.f)];
	
	if(DistancePointSquare([m_bigMonster GetKillPosition], m_particlesCenter) < 5.4 && (m_particleElectrizedTimer[0] < PARTICLE_ELECTRIZED_DURATION / m_monsterHurtCount))
	{
		if(m_flashTimerAgainstMonster < EPSILON)
		{
			int l_index = arc4random() % 2;
			[[OpenALManager sharedOpenALManager] playSoundWithKey:[NSString stringWithFormat:@"thunder%d", l_index] Volume:.2f];
			[m_bigMonster Hurt];
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"BigMonsterScream" Volume:1.f];	
			m_monsterHurtCount++;
			for(int i = 0; i < PARTICLE_FLASH_COUNT; i++)
			{
				m_particleElectrizedTimer[i] += PARTICLE_ELECTRIZED_DURATION * 0.6f;
			}
			if(m_monsterHurtCount > MONSTER_HURT_COUNT_TO_KILL)
			{
				[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreNextGeneration alloc] init]];
				[[ApplicationManager sharedApplicationManager] SaveLevel:5];
				[[OpenALManager sharedOpenALManager] playSoundWithKey:@"bicycle" Volume:0.f];
				[[OpenALManager sharedOpenALManager] FadeWithKey:@"bicycle" duration:2.f volume:0.6f stopEnd:NO];
			}
		}

		m_flashTimerAgainstMonster += a_timeInterval;
		m_breaks = 10.5f;
		
		if(m_flashTimerAgainstMonster < 0.5)
		{
			//[ParticleRose SetDistance:PARTICLE_DISTANCE_MAX - pow(cos(m_flashTimer * 20.f + myRandom() * 0.5), 2.f) * PARTICLE_DISTANCE_MAX];
			[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_PF_FLASH
												   plan:PLAN_SKY_SHADOW
												   size:2.5
											  positionX:1.f
											  positionY:m_particlesCenter.y / 2.f - 1.3
											  positionZ:0.
										  rotationAngle:0.
										rotationCenterX:0.
										rotationCenterY:0.
										   repeatNumber:1
										  widthOnHeight:.8f
											 nightBlend:FALSE
											deformation:0.f
											   distance:-1.f
												 decayX:0.f
												 decayY:0.f
												  alpha:pow(cos(m_flashTimerAgainstMonster * 20.f + myRandom() * 0.5), 3.f)
												 planFX:-1
												reverse:REVERSE_NONE
			 
			 ];
			
			[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_PF_WHITE
												   plan:PLAN_BACKGROUND_STICKERS
												   size:m_levelData.m_size * 14.f
											  positionX:0.f
											  positionY:m_particlesCenter.y / 2.f - 0.5
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
												  alpha:0.8f * pow(cos(m_flashTimerAgainstMonster * 20.f + myRandom() * 0.5), 4.f)
												 planFX:-1
												reverse:REVERSE_NONE
			 
			 ];
		}
	}
	else
	{
		m_breaks = m_breaksTouch;
		if(m_flashTimerAgainstMonster > 0.)
		{
			m_particleElectrizedTimer[0] = PARTICLE_ELECTRIZED_DURATION / m_monsterHurtCount;
		}
		m_flashTimerAgainstMonster = 0.;
	}	
}


// init pendulum.
-(void)InitSnake
{
	// init the snake.
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

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval
{
	// smooth the base speed.
	NSTimeInterval l_animationInterval = [ApplicationManager sharedApplicationManager].m_animationInterval;

	[m_pendulumHead UpdateWithBasePosition:CGPointMake(m_positionInTranslateWorld.x, m_positionInTranslateWorld.y + GROUND_Y) timeFrame:l_animationInterval];
	
	return YES;
}

-(void)FadeOutMusic
{
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"musicTripouille" duration:3.f volume:0.f stopEnd:YES];
}


-(void)Touch:(CGPoint)a_touchLocation
{
	m_breaksTouch = 0.f;
	m_fingerPositionPrevious = CGPointMake(a_touchLocation.x + m_cameraTransformation.x, a_touchLocation.y + m_cameraTransformation.y);//ConvertPositionWithCameraTransformationFromGameToScreen(a_touchLocation, l_screenTransformation);
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	a_touchLocation = CGPointMake(a_touchLocation.x + m_cameraTransformation.x, a_touchLocation.y + m_cameraTransformation.y);
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:NO];
	m_fingerPosition.x += a_touchLocation.x - m_fingerPositionPrevious.x;
	m_fingerPosition.y += a_touchLocation.y - m_fingerPositionPrevious.y;
	m_fingerPosition.x = clip(m_fingerPosition.x, -3.f, 3.f);
	m_fingerPosition.y = clip(m_fingerPosition.y, -1.7f, 1.7f);
	m_fingerPositionPrevious = a_touchLocation;
	return;
}

-(void)TouchEnded:(CGPoint)a_touchLocation
{
	m_breaksTouch = 1.f;
}

-(void)Event2:(int)a_value
{
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"shock" Volume:1.f];
	return;
}

-(void)Terminate
{
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"electricity"];
	
	[super Terminate];
	
	// destroy all the particles.
	[[ParticleManager sharedParticleManager] KillParticles];
	[ParticleRose SetXTranslate:0.f];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
	[m_pendulumStick release];
	
	[m_bigMonster release];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(CallHelp) object:nil];
}

-(NSArray *)GetSoundArray
{
    return [NSArray arrayWithObjects:@"shock", @"electricity", @"craquement mystérieux", @"musicTripouille", @"bicycle", @"noiseGrass", @"ambientSwamp", @"BigMonsterScream", @"thunder0", @"thunder1", @"eclosion", @"wind", @"treeFriction", nil];
}

@end
