//
//  PhysicPendulum.h
//  Particles
//
//  Created by Baptiste Bohelay on 10/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// pendulum current parameters.
// 
typedef struct InterParam 
{
	float m_mass;
	float m_angle;
	float m_centrifugal;
} InteractionParameter;
	
@interface PhysicPendulum : NSObject 
{
	float m_gravity;
	float m_gravityAngle;
	float m_frictionCoefficient;
	
	CGPoint m_basePosition;						// position of the base.
	CGPoint m_baseSpeed;						// speed of the base.
	float	m_angle;							// angle from the down vertical position.
	float	m_angleSpeed;						// angle speed.
	float	m_angleSpeedLimit;					// limit of the angle speed.
	float	m_length;							// length of the string of this pendulum.
	float	m_lengthSquare;						// square root of m_length.
	CGPoint			m_pendulumPosition;			// view of the attractor (vortex)
	CGPoint			m_penduleSpeed;				// Speed of the pendulum.
	NSTimer			*m_timer;
	
	NSMutableArray	* m_childList;				// pointor to the child of this pendulum.
	float			m_mass;						// mass of this pendulum.
	int				m_index;					// index of the pendulum.

}

@property CGFloat m_angle;
@property CGPoint m_penduleSpeed;
@property CGPoint m_pendulumPosition;

//
// intitialisation of the pendulum : 
// first            : position of the mass.
// basePosition     : position of the base.
// mass             : mass of the pendulum.
// angleSpeedLimit  : limit of the angle speed.
// gravity          : gravity strength.
// gravityAngle     : angle of the gravity strength.s
// friction         : friction strength.
// addInTheList     : if true, we add it in the list of pendulum. Used for pendulum with a lot of parts.
-(id)initWithPosition:(CGPoint)a_pendulePosition 
		 basePosition:(CGPoint)a_basePosition 
				 mass:(float)a_mass 
	  angleSpeedLimit:(float)a_angleSpeedLimit
			  gravity:(float)a_gravity
		 gravityAngle:(float)a_gravityAngle
			 friction:(float)a_friction
		 addInTheList:(bool)a_addInTheList;

//
// Updtate the position of the pendulum and its base.
//
-(CGPoint) UpdateWithBasePosition:(CGPoint)a_basePosition timeFrame:(float)a_timeFrame;

//
// Set the position of the base of the pendulum.
//
-(void) SetCenter:(CGPoint)a_center;

//
//  Set the position of the mass.
//
-(void) SetPosition:(CGPoint)a_center;

//
//  Get the position of the mass.
//
-(CGPoint) GetPosition;

//
// Add a child to this pendulum node.
//
-(void)AddChild:(PhysicPendulum *)a_child;

// 
//  Return the list of his childs.
//
-(NSMutableArray *)GetChildList;

//
//  Return his parameters, in a structure.
//
-(InteractionParameter)GetInteractionParameters;

//
// Change his distance between the mass and the base.
//
-(void)SetLength:(float)a_length;

//
//  Set his rotation speed.
//
-(void)SetAngleSpeed:(float)a_angleSpeed;

// 
//  Change randomly the gravity.
//
-(void)ChangeGravity;

//
//  Change the angle of the gravity strength.
//
-(void)SetGravityDegree:(float)a_angle;

//
//  Set a new gravity strength.
//
-(void)SetGravityCoefficient:(float)a_angle;

//
//  Set the new friction coefficient.
//
-(void)SetFriction:(float)a_friction;

//
//  Add it in the list.
//  Used for pendulum with a lot of parts.
//
+(void)AddInTheList:(PhysicPendulum *)a_pendulum;

//
//  Return the list of pendulums.
//
+(NSMutableArray * )GetList;

//
//  Dealloc the list, release the pendulum.
//
+(void)DeallocAllTheList;

//
// Remove all elements of the list.
//
+(void)RemoveAllElements;

@end
