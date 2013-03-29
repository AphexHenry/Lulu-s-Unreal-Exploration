//
//  MathTools.h
//  Particles
//
//  Created by Baptiste Bohelay on 1/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#import <OpenGLES/EAGL.h>
//#import <OpenGLES/ES1/gl.h>
//#import <OpenGLES/ES1/glext.h>

#import "EAGLView.h"

#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)
#define EPSILON 0.00000001

#pragma mark -
#pragma mark Vertex3D
#pragma mark -

static inline CGPoint Vector2DMake(CGFloat inX, CGFloat inY)
{
	CGPoint	ret;
	ret.x =		inX;
	ret.y =		inY;
	return		ret;
}

//
// Generates float from -1.0 to 1.0 for calculating random variance
//
static inline float myRandom()
{
	return ((float)(arc4random() % 200) / 100.0) - 1.0;
}

//
// Convert radian to degree.
//
static inline float RADIAN_TO_DEDREE(float a_radianAngle)
{
	return (a_radianAngle / M_PI) * 180.f;
}

//
//  Transform 0 to 1, and 1 to 0.
//
static inline int SWITCH(int a_value)
{
	return (a_value + 1) % 2;
}

//
//  return the max value, between two values.
//
static inline float max(float a_valueOne, float a_valueTwo)
{
	return (a_valueOne > a_valueTwo) ? a_valueOne : a_valueTwo;
}

//
//  return the min value, between two values.
//
static inline float min(float a_valueOne, float a_valueTwo)
{
	return (a_valueOne > a_valueTwo) ? a_valueTwo : a_valueOne;
}

//
//  clip a value.
//
static inline float clip(float a_value, float a_valueMin, float a_valueMax)
{
	return min(max(a_valueMin, a_value), a_valueMax);
}

// Generates float from -1.0 to 1.0 for calculating random variance
static inline float GetNorm(CGPoint a_point)
{
	return sqrt(a_point.x * a_point.x + a_point.y * a_point.y);
}

//
// return the square of the distance between two givent points.
//
static inline float DistancePointSquare(CGPoint a_pointOne,CGPoint a_pointTwo)
{
	return (pow(a_pointOne.x - a_pointTwo.x, 2) + pow(a_pointOne.y - a_pointTwo.y, 2));
}

// return the square of the distance between two givent points.
static inline float DistancePoint(CGPoint a_pointOne,CGPoint a_pointTwo)
{
	return (sqrt(DistancePointSquare(a_pointOne, a_pointTwo)));
}

//
// return the square of the distance between two givent points.
//
static inline float Absf(float a_value)
{
	return (a_value < 0.f) ? -a_value : a_value;
}

//
// convert GL coordonates into pixel coordonates.
//
static inline CGPoint GLToPixel(CGPoint a_GLCoord)
{
	UIScreen* mainscr = [UIScreen mainScreen];
	int m_w = mainscr.bounds.size.width;
	int m_h = mainscr.bounds.size.height;
	ScreenTransformation l_cameraTransformation = [[EAGLView sharedEAGLView] GetCameraTransformation];
	a_GLCoord.x = m_h * (((a_GLCoord.x + l_cameraTransformation.m_xTranslate) * l_cameraTransformation.m_scale) + 1.5) / 3.; //((a_GLCoord.x + l_sizeWall.x + (l_cameraTransformation.m_scale * l_cameraTransformation.m_xTranslate)) / (l_sizeWall.x)) * m_h;
	a_GLCoord.y = m_w - m_w * (((a_GLCoord.y + l_cameraTransformation.m_yTranslate) * l_cameraTransformation.m_scale) + 1.) / 2.;
	return a_GLCoord;
}

//
// convert pixel coordonates into GL coordonates.
//
static inline CGPoint PixelToGL(CGPoint a_GLCoord)
{
	UIScreen* mainscr = [UIScreen mainScreen];
	int m_w = mainscr.bounds.size.width;
	int m_h = mainscr.bounds.size.height;
	a_GLCoord.x = (a_GLCoord.x / m_h) * 3.f - 1.5f;
	a_GLCoord.y = -((a_GLCoord.y / m_w) * 2.f - 1.f);
	
	return a_GLCoord;
}

static inline CGPoint ConvertPositionWithCameraTransformationFromScreenToGame(CGPoint a_point, ScreenTransformation a_cameraTransformation)
{
	return CGPointMake(a_point.x / a_cameraTransformation.m_scale - a_cameraTransformation.m_xTranslate, a_point.y / a_cameraTransformation.m_scale - a_cameraTransformation.m_yTranslate);
}

static inline CGPoint ConvertPositionWithCameraTransformationFromGameToScreen(CGPoint a_point, ScreenTransformation a_cameraTransformation)
{
	return CGPointMake((a_point.x + a_cameraTransformation.m_xTranslate) * a_cameraTransformation.m_scale, (a_point.y + a_cameraTransformation.m_yTranslate) * a_cameraTransformation.m_scale);
}