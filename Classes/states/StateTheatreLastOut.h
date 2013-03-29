//
//  StateTheatreLastOut.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


#import "StateTheatre.h"
#import "PhysicPendulum.h"
#import "Puppet.h"

// texture enumeration
typedef enum TextureStateTheatreLastOut
{ 
	TEXTURE_T_FLYOUT_SHADOW_FRONT = TEXTURE_THEATRE_COUNT,
	TEXTURE_T_FLYOUT_PUPPET_SNAKE,
	TEXTURE_T_FLYOUT_PUPPET_MESSAGE,
	TEXTURE_T_FLYOUT_COUNT
}TextureStateTheatreLastOut;

@interface StateTheatreLastOut : StateTheatre
{
	BOOL m_sequenceStart;
	
	Puppet * m_puppet;
	
	CGPoint				m_skyDecay;
	NSTimeInterval		m_time;
}

@end
