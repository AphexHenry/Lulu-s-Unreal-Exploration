//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatreNextGenerationOut.h"
#import "StateSea.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleBeast.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "Puppet.h"
#import "ParticleLetter.h"

#define STICK_LENGTH 1.
#define GROUND_Y -0.6f
#define TIME_BEFORE_OPEN_CURTAINS 2.f
#define SPEED_LULU_TURN .3f
#define SPEED_LULU_WALK .06f
#define TIMER_BEFORE_HEAD_FALL 8.f
#define TIME_MIN_BEFORE_QUIT 5.f
#define POSITION_SCROLLING_INIT .75f

@implementation StateTheatreNextGenerationOut

-(void)StateInit
{
	m_index = STATE_LARVE;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 22;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_T_NGOUT_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"luluTitleBack.png"];
	m_levelData.m_textureArray[TEXTURE_T_NGOUT_SHADOW_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_T_NGOUT_PUPPET_LULU] = [[NSString alloc] initWithString:@"luluIntro.png"];
	m_levelData.m_textureArray[TEXTURE_T_NGOUT_LULU_SWORD] = [[NSString alloc] initWithString:@"puppetNewGenerationSword.png"];
	m_levelData.m_textureArray[TEXTURE_T_NGOUT_PUPPET_PIG] = [[NSString alloc] initWithString:@"pig.png"];	
    m_levelData.m_textureArray[TEXTURE_T_NGOUT_PUPPET_PIG_CRAZY] = [[NSString alloc] initWithString:@"pigCrazy.png"];	
	m_levelData.m_textureArray[TEXTURE_T_NGOUT_PANEL_SURPRISE_SQUARE] = [[NSString alloc] initWithString:@"panelSurpriseSquare.png"];
    m_levelData.m_textureArray[TEXTURE_T_NGOUT_PANEL_SURPRISE_SQUARE_REVERSE] = [[NSString alloc] initWithString:@"panelSurpriseSquareReverse.png"];
    m_levelData.m_textureArray[TEXTURE_T_NGOUT_PANEL_LULU] = [[NSString alloc] initWithString:@"panelLulu.png"];
    m_levelData.m_textureArray[TEXTURE_T_NGOUT_PANEL_INFINITE] = [[NSString alloc] initWithString:@"panelInfinite.png"];
    m_levelData.m_textureArray[TEXTURE_T_NGOUT_PANEL_MESSEDUP] = [[NSString alloc] initWithString:@"panelMessedUp.png"];
    m_levelData.m_textureArray[TEXTURE_T_NGOUT_PANEL_PIG] = [[NSString alloc] initWithString:@"panelPig.png"];
    m_levelData.m_textureArray[TEXTURE_T_NGOUT_PANEL_QUESTION] = [[NSString alloc] initWithString:@"panelQuestion.png"];
    m_levelData.m_textureArray[TEXTURE_T_NGOUT_PANEL_HORSE] = [[NSString alloc] initWithString:@"panelHorse.png"];
	
	m_skyDecay = CGPointMake(POSITION_SCROLLING_INIT, 0.);
	m_time = 0.f;
	m_sequenceStart = NO;
	m_headDeformation = 1.f;
		
	m_fingerPosition[0] = CGPointMake(0.7f, 0.8f) ;
	m_fingerPosition[1] = CGPointMake(-0.8f, 0.8f);
	m_mappingFingerZeroToPuppet = 0;
    m_swordPosition = CGPointMake(0.f, 0.f);
    m_pigDeformation = 0.f;
    m_nextNoiseTimer = 0.;
	
	[ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_THEATRE_WING_0 lastFrame:TEXTURE_THEATRE_WING_1 duration:0.07]
						 angle:(M_PI / 2.5) * 180 / M_PI
				  texturePause:TEXTURE_THEATRE_WING_0
					  sizeWing:1.7f
	 ];
	
	m_puppet[0] = [[Puppet alloc] InitWithTexturePuppet:TEXTURE_T_NGOUT_PUPPET_LULU 
												  Stick:TEXTURE_THEATRE_STICK 
										   InitPosition:m_fingerPosition[0]
										  PanelSequence:nil
				   ];
    
    NSArray * l_sequenceSnake = [[NSArray alloc] initWithObjects:
                                 [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_SCARED begin:0. end:2.] autorelease],
                                 [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_YOKAI begin:2. end:4.] autorelease],
                                 [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_SCARED begin:4. end:6.] autorelease],
                                 [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_YOKAI begin:6. end:8.] autorelease],
                                 [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_SCARED begin:8. end:10.] autorelease],
                                 [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_YOKAI begin:10. end:12.] autorelease],
                                 nil
                                 ];
	
    m_puppet[1] = [[Puppet alloc] InitWithTexturePuppet:TEXTURE_T_NGOUT_PUPPET_PIG_CRAZY 
                                               Stick:TEXTURE_THEATRE_STICK 
                                        InitPosition:m_fingerPosition[1]
                                       PanelSequence:l_sequenceSnake
                                          StickAngle:0.f
                                          PuppetSize:0.35
                                              Marker:-1
                                        FlyingMarker:NO
                                            IsStatic:YES
				];
    
    [m_puppet[1] BlockRotation:YES];
    
    [[OpenALManager sharedOpenALManager] playSoundWithKey:@"pig" Volume:0.f];
    
	return [super StateInit];
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	if(m_sequenceStart)
	{
		m_time += a_timeInterval;
        [[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"pig" Volume:0.5f * Absf(sinf(m_time * 1.5f) - 0.1f)];
        
        if(m_time > m_timeBeforeEndSequence)
        {
            [m_puppet[1] SetTexture:-1];
            m_pigDeformation += a_timeInterval;
            m_pigDeformation = clip(m_pigDeformation, 0.f, 1.f);
            m_go = YES;
        }
	}
    
	// this is just to have a clearer code.
	if(![self UpdatePuppet:a_timeInterval])
	{
		return;
	}
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_size	 = m_levelData.m_size;
	
	// draw the head.
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
	
	m_skyDecay.x += -a_timeInterval * SPEED_LULU_WALK;
    m_skyDecay.x = max(0.f, m_skyDecay.x) - 2.f * SPEED_LULU_WALK * max(m_time - m_timeBeforeEndSequence, 0.f);
    if(	m_skyDecay.x < EPSILON && !m_sequenceStart)
    {
        [self LaunchSequence];   
    }
	
	// draw background.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_SHADOW
								  plan:PLAN_SKY_SHADOW
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:-m_skyDecay.x / 1.5
								decayY:0.f
	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_T_NGOUT_SHADOW_FRONT
								  plan:PLAN_SKY_SHADOW
								  size:l_size
							 positionX:0.f
							 positionY:0.1f
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.
							  distance:-1.f
								decayX:-m_skyDecay.x
								decayY:0.f
	 
	 ];
	
	[super UpdateWithTimeInterval:a_timeInterval];
}

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval
{
	float l_puppetDeformation = 1.f;
	
	[m_puppet[0] UpdateWithPosition:CGPointMake(m_fingerPosition[m_mappingFingerZeroToPuppet].x, m_fingerPosition[m_mappingFingerZeroToPuppet].y + m_pigDeformation * 0.3 + 0.05f * sin(max(m_time - m_timeBeforeEndSequence, 0.f) * 4.f)) timeInterval:a_timeInterval];
	[m_puppet[1] UpdateWithPosition:CGPointMake(m_levelData.m_size * 4.f * (m_skyDecay.x ) - .95f, .5f) timeInterval:a_timeInterval];

    m_swordPosition = [m_puppet[0] GetPosition];
    l_puppetDeformation = [m_puppet[0] GetDeformation];
    
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_T_NGOUT_LULU_SWORD
										   plan:PLAN_PENDULUM
										   size:0.05
									  positionX:m_swordPosition.x
									  positionY:m_swordPosition.y - 0.15
									  positionZ:0.
								  rotationAngle:30.f * ((l_puppetDeformation < 0.f) ? -1.f : 1.f)
								rotationCenterX:0.f
								rotationCenterY:0.f
								   repeatNumber:1
								  widthOnHeight:l_puppetDeformation * 2.f * -1.f
									 nightBlend:true
									deformation:0.f
									   distance:50.f
	 ];
    
    [[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_T_NGOUT_PUPPET_PIG
										   plan:PLAN_PENDULUM
										   size:0.3
									  positionX:m_swordPosition.x + 0.1 * l_puppetDeformation
									  positionY:m_swordPosition.y - 0.27
									  positionZ:0.
								  rotationAngle:0.f
								rotationCenterX:0.f
								rotationCenterY:0.f
								   repeatNumber:1
								  widthOnHeight:m_pigDeformation * l_puppetDeformation
									 nightBlend:true
									deformation:0.f
									   distance:50.f
	 ];
	return YES;
}

-(void)LaunchSequence
{
	if(!m_sequenceStart)
	{  
        float between = 1.3;
        float init = 3.f;
        float init2 = init + 3.f * between + .9;
        float init3 = init2 + 3.f * between + .9;
        float init4 = init3 + 3.f * between + .9;
        float init5 = init4 + 3.f * between + .9;
        m_timeBeforeEndSequence = init5 + 3.f;
        
		NSArray * l_sequencePig = [[NSArray alloc] initWithObjects:
           [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_SQUARE begin:init end:init + between] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_EGUAL begin:init + between end:init + 2.f * between] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_CIRCLE begin:init + 2.f * between end:init2] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_UP begin:init2 end:init2 + between] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_EGUAL begin:init2 + between end:init2 + between * 2.] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_DOWN begin:init2 + between * 2. end:init2 + between * 3.] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_T_NGOUT_PANEL_LULU begin:init3 end:init3 + between] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_EGUAL begin:init3 + between end:init3 + between * 2.] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_T_NGOUT_PANEL_INFINITE begin:init3 + between * 2. end:init3 + between * 3.] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_T_NGOUT_PANEL_PIG begin:init4 end:init4 + between] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_EGUAL begin:init4 + between end:init4 + between * 2.] autorelease],
           [[[PanelEvent alloc]InitTexture:TEXTURE_T_NGOUT_PANEL_QUESTION begin:init4 + between * 2. end:m_timeBeforeEndSequence] autorelease],
           nil
									 ];
		
		[m_puppet[1] SetSequence:l_sequencePig]; 
		
		NSArray * l_sequenceMario = [[NSArray alloc] initWithObjects:
         [[[PanelEvent alloc]InitTexture:TEXTURE_THEATRE_PANEL_SURPRISE begin:0. end:init + 3.f * between] autorelease],
         [[[PanelEvent alloc]InitTexture:TEXTURE_T_NGOUT_PANEL_SURPRISE_SQUARE begin:init + 3.f * between end:init2 + 3.f * between] autorelease],
        [[[PanelEvent alloc]InitTexture:TEXTURE_T_NGOUT_PANEL_SURPRISE_SQUARE_REVERSE begin:init2 + 3.f * between end:init3 + 3.f * between] autorelease],
        [[[PanelEvent alloc]InitTexture:TEXTURE_T_NGOUT_PANEL_MESSEDUP begin:init3 + 3.f * between end:init4 + 3.f * between] autorelease],
        [[[PanelEvent alloc]InitTexture:TEXTURE_T_NGOUT_PANEL_HORSE begin:init4 + 3.5f * between end:m_timeBeforeEndSequence + 3.f * between] autorelease],
         nil
									 ];
		
		[m_puppet[0] SetSequence:l_sequenceMario];
		m_sequenceStart = YES;
        
        if(m_time > m_nextNoiseTimer)
        {
            m_nextNoiseTimer += 3.f * between + .5;
            [[OpenALManager sharedOpenALManager] playSoundWithKey:@"baptisteCoin" Volume:1.7f];
        }
	}	
}

// Multi touch event.
-(void)Touch:(CGPoint)a_touchLocation
{
	int l_newMapping;
	if(DistancePoint(a_touchLocation, m_fingerPosition[m_mappingFingerZeroToPuppet]) > DistancePoint(a_touchLocation, m_fingerPosition[(m_mappingFingerZeroToPuppet + 1) % 2]))
	{
		l_newMapping = 1;
	}
	else
	{
		l_newMapping = 0;
	}
	
	if(m_mappingFingerZeroToPuppet != l_newMapping)
	{
		m_fingerPosition[1] = m_fingerPosition[0];
		m_fingerPosition[0] = a_touchLocation;
	}
	m_mappingFingerZeroToPuppet = l_newMapping;
	
	return;
}

-(void)TouchMoved:(CGPoint)a_touchLocation
{
	m_fingerPosition[0] = a_touchLocation;
	if(m_go && m_fingerPosition[0].x > 0.9)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateSea alloc] init]];
	}
	
	return;
}

// Multi touch event.
-(void)MultiTouch:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	int l_newMapping;
	if(DistancePoint(a_touchLocation1, m_fingerPosition[m_mappingFingerZeroToPuppet]) > DistancePoint(a_touchLocation1, m_fingerPosition[(m_mappingFingerZeroToPuppet + 1) % 2]))
	{
		l_newMapping = 1;
	}
	else
	{
		l_newMapping = 0;
	}
	
	if(m_mappingFingerZeroToPuppet != l_newMapping)
	{
		m_fingerPosition[1] = a_touchLocation2;
		m_fingerPosition[0] = a_touchLocation1;
	}
	m_mappingFingerZeroToPuppet = l_newMapping;
	
	return;
}

// Multi touch event.
-(void)MultiTouchMove:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	m_fingerPosition[0] = a_touchLocation1;
	m_fingerPosition[1] = a_touchLocation2;
	
	if(m_go && (m_time > TIME_MIN_BEFORE_QUIT) && (a_touchLocation1.x > .9f || a_touchLocation2.x > .9f))
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:[[StateSea alloc] init]];
	}
	return;
}

-(void)Terminate
{
	[[EAGLView sharedEAGLView] SetCameraUpdatable:YES];
	[super Terminate];
	
	[m_puppet[0] release];
	[m_puppet[1] release];
	
	// destroy the snake.
	[PhysicPendulum RemoveAllElements];
}

-(id)GetNoteBook
{
	return [[NoteBook alloc] InitWithString:[NSString stringWithString:@"The Yōkais seem to understand that I'm the strongest._ I just loved cutting them into pieces,_ but now I'm completely lost. L."]
								MusicToFade:@"musicAphex"];
}


@end
