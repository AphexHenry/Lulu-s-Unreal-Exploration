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
typedef enum TextureStateTheatreLarveOut
{ 
	TEXTURE_T_LARVEOUT_SHADOW_FRONT = TEXTURE_THEATRE_COUNT,
	TEXTURE_T_LARVEOUT_PUPPET_MARIO,
	TEXTURE_T_LARVEOUT_PUPPET_MARIO_OPEN_MOUTH,
	TEXTURE_T_LARVEOUT_PUPPET_SNAKE,
	TEXTURE_T_LARVEOUT_SNAKE_HEAD,
	TEXTURE_T_LARVEOUT_COUNT
}TextureStateTheatreLarveOut;

@interface StateTheatreLarveOut : StateTheatre
{
	// Current position of the pendulum base.
	BOOL m_headFall;
	BOOL m_headEaten;
	BOOL m_sequenceStart;
	
	CGPoint m_headPosition;
	CGPoint m_headSpeed;
	
	float	m_headDeformation;
	
	int		m_mappingFingerZeroToPuppet;
	Puppet * m_puppet[2];
	
	CGPoint				m_skyDecay;
	NSTimeInterval		m_time;
}

@end
