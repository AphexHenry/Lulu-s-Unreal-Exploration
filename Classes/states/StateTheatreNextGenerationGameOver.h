//
//  StateTheatreNextGenerationGameOver.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatre.h"
#import "PhysicPendulum.h"
#import "Puppet.h"

// plan enumeration
typedef enum TextureStateTheatreNextGenerationGameOver
{ 
	TEXTURE_T_NG_GAMEOVER_SHADOW_FRONT = TEXTURE_THEATRE_COUNT,
	TEXTURE_T_NG_GAMEOVER_GRAVESTONE,
	TEXTURE_T_NG_MIST,
	TEXTURE_T_NG_BUTTON_RETRY,
	TEXTURE_T_NG_BUTTON_QUIT,
	TEXTURE_T_NG_GAMEOVER_G,
	TEXTURE_T_NG_GAMEOVER_A,
	TEXTURE_T_NG_GAMEOVER_M,	
	TEXTURE_T_NG_GAMEOVER_E,
	TEXTURE_T_NG_GAMEOVER_O,
	TEXTURE_T_NG_GAMEOVER_V,
	TEXTURE_T_NG_GAMEOVER_R,
	TEXTURE_T_NG_GAMEOVER_COUNT
}TextureStateTheatreNextGenerationGameOver;

@interface StateTheatreNextGenerationGameOver : StateTheatre
{
	// Current position of the pendulum base.
	BOOL m_firstClick;

	float	m_headDeformation;
	
	int		m_mappingFingerZeroToPuppet;
	float	m_musicPitch;
	
	CGPoint				m_skyDecay;
	NSTimeInterval		m_time;
}

@end

@interface StateTheatreSeaGameOver : StateTheatreNextGenerationGameOver 
{

}
@end
