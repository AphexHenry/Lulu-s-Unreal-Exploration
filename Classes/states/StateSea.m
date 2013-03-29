//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateSea.h"
#import "StateTheatreNextGenerationGameOver.h"
#import "StateTheatreLastOut.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "PuppetEvolved.h"
#import "ParticleManager.h"
#import "ParticleSea.h"
#import "ParticleBeast.h"
#import "ParticleLightBug.h"

#define STICK_LENGTH 1.
#define GROUND_Y -0.6f
#define TIME_BEFORE_OPEN_CURTAINS 2.f
#define SPEED_LULU_TURN .3f
#define SPEED_LULU_WALK 0.35f
#define TIME_MIN_BEFORE_QUIT 5.f
#define SPEED_SCROLLING_MAX 0.6f
#define VOLUME_MUSIC .9f
#define MONSTER_NUMBER 20
#define LIGHT_BUG_GROUND -0.75f
#define LIGHT_BUG_POSITION 2.9f
#define GRASS_GROUND -0.55f
#define GRASS_POSITION_BEGIN 4.7
#define FLOWER_POSITION 8.9f
#define POSITION_FINGER_LEFT_Y 0.85f
#define MAX_POS_FINGER_X -0.3f
#define SCALE_IN_LIMIT 63.f
#define SNAKE_LIMIT_X_MAX 70.8f
#define SNAKE_LIMIT_X_MIN -0.f
#define SNAKE_LIMIT_Y_MAX 0.4f
#define SNAKE_LIMIT_Y_MIN -0.f
#define LIMIT_TO_NO_LIMITE_CAMERA -3.19f
#define LIMIT_TO_RETURN_TO_NORMAL 58.f//85.f
 
@implementation StateSea

-(void)StateInit
{
	m_index = STATE_SEA;
	
	// Init the level datas.
//	m_levelData.m_isMiddleElement = FALSE;
//	m_levelData.m_isAroundElement = TRUE;
//	m_levelData.m_isShadow = FALSE;
//	m_levelData.m_sizeFactorBegin = 1.f;
//	m_levelData.m_sizeFactorEnd = 1.f;
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.05;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.03;
	m_levelData.m_snakeSizeHead = 0.15;
	m_levelData.m_snakeSizeBody = 0.1;
	m_levelData.m_arraySize = TEXTURE_SEA_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"nightSky.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"backgroundNextGeneration.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BACKGROUND_DOWNHILL] = [[NSString alloc] initWithString:@"downhill.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_PUPPET_BODY] = [[NSString alloc] initWithString:@"luluFight.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_PUPPET_HEAD] = [[NSString alloc] initWithString:@"luluFightHead.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_PUPPET_ARM] = [[NSString alloc] initWithString:@"puppetNewGenerationArm.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_PUPPET_SWORD] = [[NSString alloc] initWithString:@"puppetNewGenerationSword.png"];
    m_levelData.m_textureArray[TEXTURE_SEA_PUPPET_PIG] = [[NSString alloc] initWithString:@"pig.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_GEAR] = [[NSString alloc] initWithString:@"gear.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_LIGHTBUG] = [[NSString alloc] initWithString:@"lightBugBig.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_DEAD_THING] = [[NSString alloc] initWithString:@"deadThing.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_MOUSSE] = [[NSString alloc] initWithString:@"mousse.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BEAST] = [[NSString alloc] initWithString:[[ApplicationManager sharedApplicationManager] GetABeastName]];
	m_levelData.m_textureArray[TEXTURE_SEA_FLOWER] = [[NSString alloc] initWithString:@"flower.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_GRASS_BLADE] = [[NSString alloc] initWithString:@"grassBlade.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_GRASS_BLADE_2] = [[NSString alloc] initWithString:@"grassBlade2.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_GRASS_BACK] = [[NSString alloc] initWithString:@"grassBackground.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_GRASS_BACK_UNI] = [[NSString alloc] initWithString:@"grassBackgroundUni.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BIG_HEAD] = [[NSString alloc] initWithString:@"bigHead.png"];
    m_levelData.m_textureArray[TEXTURE_SEA_BIG_HEAD_DOWN] = [[NSString alloc] initWithString:@"bigHeadDown.png"];
    m_levelData.m_textureArray[TEXTURE_SEA_BIG_HEAD_BODY] = [[NSString alloc] initWithString:@"bigHeadBody.png"];
    m_levelData.m_textureArray[TEXTURE_SEA_BIG_HEAD_TONGUE] = [[NSString alloc] initWithString:@"bigHeadTongue.png"];
    m_levelData.m_textureArray[TEXTURE_SEA_BIG_HEAD_TONGUE_HEAD] = [[NSString alloc] initWithString:@"bigHeadTongueHead.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BIG_ARM] = [[NSString alloc] initWithString:@"bigArm.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BIG_EYE_BACKGROUND] = [[NSString alloc] initWithString:@"wallPsyche.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BIG_EYE_BACKGROUND_FRONT] = [[NSString alloc] initWithString:@"wallPsycheAround.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BIG_EYE_BACKGROUND_EXTENSION] = [[NSString alloc] initWithString:@"wallPsycheExtension.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BIG_EYE_BACKGROUND_PART] = [[NSString alloc] initWithString:@"wallPsychePart.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BIG_EYE_BACKGROUND_PART_2] = [[NSString alloc] initWithString:@"wallPsychePart2.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_BIG_EYE_BACKGROUND_PART_3] = [[NSString alloc] initWithString:@"wallPsychePart3.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_SNAKE_HEAD] = [[NSString alloc] initWithString:@"PendulumHeadEye.png"];
	m_levelData.m_textureArray[TEXTURE_SEA_SNAKE_BODY] = [[NSString alloc] initWithString:@"PendulumBodyEye.png"];
	
	EAGLView *l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView SetCameraUpdatable:YES];
	[l_sharedEAGLView initLevel:m_levelData];
	[l_sharedEAGLView SetCamera:CAMERA_CLOSE];
	[l_sharedEAGLView SetBlur:0.];
	[l_sharedEAGLView SetScale:1.3 force:YES];
	[l_sharedEAGLView SetTranslate:CGPointMake(0.f, -0.1f) forType:CAMERA_CLOSE force:NO];
	[l_sharedEAGLView SetCameraUpdatable:NO];
	
	m_skyDecay = CGPointMake(0., 0.);
	m_time = 0.f;
	m_headDeformation = 1.f;
	
	m_fingerPosition[0] = CGPointMake(-1.f, 0.6f) ;
	m_fingerPosition[1] = CGPointMake(1.f, 0.6f);
	m_headSpeed = CGPointMake(1.f, 1.f);
	m_headPosition = CGPointMake(0.f, 0.f);
	m_multiTouchMondayToTuesday = NO;
	m_isCrazy = NO;
	m_aroundTextureDeformationFrequency = 0.f;
	m_aroundTextureDeformation = 0.f;
	m_grassWave = 0.f;
	m_scale = 1.6f;
	m_cameraTranslate = CGPointMake(0.f, 0.f);
    m_cameraSpeed = CGPointMake(0.f, 0.f);
	m_eyeTransition = 0.f;
	m_state = STATE_INIT;
	m_fingerMoved = 0;
    m_soundCoeff = 0.f;
    m_positionPendulumAtEnd = CGPointMake(0.f, 0.f);
    m_skyDecayToQuit = 0.f;
    m_misterDead = NO;
	
	m_puppet = [[PuppetEvolvedPig alloc] InitWithTexturePuppet:TEXTURE_SEA_PUPPET_BODY 
                                                    TextureArm:TEXTURE_SEA_PUPPET_ARM
                                                  TextureSword:TEXTURE_SEA_PUPPET_SWORD
                                                    TexturePig:TEXTURE_SEA_PUPPET_PIG
												  Stick:TEXTURE_SEA_STICK 
											TextureHead:TEXTURE_SEA_PUPPET_HEAD
											TextureLeg:-1
										   InitPosition:m_fingerPosition[0]
										  PanelSequence:nil
				   ];
	
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	
	ParticleBeast * l_particleBeast = [[ParticleBeast alloc] init];
	[l_particleBeast SetAnimation:TEXTURE_SEA_BEAST];
	[l_particleManager AddParticle:l_particleBeast];

	int l_texture;

	[ParticleSea SetGroundY:GRASS_GROUND];
	 
	for(int i = 0; i < 185; i++)
	{
		if(myRandom() < 0.f)
		{
			l_texture = TEXTURE_SEA_GRASS_BLADE;
		}
		else
		{
			l_texture = TEXTURE_SEA_GRASS_BLADE_2;
		}
			
		[l_particleManager AddParticle:[[ParticleSea alloc] initWithTexture:l_texture size:0.07 position:GRASS_POSITION_BEGIN + myRandom() * 1.5f widthOnHeight:0.4f]];
	}
	
	l_texture = TEXTURE_SEA_FLOWER;
	for(int i = 0; i < 10; i++)
	{
		[l_particleManager AddParticle:[[ParticleSeaFlower alloc] initWithTexture:l_texture size:0.07 position:5.f + myRandom() * 1.5f widthOnHeight:1.f]];
	}
	
	[ParticleRose SetGroundY:LIGHT_BUG_GROUND];
	[ParticleRose SetHeraticCoeff:0.2f];
	[ParticleRose SetDistance:-1.f];
	
	[[ParticleManager sharedParticleManager] ActiveDeadParticles];
	
	m_bigHead	= [[BigMisterWithEye alloc] initWithPosition:CGPointMake(8.3f, 0.f) texture:TEXTURE_SEA_BIG_HEAD widthOnHeight:1.f size:0.6f step:0.6 textureEye:TEXTURE_SEA_BIG_EYE_BACKGROUND];
	m_bigArm	= [[BigMister alloc] initWithPosition:CGPointMake(5.5f, GROUND_Y) texture:TEXTURE_SEA_BIG_ARM widthOnHeight:2.f size:0.3f step:0.5f];
	
	[self InitSnake];
	
	m_bigMonster = [[BigMonster alloc] initWithPosition:CGPointMake(.6f, -0.5f) 
                                                groundY:-1.f texture:TEXTURE_SEA_BIG_EYE_BACKGROUND_PART 
                                                  block:YES 
                                            transparency:YES
                                              sizeLimit:0.035f 
                                             numTexture:3
                                              growSpeed:0.3f
                    ];
    
	m_positionExtension = CGPointMake(0.f, 0.f);
    m_timeSinceHit = 0.;
    m_luminositySky = -1.f;
    m_snakeDrawDecay = CGPointMake(0.f, 0.f);
	
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"wind" Volume:0.f];
    [[OpenALManager sharedOpenALManager] playSoundWithKey:@"pig" Volume:0.f];
    [[OpenALManager sharedOpenALManager] playSoundWithKey:@"crazyness" Volume:0.f];
    [[OpenALManager sharedOpenALManager] SetPitchWithKey:@"crazyness" Pitch:0.8f];
    [[OpenALManager sharedOpenALManager] playSoundWithKey:@"treeFriction" Volume:0.f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"raclement" Volume:0.f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"SeaStateNormal" Volume:0.5f];

	return [super StateInit];
}

// init pendulum.
-(void)InitSnake
{
	// init the snake.
	m_pendulumBasePositionScaleCurrent = CGPointMake(-1.f, 0.f);
	CGPoint l_basePosition = CGPointMake(1., 0.);
	CGPoint l_pendulumPosition = CGPointMake(l_basePosition.x + 0.2, l_basePosition.y + 0.1);
	float l_length = m_levelData.m_snakeLengthBetweenHeadAndBody;
	
	m_pendulumHead = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition basePosition:l_basePosition mass:150.f angleSpeedLimit:-1.f  gravity:0.05 gravityAngle:0.f friction:0.15 addInTheList:YES];
	PhysicPendulum * l_currentPendulum = m_pendulumHead; 
	PhysicPendulum * l_childPendulum = nil;
	
	// Creation of the elmeents of the snake.
	for(int i = 0; i < m_levelData.m_snakePartQuantity; i++)
	{
		l_childPendulum = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition basePosition:l_basePosition mass:2.f angleSpeedLimit:5.f  gravity:0.05 gravityAngle:0.f friction:0.15 addInTheList:YES];
		[l_currentPendulum AddChild:l_childPendulum];
		l_currentPendulum = l_childPendulum;
		l_basePosition = l_pendulumPosition;
		l_pendulumPosition.y += l_length;
		l_length = m_levelData.m_snakeLengthBetweenParts;
	}
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	m_time += a_timeInterval;
	
	[l_sharedEAGLView SetCameraUpdatable:YES];
    CGPoint l_positionTarget;
	
	switch (m_state)
	{
        case STATE_INIT:
            m_state = STATE_NORMAL;
            m_cameraTranslate = CGPointMake(0.f, 0.f);
            m_cameraSpeed = CGPointMake(0.f, 0.f);
            break;
        case STATE_PRE_NORMAL:
            m_luminositySky += 0.3 * a_timeInterval;
            m_cameraSpeed.x *= 0.3;
            m_cameraSpeed.y *= 1.f - 3.f * a_timeInterval;
            m_fingerPosition[0] = CGPointMake(-1.2f, 0.f);
            m_fingerPosition[1] = CGPointMake(1.2f, 0.f);
            if(m_luminositySky > 1. && m_cameraTranslate.y <= -0.4)
            {
                printf("To state Normal\n");
                m_state = STATE_NORMAL_WITH_SNAKE;
                [m_bigHead SetDisapear:YES];
                [m_bigArm SetDisapear:YES];
                m_luminositySky = 1.f;
                [[OpenALManager sharedOpenALManager] FadeWithKey:@"SeaStateNormal" duration:2.f volume:0.5f stopEnd:NO];
            }
        case STATE_NORMAL_WITH_SNAKE:
            [self UpdateSnake:a_timeInterval];
            float l_positionSnakeX = [[[PhysicPendulum GetList] objectAtIndex:4] GetPosition].x + m_snakeDrawDecay.x;
            float l_alpha1 = clip(1.f - Absf([m_bigArm GetPosition].x - l_positionSnakeX), 0.f, 1.f);
            float l_alpha2 = clip(1.f - Absf([m_bigHead GetPosition].x - l_positionSnakeX), 0.f, 1.f);
            [m_bigArm SetAlpha:l_alpha1];
            [m_bigHead SetAlpha:l_alpha2];
		case STATE_NORMAL:
			m_grassWave -= a_timeInterval;
			m_grassWave = (m_grassWave < -1.5f) ? 2.f : m_grassWave;
			float l_coeff1 = sin((m_grassWave + 1.5) * 2.f * M_PI / 3.5f);
            float l_waveAmplitude = -(m_skyDecay.x / 5.f) - 0.1;
			[ParticleSea SetWavePosition:m_grassWave];
            m_soundCoeff += (Absf(0.8 - 0.4 * Absf(m_grassWave - [m_puppet GetPositionBody].x)) - m_soundCoeff) * a_timeInterval;
            [[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"wind" Volume:1.5f * clip(l_waveAmplitude, 0.f, 2.f) * m_soundCoeff];
            [[OpenALManager sharedOpenALManager] SetPitchWithKey:@"wind" Pitch:.9f + 0.3 * m_soundCoeff];
			m_skyDecay.x += -a_timeInterval * m_puppetSpeed * SPEED_LULU_WALK;
        
            [[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"treeFriction" Volume:2.f * ((-m_skyDecay.x * 2.5f > GRASS_POSITION_BEGIN - 1.5) ? 1.f : 0.f) * (0.3f +  0.1 * cos(m_skyDecay.x * 70.f)) * pow((m_puppetSpeed / SPEED_SCROLLING_MAX), 2.f)];
            [[OpenALManager sharedOpenALManager] SetPitchWithKey:@"treeFriction" Pitch:0.9f + 0.2f * (m_puppetSpeed / SPEED_SCROLLING_MAX)];
			[ParticleSea SetXTranslate:m_skyDecay.x * 2.5f];
			[ParticleSea SetWaveAmplitude:l_waveAmplitude];
			[ParticleSea SetPositionPuppet:[m_puppet GetPositionBody].x];
			[ParticleRose SetXTranslate:-m_skyDecay.x * 2.5f];
  
            m_cameraTranslate.x += m_cameraSpeed.x * a_timeInterval;
            m_cameraTranslate.y += m_cameraSpeed.y * a_timeInterval;
            m_cameraTranslate.y = min(0.f, m_cameraTranslate.y);
            
            m_cameraSpeed = CGPointMake(m_cameraSpeed.x + (-m_cameraTranslate.x - 0.f) * .8f * a_timeInterval,m_cameraSpeed.y + (-m_cameraTranslate.y + 0.3 * clip(1.f + m_skyDecay.x, 0.f, 1.f)) * .8f * a_timeInterval);

			m_cameraSpeed.x *= 1.f - 1.f * a_timeInterval;
			m_cameraSpeed.y *= 1.f - 1.f * a_timeInterval;
            
            m_scaleSpeed += 1.4 * (clip(2.f + m_skyDecay.x, 1.2f, 1.6f) + 0.05 * clip(l_waveAmplitude, 0.f, 1.f) * l_coeff1 - m_scale) * a_timeInterval;
			m_scaleSpeed *= 1.f - 3.f * a_timeInterval;
			m_scale += m_scaleSpeed * a_timeInterval;
			[self DrawGrassThings:a_timeInterval];
            [self UpdateKilling:a_timeInterval];
			break;
        case STATE_NORMAL_EXIT:
            [[OpenALManager sharedOpenALManager] FadeWithKey:@"raclement" duration:6.f volume:1.f stopEnd:NO];
            [[OpenALManager sharedOpenALManager] FadeWithKey:@"SeaStateNormal" duration:2.f volume:0.f stopEnd:NO];
            [[OpenALManager sharedOpenALManager] FadeWithKey:@"treeFriction" duration:1.f volume:0.f stopEnd:NO];
            [[OpenALManager sharedOpenALManager] FadeWithKey:@"crazyness" duration:1.f volume:0.f stopEnd:NO];
            m_state = STATE_TRANSITION_TO_EYE_1;
            break;
		case STATE_TRANSITION_TO_EYE_1:
            m_puppetSpeed = 0.f;
			m_scale += (1.f + m_scale) * a_timeInterval;
			m_cameraTranslate.x += m_cameraSpeed.x * a_timeInterval;
			m_cameraTranslate.y += m_cameraSpeed.y * a_timeInterval;
			m_cameraSpeed = CGPointMake((-m_cameraTranslate.x - [m_bigHead GetPositionEye].x) * 2.f, (-m_cameraTranslate.y - [m_bigHead GetPositionEye].y) * 2.f);
			m_cameraSpeed.x *= 1.f - 3.f * a_timeInterval;
			m_cameraSpeed.y *= 1.f - 3.f * a_timeInterval;
			if(m_scale > SCALE_IN_LIMIT)
			{
				m_state = STATE_TRANSITION_TO_EYE_2;
				m_cameraSpeed = CGPointMake(0.f, 0.f);
                [[OpenALManager sharedOpenALManager] FadeWithKey:@"pig" duration:1.f volume:0.f stopEnd:NO];
                break;
			}
			[self DrawGrassThings:a_timeInterval];
			break;
		case STATE_TRANSITION_TO_EYE_2:
			m_eyeTransition += 0.2f * a_timeInterval;
			if(m_eyeTransition > 1.f)
			{
				m_state = STATE_EYE;
				m_eyeTransition = 1.f;
				m_positionExtension = [m_bigHead GetPositionExtention];
                m_cameraSpeed.x = -0.3f;
			}
			[m_bigHead SetTransition:m_eyeTransition];
			m_scale -= (1.f + 0.6 * m_scale) * a_timeInterval;
			m_scale = max(m_scale, 1.3);
			break;
		case STATE_EYE:
			m_cameraTranslate.x += m_cameraSpeed.x * a_timeInterval;
            m_cameraTranslate.y += m_cameraSpeed.y * a_timeInterval;
            float l_scaleCoeff = 0.7f;
            if(m_cameraTranslate.x > LIMIT_TO_NO_LIMITE_CAMERA)
            {
                m_cameraTranslate.x = clip(m_cameraTranslate.x, -SNAKE_LIMIT_X_MAX, -SNAKE_LIMIT_X_MIN); 
                m_cameraTranslate.y = clip(m_cameraTranslate.y, -SNAKE_LIMIT_Y_MAX, -SNAKE_LIMIT_Y_MIN);
                l_positionTarget = [m_pendulumHead GetPosition];
            }
            else
            {
                if(DistancePointSquare( [m_pendulumHead GetPosition], m_positionExtension) > 0.6f)
                {
                    l_scaleCoeff = .2;
                }

                l_positionTarget = CGPointMake(0.7 * [m_pendulumHead GetPosition].x + 0.3 * m_positionExtension.x, 0.7 * [m_pendulumHead GetPosition].y + 0.3 * m_positionExtension.y);
            }
            
            m_scaleSpeed += 2.5 * (1.3f + l_scaleCoeff * ( -m_cameraTranslate.x - SNAKE_LIMIT_X_MIN ) / (SNAKE_LIMIT_X_MAX - SNAKE_LIMIT_X_MIN) - m_scale) * a_timeInterval;
            m_scaleSpeed *= 1.f - 2.f * a_timeInterval;
            m_scale += m_scaleSpeed * a_timeInterval;
            
			m_cameraSpeed = CGPointMake(m_cameraSpeed.x + (-m_cameraTranslate.x - l_positionTarget.x) * 1.f * a_timeInterval,m_cameraSpeed.y + (-m_cameraTranslate.y - l_positionTarget.y) * 1.f * a_timeInterval);
			m_cameraSpeed.x *= 1.f - 1.f * a_timeInterval;
			m_cameraSpeed.y *= 1.f - 1.f * a_timeInterval;
			[self UpdateSnake:a_timeInterval];
			[m_bigMonster Update:a_timeInterval position:m_positionExtension];
			break;
        case STATE_TANSITION_TO_NORMAL:
            m_eyeTransition -= 0.3 * a_timeInterval;
            
            if(m_eyeTransition < 0.f)
            {
                printf("To state PreNormal\n");
                m_eyeTransition = 0.f;
                m_state = STATE_PRE_NORMAL;
                [[OpenALManager sharedOpenALManager] FadeWithKey:@"raclement" duration:10.f volume:0.f stopEnd:NO];
                
                CGPoint l_decay = CGPointMake(0.f, 8.f);
                m_snakeDrawDecay = CGPointMake(m_cameraTranslate.x + l_decay.x, m_cameraTranslate.y + l_decay.y);
                m_cameraTranslate = CGPointMake(-l_decay.x, -l_decay.y);
                
                [m_bigHead SetIdle:NO];
            }
            
            [self UpdateSnake:a_timeInterval];
			[m_bigHead SetTransition:m_eyeTransition];
            [m_bigMonster SetAlpha:m_eyeTransition];
			[m_bigMonster Update:a_timeInterval position:m_positionExtension];
			break;
		default:
			break;
	}
	
	[l_sharedEAGLView SetTranslate:m_cameraTranslate forType:CAMERA_CLOSE force:YES];
	[l_sharedEAGLView SetScale:m_scale force:YES];
	[l_sharedEAGLView SetCameraUpdatable:NO];
	
	[BigMister	SetDecay:m_skyDecay.x * 2.5f];
	[BigMister SetPositionEnemy:[m_puppet GetPositionBody].x];
	[m_bigHead	Update:a_timeInterval];
	[m_bigArm	Update:a_timeInterval];
	
	float l_size	 = m_levelData.m_size;

	m_aroundTextureDeformationFrequency += myRandom() * a_timeInterval * 0.3;
	m_aroundTextureDeformationFrequency = clip(m_aroundTextureDeformationFrequency, 0.2, 5.);
	m_aroundTextureDeformation += m_aroundTextureDeformationFrequency * a_timeInterval;

	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND
								  size:1. * l_size
							 positionX:0.f
							 positionY:0.f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1.
							  distance:(1.f - m_luminositySky) * 50.f
	 ];
	
	[super UpdateWithTimeInterval:a_timeInterval];
}

-(void)DrawGrassThings:(NSTimeInterval)a_timeInterval
{
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_size	 = m_levelData.m_size;
	float l_grassDeformation = -0.15f * ( + 0.2 * cos(m_time + myRandom() * 0.05));
    float l_sizeMoon = max((1.5f + m_skyDecay.x / 10.f), 1.1);
    
	[[ParticleManager sharedParticleManager] UpdateParticlesWithTimeInterval:a_timeInterval];
	[[ParticleManager sharedParticleManager] drawself];
	
	// this is just to have a clearer code.
	if(![self UpdatePuppet:a_timeInterval])
	{
		return;
	}
	
    // draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_MOON
								  plan:PLAN_BACKGROUND_STICKERS
								  size:1.f * l_sizeMoon
							 positionX:.2
							 positionY:-.1f - m_skyDecay.x / 56.f  
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1.
							  distance:0.f
	 ];
    
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_BACKGROUND_MIDDLE
								  size:l_size * 1.f
							 positionX:-2.5f + m_skyDecay.x * 2.7f
							 positionY:0.8f
							 positionZ:0.
						 rotationAngle:-5.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:8.f
							nightBlend:false
						   deformation:0.03 * l_grassDeformation
							  distance:36.f
								decayX:-.2f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SEA_BACKGROUND_DOWNHILL
								  plan:PLAN_BACKGROUND_MIDDLE
								  size:l_size / 4.f
							 positionX:3.5f + m_skyDecay.x * 3.f
							 positionY:-0.7f
							 positionZ:0.
						 rotationAngle:-5.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:10.f
							nightBlend:false
						   deformation:0.f
							  distance:min(-5.f - m_skyDecay.x * 8.f, 2.f)
								decayX:0.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SEA_BACKGROUND_DOWNHILL
								  plan:PLAN_BACKGROUND_MIDDLE
								  size:l_size / 3.2f
							 positionX:-.5f + m_skyDecay.x * 3.f
							 positionY:-0.6f
							 positionZ:0.
						 rotationAngle:175.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:10.f
							nightBlend:false
						   deformation:0.f
							  distance:min(-5.f - m_skyDecay.x * 8.f, 2.f)
								decayX:0.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SEA_GRASS_BACK
								  plan:PLAN_SKY_SHADOW
								  size:l_size / 6.f
							 positionX:0.f
							 positionY:GRASS_GROUND + (0.04f - 0.2f * (1.f - clip(-m_skyDecay.x, 0.f, 1.f)))
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:4.f
							nightBlend:false
						   deformation:-l_grassDeformation / 2.f
							  distance:10.f
								decayX:-m_skyDecay.x * .8f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SEA_GRASS_BACK_UNI
								  plan:PLAN_SKY_SHADOW
								  size:l_size / 2.f
							 positionX:0.f
							 positionY:GRASS_GROUND - 0.2
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:4.f
							nightBlend:false
						   deformation:0.f
							  distance:10.f
								decayX:-m_skyDecay.x * .2f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SEA_GRASS_BACK
								  plan:PLAN_BACKGROUND_CLOSE
								  size:l_size / 3.9f
							 positionX:0.f
							 positionY:GRASS_GROUND - (0.19f + 0.2f * (1.f - clip(-m_skyDecay.x, 0.f, 1.f)))
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:6.f
							nightBlend:false
						   deformation:-l_grassDeformation / 3.f
							  distance:28.f
								decayX:-m_skyDecay.x * .9f + 1.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];	
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval
{
	float l_positionY = clip(POSITION_FINGER_LEFT_Y + 0.17 * m_skyDecay.x, POSITION_FINGER_LEFT_Y - 0.28, POSITION_FINGER_LEFT_Y) + 0.1f * [m_puppet GetVariation];
    
    float l_speed = m_puppetSpeed / SPEED_SCROLLING_MAX;
    [m_puppet SetSpeed:l_speed];
    float l_volume = 0.3f * clip(pow(cos(m_time * (1.7f + l_speed)), 2.f) + clip(l_speed * l_speed, 0.f, 1.f), 0.f, 1.f);
    [[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"pig" Volume:l_volume];
    [[OpenALManager sharedOpenALManager] SetPitchWithKey:@"pig" Pitch:0.8f + 0.3 * clip(l_speed, 0.f, 1.f)];
    
	if(m_fingerPosition[0].x < m_fingerPosition[1].x)
	{
		//l_positionY = m_fingerPosition[0].y + (POSITION_FINGER_LEFT_Y - m_fingerPosition[0].y) * clip(-m_skyDecay.x, 0.f, 1.f);
		// the touch 1 is on the finger 0
		[m_puppet UpdateWithPosition:CGPointMake(min(m_fingerPosition[0].x, MAX_POS_FINGER_X), l_positionY) positionHand:m_fingerPosition[1] timeInterval:a_timeInterval];
		m_puppetSpeed = clip(m_fingerPosition[0].x + 0.9f, 0.f, SPEED_SCROLLING_MAX);
	}
	else
	{
		//l_positionY = m_fingerPosition[1].y + (POSITION_FINGER_LEFT_Y - m_fingerPosition[1].y) * clip(-m_skyDecay.x, 0.f, 1.f);
		[m_puppet UpdateWithPosition:CGPointMake(min(m_fingerPosition[1].x, MAX_POS_FINGER_X), l_positionY) positionHand:m_fingerPosition[0] timeInterval:a_timeInterval];
		m_puppetSpeed = clip(m_fingerPosition[1].x + 0.9f, 0.f, SPEED_SCROLLING_MAX);
	}

    if(m_misterDead && m_skyDecay.x < m_skyDecayToQuit)
    {
        [[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreLastOut alloc] init]];
        [[OpenALManager sharedOpenALManager] FadeWithKey:@"pig" duration:2.f volume:0.f stopEnd:YES];
        [[OpenALManager sharedOpenALManager] FadeWithKey:@"raclement" duration:2.f volume:0.f stopEnd:YES];
        [[OpenALManager sharedOpenALManager] FadeWithKey:@"SeaStateNormal" duration:2.f volume:0.f stopEnd:YES];
    }
    
	return YES;
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval
{
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	CGPoint l_pendulePosition;
	CGFloat l_penduleAngle;
	
	//ScreenTransformation l_screenTransformation = [l_sharedEAGLView GetCameraTransformation];
	CGPoint l_fingerPositionScaled = m_fingerPosition[m_fingerMoved];//ConvertPositionWithCameraTransformationFromScreenToGame(m_fingerPosition[0], l_screenTransformation);
	
	// smooth the base speed.
	float l_speedMax = 1.8f;
	NSTimeInterval l_animationInterval = a_timeInterval;
	
	float l_xSpeed;
	float l_xSign;
	float l_ySpeed;
	float l_ySign;
	
    switch (m_state)
    {
        case STATE_PRE_NORMAL:
            l_xSpeed = 0.f;
            l_ySpeed = 0.f;
            break;
        case STATE_NORMAL_WITH_SNAKE:
            m_positionPendulumAtEnd = CGPointMake(0.2f + cos(m_time * 0.3), 0.7 * sin(m_time * 0.3) + 0.4f);
            l_xSpeed = -min(Absf((m_pendulumBasePositionScaleCurrent.x + m_snakeDrawDecay.x - m_positionPendulumAtEnd.x) / l_animationInterval), l_speedMax);
            l_xSign = ((m_pendulumBasePositionScaleCurrent.x + m_snakeDrawDecay.x - m_positionPendulumAtEnd.x) < 0.f) ? -1.f : 1.f;
            l_ySpeed = -min(Absf((m_pendulumBasePositionScaleCurrent.y + m_snakeDrawDecay.y - m_positionPendulumAtEnd.y) / l_animationInterval), l_speedMax);
            l_ySign = ((m_pendulumBasePositionScaleCurrent.y + m_snakeDrawDecay.y - m_positionPendulumAtEnd.y) < 0.f) ? -1.f : 1.f;           
            break;
        default:
            l_xSpeed = -min(Absf((m_pendulumBasePositionScaleCurrent.x - l_fingerPositionScaled.x) / l_animationInterval), l_speedMax);
            l_xSign = ((m_pendulumBasePositionScaleCurrent.x - l_fingerPositionScaled.x) < 0.f) ? -1.f : 1.f;
            l_ySpeed = -min(Absf((m_pendulumBasePositionScaleCurrent.y - l_fingerPositionScaled.y) / l_animationInterval), l_speedMax);
            l_ySign = ((m_pendulumBasePositionScaleCurrent.y - l_fingerPositionScaled.y) < 0.f) ? -1.f : 1.f;
            break;
    }
	
    m_pendulumBasePositionScaleCurrent.x = m_pendulumBasePositionScaleCurrent.x + l_xSpeed * l_animationInterval * l_xSign;
    m_pendulumBasePositionScaleCurrent.y = m_pendulumBasePositionScaleCurrent.y + l_ySpeed * l_animationInterval * l_ySign;
    
	if(DistancePointSquare( [m_pendulumHead GetPosition], m_positionExtension) < 0.3 )
	{
        float l_length = 0.5 + 0.05 * myRandom();
        float l_angle  = (m_cameraTranslate.x > LIMIT_TO_NO_LIMITE_CAMERA) ? 0.f : 0.8 * M_PI * myRandom();
		m_positionExtension.x += l_length * cos(l_angle);
		m_positionExtension.y += l_length * sin(l_angle);
	}
    else
	{
        float l_length = 0.3 * myRandom() * a_timeInterval;
        float l_angle  = (m_cameraTranslate.x > LIMIT_TO_NO_LIMITE_CAMERA) ? 0.f : M_PI * myRandom();
		m_positionExtension.x += l_length * cos(l_angle);
		m_positionExtension.y += l_length * sin(l_angle);
	}
    
    float l_distanceToZero = DistancePointSquare( [m_pendulumHead GetPosition], CGPointMake(0.f, 0.f));
    if( m_state == STATE_EYE)
    {
        m_luminositySky = 1.f - (l_distanceToZero / LIMIT_TO_RETURN_TO_NORMAL);   
    }
    if(l_distanceToZero > LIMIT_TO_RETURN_TO_NORMAL && (m_state == STATE_EYE))
	{
        m_state = STATE_TANSITION_TO_NORMAL;
	}
	
	[m_pendulumHead UpdateWithBasePosition:m_pendulumBasePositionScaleCurrent timeFrame:l_animationInterval];
	NSMutableArray * l_pendulumArray = [PhysicPendulum GetList];
	int l_arraySize = [l_pendulumArray count];
	
	l_pendulePosition = [[l_pendulumArray objectAtIndex:2] GetPosition];
	l_penduleAngle = [[l_pendulumArray objectAtIndex:2] m_angle];
	
	// draw the head.
	int l_headTexture = TEXTURE_SEA_SNAKE_HEAD;
	[l_sharedEAGLView drawTextureIndex:l_headTexture
								  plan:PLAN_PENDULUM
								  size:	m_levelData.m_snakeSizeHead
							 positionX:l_pendulePosition.x + m_snakeDrawDecay.x
							 positionY:l_pendulePosition.y + m_snakeDrawDecay.y
							 positionZ:0.
						 rotationAngle:RADIAN_TO_DEDREE(l_penduleAngle)
					   rotationCenterX:l_pendulePosition.x
					   rotationCenterY:l_pendulePosition.y
						  repeatNumber:1
						 widthOnHeight:1.f
							nightBlend:false
						   deformation:0.f
							  distance:-1.f
								decayX:0.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	// we decrease the size of the snake parts to give it a good shape.
	float l_pendulumBodySizeCoeff = 1.f;

	for(int i = 3; i < l_arraySize; i++)
	{
		l_pendulePosition = [[l_pendulumArray objectAtIndex:i] GetPosition];
		l_penduleAngle = [[l_pendulumArray objectAtIndex:i] m_angle];
		[l_sharedEAGLView drawTextureIndex:TEXTURE_SEA_SNAKE_BODY
									  plan:PLAN_PENDULUM
									  size:	m_levelData.m_snakeSizeBody * l_pendulumBodySizeCoeff
								 positionX:l_pendulePosition.x + m_snakeDrawDecay.x
								 positionY:l_pendulePosition.y + m_snakeDrawDecay.y
								 positionZ:0.
							 rotationAngle:RADIAN_TO_DEDREE(l_penduleAngle)
						   rotationCenterX:l_pendulePosition.x
						   rotationCenterY:l_pendulePosition.y
							  repeatNumber:1
							 widthOnHeight:1.f
								nightBlend:false
							   deformation:0.f
								  distance:-1.f
		 							decayX:0.f
									decayY:0.f
									 alpha:1.f
									planFX:PLAN_BACKGROUND_SHADOW
								   reverse:REVERSE_NONE
		 ];
		
		l_pendulumBodySizeCoeff *= 0.95;
	}	
	return YES;
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateKilling:(NSTimeInterval)a_timeInterval
{
	CGPoint l_positionBody = [m_puppet GetPositionBody];
	CGPoint l_positionSword = [m_puppet GetPositionSword];
	float	l_hitStrength = [m_puppet GetSpeedSword];
    CGPoint l_positionTongue = [m_bigHead GetPositionTongue];
    m_timeSinceHit -= a_timeInterval;
    
    if(DistancePoint(l_positionSword, l_positionTongue) < 0.2 && (l_hitStrength > 1.5f))
    {
        [m_bigHead Hit];
        [[OpenALManager sharedOpenALManager] playSoundWithKey:@"BigMonsterScream" Volume:0.7f];	
        [[OpenALManager sharedOpenALManager] SetPitchWithKey:@"BigMonsterScream" Pitch:2.f];
        if(m_state == STATE_NORMAL_WITH_SNAKE)
        {
            m_misterDead = YES;
            m_skyDecayToQuit = m_skyDecay.x - 3.f;
        }
    }
    
    if((DistancePoint(l_positionBody, l_positionTongue) < 0.2f) && (m_timeSinceHit < 0.f))
    {
        m_timeSinceHit = .5f;
        [m_puppet Hit:6];
    }

	return YES;
}

// Multi touch event.
-(void)Touch:(CGPoint)a_touchLocation
{
	if(DistancePoint(a_touchLocation, m_fingerPosition[0]) > DistancePoint(a_touchLocation, m_fingerPosition[1]))
	{
		m_fingerPosition[1] = a_touchLocation;
		m_fingerMoved = 1;
	}
	else
	{
		m_fingerPosition[0] = a_touchLocation;
		m_fingerMoved = 0;
	}
	
	return;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	if(DistancePoint(a_touchLocation, m_fingerPosition[0]) > DistancePoint(a_touchLocation, m_fingerPosition[1]))
	{
		m_fingerPosition[1] = a_touchLocation;
		m_fingerMoved = 1;
	}
	else
	{
		m_fingerPosition[0] = a_touchLocation;
		m_fingerMoved = 0;
	}
	
	return;
}

// Multi touch event.
-(void)MultiTouch:(CGPoint)a_touchLocation0 touch2:(CGPoint)a_touchLocation1
{
	float l_distanceTouch0ToFinger0 = DistancePointSquare(a_touchLocation0, m_fingerPosition[0]);
	float l_distanceTouch0ToFinger1 = DistancePointSquare(a_touchLocation0, m_fingerPosition[1]);
	float l_distanceTouch1ToFinger0 = DistancePointSquare(a_touchLocation1, m_fingerPosition[0]);
	float l_distanceTouch1ToFinger1 = DistancePointSquare(a_touchLocation1, m_fingerPosition[1]);
	
	if((l_distanceTouch0ToFinger0 / l_distanceTouch0ToFinger1) < (l_distanceTouch1ToFinger0 / l_distanceTouch1ToFinger1))
	{
		// the touch 1 is on the finger 0
		m_multiTouchMondayToTuesday = NO;
		m_fingerPosition[0] = a_touchLocation0;
		m_fingerPosition[1] = a_touchLocation1;
	}
	else
	{
		m_multiTouchMondayToTuesday = YES;
		m_fingerPosition[0] = a_touchLocation1;
		m_fingerPosition[1] = a_touchLocation0;
	}
	
	return;
}

// Multi touch event.
-(void)MultiTouchMove:(CGPoint)a_touchLocation0 touch2:(CGPoint)a_touchLocation1
{
	if(m_multiTouchMondayToTuesday)
	{
		// the touch 1 is on the finger 0
		m_fingerPosition[0] = a_touchLocation1;
		m_fingerPosition[1] = a_touchLocation0;
	}
	else
	{
		m_fingerPosition[0] = a_touchLocation0;
		m_fingerPosition[1] = a_touchLocation1;
	}
	
	return;
}

-(void)Eventf1:(float)a_value
{
    m_isCrazy = YES;
    m_state = STATE_NORMAL;
}

-(void)Event1:(int)a_value
{
    if(m_state != STATE_NORMAL_WITH_SNAKE)
    {
        m_state = STATE_NORMAL_EXIT;
        [[OpenALManager sharedOpenALManager] playSoundWithKey:@"SeaTransition" Volume:0.5f];
        [[OpenALManager sharedOpenALManager] FadeWithKey:@"SeaTransition" duration:1.5f volume:1.f stopEnd:NO];
    }
    else
    {
        [m_bigHead SetDead];
        [m_bigArm SetDead];
    }
    [m_bigHead SetIdle:YES];
}

-(void)Event2:(int)a_value
{
	[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreSeaGameOver alloc] init]];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"SeaStateNormal" duration:13.f volume:0.f stopEnd:YES];
}

-(void)Terminate
{
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	// destroy the snake.
	[[ParticleManager sharedParticleManager] KillParticles];
	
	[m_puppet release];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

-(id)GetNoteBook
{
	return nil;

}

-(NSArray *)GetSoundArray
{
    return [NSArray arrayWithObjects:@"raclement", @"treeFriction", @"shock", @"crazyness", @"wind", @"SeaTransition", @"SeaStateNormal", @"slarp", @"pig", @"BigMonsterScream", nil];
}

@end
