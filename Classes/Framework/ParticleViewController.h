#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class EAGLView;

@interface ParticleViewController :UIViewController <UIAccelerometerDelegate >
{	
	IBOutlet EAGLView		*m_glview;				// View that manage the OpenGL interface
	IBOutlet UIButton		*m_buttonSkipSpeak;		// Stop speaking when clicked.
	IBOutlet UIImageView	*m_helpImage;				// label.
	IBOutlet UIImageView	*m_helpView;			// Help image.

	IBOutlet UIImageView	*m_backBaptisteImageView;	// View containing all ingame game state presentation.
	
	IBOutlet UITextView		*m_noteBookTextView;
	IBOutlet UITextView		*m_noteBookTextViewDate;
	
	NSMutableArray			*imageArray;			// array used as a container for images animation
	CGPoint					m_initTouchLocation;	// position of the finger when it touched the screen before moving
	CGRect					m_ArrowHeadDomain;		// domain representing the head, used to know if we touch the head or not
	float					m_ArrowAngle;			// orientation of the arrow (in radian)
	NSTimeInterval			m_TimeAtLastClick;		// tick of the last click, used to know if it's a double click or not
	NSMutableArray			*m_ViewArray;			// array containing the attractor views
	UIImageView				*m_AttractorTouched;	// attractor touched (nil if none);
	NSUInteger				m_lastAttractorViewMoved;	// index of the last attractor view moved
	BOOL					m_hasMoved;				// if true, the actual click is moving (do not considere it as a click).
	BOOL					m_pause;				// if true, the game is in pause mode.
	int						m_selectedSpacie;		// index of the selected particle.
	
	float					m_lastScale;			// last scale.
	NSTimeInterval			m_timeLastShake;
}

@property (nonatomic, retain) IBOutlet	EAGLView	*m_glview;

@property (nonatomic, retain) IBOutlet	UIButton	*m_buttonSkipSpeak;
@property (nonatomic, retain) IBOutlet	UIImageView	*m_helpImage;
@property (nonatomic, retain) IBOutlet	UIImageView	*m_helpView;
@property (nonatomic, retain) IBOutlet	UIImageView	*m_backBaptisteImageView;

@property (nonatomic, retain) IBOutlet  UITextView	*m_noteBookTextView;
@property (nonatomic, retain) IBOutlet  UITextView	*m_noteBookTextViewDate;

// User click back to menu.
-(IBAction)ClickBackToMenu;
// Double click event.
-(void)DoubleClick:(UIEvent*)event;
// Remove all view controller elements except GLView.
-(void)RemoveGUI;
// Skip the speaking click.
-(IBAction)ClickSkipSpeaking:(id)a_sender;
// update the ingame label.
// a_groupIndexChanged : index of the group where occured the change.
-(void)UpdateIngameInformations:(int)a_groupIndexChanged;
// update spacie information while pause.
-(void)UpdatePauseInformation;
// Switch the ingame information label on.
-(void)SetIngameInformationMode:(BOOL)a_isInformationMode;
// initialize if not done yet and return the object
+(ParticleViewController*)sharedParticleViewController;

@end
