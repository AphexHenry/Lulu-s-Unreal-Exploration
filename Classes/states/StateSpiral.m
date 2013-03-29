//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateSpiral.h"
#import "StateTheatreSpiralOut.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleManager.h"
#import "ParticleBeast.h"
#import "ApplicationManager.h"
#import "ParticleLightBug.h"
#import	"OpenALManager.h"
#import "Animation.h"
#import "NoteBook.h"

#define NB_PARTICLE 80
#define STICK_LENGTH 2.5
#define GROUND_Y -1.f
#define FINGER_SENSIBILITY 10.f
#define TIME_BEFORE_STOP_MUSIC 5.
#define WORLD_SCALE 5.f
#define WORLD_ROTATION_MIN -40.f
#define WORLD_ROTATION_MAX 3000.f
#define WORLD_ROTATION_BLOCK_DIRECTION 1200.f
#define SPEED_WHEN_BLOCK_LARVE 0.02f
#define END_SPIRAL 2400.f

@implementation StateSpiral

-(void)StateInit
{
	m_index = STATE_SPIRAL;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 5.6f;
	m_levelData.m_snakePartQuantity = 10;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_SPIRAL_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"nightSky.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_BACKGROUND_FRONT] = [[NSString alloc] initWithString:@"spiralFront.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_BACKGROUND_BACK] = [[NSString alloc] initWithString:@"spiralBack.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_SNAKE_BODY] = [[NSString alloc] initWithString:@"LuluBody.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_BIG_MONSTER] = [[NSString alloc] initWithString:@"bigMonster.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_LUCIOLE] = [[NSString alloc] initWithString:@"roseThing.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"wallSulpiceShadow.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_LIGHT] = [[NSString alloc] initWithString:@"lightGlow.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_MIST] = [[NSString alloc] initWithString:@"mist.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_BEAST_FRAME_0] = [[NSString alloc] initWithString:[[ApplicationManager sharedApplicationManager] GetABeastName]];
	
	m_levelData.m_textureArray[TEXTURE_SPIRAL_MARIO_BODY] = [[NSString alloc] initWithString:@"marioBody.png"];
	m_levelData.m_textureArray[TEXTURE_SPIRAL_MARIO_EYES] = [[NSString alloc] initWithString:@"marioEyes.png"];	
	m_levelData.m_textureArray[TEXTURE_SPIRAL_MARIO_FALL] = [[NSString alloc] initWithString:@"marioFall.png"];	
	m_levelData.m_textureArray[TEXTURE_SPIRAL_MARIO_ORA] = [[NSString alloc] initWithString:@"marioOra.png"];

	m_fingerPosition = CGPointMake(0.f, GROUND_Y - 0.5f);
	m_fingerPositionPrevious = m_fingerPosition;
	m_worldRotationDegree = -35.f;
	m_positionInTranslateWorld = -10.f;
	m_stateTimer = 0.;
	m_closeState = NO;
	m_marioBreaks = YES;
	m_lightGlowPosition = CGPointMake(1.2f, (m_levelData.m_size / 1.5f));
	m_skyDecay = CGPointMake(0.f, 0.f);
	
	EAGLView *l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView initLevel:m_levelData];
	[l_sharedEAGLView SetCamera:CAMERA_CLOSE];
	[l_sharedEAGLView SetBlur:0.];
	[l_sharedEAGLView SetScale:0.6 force:NO];
	[l_sharedEAGLView SetTranslate:CGPointMake(0.f, 0.0f) forType:CAMERA_CLOSE force:NO];
	[l_sharedEAGLView SetCameraUpdatable:FALSE];
	
	m_levelData.m_size = 2.f;
	
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"wind" Volume:0.8f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"noiseGrass" Volume:0.f];
	
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	for (int i = 0; i < NB_PARTICLE - 1; i++)
	{
		[l_particleManager AddParticle:[[ParticleRose alloc] initWithTexture:TEXTURE_SPIRAL_LUCIOLE]];
	}

	for (int i = 0; i < 10; i++)
	{
		[l_particleManager AddParticle:[[ParticleRose alloc] initWithTexture:TEXTURE_SPIRAL_SNAKE_BODY]];
	}

	[ParticleRose SetDistance:30];
	ParticleBeast * l_particleBeast = [[ParticleBeast alloc] init];
	[l_particleBeast SetAnimation:TEXTURE_SPIRAL_BEAST_FRAME_0];
	[l_particleManager AddParticle:l_particleBeast];
	[l_particleManager ActiveDeadParticlesFromGroup:PARTICLE_GROUP_BEAST];
	[l_particleManager ActiveDeadParticles:120];
	
    // init the thing.
	m_mario = [[Mario alloc] init:
						CGPointMake(-.2f, GROUND_Y - EPSILON) 
						groundY:GROUND_Y 
						animation:[[Animation alloc] initWithFirstFrame:TEXTURE_SPIRAL_MARIO_EYES lastFrame:TEXTURE_SPIRAL_MARIO_EYES duration:10.4] 
						bodyTexture:TEXTURE_SPIRAL_MARIO_BODY
						fallTexture:TEXTURE_SPIRAL_MARIO_FALL
						 fallSize:0.5
			   ];
	
	[m_mario Block:YES];
	[m_mario SetPosition:CGPointMake(-10., GROUND_Y - EPSILON) timeInterval:1.f];
	 
	
	[ParticleRose SetGroundY:GROUND_Y - 0.3];
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:NO];
	
	[self performSelector:@selector(FadeOutMusic) withObject:nil afterDelay:TIME_BEFORE_STOP_MUSIC];
	
	[self InitSnake];
	return [super StateInit];
}

-(id)InitFromMenu
{
    // add the sounds.
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"wind"];
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"string2"];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"string2" duration:0.7f volume:0.f stopEnd:YES];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"ambientSwamp" Volume:0.9f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"craquement mystérieux" Volume:0.2f];
	return [self init];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	m_stateTimer += a_timeInterval;
	
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	
	m_skyDecay.x += 0.01 * a_timeInterval;
	m_skyDecay.y += 0.001 * a_timeInterval;
    float l_size	 = m_levelData.m_size;
	float l_marioPosition = [m_mario m_position].x;

	// break the thing.
	if(m_marioBreaks)
	{
		m_fingerPosition.x = m_fingerPositionPrevious.x + (m_fingerPosition.x - m_fingerPositionPrevious.x) * 0.96;
	}
    // update the rotation of the world.
	m_worldRotationDegree = clip(((m_worldRotationDegree / (360 * 2)) + 1.f )* l_size * M_PI * l_marioPosition * 0.8f, WORLD_ROTATION_MIN, WORLD_ROTATION_MAX);
	
	// update volume of the music with the position.
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"musicTripouille" Volume:clip(2.f * (m_worldRotationDegree - 140.f) / WORLD_ROTATION_MAX, 0.f, 2.f)];
	
	if(!(m_worldRotationDegree < WORLD_ROTATION_MIN + EPSILON && (m_fingerPosition.x - m_fingerPositionPrevious.x) < 0))
	{
		m_positionInTranslateWorld = l_marioPosition + (m_fingerPosition.x - m_fingerPositionPrevious.x) * a_timeInterval * FINGER_SENSIBILITY;
	}
	
    // when we are at the end of the spiral, quit the state.
	if(m_worldRotationDegree > END_SPIRAL)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreSpiralOut alloc] init]];
		[[ApplicationManager sharedApplicationManager] SaveLevel:4];
	}
	
	[m_mario Update:a_timeInterval position:CGPointMake(m_positionInTranslateWorld, m_fingerPosition.y)];
	[m_mario draw];
	
	[l_particleManager UpdateParticlesWithTimeInterval:a_timeInterval];
	[l_particleManager drawself];

	// this is just to have a clearer code.
	if(![self UpdateSnake:a_timeInterval])
	{
		return;
	}
	
    // play the noise of the thing.
	CGPoint l_marioSpeed = [m_mario m_speed];
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"noiseGrass" Volume:0.04f + .1f * Absf(l_marioSpeed.x)];
	[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"noiseGrass" Pitch: .8f + 0.1f * Absf(l_marioSpeed.x)];
    
    [self DrawBackground];
}

-(void)DrawBackground
{
    int l_repeatNumber = m_levelData.m_duplicate;
	float l_size	 = m_levelData.m_size;
	float l_worldScale = 0.6f - 0.6 * m_worldRotationDegree / (360 * 2);
    
    EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
    
    // update the zoom.
	[l_sharedEAGLView SetCameraUpdatable:YES];
	[l_sharedEAGLView SetScale:l_worldScale force:YES];
	[l_sharedEAGLView SetCameraUpdatable:NO];
    
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
	
	// draw the moon.
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_MOON
										   plan:PLAN_BACKGROUND_STICKERS
										   size:2.6 / (0.3 + 0.7 * max(l_worldScale, -0.2))
									  positionX:1.f - [m_mario m_position].x / 300.f
									  positionY:0.f
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
	
	float distance = -1.f;
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SPIRAL_BACKGROUND_BACK
								  plan:PLAN_SKY_SHADOW
								  size:	l_size * WORLD_SCALE * 1.05f
							 positionX:0.f
							 positionY:(-1.01 + (m_worldRotationDegree * 0.5 / (360.f * 2.3))) * l_size * WORLD_SCALE + GROUND_Y
							 positionZ:0.
						 rotationAngle:m_worldRotationDegree * 0.5
					   rotationCenterX:0.
					   rotationCenterY:0.f
						  repeatNumber:1
						 widthOnHeight:1.
							nightBlend:false
						   deformation:0.f
							  distance:-1.f
	 ];
	
	// draw clouds.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:2.f * l_size / (0.5 + 0.5 * l_worldScale)
							 positionX:0.f
							 positionY:0.f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1.
							  distance:distance
								decayX:m_skyDecay.x + [m_mario m_position].x / 200.f
								decayY:m_skyDecay.y
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SPIRAL_BACKGROUND_FRONT
								  plan:PLAN_BACKGROUND_CLOSE
								  size:	l_size * WORLD_SCALE
							 positionX:0.2f
							 positionY:(-1.01 + (m_worldRotationDegree / (360.f * 2.3))) * l_size * WORLD_SCALE + GROUND_Y
							 positionZ:0.
						 rotationAngle:m_worldRotationDegree
					   rotationCenterX:0.
					   rotationCenterY:0.f
						  repeatNumber:1
						 widthOnHeight:1.
							nightBlend:false
						   deformation:0.f
							  distance:-1.f
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SPIRAL_BIG_MONSTER
								  plan:PLAN_BACKGROUND_CLOSE
								  size:	l_size * WORLD_SCALE * (0.9f + 0.4 * Absf(l_worldScale))
							 positionX:- l_size * WORLD_SCALE * (1.2f - m_worldRotationDegree / (WORLD_ROTATION_MAX * 2.f))
							 positionY:-l_size * WORLD_SCALE / 4.f
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.f
						  repeatNumber:1
						 widthOnHeight:1.
							nightBlend:false
						   deformation:0.f
							  distance:40.f
	 ];
	
    // fading of the mist.
	float l_alpha = clip(1.f - (m_positionInTranslateWorld / 36.), 0.f, 1.f);
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SPIRAL_MIST
								  plan:PLAN_BACKGROUND_SHADOW
								  size:l_size * WORLD_SCALE * 0.2f
							 positionX:0.f
							 positionY:-l_size * WORLD_SCALE / 4.f
							 positionZ:0.
								  rotationAngle:0.
								rotationCenterX:0.
								rotationCenterY:0.
								  repeatNumber:1
								 widthOnHeight:5.
									 nightBlend:FALSE
									deformation:0.f
									  distance:-1
										decayX:m_worldRotationDegree * .01f + m_skyDecay.x
										decayY:0.f
										  alpha:.6f * l_alpha
										 planFX:PLAN_BACKGROUND_STICKERS
										reverse:REVERSE_NONE
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SPIRAL_MIST
								  plan:(int)TEXTURE_SPIRAL_BACKGROUND_BACK
								  size:l_size * WORLD_SCALE * 0.1f
							 positionX:0.f
							 positionY:-l_size * WORLD_SCALE / 4.f + 1.2f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:6.
							nightBlend:FALSE
						   deformation:0.f
							  distance:-1
								decayX:(m_worldRotationDegree * .01f + m_skyDecay.x) * 0.6
								decayY:0.f
								 alpha:.6f * l_alpha
								planFX:PLAN_BACKGROUND_STICKERS
							   reverse:REVERSE_NONE
	 
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

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval
{
	CGPoint l_pendulePosition;
	// smooth the base speed.
	NSTimeInterval l_animationInterval = [ApplicationManager sharedApplicationManager].m_animationInterval;
	
	m_pendulumBasePositionScaleCurrent.x = [m_mario m_position].x;
	m_pendulumBasePositionScaleCurrent.y = m_fingerPosition.y;

    // if the thing is idle, the particles go close to him.
	if(!m_marioBreaks)
	{
		[m_pendulumHead UpdateWithBasePosition:CGPointMake(0.5f * (m_fingerPosition.x + [m_mario GetPositionShoulderScreen].x), 0.5f * (m_fingerPosition.y + [m_mario GetPositionShoulderScreen].y)) timeFrame:l_animationInterval];	
	}
	else
	{
		[m_pendulumHead UpdateWithBasePosition:[m_mario GetPositionShoulderScreen] timeFrame:l_animationInterval];	
	}
		
	[[ApplicationManager sharedApplicationManager] SetHelpPositionPixel:GLToPixel(l_pendulePosition)];
	
	return YES;
}

-(void)FadeOutMusic
{
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"morvan" duration:4.f volume:0.f stopEnd:YES];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"musicTripouille" Volume:0.f];
}

-(void)Touch:(CGPoint)a_touchLocation
{
	m_marioBreaks = NO;
	m_fingerPositionPrevious = a_touchLocation;
	
    // avoid the return of the thing when it is beyond a limit.
	if(m_worldRotationDegree > WORLD_ROTATION_BLOCK_DIRECTION)
	{
		m_fingerPosition.x = m_fingerPositionPrevious.x + SPEED_WHEN_BLOCK_LARVE;
	}
	else
	{
		m_fingerPosition = m_fingerPositionPrevious;
	}

}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:NO];
	m_fingerPosition = a_touchLocation;
    // avoid the return of the thing when it is beyond a limit.
	if(m_worldRotationDegree > WORLD_ROTATION_BLOCK_DIRECTION)
	{
		if(m_fingerPosition.x - m_fingerPositionPrevious.x < SPEED_WHEN_BLOCK_LARVE)
		{
			m_fingerPosition.x = m_fingerPositionPrevious.x + SPEED_WHEN_BLOCK_LARVE;
		}
	}
	return;
}

-(void)TouchEnded:(CGPoint)a_touchLocation
{
	if(!(m_worldRotationDegree > WORLD_ROTATION_BLOCK_DIRECTION))
	{
		m_marioBreaks = YES;
	}
}

-(void)Terminate
{
	[m_mario release];

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
    return [NSArray arrayWithObjects:@"wind", @"morvan", @"craquement mystérieux", @"musicTripouille", @"morvan", @"noiseGrass", @"ambientSwamp", nil];
}

@end
