//
//  StateLucioles.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateLucioles.h"
#import "StateLarve.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleManager.h"
#import "ParticleLightBug.h"
#import "ParticleCloud.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"

#define			NB_MAXCLOUD			2		// Total number of particles in the view.
#define			NB_PARTICLE_BEGIN	165	// Number of element of each group at the beginning.
#define			STICK_LENGTH 3.f
#define			PART_PER_STICK 4

@implementation StateLucioles

-(void)StateInit
{
	m_index = STATE_LUCIOLES;
	
	// Init the level datas.
	m_levelData.m_duplicate = 1;
	m_levelData.m_widthOnHeigth = 1.;
	m_levelData.m_size = 2.5f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.14;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_LUCIOLES_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"nightSky.png"];
	m_levelData.m_textureArray[TEXTURE_CLOUD] = [[NSString alloc] initWithString:@"cloud.png"];
	m_levelData.m_textureArray[TEXTURE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"weed.png"];
	m_levelData.m_textureArray[TEXTURE_SNAKE_BODY] = [[NSString alloc] initWithString:@"LuluBody.png"];
	m_levelData.m_textureArray[TEXTURE_SNAKE_HEAD_OPEN_MOUTH] = [[NSString alloc] initWithString:@"LuluHeadLookAhead.png"];
	m_levelData.m_textureArray[TEXTURE_SNAKE_HEAD_CLOSE_MOUTH] = [[NSString alloc] initWithString:@"LuluHeadCloseMouth.png"];
	m_levelData.m_textureArray[TEXTURE_LUCIOLE_1] = [[NSString alloc] initWithString:@"blueThing.png"];
	m_levelData.m_textureArray[TEXTURE_LUCIOLE_2] = [[NSString alloc] initWithString:@"redThing.png"];
	m_levelData.m_textureArray[TEXTURE_LUCIOLE_3] = [[NSString alloc] initWithString:@"roseThing.png"];
	m_levelData.m_textureArray[TEXTURE_LUCIOLES_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"wallSulpiceShadow.png"];

	m_aroundTextureDeformationFrequency = 1.f;
	m_isIntro = true;
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:TRUE];
	m_lastHeratic = CGPointMake(0.f, 0.f);
	m_lastBlur = 0.f;
	m_lastLuminosity = 0.f;

	m_sizeAroundIntro = 25.f;
	m_basePosition = CGPointMake(.8f, -.8f);
	m_aroundTextureDeformation = 0.f;
	m_skyDecay = CGPointMake(0., 0.);
	m_specialEaten = NO;
	m_sizeMoon = 1.2f;
	
	m_closeState = NO;
	
	[[ParticleManager sharedParticleManager] init];
	
	EAGLView *l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView initLevel:m_levelData];
	[l_sharedEAGLView SetCamera:CAMERA_GLOBAL];
	[l_sharedEAGLView SetLuminosity:0.];
	[l_sharedEAGLView SetBlur:0.];
	
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"wind" Volume:0.8f];
	
	// init the particles.
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	for (int i = 0; i < NB_PARTICLE_BEGIN - 1; i++)
	{
		[l_particleManager AddParticle:[[ParticleLightBug alloc] init]];
	}
	
	[l_particleManager AddParticle:[[ParticleLightBugSpecial alloc] init]];
	
	for (int i = 0; i < NB_MAXCLOUD; i++)
	{
		[l_particleManager AddParticle:[[ParticleCloud alloc] init]];
	}
	[l_particleManager ActiveDeadParticlesFromGroup:PARTICLE_GROUP_CLOUD];

	[self InitSnake];
	return [super StateInit];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{
	// this is just to have a clearer code.
	m_changeSnakeGravityTimer += a_timeInterval;
	if(m_changeSnakeGravityTimer > 6.)
	{
		[m_pendulumHead ChangeGravity];
		m_changeSnakeGravityTimer = 0.;
	}
	
	[self UpdateSnake:a_timeInterval];
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_currentAroundDeformation =  0.074 * cos(m_aroundTextureDeformation);
	m_aroundTextureDeformationFrequency += myRandom() * a_timeInterval * 0.3;
	m_aroundTextureDeformationFrequency = clip(m_aroundTextureDeformationFrequency, 0.2, 5.);
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	m_aroundTextureDeformation += m_aroundTextureDeformationFrequency * a_timeInterval;
	m_skyDecay.x += -a_timeInterval * 0.01;
	m_skyDecay.y += a_timeInterval * 0.003;
	
	if(m_specialEaten)
	{
		if(m_sizeMoon < 3.f)
		{
			m_sizeMoon *= 1.f + 0.08f * a_timeInterval;
		}
	}
	if(m_isIntro)
	{
		m_sizeAroundIntro -= 4.f * a_timeInterval;
		if(m_sizeAroundIntro <= 1.f)
		{
			[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"wind"];
			[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"string2"];
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"shock" Volume:1.f];
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"ambientSwamp" Volume:0.9f];
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"craquement mystérieux" Volume:0.2f];
			
			m_sizeAroundIntro = 1.f;
			if(m_isIntro)
			{
				[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:NO];	
			}
			m_isIntro = false;
			[l_particleManager ActiveDeadParticlesFromGroup:PARTICLE_GROUP_LUCIOLE_SPECIAL];
			[self performSelector:@selector(ActiveOtherParticles) withObject:nil afterDelay:8.];
			[l_sharedEAGLView SetCamera:CAMERA_CLOSE];
			[l_sharedEAGLView SetTranslate:CGPointMake(0., 0.5) forType:CAMERA_CLOSE force:NO];
			[l_sharedEAGLView SetScale:0.6 force:NO];
			m_lastLuminosity = 0.f;
			[l_sharedEAGLView SetLuminosity:m_lastLuminosity];
			m_lastBlur = .1f;
			[l_sharedEAGLView SetBlur:m_lastBlur];
		}
		else 
		{
			m_lastBlur += myRandom() * a_timeInterval;
			m_lastBlur = clip(m_lastBlur, 0.2, 1.f);
			[l_sharedEAGLView SetBlur:m_lastBlur];
			
			m_lastLuminosity += myRandom() * a_timeInterval;
			m_lastLuminosity = clip(m_lastLuminosity, 0.8, 1.f);
			[l_sharedEAGLView SetLuminosity:m_lastLuminosity];
		}
	}
	else
	{
		m_lastBlur -= a_timeInterval * .18f;
		m_lastBlur = max(m_lastBlur, -1.);
		[l_sharedEAGLView SetBlur:m_lastBlur];
		
		m_lastLuminosity += a_timeInterval * .15f;
		m_lastLuminosity = min(m_lastLuminosity, .99f);
		[l_sharedEAGLView SetLuminosity:m_lastLuminosity];
	}
	
	[l_particleManager UpdateParticlesWithTimeInterval:a_timeInterval];
	[l_particleManager drawself];
	
	int l_repeatNumber = m_levelData.m_duplicate;
	float l_widthOnHeigth = m_levelData.m_widthOnHeigth;
	float l_size	 = m_levelData.m_size;
	
	float l_heraticX = 0.f;
	float l_heraticY = 0.f;
	if(m_isIntro)
	{
		l_heraticX = myRandom() * 0.03 - m_lastHeratic.x;
		l_heraticY = myRandom() * 0.03 - m_lastHeratic.y;
		[ParticleCloud SetDecay:CGPointMake(l_heraticX, l_heraticY)];
	}
	else
	{
		// draw background.
		[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
									  plan:PLAN_SKY_SHADOW
									  size:l_size * 2.f
								 positionX:0.f
								 positionY:0.f
								 positionZ:0.
							  repeatNumber:1
							 widthOnHeight:1.
								  distance:-1.f
									decayX:m_skyDecay.x
									decayY:m_skyDecay.y
		 
		 ];	
	}

	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND
								  size:l_size
							 positionX:l_heraticX
							 positionY:l_heraticY
							 positionZ:0.
						  repeatNumber:l_repeatNumber
						 widthOnHeight:l_widthOnHeigth
							  distance:-1.f
	 ];
	
	// draw background.
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_MOON
										   plan:PLAN_BACKGROUND_STICKERS
										   size:1.3 * m_sizeMoon
									  positionX:l_heraticX + 0.2
									  positionY:l_heraticY + 0.1
									  positionZ:0.
								   repeatNumber:1
								  widthOnHeight:1.f
									   distance:-1.f
	 ];
	
	// if there is an around element, draw it.
    // draw the head.
    [l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND_AROUND
                                  plan:PLAN_BACKGROUND_CLOSE
                                  size:	l_size * m_sizeAroundIntro * 1.1
                             positionX:0.f
                             positionY:0.f
                             positionZ:0.
                         rotationAngle:0.
                       rotationCenterX:0.
                       rotationCenterY:0.
                          repeatNumber:1
                         widthOnHeight:l_widthOnHeigth
                            nightBlend:false
                           deformation:l_currentAroundDeformation
                              distance:-1.f
     ];
}

// init pendulum.
-(void)InitSnake
{
	// init the snake.
	m_pendulumBasePositionScaleCurrent = CGPointMake(30.f, 0.f);
	CGPoint l_basePosition = CGPointMake(22., 0.);
	CGPoint l_pendulumPosition = CGPointMake(l_basePosition.x + 0.2, l_basePosition.y + 0.1);
	CGPoint l_positionStick = CGPointMake(l_pendulumPosition.x, l_pendulumPosition.y + STICK_LENGTH);
	m_changeSnakeGravityTimer = 0.;
	float l_length = m_levelData.m_snakeLengthBetweenHeadAndBody;
	PhysicPendulum * l_thisStick;
	
	l_thisStick = [[PhysicPendulum alloc] initWithPosition:l_positionStick 
												  basePosition:l_pendulumPosition
														  mass:10.f 
											   angleSpeedLimit:-1.f
													   gravity:0.55
												  gravityAngle:0.f
													  friction:1.29
												  addInTheList:YES
					   ];
	
	m_pendulumHead = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition basePosition:l_basePosition mass:150.f angleSpeedLimit:-1.f  gravity:0.05 gravityAngle:0.f friction:0.15 addInTheList:YES];
	PhysicPendulum * l_currentPendulum = m_pendulumHead; 
	PhysicPendulum * l_childPendulum = nil;
	
	int l_count = 0;
	// Creation of the elmeents of the snake.
	for(int i = 0; i < m_levelData.m_snakePartQuantity; i++)
	{
		l_childPendulum = [[PhysicPendulum alloc] initWithPosition:l_pendulumPosition basePosition:l_basePosition mass:2.f angleSpeedLimit:5.f  gravity:0.05 gravityAngle:0.f friction:0.15 addInTheList:YES];
		[l_currentPendulum AddChild:l_childPendulum];
		l_currentPendulum = l_childPendulum;
		l_basePosition = l_pendulumPosition;
		l_pendulumPosition.y += l_length;
		l_positionStick.y += l_length;
		l_length = m_levelData.m_snakeLengthBetweenParts;
	
		if(l_count >= PART_PER_STICK)
		{
			l_thisStick = [[PhysicPendulum alloc] initWithPosition:l_positionStick 
													  basePosition:l_pendulumPosition
															  mass:10.f 
												   angleSpeedLimit:-1.f
														   gravity:0.55
													  gravityAngle:0.f
														  friction:1.29
													  addInTheList:NO
						   ];
			
			l_count = 0;
		}
		l_count++;
	}
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateSnake:(NSTimeInterval)a_timeInterval
{
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	CGPoint l_pendulePosition;
	CGFloat l_penduleAngle;
	
	ScreenTransformation l_screenTransformation = [l_sharedEAGLView GetCameraTransformation];
	CGPoint l_fingerPositionScaled = ConvertPositionWithCameraTransformationFromScreenToGame(m_basePosition, l_screenTransformation);
	
	// smooth the base speed.
	float l_speedMax = 1.8f;
	NSTimeInterval l_animationInterval = a_timeInterval;

	float l_xSpeed = -min(Absf((m_pendulumBasePositionScaleCurrent.x - l_fingerPositionScaled.x) / l_animationInterval), l_speedMax);
	float l_xSign = ((m_pendulumBasePositionScaleCurrent.x - l_fingerPositionScaled.x) < 0.f) ? -1.f : 1.f;
	float l_ySpeed = -min(Absf((m_pendulumBasePositionScaleCurrent.y - l_fingerPositionScaled.y) / l_animationInterval), l_speedMax);
	float l_ySign = ((m_pendulumBasePositionScaleCurrent.y - l_fingerPositionScaled.y) < 0.f) ? -1.f : 1.f;
	
	m_pendulumBasePositionScaleCurrent.x = m_pendulumBasePositionScaleCurrent.x + l_xSpeed * l_animationInterval * l_xSign;
	m_pendulumBasePositionScaleCurrent.y = m_pendulumBasePositionScaleCurrent.y + l_ySpeed * l_animationInterval * l_ySign;
	
	[m_pendulumHead UpdateWithBasePosition:m_pendulumBasePositionScaleCurrent timeFrame:l_animationInterval];
	NSMutableArray * l_pendulumArray = [PhysicPendulum GetList];
	int l_arraySize = [l_pendulumArray count];
	
	l_pendulePosition = [[l_pendulumArray objectAtIndex:1] GetPosition];
	l_penduleAngle = [[l_pendulumArray objectAtIndex:1] m_angle];
	
	// draw the head.
	int l_headTexture = m_canEat ? TEXTURE_SNAKE_HEAD_OPEN_MOUTH : TEXTURE_SNAKE_HEAD_CLOSE_MOUTH;
	[l_sharedEAGLView drawTextureIndex:l_headTexture
								  plan:PLAN_PENDULUM
								  size:	m_levelData.m_snakeSizeHead// * (1.f + (0.2 * (float)m_specialEaten))
							 positionX:l_pendulePosition.x
							 positionY:l_pendulePosition.y
							 positionZ:0.
						 rotationAngle:RADIAN_TO_DEDREE(l_penduleAngle)
					   rotationCenterX:l_pendulePosition.x
					   rotationCenterY:l_pendulePosition.y
						  repeatNumber:1
						 widthOnHeight:1.f
							nightBlend:false
						   deformation:0.f
							  distance:-17 + m_sizeMoon * 15.
	 ];

	[[ApplicationManager sharedApplicationManager] SetHelpPositionPixel:GLToPixel(l_pendulePosition)];
	
	if(m_closeState && Absf(l_pendulePosition.y) > 5.)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateLarve alloc] init]];
		[[ApplicationManager sharedApplicationManager] SaveLevel:2];
		return NO;
	}
	
	// we decrease the size of the snake parts to give it a good shape.
	float l_pendulumBodySizeCoeff = 1.f;
	for(int i = 2; i < l_arraySize; i++)
	{
		l_pendulePosition = [[l_pendulumArray objectAtIndex:i] GetPosition];
		l_penduleAngle = [[l_pendulumArray objectAtIndex:i] m_angle];
		[l_sharedEAGLView drawTextureIndex:TEXTURE_SNAKE_BODY
									  plan:PLAN_PENDULUM
									  size:	m_levelData.m_snakeSizeBody * l_pendulumBodySizeCoeff
								 positionX:l_pendulePosition.x
								 positionY:l_pendulePosition.y
								 positionZ:0.
							 rotationAngle:RADIAN_TO_DEDREE(l_penduleAngle)
						   rotationCenterX:l_pendulePosition.x
						   rotationCenterY:l_pendulePosition.y
							  repeatNumber:1
							 widthOnHeight:1.f
								nightBlend:false
							   deformation:0.f
								  distance:-15 + m_sizeMoon * 15.
		 ];
			
		l_pendulumBodySizeCoeff *= 0.95;
	}	
	return YES;
}

-(void)ActiveOtherParticles
{
	[[ParticleManager sharedParticleManager] ActiveDeadParticles];
}

-(void)Touch:(CGPoint)a_touchLocation
{
	ScreenTransformation l_screenTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	m_basePositionPrevious = ConvertPositionWithCameraTransformationFromGameToScreen(a_touchLocation, l_screenTransformation);
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	ScreenTransformation l_screenTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	CGPoint l_newPosition = ConvertPositionWithCameraTransformationFromGameToScreen(a_touchLocation, l_screenTransformation);
	m_basePosition = CGPointMake(m_basePosition.x + l_newPosition.x - m_basePositionPrevious.x, m_basePosition.y + l_newPosition.y - m_basePositionPrevious.y);
	m_basePosition.x = clip(m_basePosition.x, -m_levelData.m_size / 1.6f, m_levelData.m_size/ 1.6f);
	m_basePosition.y = clip(m_basePosition.y, -m_levelData.m_size / 1.6f, m_levelData.m_size / 1.6f);
	m_basePositionPrevious = l_newPosition;

	return;
}

-(void)Shake
{
	if(!m_specialEaten)
	{
		[[ParticleManager sharedParticleManager] ActiveDeadParticles];
		[[ParticleManager sharedParticleManager] ActiveDeadParticles];
	}
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
	if(!m_specialEaten)
	{
		m_specialEaten = YES;
		[[ParticleManager sharedParticleManager] ActiveDeadParticles:40];
		[[OpenALManager sharedOpenALManager] playSoundWithKey:@"music2" Volume:0.f];
		[[OpenALManager sharedOpenALManager] FadeWithKey:@"music2" duration:2.f volume:0.55f stopEnd:NO];
	}
	return;
}

-(void)Event3:(int)a_value
{
	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:YES];
	m_closeState = YES;
	m_basePosition = CGPointMake(500, 300);
	return;
}

-(NSArray *)GetSoundArray
{
    return [NSArray arrayWithObjects:@"music2", @"wind", @"shock", @"ambientSwamp", @"craquement mystérieux", @"string2", @"eclosion", @"crok", nil];
}

-(void)Terminate
{
	[super Terminate];
	
	// destroy all the particles.
	[[ParticleManager sharedParticleManager] KillParticles];

	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

@end
