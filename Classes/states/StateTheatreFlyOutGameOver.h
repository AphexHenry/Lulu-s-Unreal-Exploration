//
//  StateTheatreFlyOutGameOver.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatre.h"
#import "PhysicPendulum.h"
#import "Puppet.h"

// plan enumeration
typedef enum TextureStateTheatreFlyOutGameOver
{ 
	TEXTURE_T_FLY_GAMEOVER_SHADOW_FRONT = TEXTURE_THEATRE_COUNT,
	TEXTURE_T_FLY_GAMEOVER_GRAVESTONE,
	TEXTURE_T_FLY_MIST,
	TEXTURE_T_FLY_GAMEOVER_G,
	TEXTURE_T_FLY_GAMEOVER_A,
	TEXTURE_T_FLY_GAMEOVER_M,	
	TEXTURE_T_FLY_GAMEOVER_E,
	TEXTURE_T_FLY_GAMEOVER_O,
	TEXTURE_T_FLY_GAMEOVER_V,
	TEXTURE_T_FLY_GAMEOVER_R,
	TEXTURE_T_FLY_GAMEOVER_COUNT
}TextureStateTheatreFlyOutGameOver;

@interface StateTheatreFlyOutGameOver : StateTheatre
{
	// Current position of the pendulum base.
	BOOL m_sequenceStart;

	float	m_headDeformation;
	
	int		m_mappingFingerZeroToPuppet;
	float	m_musicPitch;
	
	CGPoint				m_skyDecay;
	NSTimeInterval		m_time;
}

@end
