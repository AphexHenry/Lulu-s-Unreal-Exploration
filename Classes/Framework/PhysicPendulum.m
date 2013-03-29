//
//  PhysicPendulum.m
//  Particles
//
//  Created by Baptiste Bohelay on 10/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PhysicPendulum.h"
#import "MathTools.h"

// list of pendulums.
static NSMutableArray * s_pendulumArray = nil;

@implementation PhysicPendulum

@synthesize		m_angle;
@synthesize		m_penduleSpeed;
@synthesize		m_pendulumPosition;

//
//	initialization of all the variables
//
-(id)initWithPosition:(CGPoint)a_pendulePosition 
		 basePosition:(CGPoint)a_basePosition 
				 mass:(float)a_mass 
	  angleSpeedLimit:(float)a_angleSpeedLimit
			  gravity:(float)a_gravity
		 gravityAngle:(float)a_gravityAngle
			 friction:(float)a_friction
		 addInTheList:(bool)a_addInTheList
{
	[super init];
	m_pendulumPosition = a_pendulePosition;			// view of the attractor (vortex)
	m_basePosition = a_basePosition;
	m_baseSpeed = CGPointMake(0.f, 0.f);
	m_angleSpeed = 0.f;
	m_angle = atan((a_pendulePosition.x - m_basePosition.x) / (a_pendulePosition.y - m_basePosition.y));
	m_angle = a_pendulePosition.y - m_basePosition.y > 0.f ? m_angle + M_PI : m_angle;
	m_penduleSpeed = CGPointMake(0.f, 0.f);
	m_lengthSquare = DistancePointSquare(a_pendulePosition, m_basePosition);
	m_length = sqrt(m_lengthSquare);
	m_childList = [[NSMutableArray alloc] init];
	m_mass = a_mass;
	m_gravity = a_gravity;
	m_frictionCoefficient = a_friction;
	m_gravityAngle = a_gravityAngle;
	if(s_pendulumArray == nil)
	{
		s_pendulumArray = [[NSMutableArray alloc] init];
	}
	m_index = [s_pendulumArray count];
	if(a_addInTheList)
	{
		[PhysicPendulum AddInTheList:self];
	}
	m_angleSpeedLimit = a_angleSpeedLimit;
	return self;
}

//
// Updtate the position of the pendulum and its base.
//
-(CGPoint)UpdateWithBasePosition:(CGPoint)a_basePosition timeFrame:(float)a_timeFrame
{	
    // Process the movement of the base.
	CGPoint l_baseMovement;
	l_baseMovement.x = (a_basePosition.x - m_basePosition.x);
	l_baseMovement.y = (a_basePosition.y - m_basePosition.y);

	float l_angleSpeedChildInfluence = 0.f;
	float l_brakeCoefficient = 1.0f;
	int l_childCount = [m_childList count];
	
    // Process the influence of the child on the mass.
	for(int i = 0; i < l_childCount; i++)
	{
		PhysicPendulum * l_currentChild = [m_childList objectAtIndex:i];
		InteractionParameter l_childInteractionParameter = [l_currentChild GetInteractionParameters];
		float l_angleInfluence = sin(m_angle - l_childInteractionParameter.m_angle);
		l_angleSpeedChildInfluence = l_angleInfluence * (l_childInteractionParameter.m_centrifugal * l_childInteractionParameter.m_mass / (m_mass * -400.f));
		l_brakeCoefficient = 1.f - pow(( l_childInteractionParameter.m_mass * Absf(l_angleInfluence) / (l_childInteractionParameter.m_mass + m_mass)), 2.f);
	}

    // Update the speed and the position of the pendulum.
	float l_baseAngleSpeed = -atan((l_baseMovement.x * cos(m_angle) + l_baseMovement.y * sin(m_angle)) / m_length);
	l_baseAngleSpeed += l_angleSpeedChildInfluence;
	m_angleSpeed += ((-m_gravity * sin(m_angle + m_gravityAngle)) + l_baseAngleSpeed ) / m_length;
	m_angleSpeed = m_angleSpeed / (1.f + (m_frictionCoefficient * a_timeFrame));
	m_angleSpeed *= l_brakeCoefficient;
	if(m_angleSpeedLimit > 0.f)
	{
		m_angleSpeed = clip(m_angleSpeed, -m_angleSpeedLimit, m_angleSpeedLimit);
	}
	
	m_angle += (m_angleSpeed * a_timeFrame) + l_baseAngleSpeed;
	
	m_baseSpeed = l_baseMovement;
	m_basePosition = a_basePosition;

	float l_newPosX = m_basePosition.x + sin(m_angle) * m_length;
	float l_newPosY = m_basePosition.y - cos(m_angle) * m_length;
	
	m_penduleSpeed.x = (l_newPosX - m_pendulumPosition.x) / a_timeFrame;
	m_penduleSpeed.y = (l_newPosY - m_pendulumPosition.y) / a_timeFrame;
	
	m_pendulumPosition.x = l_newPosX;
	m_pendulumPosition.y = l_newPosY;
	
	CGPoint l_decay = CGPointMake(m_pendulumPosition.x + (l_childCount - 1) * 0.01, m_pendulumPosition.y);
	for(int i = 0; i < l_childCount; i++)
	{
		PhysicPendulum * l_currentChild = [m_childList objectAtIndex:i];
		[l_currentChild UpdateWithBasePosition:l_decay timeFrame:a_timeFrame];
		l_decay.x += 0.01;
	}
	
	return m_pendulumPosition;
}

//
//  Add it in the list.
//  Used for pendulum with a lot of parts.
//
+(void)AddInTheList:(PhysicPendulum *)a_pendulum
{
	[s_pendulumArray addObject:a_pendulum];
}

//
// Get the list of all the pendulum node (static).
//
+(NSMutableArray * )GetList
{
	return s_pendulumArray;
}

//
// Add a child to this pendulum node.
//
-(void)AddChild:(PhysicPendulum *)a_child
{
	[m_childList addObject:a_child];
}

// 
//  Return the list of his childs.
//
-(NSMutableArray * )GetChildList
{
	return m_childList;
}

//
//  Return his parameters, in a structure.
//
-(InteractionParameter)GetInteractionParameters
{
	InteractionParameter r_parameters;
	r_parameters.m_mass = m_mass;
	r_parameters.m_angle = m_angle;
	r_parameters.m_centrifugal = m_angleSpeed * m_angleSpeed * m_length;
	return r_parameters;
}

//
// Set the position of the base of the pendulum.
//
-(void) SetCenter:(CGPoint)a_center
{
	m_basePosition = a_center;
}

//
//  Set the position of the mass.
//
-(void) SetPosition:(CGPoint)a_center
{
	m_angle = atan((a_center.x - m_basePosition.x) / (a_center.y - m_basePosition.y));
	m_lengthSquare = DistancePointSquare(a_center, m_basePosition);
	m_length = sqrt(m_lengthSquare);
}

//
// Change his distance between the mass and the base.
//
-(void)SetLength:(float)a_length
{
	m_length = a_length;
	m_lengthSquare = (float)pow(m_length, 2.);
}

//
//  Get the position of the mass.
//
-(CGPoint) GetPosition
{
	return m_pendulumPosition;
}

//
//  Set his rotation speed.
//
-(void)SetAngleSpeed:(float)a_angleSpeed
{
	m_angleSpeed = a_angleSpeed;
}

// 
//  Dealloc.
//
-(void)dealloc
{
	[m_childList release];
	[super dealloc];
}

// 
//  Dealloc the list.
//
+(void)DeallocAllTheList
{
	int l_num = [s_pendulumArray count];
	for(int i = l_num - 1; i >= 0; i--)
	{
		[[s_pendulumArray objectAtIndex:i] release];
	}
	[s_pendulumArray release];
}

//
// Remove all elements of the list, and release theim.
//
+(void)RemoveAllElements
{	
	//[PhysicPendulum DeallocAllTheList];
	int l_num = [s_pendulumArray count];
	for(int i = l_num - 1; i >= 0; i--)
	{
		[[s_pendulumArray objectAtIndex:i] release];
	}
	
	[s_pendulumArray removeAllObjects];
}

// 
//  Change randomly the gravity.
//
-(void)ChangeGravity
{
	[self SetGravityDegree:myRandom() * 180.f];
}

//
//  Change the angle of the gravity strength.
//
-(void)SetGravityDegree:(float)a_angle
{
	for(int i = 0; i < [m_childList count]; i++)
	{
		[[m_childList objectAtIndex:i] SetGravityDegree:a_angle];
	}
	m_gravityAngle = a_angle * M_PI / 180.;
}

//
//  Set a new gravity strength.
//
-(void)SetGravityCoefficient:(float)a_gravityCoeff
{
	for(int i = 0; i < [m_childList count]; i++)
	{
		[[m_childList objectAtIndex:i] SetGravityCoefficient:a_gravityCoeff];
	}
	m_gravity = a_gravityCoeff;
}

//
//  Set the new friction coefficient.
//
-(void)SetFriction:(float)a_friction
{
	m_frictionCoefficient = a_friction;
}

@end
