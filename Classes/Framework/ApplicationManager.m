//
//  ApplicationManager.m
//  Particles
//
//  Created by Baptiste Bohelay on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ApplicationManager.h"
#import "EAGLView.h"
#import "OpenALManager.h"
#import "ParticleManager.h"
#import "ParticleViewController.h"
#import "PhysicPendulum.h"
#import "StateIntro.h"
#import "StateLucioles.h"
#import "StateLarve.h"
#import "StateSpiral.h"
#import "StateParticleFight.h"
#import "StateTheatreLarveOut.h"
#import "StateTheatreSpiralOut.h"
#import "StateTheatreFlyOutGameOver.h"
#import "StateTheatreLastOut.h"
#import "StateTheatreRateIt.h"
#import "StateTheatreNextGeneration.h"
#import "StateTheatreNextGenerationGameOver.h"
#import "StateTheatreNextGenerationOut.h"
#import "StateTheatreTreesFast.h"
#import "StateSea.h"

#define DEBUG 1
#define FADING_DURATION 1.5f
#define BAPTISTE_SIZE 89
#define TIME_BEFORE_BAPTISTE_COMING 4.
#define NUM_BEAST_TEXTURE 4
#define HELP_DURATION 5.f

@implementation ApplicationManager

static ApplicationManager* _sharedApplicationManager = nil;

@synthesize m_animationInterval;
@synthesize m_numberMaxParticleToLose;
@synthesize m_numberGenerationToMutate;
@synthesize m_pause;
@synthesize m_savedLevel;

//
// initialize if not done yet and return the object
//
+(ApplicationManager*)sharedApplicationManager
{
	@synchronized([ApplicationManager class])
	{
		if (!_sharedApplicationManager)
			[[self alloc] init];
		return _sharedApplicationManager;
	}
	return nil;
}

+(id)alloc
{
	@synchronized([ApplicationManager class])
	{
		NSAssert(_sharedApplicationManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedApplicationManager = [super alloc];
		return _sharedApplicationManager;
	}
	return nil;
}

//
// init the application.
//
- (id)init
{		
	// Start animation and update.
	m_animationInterval = 1.f / 50.f;
	
	NSUserDefaults *l_userDefault = [NSUserDefaults standardUserDefaults];
	
	// getting an NSInteger
	NSInteger l_savedLevel = [l_userDefault integerForKey:@"level"];
	
	if(l_savedLevel == 0)
	{
		m_savedLevel = 1;
	}
	else
	{
		m_savedLevel = l_savedLevel;
	}
	
	if(DEBUG)
	{
		m_savedLevel = STATE_COUNT - 1;
	}
	
	// Sound metadata loading.
	OpenALManager * l_soundManager = [OpenALManager sharedOpenALManager];
	[l_soundManager AddMetadata:@"wind" fileExt:@"mp3" loop:true];
	[l_soundManager AddMetadata:@"shock" fileExt:@"mp3" loop:false pitchVar:0.1f];
	[l_soundManager AddMetadata:@"crok" fileExt:@"mp3" loop:false pitchVar:0.1f];
	[l_soundManager AddMetadata:@"eclosion" fileExt:@"wav" loop:false pitchVar:0.3f];
	[l_soundManager AddMetadata:@"ambientSwamp" fileExt:@"mp3" loop:true];
	[l_soundManager AddMetadata:@"craquement mystérieux" fileExt:@"mp3" loop:true];
	[l_soundManager AddMetadata:@"string" fileExt:@"mp3" loop:true];
	[l_soundManager AddMetadata:@"string2" fileExt:@"mp3" loop:false];
	[l_soundManager AddMetadata:@"music2" fileExt:@"mp3" loop:true];
	[l_soundManager AddMetadata:@"morvan" fileExt:@"mp3" loop:true];
	[l_soundManager AddMetadata:@"musicTripouille" fileExt:@"mp3" loop:true];	
	[l_soundManager AddMetadata:@"menuClick" fileExt:@"mp3" loop:NO];
	[l_soundManager AddMetadata:@"noiseGrass" fileExt:@"mp3" loop:YES];
	[l_soundManager AddMetadata:@"treeFriction" fileExt:@"mp3" loop:YES];
	[l_soundManager AddMetadata:@"siurp" fileExt:@"mp3" loop:NO];
	[l_soundManager AddMetadata:@"baptisteCoin" fileExt:@"wav" loop:NO pitchVar:0.15f permanent:YES];
	[l_soundManager AddMetadata:@"grind" fileExt:@"mp3" loop:YES pitchVar:0.f permanent:YES];
	[l_soundManager AddMetadata:@"thunder0" fileExt:@"mp3" loop:NO pitchVar:0.1f];
	[l_soundManager AddMetadata:@"thunder1" fileExt:@"mp3" loop:NO pitchVar:0.1f];
	[l_soundManager AddMetadata:@"BigMonsterScream" fileExt:@"wav" loop:NO pitchVar:0.15f];
	[l_soundManager AddMetadata:@"write" fileExt:@"wav" loop:YES pitchVar:0.f permanent:YES];
	[l_soundManager AddMetadata:@"erase" fileExt:@"wav" loop:YES pitchVar:0.f permanent:YES];
	[l_soundManager AddMetadata:@"bicycle" fileExt:@"mp3" loop:YES pitchVar:0.f];
	[l_soundManager AddMetadata:@"electricity" fileExt:@"mp3" loop:YES pitchVar:0.f];
	[l_soundManager AddMetadata:@"musicAphex" fileExt:@"mp3" loop:YES pitchVar:0.f];
	[l_soundManager AddMetadata:@"guadaStick1" fileExt:@"mp3" loop:NO pitchVar:0.2f];
	[l_soundManager AddMetadata:@"guadaStick2" fileExt:@"mp3" loop:NO pitchVar:0.2f];
	[l_soundManager AddMetadata:@"crazyness" fileExt:@"mp3" loop:YES pitchVar:0.f];
    [l_soundManager AddMetadata:@"raclement" fileExt:@"mp3" loop:YES pitchVar:0.f];
    [l_soundManager AddMetadata:@"SeaTransition" fileExt:@"mp3" loop:NO pitchVar:0.1f];
    [l_soundManager AddMetadata:@"SeaStateNormal" fileExt:@"mp3" loop:YES pitchVar:0.f];
    [l_soundManager AddMetadata:@"slarp" fileExt:@"mp3" loop:NO pitchVar:0.1f];
    [l_soundManager AddMetadata:@"pig" fileExt:@"mp3" loop:YES];
    
	m_currentState = nil;
//    [self ChangeState:[[StateTheatreTreesFast alloc] InitFromMenu]];
	[self ChangeState:[[StateIntro alloc] init]];
	
	[m_ParticleManager ActiveDeadParticlesFromGroup:PARTICLE_GROUP_CLOUD];
	
	m_numberMaxParticleToLose = 25;
	m_numberGenerationToMutate = 5;

	m_updateType = UPDATE_FADE_IN;
	
    // Init visibility of the xib GUI objects.
	UIScreen* mainscr = [UIScreen mainScreen];
	ParticleViewController * l_particleViewController = [ParticleViewController sharedParticleViewController];
	[[l_particleViewController m_glview] bringSubviewToFront:[l_particleViewController m_backBaptisteImageView]];
	[[l_particleViewController m_helpView] setHidden:YES];
	[[l_particleViewController m_helpImage] setHidden:YES];
	[[l_particleViewController m_backBaptisteImageView] setHidden:NO];
	[[l_particleViewController m_glview] bringSubviewToFront:[l_particleViewController m_helpImage]];
	[[ParticleViewController sharedParticleViewController].m_buttonSkipSpeak setHidden:YES];
	
	m_baptisteIsComingTimer = 0.f;
	m_baptisteClicked = NO;
	m_baptisteBlocked = YES;
	m_baptisteBackPosition = CGPointMake(-BAPTISTE_SIZE / 2., mainscr.bounds.size.width + BAPTISTE_SIZE / 2.);
	m_baptisteBackSpeed = CGPointMake(+0.f, -0.f);
	
	return self;
}

//
// Update the application manager.
//
- (void)Update
{	
	NSTimeInterval l_now =  [NSDate timeIntervalSinceReferenceDate];
	m_timeFrame = l_now - m_timeAtLastUpdate;
	m_timeAtLastUpdate = l_now;
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	
	[self UpdateBaptiste:m_timeFrame];
	
    // fade the luminosity, before switching the state.
	switch (m_updateType)
	{
		case UPDATE_FADE_IN:
			m_timerFading += m_timeFrame;
			[l_sharedEAGLView SetLuminosity:clip(m_timerFading / FADING_DURATION, 0.f, 1.f)];
			if(m_timerFading > FADING_DURATION)
			{
				m_updateType = UPDATE_STATE;
			}
			break;
		case UPDATE_FADE_OUT:
			m_timerFading += m_timeFrame;
			[l_sharedEAGLView SetLuminosity:clip(1.f - (m_timerFading / FADING_DURATION), 0.f, 1.f)];
			if(m_timerFading > FADING_DURATION)
			{
				[self ApplyState];
				m_updateType = UPDATE_FADE_IN;
				m_timerFading = 0.f;
			}
			break;
		default:
			break;
	}
	
	[m_currentState UpdateWithTimeInterval:min(m_timeFrame, 0.2)];
	[l_sharedEAGLView UpdateCameraWithTimeInterval:m_timeFrame];
	[l_sharedEAGLView drawView];
	
	OpenALManager * l_soundManager = [OpenALManager sharedOpenALManager];
	[l_soundManager UpdateFading:m_timeFrame];

	return;
}

//
// update the Baptiste GUI.
//
-(void)UpdateBaptiste:(NSTimeInterval)a_timeInterval
{
    // make apear the help GUI when the player doesn't play for a time, or if he click on the help space.
	if(!m_baptisteBlocked)
	{
		m_baptisteIsComingTimer += m_timeFrame;
	}
	else
	{
		m_baptisteIsComingTimer = 0.f;
	}

    // the help GUI pop up when the user is idle for a long time, or when he has clicked on the help zone.
	if(m_baptisteIsComingTimer > TIME_BEFORE_BAPTISTE_COMING)
	{
		m_baptisteBackSpeed = CGPointMake(7.f, -7.f);
	}
	else if(m_baptisteClicked)
	{
		m_baptisteBackSpeed = CGPointMake(70.f, -70.f);		
	}
	else
	{
		m_baptisteBackSpeed = CGPointMake(-70.f, 70.f);
	}
	
	UIScreen* mainscr = [UIScreen mainScreen];
	m_baptisteBackPosition.x += m_baptisteBackSpeed.x * m_timeFrame;
	m_baptisteBackPosition.y += m_baptisteBackSpeed.y * m_timeFrame;
	m_baptisteBackPosition.x = clip(m_baptisteBackPosition.x, -BAPTISTE_SIZE / 2., BAPTISTE_SIZE / 2.);
	m_baptisteBackPosition.y = clip(m_baptisteBackPosition.y, mainscr.bounds.size.width - BAPTISTE_SIZE / 2.f, mainscr.bounds.size.width + BAPTISTE_SIZE / 2.f);
	[[[ParticleViewController sharedParticleViewController] m_backBaptisteImageView] setCenter:m_baptisteBackPosition];
}

//
// Call for changing to a new state.
//
-(void)ChangeState:(State * )a_newState
{
    // Avoid to load two times the same state. We need to wait for the end of the fading.
	if(m_updateType == UPDATE_FADE_OUT)
	{
		if(a_newState != nil)
		{
			[a_newState release];
		}
		return;
	}
	
	// if there is not a new state, that means that the next state is already the good one. (used for the notebook).
	if(a_newState)
	{
		m_nextState = a_newState;
	}

    // Security!
	if(m_currentState == nil)
	{
		[self ApplyState];
		m_updateType = UPDATE_STATE;
		return;
	}
	m_timerFading = 0;
	m_updateType = UPDATE_FADE_OUT;
}

//
// if the state is called from the menu, we need to know it
// because we have to call an extra init of the state. Example: the sound files are played during a previous state, are not loaded now.
//
-(void)ChangeStateFromMenu:(State * )a_newState
{
    m_callExtraInit = YES;
    [self ChangeState:a_newState];
}

//
// Switch immediatly to the next state.
//
-(void)ApplyState
{
	[self ClosePreviousState];
	if(m_noteBook)
	{
		m_noteBook = nil;
	}
	else
	{
		m_noteBook = [m_nextState GetNoteBook];
	}

	if(m_noteBook)
	{
		m_currentState = m_noteBook;
	}
	else
	{
		m_currentState = m_nextState;
        [[OpenALManager sharedOpenALManager] SetNewList:[m_currentState GetSoundArray]];
	}
	
	[self InitState];
}

//
// return the current state.
//
-(State *)GetState
{
	return m_currentState;
}

//
// Close previous state.
//
-(void)ClosePreviousState
{
	// destroy all the particles.
	if(m_currentState)
	{
		[m_currentState Terminate];
	}
}

//
// Init new state.
//
-(void)InitState
{
    if(m_callExtraInit)
    {
        [m_currentState InitFromMenu];
        m_callExtraInit = NO;
    }
    
	[m_currentState StateInit];
}

//
// Set a new timer for the update.
//
- (void)setTimer:(NSTimer *)newTimer 
{
    [animationTimer invalidate];
    animationTimer = newTimer;
}

//
// Block or not Baptiste GUI.
//
-(void)SetBaptisteBlocked:(BOOL)a_baptisteBlocked
{
	m_baptisteBlocked = a_baptisteBlocked;
}

//
// Get an availble random texture for a background monster.
//
-(NSString *)GetABeastName
{
	int l_index = arc4random() % NUM_BEAST_TEXTURE;
	return [NSString stringWithFormat:@"beast%d", l_index];
}

//
// Simple click event.
//
-(void)SimpleClick:(CGPoint)a_touchLocation
{
	//CGRect l_buttonRect;
	CGPoint l_convertedPoint = PixelToGL(a_touchLocation);
	ScreenTransformation l_screenTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	l_convertedPoint = ConvertPositionWithCameraTransformationFromScreenToGame(l_convertedPoint, l_screenTransformation);
	[m_currentState SimpleClick:l_convertedPoint];
	
	m_baptisteIsComingTimer = 0.f;
	if(m_baptisteClicked)
	{
		if(DistancePoint(a_touchLocation, m_baptisteBackPosition) < BAPTISTE_SIZE * 4)
		{
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"baptisteCoin" Volume:2.5f];
			[self ChangeState:[[StateIntro alloc] init]];
			m_baptisteClicked = NO;
			[self SetHelp:nil];
			return;
		}
	}
	if(!m_baptisteBlocked && a_touchLocation.x < (BAPTISTE_SIZE / 1.5f) && a_touchLocation.y > (320 - (BAPTISTE_SIZE / 1.5f)))
	{
		m_baptisteClicked = YES;
		[self SetHelp:@"helpQuit.png"];
		[self SetHelpPositionPixel:CGPointMake(0.f, 0.f)];
	}
}

//
// Touch event.
//
-(void)Touch:(CGPoint)a_touchLocation
{
	CGPoint l_convertedPoint = PixelToGL(a_touchLocation);
	ScreenTransformation l_screenTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	l_convertedPoint = ConvertPositionWithCameraTransformationFromScreenToGame(l_convertedPoint, l_screenTransformation);
	[m_currentState Touch:l_convertedPoint];
	m_baptisteIsComingTimer = -TIME_BEFORE_BAPTISTE_COMING;;
}

//
// Touch event.
//
-(void)MultiTouch:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	a_touchLocation1 = PixelToGL(a_touchLocation1);
	a_touchLocation2 = PixelToGL(a_touchLocation2);
	ScreenTransformation l_screenTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	a_touchLocation1 = ConvertPositionWithCameraTransformationFromScreenToGame(a_touchLocation1, l_screenTransformation);
	a_touchLocation2 = ConvertPositionWithCameraTransformationFromScreenToGame(a_touchLocation2, l_screenTransformation);
	[m_currentState Touch:a_touchLocation1];
	[m_currentState MultiTouch:a_touchLocation1 touch2:a_touchLocation2];
	m_baptisteIsComingTimer = -TIME_BEFORE_BAPTISTE_COMING;;
}

//
// Touch event.
//
-(void)TouchMoved:(CGPoint)a_touchLocation
{
	//	CGRect l_buttonRect;
	CGPoint l_convertedPoint = PixelToGL(a_touchLocation);
	ScreenTransformation l_screenTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	l_convertedPoint = ConvertPositionWithCameraTransformationFromScreenToGame(l_convertedPoint, l_screenTransformation);
	[m_currentState TouchMoved:l_convertedPoint];
	m_baptisteIsComingTimer = -TIME_BEFORE_BAPTISTE_COMING;;
}

//
// multi touch move event.
//
-(void)MultiTouchMove:(CGPoint)a_touchLocation1 touch2:(CGPoint)a_touchLocation2
{
	a_touchLocation1 = PixelToGL(a_touchLocation1);
	a_touchLocation2 = PixelToGL(a_touchLocation2);
	ScreenTransformation l_screenTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	a_touchLocation1 = ConvertPositionWithCameraTransformationFromScreenToGame(a_touchLocation1, l_screenTransformation);
	a_touchLocation2 = ConvertPositionWithCameraTransformationFromScreenToGame(a_touchLocation2, l_screenTransformation);
	[m_currentState Touch:a_touchLocation1];
	[m_currentState MultiTouchMove:a_touchLocation1 touch2:a_touchLocation2];
	m_baptisteIsComingTimer = -TIME_BEFORE_BAPTISTE_COMING;
}

-(void)TouchEnded:(CGPoint)a_touchLocation
{
    CGPoint l_convertedPoint = PixelToGL(a_touchLocation);
    ScreenTransformation l_screenTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	l_convertedPoint = ConvertPositionWithCameraTransformationFromScreenToGame(l_convertedPoint, l_screenTransformation);
	[m_currentState TouchEnded:l_convertedPoint];
	m_baptisteIsComingTimer = 0.f;
}

-(void)SkipSpeaking
{
	[m_currentState SkipSpeaking];
}

-(void)Shake
{
	m_baptisteIsComingTimer = 0.f;
	[m_currentState Shake];
}

//
// Return to main menu.
//
-(void)BackToMenu
{
	
}

//
// Set the stop state.
//
-(void)Stop:(BOOL)a_isStop
{
	if(a_isStop)
	{
		[animationTimer invalidate];
	}
	else
	{
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:m_animationInterval target:self selector:@selector(Update) userInfo:nil repeats:YES];
		m_timeAtLastUpdate = [NSDate timeIntervalSinceReferenceDate];
	}
}

//
// remove help.
//
-(void)RemoveHelp
{
	[self SetHelp:nil];
	m_baptisteClicked = NO;
}

//
// Set the help message.
//
-(void)SetHelp:(NSString *)a_string
{
	ParticleViewController * l_particleViewController = [ParticleViewController sharedParticleViewController];
	if(a_string != nil)
	{
		[[l_particleViewController m_helpImage] setImage:[UIImage imageNamed:a_string]];
		[[l_particleViewController m_helpView] setHidden:NO];
		[[l_particleViewController m_helpImage] setHidden:NO];
		[self performSelector:@selector(RemoveHelp) withObject:nil afterDelay:HELP_DURATION];
	}
	else
	{
		[[l_particleViewController m_helpView] setHidden:YES];
		[[l_particleViewController m_helpImage] setHidden:YES];
	}
}

//
// Set help position.
//
-(void)SetHelpPositionPixel:(CGPoint)a_position
{
	ParticleViewController * l_particleViewController = [ParticleViewController sharedParticleViewController];
	
	if(m_baptisteClicked)
	{
		a_position = CGPointMake(m_baptisteBackPosition.x, m_baptisteBackPosition.y);
	}
	a_position.x += [[l_particleViewController m_helpView] bounds].size.width / 2 + 10;
	a_position.y -= [[l_particleViewController m_helpView] bounds].size.height / 2 + 10;

    [[l_particleViewController m_helpView] setCenter:a_position];
    [[l_particleViewController m_helpImage] setCenter:a_position];
}

//
// Save the given level.
//
-(void)SaveLevel:(int)a_level
{
	m_savedLevel = (int)max(a_level, m_savedLevel);
	NSUserDefaults *l_savedLevel = [NSUserDefaults standardUserDefaults];
	[l_savedLevel setInteger:m_savedLevel forKey:@"level"];	
}

//
// Set the game rated.
// a_rated: version of the rating.
//
-(void)SetRated:(int)a_rated
{
	NSUserDefaults *l_savedLevel = [NSUserDefaults standardUserDefaults];
	[l_savedLevel setInteger:a_rated forKey:@"rated"];	
}

//
// return the version of the rating.
//
-(int)GetRated
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"rated"];
}

//
// Release all classes.
//
- (void)Finnish
{
	animationTimer = nil;
	[m_ParticleManager release];
	[PhysicPendulum DeallocAllTheList];
	[[OpenALManager sharedOpenALManager] shutdownOpenALManager];
	[m_currentState Terminate];
}

@end
