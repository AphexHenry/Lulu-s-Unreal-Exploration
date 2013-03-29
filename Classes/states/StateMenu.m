//
//  StateIntro.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateMenu.h"
#import "State.h"
#import	"StateLucioles.h"
#import	"StateLarve.h"
#import	"StateSpiral.h"
#import	"StateParticleFight.h"
#import	"StateTheatreNextGeneration.h"
#import	"StateSea.h"
#import	"StateTheatreTreesFast.h"
#import "ParticleViewController.h"
#import "ParticleManager.h"
#import "ParticleLetter.h"
#import "MathTools.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"

#define RABBIT_DISTANCE_INIT 25.f

const float ANGLE_MENU = M_PI / 2.5;

@implementation StateMenu

-(void)StateInit
{
	m_index = STATE_MENU;
	m_levelData.m_duplicate = 1;
	m_levelData.m_widthOnHeigth = 1.f;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 17;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.14;
	m_levelData.m_snakeSizeHead = 0.17;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_MENU_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"nightSky.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"wallSulpiceShadow.png"];
	m_levelData.m_textureArray[TEXTURE_MENU_THEATRE] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_RABBIT] = [[NSString alloc] initWithString:@"rabbit.png"];
	m_levelData.m_textureArray[TEXTURE_BACK] = [[NSString alloc] initWithString:@"back.png"];
	m_levelData.m_textureArray[TEXTURE_N] = [[NSString alloc] initWithString:@"n.png"];
	m_levelData.m_textureArray[TEXTURE_E] = [[NSString alloc] initWithString:@"e.png"];
	m_levelData.m_textureArray[TEXTURE_W] = [[NSString alloc] initWithString:@"w.png"];
	m_levelData.m_textureArray[TEXTURE_G] = [[NSString alloc] initWithString:@"g.png"];
	m_levelData.m_textureArray[TEXTURE_A] = [[NSString alloc] initWithString:@"a.png"];
	m_levelData.m_textureArray[TEXTURE_M] = [[NSString alloc] initWithString:@"m.png"];
	m_levelData.m_textureArray[TEXTURE_D] = [[NSString alloc] initWithString:@"d.png"];
	m_levelData.m_textureArray[TEXTURE_S] = [[NSString alloc] initWithString:@"s.png"];
	m_levelData.m_textureArray[TEXTURE_V] = [[NSString alloc] initWithString:@"v.png"];
	m_levelData.m_textureArray[TEXTURE_LEVEL_1] = [[NSString alloc] initWithString:@"level1.png"];
	m_levelData.m_textureArray[TEXTURE_LEVEL_2] = [[NSString alloc] initWithString:@"level2.png"];	
	m_levelData.m_textureArray[TEXTURE_LEVEL_3] = [[NSString alloc] initWithString:@"level3.png"];
	m_levelData.m_textureArray[TEXTURE_LEVEL_4] = [[NSString alloc] initWithString:@"level4.png"];
	m_levelData.m_textureArray[TEXTURE_LEVEL_5] = [[NSString alloc] initWithString:@"level5.png"];
    m_levelData.m_textureArray[TEXTURE_LEVEL_6] = [[NSString alloc] initWithString:@"level6.png"];
    m_levelData.m_textureArray[TEXTURE_LEVEL_FINAL] = [[NSString alloc] initWithString:@"level7.png"];
	m_levelData.m_textureArray[TEXTURE_MENU_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_ANIM_WINGS_0] = [[NSString alloc] initWithString:@"wings0.png"];
	m_levelData.m_textureArray[TEXTURE_ANIM_WINGS_1] = [[NSString alloc] initWithString:@"wings1.png"];
	
	m_cloudPosition = -3.f;
	m_cloudSize = 1.;
	m_cloudAngle = 0.;
	
	m_rabbitDistance = 100.f;
	m_rabbitAlpha = 0.f;
	m_clickPosition = CGPointMake(-1.f, -1.f);

	EAGLView *l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView initLevel:m_levelData];
	[l_sharedEAGLView SetCamera:CAMERA_GLOBAL];
	[l_sharedEAGLView SetLuminosity:0.];
	[l_sharedEAGLView SetBlur:0.];
	
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];

	[ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_ANIM_WINGS_0 lastFrame:TEXTURE_ANIM_WINGS_1 duration:0.07]
						 angle:ANGLE_MENU * 180 / M_PI
				 texturePause:TEXTURE_ANIM_WINGS_0
					  sizeWing:1.7f
	 ];
	
	[ParticleLetter SetPosition:CGPointMake(-0.5, 0.3f)];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_N textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_NEW_GAME]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_E textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_NEW_GAME]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_W textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_NEW_GAME]];
	[ParticleLetter Space];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_G textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_NEW_GAME]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_A textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_NEW_GAME]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_M textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_NEW_GAME]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_E textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_NEW_GAME]];
	[ParticleLetter SetSize:0.06 group:MENU_TYPE_MAIN_NEW_GAME];
	[ParticleLetter SetPosition:CGPointMake(-0.5, -0.3f)];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_S textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_A textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_V textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_E textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_D textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[ParticleLetter Space];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_G textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_A textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_M textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_E textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_MAIN_SELECT_LEVEL]];
	[ParticleLetter SetSize:0.06 group:MENU_TYPE_MAIN_SELECT_LEVEL];
	[ParticleLetter SetPosition:CGPointMake(-0.4, 0.3f)];
	
	int l_texture;
	int l_row = 0;
	for(int i = 0; i < [[ApplicationManager sharedApplicationManager] m_savedLevel]; i++)
	{
		if(i - (l_row + 1) * 4 >= 0)
		{
			[ParticleLetter SetPosition:CGPointMake(-0.4, -0.1f)];
			l_row++;
		}
		l_texture = TEXTURE_LEVEL_1 + i;
		[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:l_texture textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_LEVEL_SELECT initPosition:CGPointMake(-4.f, 0.f)]];
		[ParticleLetter Space];
	}

	[ParticleLetter SetPosition:CGPointMake(0.7, -0.5f)];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_BACK textureStick:TEXTURE_MENU_STICK groupIndex:MENU_TYPE_LEVEL_SELECT initPosition:CGPointMake(-4.f, 0.f)]];
	
	[ParticleLetter SetSize:0.09 group:MENU_TYPE_LEVEL_SELECT];
	[l_particleManager ActiveDeadParticles];
	
	OpenALManager * l_soundManager =  [OpenALManager sharedOpenALManager];
	[l_soundManager playSoundWithKey:@"wind" Volume:0.23f];
	if(![l_soundManager isPlayingSoundWithKey:@"string"])
	{
		[l_soundManager playSoundWithKey:@"string" Volume:4.f];
	}
	
	m_skyDecay = CGPointMake(0.f, 0.f);
	m_state = STATE_MAIN_INIT;
	m_levelSelect = -1;
	
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:TRUE];
	
	return [super StateInit];
}

//Terminate.
-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{
	switch(m_state)
	{
		case STATE_MAIN_INIT:
			[ParticleLetter SetGroupStatus:MENU_TYPE_MAIN_NEW_GAME attractionCommon:NO goAway:NO];
			[ParticleLetter SetGroupStatus:MENU_TYPE_MAIN_SELECT_LEVEL attractionCommon:NO goAway:NO];
			[ParticleLetter SetGroupStatus:MENU_TYPE_LEVEL_SELECT attractionCommon:NO goAway:YES];
			m_state = STATE_MAIN_UPDATE;
			break;
		case STATE_MAIN_UPDATE:
			if(m_clickPosition.y > -1.)
			{
				if(m_clickPosition.y > 0.)
				{
					[ParticleLetter SetGroupStatus:MENU_TYPE_MAIN_NEW_GAME attractionCommon:YES goAway:NO];
					[ParticleLetter SetGroupStatus:MENU_TYPE_MAIN_SELECT_LEVEL attractionCommon:NO goAway:YES];
					[ParticleLetter SetGroupStatus:MENU_TYPE_LEVEL_SELECT attractionCommon:NO goAway:YES];
					[ParticleLetter SetAttractionPoint:MENU_TYPE_MAIN_NEW_GAME position:m_clickPosition];
					m_levelSelect = 0;
					m_state = STATE_BEGIN_GAME_INIT;
				}
				else
				{
					[ParticleLetter SetGroupStatus:MENU_TYPE_MAIN_NEW_GAME attractionCommon:NO goAway:YES];
					[ParticleLetter SetGroupStatus:MENU_TYPE_MAIN_SELECT_LEVEL attractionCommon:YES goAway:NO];
					[ParticleLetter SetGroupStatus:MENU_TYPE_LEVEL_SELECT attractionCommon:NO goAway:NO];
					[ParticleLetter SetAttractionPoint:MENU_TYPE_MAIN_SELECT_LEVEL position:m_clickPosition];
					m_nextStateTimer = 1.6f;
					[[OpenALManager sharedOpenALManager] playSoundWithKey:@"menuClick" Volume:.6f];
					[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"menuClick" Pitch:1.f];
					m_state = STATE_MAIN_END;
				}
				m_clickPosition = CGPointMake(-1.f, -1.f);
			}
			break;
		case STATE_MAIN_END:
			m_nextStateTimer -= a_timeInterval;
			if(m_nextStateTimer < 0.f)
			{
				[ParticleLetter SetGroupStatus:MENU_TYPE_MAIN_NEW_GAME attractionCommon:NO goAway:YES];
				[ParticleLetter SetGroupStatus:MENU_TYPE_MAIN_SELECT_LEVEL attractionCommon:NO goAway:YES];
				[ParticleLetter SetGroupStatus:MENU_TYPE_LEVEL_SELECT attractionCommon:NO goAway:NO];
				m_state = STATE_LEVEL_UPDATE;
			}
			break;
		case STATE_LEVEL_UPDATE:
			if(m_clickPosition.y > -1.)
			{
				int l_texture = [[ParticleManager sharedParticleManager] GetTextureWithPosition:m_clickPosition];
				m_clickPosition = CGPointMake(-1.f, -1.f);
				if(l_texture > 1)
				{
					if(l_texture == TEXTURE_BACK)
					{
						[[OpenALManager sharedOpenALManager] playSoundWithKey:@"menuClick" Volume:.6f];
						[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"menuClick" Pitch:0.9f];
						m_state = STATE_MAIN_INIT;
					}
					else
					{
						m_levelSelect = l_texture - TEXTURE_LEVEL_1;
						if(m_levelSelect >= 0)
						{
							m_state = STATE_BEGIN_GAME_INIT;
							[ParticleLetter SetGroupStatus:MENU_TYPE_LEVEL_SELECT attractionCommon:NO goAway:YES];
						}
					}
				}
			}
			break;
		case STATE_BEGIN_GAME_INIT :
			m_rabbitDistance = RABBIT_DISTANCE_INIT;
			[[OpenALManager sharedOpenALManager] FadeWithKey:@"string" duration:2.f volume:0.f stopEnd:YES];
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"string2" Volume:.3f];
			m_rabbitAlpha = 0.f;
			m_state = STATE_BEGIN_GAME_UPDATE;
			break;
		case STATE_BEGIN_GAME_UPDATE:
			m_rabbitDistance *= 1. - 0.8 * a_timeInterval;
			m_rabbitAlpha = clip(1.f - ((m_rabbitDistance - 0.2 * RABBIT_DISTANCE_INIT) / (0.8 * RABBIT_DISTANCE_INIT)), 0.f, 1.f);
			// draw background.
			[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_RABBIT
												   plan:PLAN_PARTICLE_BEHIND
												   size:2. / m_rabbitDistance
											  positionX:0.
											  positionY:0.
											  positionZ:0.
										  rotationAngle:3000.f / m_rabbitDistance
										rotationCenterX:0.
										rotationCenterY:0.
										   repeatNumber:1
										  widthOnHeight:m_rabbitAlpha * (1. + 0.2 * cos(m_rabbitDistance))
											 nightBlend:false
											deformation:0.2 * cos(0.5 * m_rabbitDistance)
											   distance:m_rabbitDistance + 40.
												 decayX:0.
												 decayY:0.
												  alpha:m_rabbitAlpha
												 planFX:-1
												reverse:REVERSE_NONE
			 
			 ];
			
			float l_stickSize = 16. / m_rabbitDistance;
			[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_MENU_STICK
												   plan:PLAN_PARTICLE_BEHIND
												   size:l_stickSize
											  positionX:0.
											  positionY:-l_stickSize
											  positionZ:0.
										  rotationAngle:0.
										rotationCenterX:0.
										rotationCenterY:0.
										   repeatNumber:1
										  widthOnHeight:1.f / 100.f
											 nightBlend:false
											deformation:0.
											   distance: 150.
												 decayX:0.
												 decayY:0.
												  alpha:m_rabbitAlpha//m_rabbitAlpha * 0.8f
												 planFX:-1
												reverse:REVERSE_NONE
			 
			 ];
			
			if(m_rabbitDistance < RABBIT_DISTANCE_INIT / 10.f)
			{
				[ParticleLetter SetAttractionPoint:MENU_TYPE_MAIN_NEW_GAME position:CGPointMake(-2.f, 0.f)];
			}
			float l_limitBeforFading = 3.f;
			float l_limitEndOfFading = 1.5f;
			if(m_rabbitDistance < (RABBIT_DISTANCE_INIT * l_limitBeforFading / 100.f))
			{
				float l_luminosity = (m_rabbitDistance - (RABBIT_DISTANCE_INIT * l_limitEndOfFading / 100.f)) / (RABBIT_DISTANCE_INIT * (l_limitBeforFading - l_limitEndOfFading) / 100.f);
				[[EAGLView sharedEAGLView] SetLuminosity:max(l_luminosity, 0.f)];
				m_levelSelect = (int)clip(m_levelSelect, 0., TEXTURE_LEVEL_FINAL - TEXTURE_LEVEL_1);
				if(l_luminosity <= 0.f)
				{
					switch(m_levelSelect)
					{
						case 0:
							[[ApplicationManager sharedApplicationManager] ChangeState:[[StateLucioles alloc] init]];
							break;
						case 1:
							[[OpenALManager sharedOpenALManager] StopAll];
							[[ApplicationManager sharedApplicationManager] ChangeStateFromMenu:[[StateLarve alloc] init]];
							return;
						case 2:
							[[OpenALManager sharedOpenALManager] StopAll];
							[[ApplicationManager sharedApplicationManager] ChangeStateFromMenu:[[StateSpiral alloc] init]];
                            break;
						case 3:
							[[OpenALManager sharedOpenALManager] StopAll];
							[[ApplicationManager sharedApplicationManager] ChangeStateFromMenu:[[StateParticleFight alloc] init]];
                            break;
						case 4:
							[[OpenALManager sharedOpenALManager] StopAll];
							[[ApplicationManager sharedApplicationManager] ChangeStateFromMenu:[[StateTheatreNextGeneration alloc] init]];
                            break;
                        case 5:
							[[OpenALManager sharedOpenALManager] StopAll];
							[[ApplicationManager sharedApplicationManager] ChangeStateFromMenu:[[StateSea alloc] init]];
                            break;
                        case 6:
							[[OpenALManager sharedOpenALManager] StopAll];
							[[ApplicationManager sharedApplicationManager] ChangeStateFromMenu:[[StateTheatreTreesFast alloc] init]];
                            break;

					}
				}
			}
			break;
		default:
			break;
			
	}
	
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	[l_particleManager UpdateParticlesWithTimeInterval:a_timeInterval];
	[l_particleManager drawself];
	
	// draw background.
	int l_repeatNumber = m_levelData.m_duplicate;
	float l_widthOnHeigth = m_levelData.m_widthOnHeigth;
	float l_size	 = m_levelData.m_size;
	
	m_cloudPosition += 0.4 * a_timeInterval * m_cloudSize;
	m_zoom += 0.2 * ((M_PI / 2) * a_timeInterval);
	float l_multiply = 1.1 + 0.09 * cos(m_zoom);
	
	m_skyDecay.x += -0.004 * a_timeInterval * sin(ANGLE_MENU);
	m_skyDecay.y += -0.001 * a_timeInterval * cos(ANGLE_MENU);

	// draw background.
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND
								  size:l_size * l_multiply
							 positionX:0
							 positionY:0
							 positionZ:0.
						  repeatNumber:l_repeatNumber
						 widthOnHeight:l_widthOnHeigth
							  distance:-1.f
								decayX:m_skyDecay.x
								decayY:m_skyDecay.y
	 
	 ];
	
	// draw the head.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_MENU_THEATRE
								  plan:PLAN_BACKGROUND_CLOSE
								  size:	l_size * 1.1f
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
							  distance:40.f
	 ];
	
	// draw background.
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_SHADOW
										   plan:PLAN_BACKGROUND_STICKERS
										   size:6. * l_size * l_multiply
									  positionX:0
									  positionY:-0.6f
									  positionZ:0.
								   repeatNumber:l_repeatNumber
								  widthOnHeight:l_widthOnHeigth
									   distance:-1.f
										 decayX:m_skyDecay.x * 10.
										 decayY:m_skyDecay.y * 10.
	 
	 ];
	
	// draw background.
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_MOON
										   plan:PLAN_BACKGROUND_STICKERS
										   size:l_multiply * 1.7
									  positionX:0.f
									  positionY:0.f
									  positionZ:0.
								   repeatNumber:1
								  widthOnHeight:1.
									   distance:-1.f	 
	 ];
	
	if(m_cloudPosition > 3.)
	{
		m_cloudPosition = -3.;
		m_cloudDecay = 2.f * myRandom();
		m_cloudSize = 0.5 + 0.3 * myRandom();
		m_cloudAngle = myRandom() * 10 + ANGLE_MENU * 180 / M_PI;
	}

	[super UpdateWithTimeInterval:a_timeInterval];
	
}

-(void)SimpleClick:(CGPoint)a_touchLocation
{
	if(Absf(a_touchLocation.x) < 1. && Absf(a_touchLocation.y) < 0.8)
	{
		m_clickPosition = a_touchLocation;
	}
}

-(NSArray *)GetSoundArray
{
    return [NSArray arrayWithObjects:@"wind", @"string", @"string2", @"music2", @"menuClick",nil];
}

//Terminate.
-(void)Terminate
{
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:NO];
	[[ParticleManager sharedParticleManager] KillParticles];
	[ParticleLetter Terminate];
	[PhysicPendulum RemoveAllElements];
	[super Terminate];
}

@end
