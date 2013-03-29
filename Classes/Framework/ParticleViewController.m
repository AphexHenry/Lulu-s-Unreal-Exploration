#import "ParticleViewController.h"
#import "EAGLView.h"
#import "MathTools.h"

#import	"ApplicationManager.h"
#import "OpenALManager.h"
#import "ParticleManager.h"
#import "PhysicPendulum.h"

#define DBLECLICK_TIME	0.4		// time max between two click in a double click

@implementation ParticleViewController

static ParticleViewController* _sharedParticleViewController = nil;

@synthesize m_glview;
@synthesize m_buttonSkipSpeak;
@synthesize m_helpImage;
@synthesize m_helpView;
@synthesize m_backBaptisteImageView;
@synthesize m_noteBookTextView;
@synthesize m_noteBookTextViewDate;

//
// initialize if not done yet and return the object
//
+(ParticleViewController*)sharedParticleViewController
{
	@synchronized([ParticleViewController class])
	{
		if (!_sharedParticleViewController)
			[[self alloc] init];
		return _sharedParticleViewController;
	}
	return nil;
}

+(id)alloc
{
	@synchronized([ParticleViewController class])
	{
		NSAssert(_sharedParticleViewController == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedParticleViewController = [super alloc];
		return _sharedParticleViewController;
	}
	return nil;
}

- (void)viewDidLoad
{
    // Now try to set the orientation to landscape (right)
	[ApplicationManager sharedApplicationManager];
	m_ArrowHeadDomain = CGRectMake(129, 140., 68, 55);
	m_ArrowAngle = DEGREES_TO_RADIANS(90);
	m_AttractorTouched = nil;
	m_lastScale = 1.f;
	
	[m_glview setMultipleTouchEnabled:YES];
	
	m_timeLastShake = 0.;
	
	UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
	
	accel.delegate = self;
	accel.updateInterval = 1.0f/40.0f;
	
	[m_helpView setHidden:YES];
	[m_helpImage setHidden:YES];
}


- (void)accelerometer:(UIAccelerometer *)acel didAccelerate:(UIAcceleration *)aceler 
{	
	if (fabsf(aceler.x) > 2. || fabsf(aceler.y) > 2. || fabsf(aceler.z) > 2.)
	{
		NSTimeInterval l_now =  [NSDate timeIntervalSinceReferenceDate];
		if((l_now - m_timeLastShake) > 3.f)
		{
			printf("shake");
			[[ApplicationManager sharedApplicationManager] Shake];

			m_timeLastShake = l_now;
		}
	}
}

// 
//	here we,ve got the events du to the secreen touch
//	in a case of a double click on arrow head, we launch circle sequence
//	in a case of a double click in another place, we controle the attractor position and activation
//	then we define if it is the head or another place wich is touched. 
//	If it's the head, we controle the arrow orientation
//	If it's the view except the head, we control the wind
//
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSSet *allTouches = [event allTouches];
	ApplicationManager * l_applicationManager = [ApplicationManager sharedApplicationManager];
	UITouch * l_touch;
	UITouch * l_touch2;
    switch ([allTouches count]) 
	{
        case 1:
        {
			l_touch = [[allTouches allObjects] objectAtIndex:0];
			m_initTouchLocation = [l_touch locationInView:l_touch.view];
			[l_applicationManager Touch:m_initTouchLocation];
			m_pause = [l_applicationManager m_pause];
			NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
			NSTimeInterval timeElapsed = now - m_TimeAtLastClick;
			if(timeElapsed < DBLECLICK_TIME)
			{
				[self DoubleClick:event];
			}
			
			m_TimeAtLastClick = now;
			m_hasMoved = FALSE;
            break;
        }
        default:
        {
			l_touch = [[allTouches allObjects] objectAtIndex:0];
			l_touch2 = [[allTouches allObjects] objectAtIndex:1];
			// handle multi touch
			CGPoint l_touchPosition1 = [l_touch locationInView:l_touch.view];
			CGPoint l_touchPosition2 = [l_touch2 locationInView:l_touch.view];
			[l_applicationManager MultiTouch:l_touchPosition1 touch2:l_touchPosition2];

            break;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	int i = 0;
	i++;
	return;
}

//
//	we just update the arrow orientation when we touched its head and move the finger
//
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{	
	NSSet *allTouches = [event allTouches];
	ApplicationManager * l_applicationManager = [ApplicationManager sharedApplicationManager];
	UITouch * l_touch;
	UITouch * l_touch2;
    switch ([allTouches count]) 
	{
        case 1:
        {
			l_touch = [[allTouches allObjects] objectAtIndex:0];
			m_initTouchLocation = [l_touch locationInView:l_touch.view];
			
			if(!m_pause)
			{
				[[ApplicationManager sharedApplicationManager] TouchMoved:m_initTouchLocation];
				
				m_initTouchLocation.x = m_initTouchLocation.x / 160. - 1.5;
				m_initTouchLocation.y = -m_initTouchLocation.y / 160. + 1.1;
				m_initTouchLocation.x *= 1.5;
				m_initTouchLocation.y *= 1.5;
				[[EAGLView sharedEAGLView] SetTranslate:m_initTouchLocation forType:CAMERA_CLOSE force:NO];
			}			
            break;
        }
        default:
        {
			l_touch = [[allTouches allObjects] objectAtIndex:0];
			l_touch2 = [[allTouches allObjects] objectAtIndex:1];
			// handle multi touch
			CGPoint l_touchPosition1 = [l_touch locationInView:m_glview];
			CGPoint l_touchPosition2 = [l_touch2 locationInView:m_glview];
			[l_applicationManager MultiTouchMove:l_touchPosition1 touch2:l_touchPosition2];
			
            break;
        }
	}
	m_hasMoved = TRUE;
}


//
//	Actions when we stop touching the screen
//	If the view except the head is touched, the wind vector is initialised and a sound is played in loop
//	Then the position of the rectangle containing the arrow head is updated
//
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch		*touch					=	[[event allTouches] anyObject];
	CGPoint		l_currentTouchLocation	=	[touch locationInView:m_glview];
	if(!m_hasMoved)
	{
		[[ApplicationManager sharedApplicationManager] SimpleClick:l_currentTouchLocation];
	}

	[[ApplicationManager sharedApplicationManager] TouchEnded:l_currentTouchLocation];
}

-(void)scale:(id)sender 
{	
//	[self.view bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
//	
//	if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) 
//	{
//		m_lastScale = 1.0;
//		return;
//	}
//	
//	CGFloat scale = 1.0 - (m_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
//	
//	[[EAGLView sharedEAGLView] MultiplyScale:scale force:YES];
//	m_lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

//
//	Double click on the view except the arrow head.
//	if the double click is on the attractor, we hide it and desactive his influence.
//	if the double click is elsewhere, we change its position and activate it.
//
-(void)DoubleClick:(UIEvent*)event
{
//	[self SetIngameInformationMode:[[EAGLView sharedEAGLView] SwitchCamera]];
}

// update spacie information while pause.
-(void)UpdatePauseInformation
{
//	LevelData l_levelData = [[LevelLoader sharedLevelLoader] GetLevelData];
//	SpacieStateCurrent l_spacieState = [[ParticleManager sharedParticleManager] GetStateOfGroup:m_selectedSpacie];
//	
//	NSString * l_string = [NSString stringWithFormat:@"%@ \nquantity : %d\nEvolution :\n %d members at the generation %d. Evolution at generation %d", 
//						   l_levelData.m_particleTable[m_selectedSpacie].m_name, 
//						   l_spacieState.m_quantity, 
//						   l_spacieState.m_numberOfGenerationMaxElement, 
//						   l_spacieState.m_generationMax, 
//						   [[ApplicationManager sharedApplicationManager] m_numberGenerationToMutate]];
//	[m_labelGameStateExplanation setText:l_string];
//	[m_labelGameStateExplanation sizeToFit];
//	CGSize l_contentSize = [m_labelGameStateExplanation bounds].size;
//	l_contentSize.height += 40;
//	[m_viewScrollInGameGUI setContentSize:l_contentSize];
}

// update the ingame label.
-(void)UpdateIngameInformations
{
	[self UpdateIngameInformations:-1];
}

// Switch the ingame information label on.
-(void)SetIngameInformationMode:(BOOL)a_isInformationMode
{
	[self performSelector:@selector(UpdateIngameInformations) withObject:nil afterDelay:0.7];
}

// Click on back to menu button.
-(IBAction)ClickBackToMenu
{
	[[ApplicationManager sharedApplicationManager] BackToMenu];
}

-(IBAction)ClickSkipSpeaking:(id)a_sender
{
	[[ApplicationManager sharedApplicationManager] SkipSpeaking];
}

- (void)dealloc 
{
    [super dealloc];
	[m_glview release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
