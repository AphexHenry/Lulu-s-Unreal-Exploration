//
//  StateTheatreRateIt.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


#import "StateTheatre.h"
#import "PhysicPendulum.h"
#import "Puppet.h"

// plan enumeration
typedef enum TextureStateTheatreRateIt
{ 
	TEXTURE_T_RATEIT_SHADOW_FRONT = TEXTURE_THEATRE_COUNT,
	TEXTURE_T_RATEIT_PUPPET_SNAKE,
	TEXTURE_T_RATEIT_PUPPET_MESSAGE,
	TEXTURE_T_RATEIT_PUPPET_YES,
	TEXTURE_T_RATEIT_PUPPET_NO,
	TEXTURE_T_RATEIT_PUPPET_LATER,
	TEXTURE_T_RATEIT_COUNT
}TextureStateTheatreRateIt;

@interface StateTheatreRateIt : StateTheatre
{
	// Current position of the pendulum base.
	BOOL m_headFall;
	BOOL m_headEaten;
	BOOL m_sequenceStart;
	
	CGPoint				m_skyDecay;
	NSTimeInterval		m_time;
}

//
//  Check if we can connect the network.
//
+ (BOOL)connectedToNetwork;

//
//  Get the current version of the application.
//
+(int)GetVersion;

@end
