//
//  EAGLView.m
//  Particles
//
//  Created by Baptiste Bohelay on 1/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "MathTools.h"
#import "ApplicationManager.h"

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end

@implementation ElementState

@synthesize m_textureIndex;
@synthesize m_size;
@synthesize m_positionX;
@synthesize m_positionY;
@synthesize m_positionZ;
@synthesize m_degreeAngle;
@synthesize m_repeatNumber;
@synthesize m_widthOnHeigth;
@synthesize m_nightBlend;
@synthesize m_deformation;
@synthesize m_distance;
@synthesize m_alpha;
@synthesize m_decayX;
@synthesize m_decayY;
@synthesize m_planFX;
@synthesize m_reverseType;

@end

@implementation EAGLView

@synthesize context;
@synthesize m_isGhostMode;
@synthesize m_environmentSize;

const float ZOOM_MAX = 0.5;
const float CAMERA_TRANSLATE_SPEED_MAX = 1.09;
const float CAMERA_ZOOM_SPEED_MAX = 0.87;

// You must implement this method
+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

static EAGLView* _sharedEAGLView = nil;

//
// initialize if not done yet and return the object
//
+(EAGLView*)sharedEAGLView
{
	@synchronized([EAGLView class])
	{
		if (!_sharedEAGLView)
			[[self alloc] init];
		return _sharedEAGLView;
	}
	return nil;
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder 
{
    if ((self = [super initWithCoder:coder])) 
	{
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];        
        if (!context || ![EAGLContext setCurrentContext:context]) 
		{
            [self release];
            return nil;
        }        
    }
	
	[self setupView];
	_sharedEAGLView = self;
	
	m_texturesArray = [[NSMutableArray alloc] init];
	for(int i = 0; i < PLAN_NUMBER; i++)
	{
		[m_texturesArray addObject:[[NSMutableArray alloc] init]];
	}

	// Set the cameras settings.
	m_cameraTransformation[CAMERA_CLOSE].m_scale = 0.6f;
	m_cameraTransformation[CAMERA_CLOSE].m_xTranslate = 0.f;
	m_cameraTransformation[CAMERA_CLOSE].m_yTranslate = -0.2f;
	m_cameraTransformation[CAMERA_CLOSE].m_isGhost = FALSE;
	m_cameraTransformation[CAMERA_CLOSE].m_updatable = TRUE;
	
	m_cameraTransformation[CAMERA_LOSE].m_scale = 2.f;
	m_cameraTransformation[CAMERA_LOSE].m_xTranslate = 0.f;
	m_cameraTransformation[CAMERA_LOSE].m_yTranslate = 0.f;
	m_cameraTransformation[CAMERA_LOSE].m_isGhost = TRUE;
	m_cameraTransformation[CAMERA_LOSE].m_updatable = TRUE;
	
	m_cameraTransformation[CAMERA_PAUSE].m_scale = 2.5f;
	m_cameraTransformation[CAMERA_PAUSE].m_xTranslate = 0.f;
	m_cameraTransformation[CAMERA_PAUSE].m_yTranslate = 0.f;
	m_cameraTransformation[CAMERA_PAUSE].m_isGhost = TRUE;
	m_cameraTransformation[CAMERA_PAUSE].m_updatable = TRUE;
	
	m_cameraTransformation[CAMERA_GLOBAL].m_isGhost = TRUE;
	m_cameraTransformation[CAMERA_GLOBAL].m_updatable = FALSE;
	
	m_currentCamera = CAMERA_CLOSE;
	
    return self;
}

//
// init the specified level textures.
//
-(void)initLevel:(LevelData)a_level
{
	// loading the level datas.
	LevelData l_tempLevelData = a_level;
	NSString ** l_array = l_tempLevelData.m_textureArray;
	m_numTexture = l_tempLevelData.m_arraySize;
	textures = malloc(m_numTexture * sizeof(GLuint));
	for(int i = 0; i < m_numTexture; i++)
	{
        NSLog([NSString stringWithFormat:@"Texture %i not loaded.", i]);
		[self LoadTextureNamed:l_array[i] AtIndex:i];
	}
	
	m_scaleFactorEnd = 1.f;
	m_scaleFactorBegin = 1.f;
	m_sizeWall = l_tempLevelData.m_size;
	m_isGhostMode = FALSE;
	
	// Set the bounds of the screen.
	[self SetBounds:CGRectMake(-l_tempLevelData.m_size, l_tempLevelData.m_size, -l_tempLevelData.m_size * l_tempLevelData.m_widthOnHeigth, l_tempLevelData.m_widthOnHeigth * l_tempLevelData.m_size) forType:CAMERA_GLOBAL];
	[self SetBounds:CGRectMake(-l_tempLevelData.m_size, l_tempLevelData.m_size, -l_tempLevelData.m_size * l_tempLevelData.m_widthOnHeigth, l_tempLevelData.m_widthOnHeigth * l_tempLevelData.m_size) forType:CAMERA_PREVIOUS];
	m_environmentSize.y = l_tempLevelData.m_size;
	m_environmentSize.x = l_tempLevelData.m_size * l_tempLevelData.m_widthOnHeigth;
	
	m_blur = -1.f;
}

//
// load texture with name.
//
-(void)LoadTextureNamed:(NSString * )a_textureName AtIndex:(GLuint)a_index
{
	CGImageRef textureImage = [[UIImage imageNamed:a_textureName] CGImage];
	if (textureImage == nil) 
	{
		NSLog([NSString stringWithFormat:@"Texture %@ not loaded.", a_textureName]);
		return;
	}
	
	NSInteger textureWidth = CGImageGetWidth(textureImage);
	NSInteger textureHeight = CGImageGetHeight(textureImage);
	NSInteger bytesPerRow = CGImageGetBytesPerRow(textureImage);
	
	// un peu d'allocation dynamique de mémoire...
	GLubyte *textureData = (GLubyte *)malloc(bytesPerRow * textureHeight); // 4 car RVBA
	memset( textureData, 0, bytesPerRow * textureHeight);
	CGContextRef textureContext = CGBitmapContextCreate(
														textureData,
														textureWidth,
														textureHeight,
														CGImageGetBitsPerComponent(textureImage), bytesPerRow,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	
	CGContextDrawImage(textureContext,
					   CGRectMake(0.0, 0.0, (float)textureWidth, (float)textureHeight),
					   textureImage);
	
	CGContextRelease(textureContext);
	
	glGenTextures(1, &textures[a_index]);
	
	glBindTexture(GL_TEXTURE_2D, textures[a_index]);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureWidth, textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
}

-(void)setupView
{
	const GLfloat	zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
    GLfloat			size;
	
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);	
	// Return the Iphone sizes
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.height / rect.size.width), size / (rect.size.width / rect.size.height), zNear, zFar);
	
	// mélange, plus de plan glBlendFunc(GL_ONE, GL_ONE);
	// normal glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	// effet fantome glBlendFunc(GL_ONE_MINUS_SRC_COLOR, GL_ONE);
	// effet vitre (on voit a travers les couleurs) glBlendFunc(GL_ONE_MINUS_SRC_COLOR, GL_SRC_ALPHA);
	// jolie effet nuit glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA);
	// apparition de ce qu'il y a derriere, utile pour faire de la magie. glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_SRC_COLOR);
	// un peu pareil mais différent et sympa aussi.	glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable (GL_BLEND);
	glEnable(GL_ALPHA);
	
//	TODO: think about the light.
//	glEnable(GL_LIGHTING);
//	glEnable(GL_LIGHT0);
//	glEnable(GL_COLOR_MATERIAL);
//	const GLfloat l_light0Ambient[] = {0.01, 0.01, 0.01, 1.0};
//    glLightfv(GL_LIGHT0, GL_AMBIENT, l_light0Ambient);
//	const GLfloat light0Diffuse[] = {1., 1., 1., 1.0};
//    glLightfv(GL_LIGHT0, GL_DIFFUSE, light0Diffuse);
//	const GLfloat light0Specular[] = {0.3, 0.3, 0.3, 1.0};
//    glLightfv(GL_LIGHT0, GL_SPECULAR, light0Specular);
//	const GLfloat light0Position[] = {0.0, 0.0, 4.0, 0.0};  // 0.0 for omni 1. for spot light
//    glLightfv(GL_LIGHT0, GL_POSITION, light0Position);
//	const GLfloat light0Direction[] = {0.0, .0, -1.0};
//    glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, light0Direction);
//	glLightf(GL_LIGHT0, GL_SPOT_EXPONENT, 50);
//	glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 1.f);	
//	glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 95.0);
	
    glViewport(0, 0, rect.size.height, rect.size.width);	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

- (void)drawView
{    	
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    glLoadIdentity();

    glOrthof(-1.5f, 1.5f, -1.f, 1.f, -1.0f, 1.0f);
    glMatrixMode(GL_MODELVIEW);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); 
	
	if(m_cameraTransformation[m_currentCamera].m_isGhost)
	{
		glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA);
	}
	else
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);	
	}

	
	// draw all the containers.
	[self drawAll];
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (BOOL)createFramebuffer 
{
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) 
	{
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RGBA4_OES, depthRenderbuffer);
		glRenderbufferStorageOES(GL_RGBA4_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_RGBA4_OES, GL_DEPTH_ATTACHMENT_OES, GL_RGBA4_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
	{
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer 
{
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer		= 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer	= 0;
    
    if(depthRenderbuffer)
	{
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

//
//	creation of the circles (the number of vectrices must be flexible, to be improved)
//	then call OpenGL for the drowing
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

{
	[
		self drawTextureIndex:a_textureIndex 
						 plan:a_planIndex 
						 size:a_size 
					positionX:a_positionX 
					positionY:a_positionY 
					positionZ:a_positionZ 
				rotationAngle:a_degreeAngle 
			  rotationCenterX:a_rotationCenterX 
			  rotationCenterY:a_rotationCenterY 
				 repeatNumber:a_repeat 
				widthOnHeight:a_widthOnHeight 
				   nightBlend:false
				  deformation:a_deformation 
					 distance:a_distance
					   decayX:0.f
					   decayY:0.f
						alpha:1.f
					   planFX:-1
					  reverse:REVERSE_NONE
	 ];
}

//
//	creation of the circles (the number of vectrices must be flexible, to be improved)
//	then call OpenGL for the drowing
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
				 planFX:(int)a_planFX
				reverse:(ReverseType)a_reverseType
{
	int l_repeat = 1;
	float l_blurEffect = 0.f;
	if(m_blur > 0.f)
	{
		l_repeat = 5;
		l_blurEffect = m_blur;
		for(int i = 0; i < l_repeat; i++)
		{
			float l_angleX = cos(2 * M_PI * (float)i / (float)l_repeat);
			float l_angleY = sin(2 * M_PI * (float)i / (float)l_repeat);
			ElementState * l_newElement = [[[ElementState alloc] init] autorelease];
			l_newElement.m_textureIndex = a_textureIndex;
			l_newElement.m_size = a_size + 0.02 * l_blurEffect;
			l_newElement.m_positionX = a_positionX + 0.02 * (l_angleX + l_angleY) * l_blurEffect;
			l_newElement.m_positionY = a_positionY + 0.03 * l_angleY * l_blurEffect;
			l_newElement.m_positionZ = a_positionZ;
			l_newElement.m_degreeAngle = a_degreeAngle;
			l_newElement.m_repeatNumber = a_repeat;
			l_newElement.m_widthOnHeigth = a_widthOnHeight;
			l_newElement.m_nightBlend = a_nightBlend;
			l_newElement.m_deformation = a_deformation;
			l_newElement.m_distance	= a_distance;
			l_newElement.m_alpha = (float)1.3f / (float)l_repeat;	
			l_newElement.m_decayX = a_decayX;	
			l_newElement.m_decayY = a_decayY;	
			l_newElement.m_planFX = a_planFX;
			l_newElement.m_reverseType = a_reverseType;	
			[[m_texturesArray objectAtIndex:a_planIndex] addObject:l_newElement];
		}
	}
	
	ElementState * l_newElement = [[[ElementState alloc] init] autorelease];
	l_newElement.m_textureIndex = a_textureIndex;
	l_newElement.m_size = a_size + 0.03 * l_blurEffect;
	l_newElement.m_positionX = a_positionX + 0.02;
	l_newElement.m_positionY = a_positionY + 0.03;
	l_newElement.m_positionZ = a_positionZ;
	l_newElement.m_degreeAngle = a_degreeAngle;
	l_newElement.m_repeatNumber = a_repeat;
	l_newElement.m_widthOnHeigth = a_widthOnHeight;
	l_newElement.m_nightBlend = a_nightBlend;
	l_newElement.m_deformation = a_deformation;
	l_newElement.m_distance = a_distance;
	l_newElement.m_alpha = a_alpha;
	l_newElement.m_decayX = a_decayX;	
	l_newElement.m_decayY = a_decayY;
	l_newElement.m_planFX = a_planFX;
	l_newElement.m_reverseType = a_reverseType;	
	[[m_texturesArray objectAtIndex:a_planIndex] addObject:l_newElement];
}

-(void)drawTextureIndex:(GLuint)a_textureIndex
				   plan:(PlanIndex)a_planIndex
				   size:(GLfloat)a_size
			  positionX:(GLfloat)a_positionX 
			  positionY:(GLfloat)a_positionY
			  positionZ:(GLfloat)a_positionZ
			   distance:(float)a_distance
{
	[self drawTextureIndex:a_textureIndex plan:a_planIndex size:a_size positionX:a_positionX positionY:a_positionY positionZ:a_positionZ 
			 rotationAngle:0. rotationCenterX:0. rotationCenterY:0. repeatNumber:1 widthOnHeight:1.f nightBlend:false deformation:0.f distance:a_distance];
}

-(void)drawTextureIndex:(GLuint)a_textureIndex
				   plan:(PlanIndex)a_planIndex
				   size:(GLfloat)a_size
			  positionX:(GLfloat)a_positionX 
			  positionY:(GLfloat)a_positionY
			  positionZ:(GLfloat)a_positionZ
		   repeatNumber:(int)a_repeatNumber
		  widthOnHeight:(float)a_widthOnHeight
			   distance:(float)a_distance
{
	[self drawTextureIndex:a_textureIndex 
					  plan:a_planIndex 
					  size:a_size 
				 positionX:a_positionX 
				 positionY:a_positionY 
				 positionZ:a_positionZ 
			 rotationAngle:0. 
		   rotationCenterX:0. 
		   rotationCenterY:0. 
			  repeatNumber:a_repeatNumber 
			 widthOnHeight:a_widthOnHeight 
				nightBlend:false 
			   deformation:0.f 
				  distance:a_distance 
					decayX:0.
					decayY:0.
					 alpha:1.f
					planFX:-1
				   reverse:REVERSE_NONE
	 ];
}

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
				 decayY:(float)a_decayY
{
	[self drawTextureIndex:a_textureIndex 
					  plan:a_planIndex 
					  size:a_size 
				 positionX:a_positionX 
				 positionY:a_positionY 
				 positionZ:a_positionZ 
			 rotationAngle:0. 
		   rotationCenterX:0. 
		   rotationCenterY:0. 
			  repeatNumber:a_repeatNumber 
			 widthOnHeight:a_widthOnHeight 
				nightBlend:false 
			   deformation:0.f 
				  distance:a_distance 
					decayX:a_decayX
					decayY:a_decayY
					 alpha:1.f
					planFX:-1
				   reverse:REVERSE_NONE
	 ];
}

-(void)drawAll
{	
	//NSArray * l_tempArray;	
	ElementState * l_elementState;
	GLuint  l_textureIndex;
	GLfloat l_size, l_positionX, l_positionY, l_positionZ, l_degreeAngle;
	int l_repeatNumber;
	BOOL l_resize;
	float l_widthOnHeigth;
	BOOL l_nightBlend;
	float l_deformation;
	float l_distance;
	float l_alpha;
	GLfloat l_decayX;
	GLfloat l_decayY;
	ReverseType l_reverseType;

	float l_farCoeff;
	float l_usedFarCoeff;
	// We iterate from the end because the last plan must be drawn first.
	for(int l = PLAN_NUMBER - 1; l >= 0; l--)
	{
		l_farCoeff = (float)l/((float)PLAN_NUMBER - 1.f);
		l_resize = TRUE;
		if((l == PLAN_BACKGROUND_CLOSE) || (l == PLAN_BACKGROUND_SHADOW) || (l == PLAN_BACKGROUND) || (l == PLAN_BACKGROUND_MIDDLE))
		{
			l_resize = FALSE;
		}
		
		NSSortDescriptor * sortByDistance = [[[NSSortDescriptor alloc] initWithKey:@"m_distance" ascending:YES] autorelease];
		NSArray * descriptors = [NSArray arrayWithObject:sortByDistance];
		NSArray * l_tempArray = [[m_texturesArray objectAtIndex:l] sortedArrayUsingDescriptors:descriptors];	
		
		int l_arraySize = [l_tempArray  count];

		for(int i = l_arraySize - 1; i >= 0 ; i--)
		{
            // get all the settings of the texture.
			l_elementState = [l_tempArray objectAtIndex:i];
			l_textureIndex = [l_elementState m_textureIndex];
			l_usedFarCoeff = ([[l_tempArray objectAtIndex:i] m_planFX] < 0) ? l_farCoeff : (float)[[l_tempArray objectAtIndex:i] m_planFX] / (float)(PLAN_NUMBER - 1.f);
			l_positionX = [l_elementState m_positionX] - (l_usedFarCoeff * m_cameraTransformation[CAMERA_PREVIOUS].m_xTranslate);
			l_positionY = [l_elementState m_positionY] - (l_usedFarCoeff * m_cameraTransformation[CAMERA_PREVIOUS].m_yTranslate);
			l_positionZ = 0.1f;
			l_degreeAngle = [l_elementState m_degreeAngle];		
			l_repeatNumber = [l_elementState m_repeatNumber];
			l_widthOnHeigth = [l_elementState m_widthOnHeigth];
			l_size = [[l_tempArray objectAtIndex:i] m_size];
			l_nightBlend = [[l_tempArray objectAtIndex:i] m_nightBlend];
			l_deformation = [[l_tempArray objectAtIndex:i] m_deformation];
			l_distance = [[l_tempArray objectAtIndex:i] m_distance];
			
            // set the luminosity with the distance coefficient.
			if(l_distance > 0.)
				l_distance = clip(((50 - l_distance) / 50.), 0.f, 1.f);
			else
				l_distance = 1.f;
			l_alpha = [[l_tempArray objectAtIndex:i] m_alpha];
			l_decayX = [[l_tempArray objectAtIndex:i] m_decayX];
			l_decayY = [[l_tempArray objectAtIndex:i] m_decayY];
			l_reverseType = [[l_tempArray objectAtIndex:i] m_reverseType];
			
            // resize the texture, if the world isn't flat.
			if (l_resize)
			{
				l_size = l_size * (m_scaleFactorBegin + (l_positionX + m_sizeWall) / (2. * m_sizeWall) * (m_scaleFactorEnd - m_scaleFactorBegin));
			}
			
			// square definition.
			const GLfloat SQUARE_TEXTURE_VECTRICE[] = 
			{
				-l_widthOnHeigth * l_size * (1. + l_deformation), l_size, l_positionZ,            // Haut gauche
				-l_widthOnHeigth * l_size, -l_size, l_positionZ,           // Bas gauche
				l_widthOnHeigth * l_size, -l_size, l_positionZ,            // Bas droit
				l_widthOnHeigth * l_size * (1. - l_deformation), l_size, l_positionZ              // Haut droit
			};
			
            // texture position in the square.
			GLfloat SQUARE_TEXTURE_COORD[] = 
			{
				0. + l_decayX, 0 + l_decayY,									// Up left.
				0. + l_decayX, l_repeatNumber + l_decayY,						// Down left.
				l_repeatNumber + l_decayX, l_repeatNumber + l_decayY,			// Down right.
				l_repeatNumber + l_decayX, 0 + l_decayY							// Up right.
			};
			
            // update texture position if it has to be reversed.
			switch(l_reverseType)
			{
				case REVERSE_HORIZONTAL:
					SQUARE_TEXTURE_COORD[0] = l_repeatNumber + l_decayX;
					SQUARE_TEXTURE_COORD[1] = l_decayY;
					SQUARE_TEXTURE_COORD[2] = l_repeatNumber + l_decayX;
					SQUARE_TEXTURE_COORD[3] = l_repeatNumber + l_decayY;
					SQUARE_TEXTURE_COORD[4] = l_decayX;
					SQUARE_TEXTURE_COORD[5] = l_repeatNumber + l_decayY;
					SQUARE_TEXTURE_COORD[6] = l_decayX;
					SQUARE_TEXTURE_COORD[7] = l_decayY;
					break;
				default:
					break;
			}

			glLoadIdentity();

            // apply the camera.
			glScalef(m_cameraTransformation[CAMERA_PREVIOUS].m_scale, m_cameraTransformation[CAMERA_PREVIOUS].m_scale, 1.);
			glTranslatef(m_cameraTransformation[CAMERA_PREVIOUS].m_xTranslate, m_cameraTransformation[CAMERA_PREVIOUS].m_yTranslate, 0.f);
			
            // change the blend function if needed.
			if(l_nightBlend)
			{
				glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA);
			}
			else
			{
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);	
			}
			
			glBindTexture(GL_TEXTURE_2D, textures[l_textureIndex]);
			glEnable(GL_TEXTURE_2D);
			glColor4f(m_luminosity * l_distance, m_luminosity * l_distance, m_luminosity * l_distance, l_alpha); // nouvelle ligne
			
			glTranslatef(l_positionX, l_positionY, 0.);
			glRotatef (l_degreeAngle, 0.f, 0.f, 0.1f);
			glVertexPointer(3, GL_FLOAT, 0, SQUARE_TEXTURE_VECTRICE);
			float const l_normal[] = {0., 0., 1.};
			
			glNormalPointer(GL_FLOAT, 0, l_normal);
			glEnableClientState(GL_VERTEX_ARRAY);
			glTexCoordPointer(2, GL_FLOAT, 0, SQUARE_TEXTURE_COORD);     // nouvelle ligne
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);                // nouvelle ligne
			glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);               // nouvelle ligne
		}
	
		[[m_texturesArray objectAtIndex:l] removeAllObjects];
	}
}

//
// Set the bounds of a camera.
//
-(void)SetBounds:(CGRect)a_rect forType:(Camera)a_type
{
	float l_scale =  max( 3.f /( a_rect.origin.y - a_rect.origin.x), 2.f /( a_rect.size.height - a_rect.size.width));
	m_cameraTransformation[a_type].m_scale = max(ZOOM_MAX, l_scale);
	float l_scaleRatio = l_scale / m_cameraTransformation[a_type].m_scale;
	m_cameraTransformation[a_type].m_xTranslate = -l_scaleRatio * ( a_rect.origin.x + a_rect.origin.y) / 2.f;
	m_cameraTransformation[a_type].m_yTranslate = -l_scaleRatio * (a_rect.size.width + a_rect.size.height) / 2.f;
}

//
// Set the translate parameter of a camera.
//
-(void)SetTranslate:(CGPoint)a_translate forType:(Camera)a_type force:(BOOL)a_force
{
	if(!m_cameraTransformation[a_type].m_updatable)
	{
		return;
	}
	if(!a_force)
	{
		float l_scale = m_cameraTransformation[a_type].m_scale;
		float l_limiteX = m_environmentSize.x - (1.52 / l_scale);
		float l_limiteY = m_environmentSize.y - (1.02f / l_scale);
		if(a_translate.x > l_limiteX)
		{
			a_translate.x = l_limiteX;
		}
		else if(a_translate.x < -l_limiteX)
		{
			a_translate.x = -l_limiteX;
		}
		if(a_translate.y > l_limiteY)
		{
			a_translate.y = l_limiteY;
		}
		else if(a_translate.y < -l_limiteY)
		{
			a_translate.y = -l_limiteY;
		}
		
		m_cameraTransformation[a_type].m_xTranslate = -a_translate.x;
		m_cameraTransformation[a_type].m_yTranslate = -a_translate.y;

	}
	else
	{
		m_cameraTransformation[CAMERA_PREVIOUS].m_xTranslate = m_cameraTransformation[a_type].m_xTranslate = a_translate.x;
		m_cameraTransformation[CAMERA_PREVIOUS].m_yTranslate = m_cameraTransformation[a_type].m_yTranslate = a_translate.y;
	}
}

//
// Set the scale parameter of a camera.
//
-(void)SetScale:(float)a_scale force:(BOOL)a_force
{
	if(m_currentCamera == CAMERA_CLOSE && m_cameraTransformation[CAMERA_CLOSE].m_updatable)
	{
		m_cameraTransformation[CAMERA_CLOSE].m_scale = a_scale;
		m_cameraTransformation[CAMERA_CLOSE].m_scale = (m_cameraTransformation[CAMERA_CLOSE].m_scale < (1.f /  m_environmentSize.y)) ? 1.f /  m_environmentSize.y : m_cameraTransformation[CAMERA_CLOSE].m_scale;
		m_cameraTransformation[CAMERA_CLOSE].m_scale = (m_cameraTransformation[CAMERA_CLOSE].m_scale < (1.5f /  m_environmentSize.x)) ? 1.5f /  m_environmentSize.x : m_cameraTransformation[CAMERA_CLOSE].m_scale;	
		if(a_force)
		{
			m_cameraTransformation[CAMERA_PREVIOUS].m_scale = m_cameraTransformation[CAMERA_CLOSE].m_scale;
		}
		[self SetTranslate:CGPointMake(m_cameraTransformation[CAMERA_CLOSE].m_xTranslate, m_cameraTransformation[CAMERA_CLOSE].m_yTranslate) forType:CAMERA_CLOSE force:NO];
	}
}

//
// return the current camera settings.
//
-(ScreenTransformation)GetCameraTransformation
{
	return m_cameraTransformation[CAMERA_PREVIOUS];
}

//
// Set the scale parameter of a camera.
//
-(void)MultiplyScale:(float)a_scale force:(BOOL)a_force
{
	[self SetScale:m_cameraTransformation[m_currentCamera].m_scale * a_scale force:a_force];
}

//
// Set the camera following interactive or not.
//
-(void)SetCameraUpdatable:(BOOL)a_updatable
{
	m_cameraTransformation[m_currentCamera].m_updatable = a_updatable;
}

// Define the camera.
// Return true if the camera is the general one.
-(BOOL)SwitchCamera
{
	m_currentCamera++;
	m_currentCamera = (m_currentCamera > CAMERA_GLOBAL) ? CAMERA_CLOSE : m_currentCamera;
	return (m_currentCamera == CAMERA_GLOBAL);
}

// Set the camera
-(void)SetCamera:(Camera)a_camera
{
	m_currentCamera = a_camera;
}


//
// Update the camera, smooth its settings.
//
- (void)UpdateCameraWithTimeInterval:(float)a_timeInterval
{
	if (!m_cameraTransformation[CAMERA_CLOSE].m_updatable) 
	{
		return;
	}
	
	ScreenTransformation l_tempScreenTransformation = m_cameraTransformation[m_currentCamera];
	float l_scaleForPerspective = 1.f;

	float l_scaleSpeedMax = CAMERA_ZOOM_SPEED_MAX;
	float l_speedMax = CAMERA_TRANSLATE_SPEED_MAX;
	NSTimeInterval	l_animationInterval = a_timeInterval;
	float l_scaleRatio = clip((l_tempScreenTransformation.m_scale * l_scaleForPerspective) / m_cameraTransformation[CAMERA_PREVIOUS].m_scale, 1.f - l_animationInterval * l_scaleSpeedMax, 1.f + l_animationInterval * l_scaleSpeedMax);
	float l_xSpeed = -min(Absf((m_cameraTransformation[CAMERA_PREVIOUS].m_xTranslate - l_tempScreenTransformation.m_xTranslate) / l_animationInterval), l_speedMax);
	float l_xSign = ((m_cameraTransformation[CAMERA_PREVIOUS].m_xTranslate - l_tempScreenTransformation.m_xTranslate) < 0.f) ? -1.f : 1.f;
	float l_ySpeed = -min(Absf((m_cameraTransformation[CAMERA_PREVIOUS].m_yTranslate - l_tempScreenTransformation.m_yTranslate) / l_animationInterval), l_speedMax);
	float l_ySign = ((m_cameraTransformation[CAMERA_PREVIOUS].m_yTranslate - l_tempScreenTransformation.m_yTranslate) < 0.f) ? -1.f : 1.f;
	l_tempScreenTransformation.m_scale = l_scaleRatio * m_cameraTransformation[CAMERA_PREVIOUS].m_scale;
	l_tempScreenTransformation.m_xTranslate = m_cameraTransformation[CAMERA_PREVIOUS].m_xTranslate + l_xSpeed * l_animationInterval * l_xSign;
	l_tempScreenTransformation.m_yTranslate = m_cameraTransformation[CAMERA_PREVIOUS].m_yTranslate + l_ySpeed * l_animationInterval * l_ySign;
	
	m_cameraTransformation[CAMERA_PREVIOUS] = l_tempScreenTransformation;	
}

//
// Set the blur coefficient.
//
-(void)SetBlur:(float)a_blur
{
	m_blur = a_blur;
}

//
// Set the amount of luminosity. O for dark, 1 for full light.
//
-(void)SetLuminosity:(float)a_luminosity
{
	m_luminosity = a_luminosity;
}

//
// return the luminosity coefficient. O for dark, 1 for full light.
//
-(float)GetLuminosity
{
	return m_luminosity;
}

//
// Reset OpenGL, free the texture container.
//
-(void)Reset
{
	glDeleteTextures(m_numTexture, &textures[0]);

	free(textures);
}

//
// dealloc.
//
- (void)dealloc
{    
    if ([EAGLContext currentContext] == context) 
	{
        [EAGLContext setCurrentContext:nil];
    }
    [context release];  
	int l_textureArrayCount = [m_texturesArray count];
	for(int i = l_textureArrayCount - 1; i >= 0; i++)
	{
		[[m_texturesArray objectAtIndex:i] dealloc];
	}
	[m_texturesArray dealloc];
    [super dealloc];
}

@end
