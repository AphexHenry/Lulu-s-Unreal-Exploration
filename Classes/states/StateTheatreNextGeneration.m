//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatreNextGeneration.h"
#import "StateTheatreNextGenerationGameOver.h"
#import "StateTheatreNextGenerationOut.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "PuppetEvolved.h"
#import "ParticleManager.h"
#import "ParticleMonsterTheatreBasic.h"
#import "ParticleMonsterTheatreTeleport.h"
#import "ParticleMonsterTheatreFlower.h"
#import "ParticleLightBug.h"
#import "ParticleBeast.h"

#define STICK_LENGTH 1.
#define GROUND_Y -0.6f
#define TIME_BEFORE_OPEN_CURTAINS 2.f
#define SPEED_LULU_TURN .3f
#define SPEED_LULU_WALK 0.25f
#define TIME_MIN_BEFORE_QUIT 5.f
#define GEAR_SPEED 15.f
#define GEAR_POSITION 6.f
#define SPEED_SCROLLING_MAX 0.6f
#define VOLUME_MUSIC .9f
#define MONSTER_NUMBER 20
#define LIGHT_BUG_GROUND -0.75f
#define LIGHT_BUG_POSITION 2.9f
#define FLOWER_POSITION 8.9f
 
@implementation StateTheatreNextGeneration

-(void)StateInit
{
	m_index = STATE_PARTICLE_NEXT_GENERATION_PUPPET;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_T_NEXT_GENERATION_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"nightSky.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"backgroundNextGeneration.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_PUPPET_BODY] = [[NSString alloc] initWithString:@"luluFight.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_PUPPET_HEAD] = [[NSString alloc] initWithString:@"luluFightHead.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_PUPPET_ARM] = [[NSString alloc] initWithString:@"puppetNewGenerationArm.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_PUPPET_SWORD] = [[NSString alloc] initWithString:@"puppetNewGenerationSword.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_GEAR] = [[NSString alloc] initWithString:@"gear.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_LIGHTBUG] = [[NSString alloc] initWithString:@"lightBugBig.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_DEAD_THING] = [[NSString alloc] initWithString:@"deadThing.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MOUSSE] = [[NSString alloc] initWithString:@"mousse.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_BEAST] = [[NSString alloc] initWithString:[[ApplicationManager sharedApplicationManager] GetABeastName]];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_FLOWER] = [[NSString alloc] initWithString:@"flower.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_GRASS] = [[NSString alloc] initWithString:@"grass.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_PART_1] = [[NSString alloc] initWithString:@"puppetMonster0Part1.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_PART_2] = [[NSString alloc] initWithString:@"puppetMonster0Part2.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_1_PART_1] = [[NSString alloc] initWithString:@"puppetMonster1Part1.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_1_PART_2] = [[NSString alloc] initWithString:@"puppetMonster1Part2.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_2_PART_1] = [[NSString alloc] initWithString:@"puppetMonster2Part1.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_2_PART_2] = [[NSString alloc] initWithString:@"puppetMonster2Part2.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_3_PART_1] = [[NSString alloc] initWithString:@"puppetMonster3Part1.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_3_PART_2] = [[NSString alloc] initWithString:@"puppetMonster3Part2.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_4_PART_1] = [[NSString alloc] initWithString:@"puppetMonster4Part1.png"];
	m_levelData.m_textureArray[TEXTURE_T_NEXT_GENERATION_MONSTER_4_PART_2] = [[NSString alloc] initWithString:@"puppetMonster4Part2.png"];
	
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
	
	m_puppet = [[PuppetEvolved alloc] InitWithTexturePuppet:TEXTURE_T_NEXT_GENERATION_PUPPET_BODY 
												 TextureArm:TEXTURE_T_NEXT_GENERATION_PUPPET_ARM
											   TextureSword:TEXTURE_T_NEXT_GENERATION_PUPPET_SWORD
												  Stick:TEXTURE_T_NEXT_GENERATION_STICK 
											TextureHead:TEXTURE_T_NEXT_GENERATION_PUPPET_HEAD
											TextureLeg:-1
										   InitPosition:m_fingerPosition[0]
										  PanelSequence:nil
				   ];
	
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	float l_position = 6.5f;
	int l_texture = TEXTURE_T_NEXT_GENERATION_MONSTER_PART_1;
	for(int i = 0; i < MONSTER_NUMBER; i++)
	{
		l_texture = TEXTURE_T_NEXT_GENERATION_MONSTER_PART_1 + (arc4random() % 4) * 2;
		[l_particleManager AddParticle:[[ParticleMonsterTheatreBasic alloc] initWithTexture:l_texture textureStick:TEXTURE_T_NEXT_GENERATION_STICK initPosition:CGPointMake(l_position, myRandom() * 1.9f)]];
		
		l_position += (1.f - (float)i/(float)MONSTER_NUMBER) * (1.6f + myRandom() * 0.6f);
	}
	
	l_position += 3.5f;
	
	for(int i = 0; i < 1; i++)
	{
		[l_particleManager AddParticle:[[ParticleMonsterTheatreTeleport alloc] initWithTexture:TEXTURE_T_NEXT_GENERATION_MONSTER_4_PART_1 textureStick:TEXTURE_T_NEXT_GENERATION_STICK initPosition:CGPointMake(l_position, myRandom() * 1.9f)]];
	}

	float l_flowerBasePosition = FLOWER_POSITION + myRandom();
	for(int i = 0; i < 3; i++)
	{
		for(int i = 0; i < 12; i++)
		{
			l_position = l_flowerBasePosition + myRandom() * 0.8f;
			[l_particleManager AddParticle:[[ParticleMonsterTheatreFlower alloc] initWithTexture:TEXTURE_T_NEXT_GENERATION_FLOWER textureStick:TEXTURE_T_NEXT_GENERATION_STICK initPosition:CGPointMake(l_position, LIGHT_BUG_GROUND + 0.1)]];
		}
		l_flowerBasePosition += 5.f + myRandom() * 4.f; 
	}
	
	l_position = LIGHT_BUG_POSITION;
	for(int i = 0; i < 35; i++)
	{
		l_texture = TEXTURE_T_NEXT_GENERATION_LIGHTBUG;
		[l_particleManager AddParticle:[[ParticleLightBugNextGeneration alloc] initWithTexture:TEXTURE_T_NEXT_GENERATION_LIGHTBUG size:3.1f position:CGPointMake(l_position, LIGHT_BUG_GROUND)]];
		
		l_position = LIGHT_BUG_POSITION + myRandom() * 0.07f;
	}
	
	ParticleBeast * l_particleBeast = [[ParticleBeast alloc] init];
	[l_particleBeast SetAnimation:TEXTURE_T_NEXT_GENERATION_BEAST];
	[l_particleManager AddParticle:l_particleBeast];
	
	[ParticleRose SetGroundY:LIGHT_BUG_GROUND];
	[ParticleRose SetHeraticCoeff:0.2f];
	[ParticleRose SetDistance:-1.f];
	
	[[ParticleManager sharedParticleManager] ActiveDeadParticles];
	
	//[[OpenALManager sharedOpenALManager] StopAll];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"wind" duration:2.f volume:0.f stopEnd:YES];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"treeFriction" Volume:0.f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"musicAphex" Volume:0.3f * VOLUME_MUSIC];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"crazyness" Volume:0.f];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"bicycle" duration:6.f volume:0.f stopEnd:YES];
	
	return [super StateInit];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	m_time += a_timeInterval;
	m_skyDecay.x += -a_timeInterval * m_puppetSpeed * SPEED_LULU_WALK;
	
	// this is just to have a clearer code.
	if(![self UpdatePuppet:a_timeInterval])
	{
		return;
	}
	
	[self UpdateKilling:a_timeInterval];

	[ParticleMonsterTheatre SetPosition:CGPointMake(-m_skyDecay.x * 2.5f, 0.f)];
	[ParticleMonsterTheatre SetTargetPosition:[m_puppet GetPositionBody]];
	[ParticleRose SetXTranslate:-m_skyDecay.x * 2.5f];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_NEXT_GENERATION_DEAD_THING
								  plan:PLAN_BACKGROUND_STICKERS
								  size:0.2
							 positionX:m_skyDecay.x * 2.5f + LIGHT_BUG_POSITION
							 positionY:LIGHT_BUG_GROUND + 0.1
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1.
							  distance:0.f
	  ];
	
	
	[ParticleLightBugNextGeneration SetPositionTarget:[m_puppet GetPositionBody]];
	
	float l_size	 = m_levelData.m_size;
	
	[[ParticleManager sharedParticleManager] UpdateParticlesWithTimeInterval:a_timeInterval];
	[[ParticleManager sharedParticleManager] drawself];

	float l_currentAroundDeformation =  0.07 * cos(m_aroundTextureDeformation);
	m_aroundTextureDeformationFrequency += myRandom() * a_timeInterval * 0.3;
	m_aroundTextureDeformationFrequency = clip(m_aroundTextureDeformationFrequency, 0.2, 5.);
	m_aroundTextureDeformation += m_aroundTextureDeformationFrequency * a_timeInterval;
	
	float l_sizeMoon = max((1.5f + m_skyDecay.x / 10.f), 1.1);

	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND
								  size:1. * l_size
							 positionX:0.f
							 positionY:0.f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1.
							  distance:10.f
	 ];
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_MOON
								  plan:PLAN_BACKGROUND_STICKERS
								  size:1.7 * l_sizeMoon
							 positionX:-.5 - m_skyDecay.x / 14.f
							 positionY:-1.5f - m_skyDecay.x / 5.f  
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1.
							  distance:0.f
	 ];
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 1.f
							 positionX:0.f
							 positionY:0.2f
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:8.f
							nightBlend:false
						   deformation:0.5 * l_currentAroundDeformation
							  distance:min(-5.f - m_skyDecay.x * 10.f, 2.f)
								decayX:-m_skyDecay.x / 7.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_STICKERS
							   reverse:REVERSE_NONE
	 ];
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_NEXT_GENERATION_GRASS
								  plan:PLAN_PENDULUM
								  size:l_size / 7.f
							 positionX:0.f
							 positionY:LIGHT_BUG_GROUND + 0.08f
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:9.f
							nightBlend:false
						   deformation:0.5 * l_currentAroundDeformation
							  distance:min(-5.f - m_skyDecay.x * 10.f, 2.f)
								decayX:-m_skyDecay.x * 1.5f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_STICKERS
							   reverse:REVERSE_NONE
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_NEXT_GENERATION_FRONT
								  plan:PLAN_BACKGROUND_SHADOW
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							nightBlend:false
						   deformation:l_currentAroundDeformation
							  distance:-1.f
								decayX:-m_skyDecay.x
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_STICKERS
							   reverse:REVERSE_NONE
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_NEXT_GENERATION_MOUSSE
								  plan:PLAN_SKY_SHADOW
								  size:	.9f
							 positionX:GEAR_POSITION + 0.3 + m_skyDecay.x / 1.f
							 positionY:.9f
							 positionZ:0.
						 rotationAngle:180.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.
							nightBlend:false
						   deformation:.2 * cos(m_time)
							  distance:30.f
								decayX:0.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_STICKERS
							   reverse:REVERSE_NONE
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_NEXT_GENERATION_GEAR
								  plan:PLAN_SKY_SHADOW
								  size:	1.f
							 positionX:GEAR_POSITION + m_skyDecay.x / 1.f
							 positionY:.9f
							 positionZ:0.
						 rotationAngle:m_time * GEAR_SPEED
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.
							nightBlend:false
						   deformation:0.f
							  distance:30.f
								decayX:0.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_STICKERS
							   reverse:REVERSE_NONE
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_NEXT_GENERATION_GEAR
								  plan:PLAN_SKY_SHADOW
								  size:	0.6f
							 positionX:GEAR_POSITION + 0.6 + m_skyDecay.x / 1.f
							 positionY:0.6f
							 positionZ:0.
						 rotationAngle:-m_time * GEAR_SPEED * 1.5
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.
							nightBlend:false
						   deformation:0.f
							  distance:30.f
								decayX:0.f
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_STICKERS
							   reverse:REVERSE_NONE
	 ];
	
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"grind" Volume:clip(1.f - 0.5 * Absf(GEAR_POSITION + m_skyDecay.x / 1.f), 0.f, 1.f)];
	
	
	[super UpdateWithTimeInterval:a_timeInterval];
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval
{
	if(m_fingerPosition[0].x < m_fingerPosition[1].x)
	{
        m_fingerPosition[0].x = min(m_fingerPosition[0].x, -0.2f);
		// the touch 1 is on the finger 0
		[m_puppet UpdateWithPosition:m_fingerPosition[0] positionHand:m_fingerPosition[1] timeInterval:a_timeInterval];
		m_puppetSpeed = clip(m_fingerPosition[0].x + 0.9f, 0.f, SPEED_SCROLLING_MAX);
	}
	else
	{
        m_fingerPosition[1].x = min(m_fingerPosition[1].x, -0.2f);
		[m_puppet UpdateWithPosition:m_fingerPosition[1] positionHand:m_fingerPosition[0] timeInterval:a_timeInterval];
		m_puppetSpeed = clip(m_fingerPosition[1].x + 0.9f, 0.f, SPEED_SCROLLING_MAX);
	}
	
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"musicAphex" Volume:VOLUME_MUSIC * ( 0.6f + 0.4f * m_puppetSpeed / SPEED_SCROLLING_MAX )];

	return YES;
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateKilling:(NSTimeInterval)a_timeInterval
{
	CGPoint l_positionSword = [m_puppet GetPositionSword];
	float	l_hitStrength = [m_puppet GetSpeedSword];
	ParticleMonsterTheatre * l_monsterToKill = (ParticleMonsterTheatre *)[[ParticleManager sharedParticleManager] GetParticleWithPosition:l_positionSword distanceMin:0.05];
	if(l_monsterToKill && (l_monsterToKill->m_group == PARTICLE_GROUP_MONSTER_THEATRE) && (l_hitStrength > 1.f))
	{
		[l_monsterToKill HitWithStrength:l_hitStrength];
	}

	return YES;
}

-(void)LaunchSequence
{

}

// Multi touch event.
-(void)Touch:(CGPoint)a_touchLocation
{
	if(DistancePoint(a_touchLocation, m_fingerPosition[0]) > DistancePoint(a_touchLocation, m_fingerPosition[1]))
	{
		m_fingerPosition[1] = a_touchLocation;
	}
	else
	{
		m_fingerPosition[0] = a_touchLocation;
	}
	
	return;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	if(DistancePoint(a_touchLocation, m_fingerPosition[0]) > DistancePoint(a_touchLocation, m_fingerPosition[1]))
	{
		m_fingerPosition[1] = a_touchLocation;
	}
	else
	{
		m_fingerPosition[0] = a_touchLocation;
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

-(void)Event1:(int)a_value
{
	[m_puppet Hit:1.6f];
}

-(void)Event2:(int)a_value
{
	[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreNextGenerationGameOver alloc] init]];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"musicAphex" duration:13.f volume:0.f stopEnd:YES];
}

-(void)Event3:(int)a_value
{
	if(!m_isCrazy)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateTheatreNextGenerationOut alloc] init]];
        [[ApplicationManager sharedApplicationManager] SaveLevel:STATE_SEA];
		[[OpenALManager sharedOpenALManager] FadeWithKey:@"crazyness" duration:13.f volume:0.f stopEnd:YES];
	}
}

-(void)Eventf1:(float)a_value
{
	m_isCrazy = YES;
}

-(void)Terminate
{
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	// destroy the snake.
	[[ParticleManager sharedParticleManager] KillParticles];
	
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"grind"];
	
	[m_puppet release];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

-(id)GetNoteBook
{
	return [[NoteBook alloc] InitWithString:@"Damn monster!_£££££££££££££Now the Scutigerus has gone far away, to the deepest forest._ It is said that the cursed Yōkais live there, which feed on the minds of lost travellers._ Let's go find it!_£££££££££L."
								MusicToFade:@"bicycle"
			];
}

-(NSArray *)GetSoundArray
{
    return [NSArray arrayWithObjects:@"crazyness", @"craquement mystérieux", @"bicycle", @"musicAphex", @"noiseGrass", @"ambientSwamp",@"eclosion", @"wind", @"treeFriction", @"guadaStick1", @"guadaStick2", @"pig", nil];
}


@end
