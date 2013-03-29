//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "ParticleBug2.h"
#import "StateTheatreTreesFast.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleManager.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "Puppet.h"

#define GROUND_Y_TREEF -0.6f
#define LULU_POSITION -0.3f
#define LULU_SIZE 0.6f
#define SPEED_LULU_TURN .3f
#define SPEED_LULU_WALK .06f
#define TIMER_BEFORE_HEAD_FALL 8.f
#define TIME_MIN_BEFORE_QUIT 3.f
#define LULU_PLAN PLAN_SKY_SHADOW

@implementation LettersDatas

@synthesize m_letter;
@synthesize m_indexFinger;
@synthesize m_decay;
@synthesize m_touched;

-(id)init
{
    m_touched = NO;
    m_letter = [[ParticleLetterEvolved alloc] initWithTexture:TEXTURE_T_TREESFAST_LETTER_Z textureStick:TEXTURE_T_TREESFAST_STICK groupIndex:0];
    [m_letter SetStrenghtAttractor:10.f];
    m_indexFinger = -1;
    m_decay = CGPointMake(0.f, 0.f);
    return [super init];
}

-(void)SetIndex:(int)a_index decay:(CGPoint)a_decay
{
    m_touched = YES;
    m_indexFinger = a_index;
    if(m_indexFinger > -1)
    {
        m_decay = a_decay;
    }
    
    printf("decayX = %f, Y = %f", m_decay.x, m_decay.y);
}

@end

@implementation StateTheatreTreesFast

-(void)StateInit
{
	m_index = STATE_DREAM_IMMORTAL;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_T_TREESFAST_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"ForestBack.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"ForestBackSleep"];
    m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
    m_levelData.m_textureArray[TEXTURE_T_TREESFAST_BACKPSYCH1] = [[NSString alloc] initWithString:@"ForestBackBackSleep.png"];
    m_levelData.m_textureArray[TEXTURE_T_TREESFAST_BACKPSYCH2] = [[NSString alloc] initWithString:@"ForestBackBackSleep2.png"];
	m_levelData.m_textureArray[TEXTURE_T_TREESFAST_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_T_TREESFAST_WINGS_0] = [[NSString alloc] initWithString:@"wings0.png"];
	m_levelData.m_textureArray[TEXTURE_T_TREESFAST_WINGS_1] = [[NSString alloc] initWithString:@"wings1.png"];  
    m_levelData.m_textureArray[TEXTURE_T_TREESFAST_LETTER_Z] = [[NSString alloc] initWithString:@"z.png"];
    m_levelData.m_textureArray[TEXTURE_T_TREESFAST_LULU_SLEEP] = [[NSString alloc] initWithString:@"LuluSleepNaked.png"];
    m_levelData.m_textureArray[TEXTURE_T_TREESFAST_LULU_SLEEPING_BAG] = [[NSString alloc] initWithString:@"furryThingBlack.png"];
	
    // Set openGL.
	EAGLView *l_sharedEAGLView = [EAGLView sharedEAGLView];
	[l_sharedEAGLView SetCameraUpdatable:YES];
	[l_sharedEAGLView initLevel:m_levelData];
	[l_sharedEAGLView SetCamera:CAMERA_CLOSE];
	[l_sharedEAGLView SetBlur:0.];
	[l_sharedEAGLView SetScale:1.3 force:YES];
	[l_sharedEAGLView SetTranslate:CGPointMake(0.f, -0.1f) forType:CAMERA_CLOSE force:NO];
	[l_sharedEAGLView SetCameraUpdatable:NO];
    
	m_skyDecay = mTreesPosition = CGPointZero;
	m_time = 0.f;
	
	m_fingerPosition[0] = CGPointMake(0.7f, 0.8f);
	m_fingerPosition[1] = CGPointMake(-0.8f, 0.8f);
	
    [ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_T_TREESFAST_WINGS_0 lastFrame:TEXTURE_T_TREESFAST_WINGS_1 duration:0.07]
						 angle:-75.
                  texturePause:TEXTURE_T_TREESFAST_WINGS_0
					  sizeWing:1.7f
                         block:NO
	 ];
    
    float decayLetterX = 0.15f;
	[ParticleLetter SetSize:0.07 group:0];
    [ParticleLetter SetPosition:CGPointMake(LULU_POSITION + decayLetterX + LULU_SIZE * 0.25, GROUND_Y_TREEF + 0.7)];
    
    m_letters = [[NSMutableArray alloc] init];
    LettersDatas * l_letter;
    ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
    l_letter = [[LettersDatas alloc] init];
    [m_letters addObject:l_letter];
	[l_particleManager AddParticle:l_letter.m_letter];

    [ParticleLetter SetPosition:CGPointMake(LULU_POSITION + decayLetterX + LULU_SIZE * 0.25, GROUND_Y_TREEF + 0.55)];
    l_letter = [[LettersDatas alloc] init];
    [m_letters addObject:l_letter];
	[l_particleManager AddParticle:l_letter.m_letter];

    [ParticleLetter SetPosition:CGPointMake(LULU_POSITION + decayLetterX - LULU_SIZE * 0.25, GROUND_Y_TREEF + 0.42)];
    l_letter = [[LettersDatas alloc] init];
    [m_letters addObject:l_letter];
	[l_particleManager AddParticle:l_letter.m_letter];

	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"treeFriction" Volume:0.f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"wind" Volume:0.f];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"wind" duration:2.f volume:0.7f stopEnd:NO];
	[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"wind" Pitch:1.1f];
    
    float l_position = LULU_POSITION;
    int l_texture = 0;
    float lSize;

    [ParticleBugSleep SetGroundY:GROUND_Y_TREEF - 0.4f];
	for(int i = 0; i < 65; i++)
	{
        lSize  = .07f * (1.f + myRandom() * 0.5);
		l_texture = TEXTURE_T_TREESFAST_LULU_SLEEPING_BAG;
		[l_particleManager AddParticle:[[ParticleBugSleep alloc] initWithTexture:l_texture size:lSize plan:LULU_PLAN position:CGPointMake(l_position, GROUND_Y_TREEF - 0.05 + myRandom() * 0.1f)]];
		
		l_position = LULU_POSITION + myRandom() * 0.27f + LULU_SIZE * 0.35;
	}
    
    [[ParticleManager sharedParticleManager] ActiveDeadParticles];
    
    mGoLetters = NO;
    
	return [super StateInit];
}

//
//  Update.
//
-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{
	m_time += a_timeInterval;
	
	m_skyDecay.x += -0.5 * a_timeInterval * 1.2;
	
    [[ParticleManager sharedParticleManager] UpdateParticlesWithTimeInterval:a_timeInterval];
	[[ParticleManager sharedParticleManager] drawself];
	
    [self Draw];
    
    mPositionInScene.x += mSpeedInScene.x * a_timeInterval;
    mPositionInScene.y += mSpeedInScene.y * a_timeInterval;
    
    [self UpdateLetters:a_timeInterval];
	[super UpdateWithTimeInterval:a_timeInterval];
}

-(void)Draw
{
    EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
    float l_size	 = m_levelData.m_size;
    float l_treeEvolution = cos(m_time * 0.2);
	float l_treeDistance = 2.3f + l_treeEvolution * 0.3f;
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"treeFriction" Volume:0.4 * (1.f - 0.8 * ((l_treeEvolution + 1.f) / 2.f))];
    
    // draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_MOON
                                  plan:PLAN_BACKGROUND
                                  size:1.7
                             positionX:-0.2
                             positionY:.2
                             positionZ:0.
                          repeatNumber:1
                         widthOnHeight:1.
                              distance:0.
	 ];
    
    [l_sharedEAGLView drawTextureIndex:TEXTURE_T_TREESFAST_LETTER_Z
                                  plan:PLAN_BACKGROUND_STICKERS
                                  size:10.7
                             positionX:6.
                             positionY:.2
							 positionZ:0.f
						 rotationAngle:0.f
					   rotationCenterX:0.f
					   rotationCenterY:0.f
						  repeatNumber:1
						 widthOnHeight:3.
							nightBlend:NO
						   deformation:0.01 * sin(m_time * 0.7)
							  distance:-1.f
								decayX:0
								decayY:0
								 alpha:0.8
								planFX:-1
							   reverse:REVERSE_NONE
	 ];
    
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_TREESFAST_LULU_SLEEP
								  plan:LULU_PLAN
								  size:LULU_SIZE
							 positionX:LULU_POSITION
							 positionY:GROUND_Y_TREEF + 0.07
							 positionZ:0.
						 rotationAngle:0.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.f
							nightBlend:FALSE
						   deformation:0.f
							  distance:-1.f
								decayX:0.
								decayY:0.f
								 alpha:1.f
								planFX:LULU_PLAN
							   reverse:REVERSE_NONE
	 ];
    
    // draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:LULU_PLAN
								  size:l_size * 1.f
							 positionX:-LULU_POSITION * 2 - 0.2
							 positionY:0.2
							 positionZ:0.f
						 rotationAngle:0.f
					   rotationCenterX:0.f
					   rotationCenterY:0.f
						  repeatNumber:1
						 widthOnHeight:2.
							nightBlend:NO
						   deformation:0.01 * cos(m_time * 0.5)
							  distance:-1.f
								decayX:0
								decayY:0
								 alpha:1.f
								planFX:-1
							   reverse:REVERSE_NONE
	 ];
    
    // draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_TREESFAST_BACKPSYCH1
								  plan:PLAN_BACKGROUND_STICKERS
								  size:l_size * 2.f
							 positionX:-1.6
							 positionY:GROUND_Y_TREEF - LULU_SIZE * 0.4
							 positionZ:0.f
						 rotationAngle:0.f
					   rotationCenterX:0.f
					   rotationCenterY:0.f
						  repeatNumber:2
						 widthOnHeight:2.
							nightBlend:NO
						   deformation:0.1 * cos(m_time * 0.3)
							  distance:-1.f
								decayX:0
								decayY:0
								 alpha:1.f
								planFX:-1
							   reverse:REVERSE_NONE
	 ];
    
    // draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_TREESFAST_BACKPSYCH2
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 2.f
							 positionX:-1.6
							 positionY:GROUND_Y_TREEF - LULU_SIZE * 0.4
							 positionZ:0.f
						 rotationAngle:0.f
					   rotationCenterX:0.f
					   rotationCenterY:0.f
						  repeatNumber:2
						 widthOnHeight:2.
							nightBlend:NO
						   deformation:0.1 * cos(m_time * 0.2)
							  distance:-1.f
								decayX:0
								decayY:0
								 alpha:1.f
								planFX:-1
							   reverse:REVERSE_NONE
	 ];
    
    [l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 2.f
							 positionX:-1.6
							 positionY:GROUND_Y_TREEF - LULU_SIZE * 0.4
							 positionZ:0.f
						 rotationAngle:0.f
					   rotationCenterX:0.f
					   rotationCenterY:0.f
						  repeatNumber:2
						 widthOnHeight:2.
							nightBlend:NO
						   deformation:0.
							  distance:-1.f
								decayX:0
								decayY:0
								 alpha:1.f
								planFX:-1
							   reverse:REVERSE_HORIZONTAL
	 ];
    
    CGPoint l_letterPos;
    for(int i = 0; i < [m_letters count]; i++)
    {
        l_letterPos.x += [[m_letters objectAtIndex:i] m_letter ].m_position.x;
        l_letterPos.y += [[m_letters objectAtIndex:i] m_letter].m_position.y;
    }
    m_screenPos.x = l_letterPos.x / (float)[m_letters count];
    m_screenPos.y = l_letterPos.y / (float)[m_letters count];
    
    mTreesPosition.x = m_screenPos.x;
    mTreesPosition.y = (1.f * m_screenPos.y + 30.f * mTreesPosition.y) / 31.f;
    
    float decaySpeedTree = l_size * 1.9f * 2.f * max(1.f - 0.02f * m_screenPos.x, 0.f);
    [l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND_SHADOW
								  size:l_size * 1.9f
							 positionX:mTreesPosition.x
							 positionY:mTreesPosition.y + l_treeDistance + decaySpeedTree
							 positionZ:0.
						 rotationAngle:180.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							nightBlend:FALSE
						   deformation:0.f
							  distance:-1.f
								decayX:m_skyDecay.x
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND_SHADOW
								  size:l_size * 1.9f
							 positionX:mTreesPosition.x
							 positionY:mTreesPosition.y -l_treeDistance - decaySpeedTree
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							  distance:31.f
								decayX:-m_skyDecay.x
								decayY:0.f
	 ];
    

    [l_sharedEAGLView SetCameraUpdatable:YES];
    
    [l_sharedEAGLView SetTranslate:CGPointMake(-m_screenPos.x, -m_screenPos.y) forType:CAMERA_CLOSE force:YES];
	[l_sharedEAGLView SetScale:1.2f + 0.2f * cos(m_time * 0.4f) force:YES];
	[l_sharedEAGLView SetCameraUpdatable:NO];
}

-(void)UpdateLetters:(NSTimeInterval)a_timeInterval
{
    if(mGoLetters)
    {
        mSpeedInScene.x += (8.f - mSpeedInScene.x) * a_timeInterval * 0.1f;
        mSpeedInScene.y += (0.f - mSpeedInScene.y) * a_timeInterval * 0.1f;
        for(int i = 0; i < [m_letters count]; i++)
        {
            if(![[m_letters objectAtIndex:i] m_touched ])
            {
                [[[m_letters objectAtIndex:i] m_letter ] SetAttractorPosition:CGPointMake(mPositionInScene.x + 0.6 * cos(m_time * 0.4 + i), mPositionInScene.y + 0.4 * sin(m_time * 0.4 + i))];
            }
            else
            {
                CGPoint l_decay = [[m_letters objectAtIndex:i] m_decay];
                [[[m_letters objectAtIndex:i] m_letter ] SetAttractorPosition:CGPointMake(mPositionInScene.x - l_decay.x, mPositionInScene.y - l_decay.y)];
            }
        }
    }
}


-(void)SimpleClick:(CGPoint)a_touchLocation
{
    mGoLetters = YES;
	return;
}


// Multi touch event.
-(void)Touch:(CGPoint)a_touchLocation
{
    int l_indexTouch = 0;
	if(DistancePoint(a_touchLocation, m_fingerPosition[0]) > DistancePoint(a_touchLocation, m_fingerPosition[1]))
	{
        l_indexTouch = 1;
	}
	else
	{
        l_indexTouch = 0;
	}

    m_fingerPosition[l_indexTouch] = a_touchLocation;
    
    for(int i = 0; i < [m_letters count]; i++)
    {
        if([[[m_letters objectAtIndex:i] m_letter] Touch:a_touchLocation])
        {
            [[m_letters objectAtIndex:i] SetIndex:l_indexTouch decay:[self GetDecayForLetters:a_touchLocation]];
        }
    }
    
	return;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
    int l_indexTouch = 0;
	if(DistancePoint(a_touchLocation, m_fingerPosition[0]) > DistancePoint(a_touchLocation, m_fingerPosition[1]))
	{
        l_indexTouch = 1;
	}
	else
	{
        l_indexTouch = 0;
	}
    
    m_fingerPosition[l_indexTouch] = a_touchLocation;
    
    for(int i = 0; i < [m_letters count]; i++)
    {
        if([[m_letters objectAtIndex:i] m_indexFinger] == l_indexTouch)
        {
            [[m_letters objectAtIndex:i] SetIndex:l_indexTouch decay:[self GetDecayForLetters:a_touchLocation]];
        }
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
	int index0, index1;
	if((l_distanceTouch0ToFinger0 / l_distanceTouch0ToFinger1) < (l_distanceTouch1ToFinger0 / l_distanceTouch1ToFinger1))
	{
		// the touch 1 is on the finger 0
		m_multiTouchMondayToTuesday = NO;
        index0 = 0;
        index1 = 1;

	}
	else
	{
		m_multiTouchMondayToTuesday = YES;
        index0 = 1;
        index1 = 0;
	}
    
    m_fingerPosition[index0] = a_touchLocation0;
    m_fingerPosition[index1] = a_touchLocation1;
    
    for(int i = 0; i < [m_letters count]; i++)
    {
        if([[[m_letters objectAtIndex:i] m_letter] Touch:a_touchLocation0])
        {
            [[m_letters objectAtIndex:i] SetIndex:index0 decay:[self GetDecayForLetters:m_fingerPosition[index0]]];
        }
        
        if([[[m_letters objectAtIndex:i] m_letter] Touch:a_touchLocation1])
        {
            [[m_letters objectAtIndex:i] SetIndex:index1 decay:[self GetDecayForLetters:m_fingerPosition[index1]]];
        }
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

-(void)TouchEnded:(CGPoint)a_touchLocation
{
    int l_indexTouch = 0;
	if(DistancePoint(a_touchLocation, m_fingerPosition[0]) > DistancePoint(a_touchLocation, m_fingerPosition[1]))
	{
        l_indexTouch = 1;
	}
	else
	{
        l_indexTouch = 0;
	}
    
    m_fingerPosition[l_indexTouch] = a_touchLocation;
    
    for(int i = 0; i < [m_letters count]; i++)
    {
        if([[m_letters objectAtIndex:i] m_indexFinger] == l_indexTouch)
        {
            [[m_letters objectAtIndex:i] SetIndex:-1 decay:CGPointZero];
        }
    }

}

-(CGPoint)GetDecayForLetters:(CGPoint)a_position
{
    return CGPointMake(m_screenPos.x - a_position.x, m_screenPos.y - a_position.y);
}

-(void)Terminate
{
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"musicAphex" duration:1.f volume:0.f stopEnd:YES];
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

-(id)GetNoteBook
{
	return nil;
}


@end
