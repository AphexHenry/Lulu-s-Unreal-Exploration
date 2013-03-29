//
//  StateLucioles.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatre.h"
#import "PhysicPendulum.h"
#import "Puppet.h"

// plan enumeration
typedef enum TextureStateTheatreSpiralOut
{ 
	TEXTURE_T_SPIRALOUT_SHADOW_FRONT = TEXTURE_THEATRE_COUNT,
	TEXTURE_T_SPIRALOUT_BIG_MONSTER,
	TEXTURE_T_SPIRALOUT_BIG_ARM,
	TEXTURE_T_SPIRALOUT_PUPPET_MARIO_DEAD,
	TEXTURE_T_SPIRALOUT_PUPPET_SNAKE,
	TEXTURE_T_SPIRALOUT_COUNT
}TextureStateTheatreSpiralOut;

@interface StateTheatreSpiralOut : StateTheatre
{
	// Current position of the pendulum base.
	BOOL m_sequenceStart;

	float	m_headDeformation;
	
	int		m_mappingFingerZeroToPuppet;
	Puppet * m_puppet;
	PhysicPendulum * m_marioDead;
	
	CGPoint				m_skyDecay;
	NSTimeInterval		m_time;
}

@end
