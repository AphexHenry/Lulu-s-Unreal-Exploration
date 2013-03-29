//
//  StateLarve.m
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "StateIntro.h"
#import "StateTheatreRateIt.h"
#import "EAGLView.h"
#import "MathTools.h"
#import "ParticleManager.h"
#import "ApplicationManager.h"
#import	"OpenALManager.h"
#import "Puppet.h"
#import "ParticleLetter.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>

#define STICK_LENGTH 1.
#define GROUND_Y -0.6f
#define TIME_BEFORE_OPEN_CURTAINS 2.f
#define SPEED_LULU_TURN .3f
#define SPEED_LULU_WALK .06f
#define TIMER_BEFORE_HEAD_FALL 8.f
#define TIME_MIN_BEFORE_QUIT 3.f
#define STATE_FLY_OUT_TIME_TO_FADE 10.f
#define VERSION 2 // version 2 = version act 6.

@implementation StateTheatreRateIt

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
	m_levelData.m_arraySize = TEXTURE_T_RATEIT_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"ForestBack.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"wallSulpiceShadow.png"];
	m_levelData.m_textureArray[TEXTURE_T_RATEIT_SHADOW_FRONT] = [[NSString alloc] initWithString:@"luluTitleFront.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_STICK] = [[NSString alloc] initWithString:@"stick.png"];
	m_levelData.m_textureArray[TEXTURE_T_RATEIT_PUPPET_MESSAGE] = [[NSString alloc] initWithString:@"rateIt.png"];
	m_levelData.m_textureArray[TEXTURE_T_RATEIT_PUPPET_SNAKE] = [[NSString alloc] initWithString:@"puppetSnakeDecomposed.png"];	
	m_levelData.m_textureArray[TEXTURE_T_RATEIT_PUPPET_YES] = [[NSString alloc] initWithString:@"yes.png"];	
	m_levelData.m_textureArray[TEXTURE_T_RATEIT_PUPPET_NO] = [[NSString alloc] initWithString:@"no.png"];	
	m_levelData.m_textureArray[TEXTURE_T_RATEIT_PUPPET_LATER] = [[NSString alloc] initWithString:@"later.png"];	
	
	m_skyDecay = CGPointMake(0., 0.);
	m_time = 0.f;
	m_headFall = NO;
	m_headEaten = NO;
	m_sequenceStart = NO;
	
	m_fingerPosition[0] = CGPointMake(0.7f, 0.8f) ;
	m_fingerPosition[1] = CGPointMake(-0.8f, 0.8f);
	
	[ParticleLetter GlobalInit:[[Animation alloc] initWithFirstFrame:TEXTURE_THEATRE_WING_0 lastFrame:TEXTURE_THEATRE_WING_1 duration:0.07]
						 angle:90.f
				  texturePause:TEXTURE_THEATRE_WING_0
					  sizeWing:1.4f
	 ];

	[ParticleLetter SetPosition:CGPointMake(-0.7, -0.4f)];
	ParticleManager * l_particleManager = [ParticleManager sharedParticleManager];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_RATEIT_PUPPET_NO textureStick:TEXTURE_THEATRE_STICK groupIndex:0 initPosition:CGPointMake(-4.f, 0.f)]];
	[ParticleLetter Space];
	[ParticleLetter Space];
	[ParticleLetter Space];
	[ParticleLetter Space];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_RATEIT_PUPPET_LATER textureStick:TEXTURE_THEATRE_STICK groupIndex:0 initPosition:CGPointMake(-4.f, 0.f)]];
	[ParticleLetter Space];
	[ParticleLetter Space];
	[ParticleLetter Space];
	[ParticleLetter Space];
	[l_particleManager AddParticle:[[ParticleLetter alloc] initWithTexture:TEXTURE_T_RATEIT_PUPPET_YES textureStick:TEXTURE_THEATRE_STICK groupIndex:0 initPosition:CGPointMake(-4.f, 0.f)]];	
	
	[ParticleLetter SetSize:0.2 group:0];
	
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"treeFriction" Volume:0.f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"wind" Volume:0.f];
	[[OpenALManager sharedOpenALManager] FadeWithKey:@"wind" duration:2.f volume:0.7f stopEnd:NO];
	[[OpenALManager sharedOpenALManager] SetPitchWithKey:@"wind" Pitch:1.1f];
	
	return [super StateInit];
}

//
//  Update.
//
-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{	
	m_time += a_timeInterval;
	
	// this is just to have a clearer code.
	if(![self UpdatePuppet:a_timeInterval])
	{
		return;
	}
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_size	 = m_levelData.m_size;
	m_skyDecay.x += -0.5 * a_timeInterval * 1.2;

	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_THEATRE_STICK
										   plan:PLAN_PENDULUM
										   size:0.4f
									  positionX:0.f
									  positionY:0.9f
									  positionZ:0.
								  rotationAngle:0.f
								rotationCenterX:0.f
								rotationCenterY:0.f
								   repeatNumber:1
								  widthOnHeight:1.f / 15.f
									 nightBlend:false
									deformation:0.f
									   distance:50.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:-1
										reverse:REVERSE_NONE
	 ];
	
	// draw background.
	[[EAGLView sharedEAGLView] drawTextureIndex:TEXTURE_T_RATEIT_PUPPET_MESSAGE
										   plan:PLAN_SKY_SHADOW
										   size:.3f
									  positionX:0.f
									  positionY:.3f
									  positionZ:0.
								  rotationAngle:0.f
								rotationCenterX:0.
								rotationCenterY:0.
								   repeatNumber:1
								  widthOnHeight:2.f * (1.f - 0.1 * Absf(1.f - cos(m_time)))
									 nightBlend:FALSE
									deformation:0.f
									   distance:-1.f
										 decayX:0.f
										 decayY:0.f
										  alpha:1.f
										 planFX:PLAN_BACKGROUND_STICKERS
										reverse:REVERSE_NONE	 
	 ];
	
	float l_treeEvolution = cos(m_time * 0.2);
	float l_treeDistance = 2.3f + l_treeEvolution * 0.3f;
	[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"treeFriction" Volume:0.4 * (1.f - 0.8 * ((l_treeEvolution + 1.f) / 2.f))];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_SKY_SHADOW
								  size:l_size * 1.9f
							 positionX:0
							 positionY:l_treeDistance
							 positionZ:0.
						 rotationAngle:180.f
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							nightBlend:FALSE
						   deformation:0.f
							  distance:-1.f
								decayX:-m_skyDecay.x
								decayY:0.f
								 alpha:1.f
								planFX:PLAN_BACKGROUND_SHADOW
							   reverse:REVERSE_NONE	 
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_BACKGROUND
								  plan:PLAN_BACKGROUND_SHADOW
								  size:l_size * 1.9f
							 positionX:0
							 positionY:-l_treeDistance
							 positionZ:0.
						  repeatNumber:1
						 widthOnHeight:2.f
							  distance:31.f
								decayX:m_skyDecay.x
								decayY:0.f
	 ];
	
	[l_sharedEAGLView SetCameraUpdatable:YES];
	[l_sharedEAGLView SetScale:1.2f + sin(m_time * .15) * 0.2f force:YES];
	[l_sharedEAGLView SetCameraUpdatable:NO];
	
	[super UpdateWithTimeInterval:a_timeInterval];
}

-(void)SimpleClick:(CGPoint)a_touchLocation
{
	int l_texture = [[ParticleManager sharedParticleManager] GetTextureWithPosition:a_touchLocation];
	NSString *templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=478405155";

	// don't ask again if clicked on no. Don't go to the rate screen.
    // ask later if click on later. Don't go to the rate screen.
    // don't ask again if click on yes. Go to the rate screen.
	switch (l_texture)
	{
		case TEXTURE_T_RATEIT_PUPPET_YES:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:templateReviewURL]];
			[[ApplicationManager sharedApplicationManager] ChangeState:[[StateIntro alloc] init]];
			[[ApplicationManager sharedApplicationManager] SetRated:VERSION];
			break;
		case TEXTURE_T_RATEIT_PUPPET_NO:
			[[ApplicationManager sharedApplicationManager] ChangeState:[[StateIntro alloc] init]];
			[[ApplicationManager sharedApplicationManager] SetRated:VERSION];
			break;
		case TEXTURE_T_RATEIT_PUPPET_LATER:
			[[ApplicationManager sharedApplicationManager] ChangeState:[[StateIntro alloc] init]];
			break;			
		default:
			break;
	}
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

+(BOOL)connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	NSURL *testURL = [NSURL URLWithString:@"http://www.apple.com/"];
	NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
	NSURLConnection *testConnection = [[NSURLConnection alloc] initWithRequest:testRequest delegate:self];
	
    return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
}

+(int)GetVersion
{
    return VERSION;
}

@end
