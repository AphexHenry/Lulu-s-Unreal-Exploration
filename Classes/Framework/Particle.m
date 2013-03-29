//
//  Particle.m
//  Lulu
//
//  Created by Baptiste Bohelay on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "Particle.h"
#import	"MathTools.h"
#import	"AttractorsPositions.h"
#import "PhysicPendulum.h"
#import "OpenALManager.h"


@implementation Particle

@synthesize		next;
@synthesize		prev;
@synthesize		m_lifetime;
@synthesize		m_group;
@synthesize		m_position;
@synthesize		m_texture;
@synthesize		m_size;


//
// initialization of a particle
//
-(id)init
{
	[super init];
	return self;
}

//
//	Update of the particles positions and state
//	We put the dead particles in a trash and reinitialize them when needed
//  A chain list is used for the particles container
// 
-(void)UpdateWithTimeInterval:(float)a_timeInterval
{

}

-(void)draw
{	
	[[EAGLView sharedEAGLView] drawTextureIndex:m_texture 
										   plan:m_plan 
										   size:m_size * 3.5f / (m_distance + EPSILON)
									  positionX:m_position.x / (m_distance + EPSILON)
									  positionY:m_position.y / (m_distance + EPSILON)
									  positionZ:0.5
								  rotationAngle:0.f
								rotationCenterX:m_position.x 
								rotationCenterY:m_position.y
								   repeatNumber:1
								  widthOnHeight:1.f
									 nightBlend:FALSE
									deformation:0.f
										distance:m_distance
	 ];
}

-(CGPoint)GetDisplayPosition
{
	return m_position;
}

-(void)kill
{
	m_lifetime = -1.;
}

@end
