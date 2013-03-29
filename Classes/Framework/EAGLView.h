//
//  EAGLView.h
//  Particles
//
//  Created by Baptiste Bohelay on 1/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "State.h"

/*
This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
The view content is basically an EAGL surface you render your OpenGL scene into.
Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
*/
@class ApplicationManager;

// plan enumeration
typedef enum EnumReverseType
{ 
	REVERSE_NONE,
	REVERSE_VERTICAL,
	REVERSE_HORIZONTAL,
	REVERSE_COUNT,
}ReverseType;

// plan enumeration
// from the closest, to the furthest.
typedef enum EnumPlanIndex
{ 
	PLAN_BACKGROUND_SHADOW,
	PLAN_BACKGROUND_CLOSE,
	PLAN_PARTICLE_FRONT,
	PLAN_PENDULUM,
	PLAN_BACKGROUND_MIDDLE,
	PLAN_PARTICLE_BEHIND,
	PLAN_SKY_SHADOW,
	PLAN_BACKGROUND_STICKERS,
	PLAN_BACKGROUND,
	PLAN_NUMBER
}PlanIndex;

// Cameras enumeration.
// CAMERA_CLOSE     : Camera close to the snake.
// CAMERA_GLOBAL    : Camera wich takes the bigest space.
// CAMERA_LOSE      : Camera when we lose.
// CAMERA_PAUSE     : Camera when pause.
// CAMERA_PREVIOUS  : previous camera.
// CAMERA_NUMBE     : number of camera.
typedef enum EnumScreenTransformation
{ 
	CAMERA_CLOSE,
	CAMERA_GLOBAL,
	CAMERA_LOSE,
	CAMERA_PAUSE,
	CAMERA_PREVIOUS,
	CAMERA_NUMBER
}Camera;

// describe the openGL texture element.
//m_textureIndex    : index of the texture.
//m_size            : size.
//m_positionX       : x position.
//m_positionY       : y position.
//m_positionZ       : z position.
//m_degreeAngle     : angle.
//m_repeatNumber    : number of time the pattern have to be repeated.
//m_widthOnHeigth   : width on height ratio.
//m_nightBlend      : if true, the texture will use the "night blend".
//m_deformation     : lean ratio of the texture.
//m_distance        : distance-> luminosity.
//m_alpha           : transparency.
//m_decayX          : x decay of the texture in the rectangle (will be wraped).
//m_decayY          : y decay of the texture in the rectangle (will be wraped).
//m_planFX          : shot index, for the camera movement distance effect.
//m_reverseType     : reverse the texture, vertically or horizontally.
@interface ElementState : NSObject 
{
@private
	GLuint m_textureIndex;
	GLfloat m_size;
	GLfloat m_positionX; 
	GLfloat m_positionY;
	GLfloat m_positionZ;
	GLfloat m_degreeAngle;
	int		m_repeatNumber;
	float	m_widthOnHeigth;
	BOOL	m_nightBlend;
	float   m_deformation;
	float	m_distance;
	GLfloat m_alpha;
	GLfloat m_decayX;
	GLfloat m_decayY;
	int		m_planFX;
	ReverseType m_reverseType;
}

@property GLuint m_textureIndex;
@property GLfloat m_size;
@property (readwrite) GLfloat m_positionX;
@property GLfloat m_positionY;
@property GLfloat m_positionZ;
@property GLfloat m_degreeAngle;
@property int m_repeatNumber;
@property float	m_widthOnHeigth;
@property BOOL m_nightBlend;
@property float m_deformation;
@property float m_distance;
@property GLfloat m_alpha;
@property GLfloat m_decayX;
@property GLfloat m_decayY;
@property int m_planFX;
@property ReverseType m_reverseType;

@end

// Camera settings.
// m_scale      : scale
// m_xTranslate : x translate.
// m_yTranslate : y translate.
// m_isGhost    : is true, we will use the ghost blending function.
// m_updatable  : if true, the camera will be updated when moving.
typedef struct ScreenTrans
{
	float m_scale;
	float m_xTranslate;
	float m_yTranslate;
	BOOL  m_isGhost;
	BOOL  m_updatable;
} ScreenTransformation;


@interface EAGLView : UIView 
{    
@private
	 
	/* The pixel dimensions of the backbuffer */
    GLint				backingWidth;
    GLint				backingHeight;
    
    EAGLContext			*context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint				viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint				depthRenderbuffer;
    	
	GLuint				*textures;				// Texture
	int					m_numTexture;
	
	NSMutableArray *m_texturesArray;
	
	// position of the head of the pendulum.
	ScreenTransformation m_cameraTransformation[CAMERA_NUMBER];

	// Set the actual camera.
	Camera m_currentCamera;
	
	// Background variables.
	// factor of scaling of the elements when at 1.5f from x.
	float m_scaleFactorBegin;
	float m_scaleFactorEnd;
	float m_sizeWall;
	CGPoint m_environmentSize;
	
	BOOL	m_isGhostMode;  // if true, the blend function will change.
	float	m_blur;         // blur amount.
	float	m_luminosity;   // luminosity amount.
}

@property BOOL m_isGhostMode;
@property CGPoint m_environmentSize;

// the class is a singleton, we use this method to get the object
+(EAGLView*)sharedEAGLView;						

//
// init the specified level textures.
//
-(void)initLevel:(LevelData)a_level;

//
//  Setup the view.
//
- (void)setupView;

//
//  Draw the view.
//
- (void)drawView;

//
// Load a texture.
//
-(void)LoadTextureNamed:(NSString * )a_textureName AtIndex:(GLuint)a_index;

//
// draw the loaded texture at the specified position and rotation.
//
-(void)drawTextureIndex:(GLuint)a_textureIndex
				   plan:(PlanIndex)a_planIndex
				   size:(GLfloat)a_size
			  positionX:(GLfloat)a_positionX 
			  positionY:(GLfloat)a_positionY
			  positionZ:(GLfloat)a_positionZ
		  rotationAngle:(GLfloat)a_degreeAngle
		rotationCenterX:(GLfloat)a_rotationCenterX
		rotationCenterY:(GLfloat)a_rotationCenterY
		   repeatNumber:(int)a_repeat
		  widthOnHeight:(float)a_widthOnHeight
			 nightBlend:(BOOL)a_nightBlend
			deformation:(float)a_deformation
			   distance:(float)a_distance
				 decayX:(float)a_decayX
				 decayY:(float)a_decayY
				  alpha:(float)a_alpha
				 planFX:(int)m_planFX
				reverse:(ReverseType)a_reverseType;

//
// draw the loaded texture at the specified position and rotation.
//
-(void)drawTextureIndex:(GLuint)a_textureIndex
				   plan:(PlanIndex)a_planIndex
				   size:(GLfloat)a_size
			  positionX:(GLfloat)a_positionX 
			  positionY:(GLfloat)a_positionY
			  positionZ:(GLfloat)a_positionZ
		  rotationAngle:(GLfloat)a_degreeAngle
		rotationCenterX:(GLfloat)a_rotationCenterX
		rotationCenterY:(GLfloat)a_rotationCenterY
		   repeatNumber:(int)a_repeat
		  widthOnHeight:(float)a_widthOnHeight
			 nightBlend:(BOOL)a_nightBlend
			deformation:(float)a_deformation
			   distance:(float)a_distance;

//
// draw texture without rotation.
//
-(void)drawTextureIndex:(GLuint)a_textureIndex
				   plan:(PlanIndex)a_planIndex
				   size:(GLfloat)a_size
			  positionX:(GLfloat)a_positionX 
			  positionY:(GLfloat)a_positionY
			  positionZ:(GLfloat)a_positionZ
		   repeatNumber:(int)a_repeatNumber
		  widthOnHeight:(float)a_widthOnHeight
			   distance:(float)a_distance;

//
// Same method as the previous one, with default rotation and repeat parameters.
//
-(void)drawTextureIndex:(GLuint)a_textureIndex 
				   plan:(PlanIndex)a_planIndex 
				   size:(GLfloat)a_size
			  positionX:(GLfloat)a_positionX 
			  positionY:(GLfloat)a_positionY
			  positionZ:(GLfloat)a_positionZ
			   distance:(float)a_distance;

-(void)drawTextureIndex:(GLuint)a_textureIndex
				   plan:(PlanIndex)a_planIndex
				   size:(GLfloat)a_size
			  positionX:(GLfloat)a_positionX 
			  positionY:(GLfloat)a_positionY
			  positionZ:(GLfloat)a_positionZ
		   repeatNumber:(int)a_repeatNumber
		  widthOnHeight:(float)a_widthOnHeight
			   distance:(float)a_distance
				 decayX:(float)a_decayX
				 decayY:(float)a_decayY;

//
// draw all register elements.
//
-(void)drawAll;

//
// Set the bounds of a camera.
//
-(void)SetBounds:(CGRect)a_rect forType:(Camera)a_type;

//
// Set the translate parameter of a camera.
//
-(void)SetTranslate:(CGPoint)a_translate forType:(Camera)a_type force:(BOOL)a_force;

//
// Set the scale parameter of a camera.
//
-(void)SetScale:(float)a_scale force:(BOOL)a_force;

//
// multiply the current scale by a factor.
//
-(void)MultiplyScale:(float)a_scale force:(BOOL)a_force;

//
// Define the camera.
// Return true if the camera is the general one.
//
-(BOOL)SwitchCamera;

//
// Set the camera
//
-(void)SetCamera:(Camera)a_camera;

//
// Update the camera.
//
- (void)UpdateCameraWithTimeInterval:(float)a_timeInterval;

//
// Return the actual screen transformation.
//
-(ScreenTransformation)GetCameraTransformation;

//
// Reset OpenGL, free the texture container.
//
-(void)Reset;

//
// Set the blur coefficient.
//
-(void)SetBlur:(float)a_blur;

//
// Set the camera following interactive or not.
//
-(void)SetCameraUpdatable:(BOOL)a_updatable;

//
// Set the amount of luminosity. O for dark, 1 for full light.
//
-(void)SetLuminosity:(float)a_luminosity;

//
// return the luminosity coefficient. O for dark, 1 for full light.
//
-(float)GetLuminosity;

@end
