//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatreFlyOutGameOver.h"
#import "StateIntro.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleBeast.h"
#import "ParticleManager.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "Puppet.h"
#import "ParticleLetter.h"

@implementation StateTheatreFlyOutGameOver

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
	m_levelData.m_arraySize = TEXTURE_T_FLY_GAMEOVER_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"luluTitleBack.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_SHADOW_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_GRAVESTONE] = [[NSString alloc] initWithString:@"graveStone.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_MIST] = [[NSString alloc] initWithString:@"mist.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_G] = [[NSString alloc] initWithString:@"g.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_A] = [[NSString alloc] initWithString:@"a.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_M] = [[NSString alloc] initWithString:@"m.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_E] = [[NSString alloc] initWithString:@"e.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_O] = [[NSString alloc] initWithString:@"o.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_V] = [[NSString alloc] initWithString:@"v.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_E] = [[NSString alloc] initWithString:@"e.png"];
	m_levelData.m_textureArray[TEXTURE_T_FLY_GAMEOVER_R] = [[NSString alloc] initWithString:@"r.png"];
	
	[ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_THEATRE_WING_0 lastFrame:TEXTURE_THEATRE_WING_1 duration:0.07]
						 angle:(M_PI / 2.5) * 180 / M_PI
				  texturePause:TEXTURE_THEATRE_WING_0
					  sizeWing:1.7f
	 ];
	
    // init the letters, and set their positions.
	[ParticleLetter SetPosition:CGPointMake(-0.3, 0.3f)];
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_FLY_GAMEOVER_G textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_FLY_GAMEOVER_A textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_FLY_GAMEOVER_M textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_FLY_GAMEOVER_E textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
	[ParticleLetter SetSize:0.07 group:0];
	[ParticleLetter SetPosition:CGPointMake(0., -0.3f)];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_FLY_GAMEOVER_O textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_FLY_GAMEOVER_V textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_FLY_GAMEOVER_E textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_FLY_GAMEOVER_R textureStick:TEXTURE_THEATRE_STICK groupIndex:0]];
	[ParticleLetter SetGroupStatus:0 attractionCommon:NO goAway:NO];
	
	m_skyDecay = CGPointMake(0., 0.);
	m_time = 0.;
	m_sequenceStart = YES;
	m_headDeformation = 1.f;
	
	m_fingerPosition[0] = CGPointMake(0.7f, 0.8f) ;

	m_mappingFingerZeroToPuppet = 0;
	m_musicPitch = 1.f;
	
	return [super StateInit];
}

//
//  Update.
//
-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	m_skyDecay.x += 0.2 * a_timeInterval;
	m_time += a_timeInterval;
	
	m_musicPitch *= 1.f - 0.5 * a_timeInterval;
	m_musicPitch = max(0.35f, m_musicPitch);
	
	[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"bicycle" Pitch:m_musicPitch];
	
	// this is just to have a clearer code.
	if(![self UpdatePuppet:a_timeInterval])
	{
		return;
	}
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_size	 = m_levelData.m_size;
	
	// draw the background..
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
	
	// draw shadows.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:0.f
								decayY:0.f
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_FLY_GAMEOVER_SHADOW_FRONT
								  plan:PLAN_SKY_SHADOW
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:0.f
								decayY:0.f
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_FLY_MIST
								  plan:PLAN_SKY_SHADOW
								  size:1. * 0.3f
							 positionX:0.f
							 positionY:-.65f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:6.
							  distance:-1
								decayX:m_skyDecay.x * 0.05f
								decayY:0.f
	 ];
	
    // draw the gravestone.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_FLY_GAMEOVER_GRAVESTONE
								  plan:PLAN_BACKGROUND_MIDDLE
								  size:0.5
							 positionX:-0.7f
							 positionY:-0.25f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:1.f
							  distance:-1.f
								decayX:0.f
								decayY:0.f
	 
	 ];
	
    // draw the mist.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_FLY_MIST
								  plan:PLAN_BACKGROUND_CLOSE
								  size:1. * 0.3f
							 positionX:0.f
							 positionY:-.8f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:9.
							  distance:-1
								decayX:m_skyDecay.x * .1f
								decayY:0.f
	 ];

	[super UpdateWithTimeInterval:a_timeInterval];
}

//
// Touch event.
//
-(void)Touch:(CGPoint)a_touchLocation
{
	if(m_time > 0.5)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateIntro alloc] init]];
	}
	return;
}

//
//  Terminate.
//
-(void)Terminate
{
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"morvan"];
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

//
//  Return the notebook.
//
-(id)GetNoteBook
{
	return [[NoteBook alloc] InitWithString:@"How disapointing! Component by component, the blue scutigerus decayed and died. It's just_££££££££££ This is so natural! My exploration ends here _I guess. L."
								MusicToFade:@"bicycle"
			];
}

@end
