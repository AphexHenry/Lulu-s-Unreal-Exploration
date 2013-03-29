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
typedef enum TextureStateTheatreNextGenerationOut
{ 
	TEXTURE_T_NGOUT_SHADOW_FRONT = TEXTURE_THEATRE_COUNT,
	TEXTURE_T_NGOUT_PUPPET_LULU,
    TEXTURE_T_NGOUT_LULU_SWORD,
	TEXTURE_T_NGOUT_PUPPET_PIG,
    TEXTURE_T_NGOUT_PUPPET_PIG_CRAZY,
    TEXTURE_T_NGOUT_PANEL_SURPRISE_SQUARE,
    TEXTURE_T_NGOUT_PANEL_SURPRISE_SQUARE_REVERSE,
    TEXTURE_T_NGOUT_PANEL_LULU,
    TEXTURE_T_NGOUT_PANEL_INFINITE,
    TEXTURE_T_NGOUT_PANEL_MESSEDUP,
    TEXTURE_T_NGOUT_PANEL_QUESTION,
    TEXTURE_T_NGOUT_PANEL_PIG,
    TEXTURE_T_NGOUT_PANEL_HORSE,
	TEXTURE_T_NGOUT_COUNT
}TextureStateTheatreNextGenerationOut;

@interface StateTheatreNextGenerationOut : StateTheatre
{
	// Current position of the pendulum base.
	BOOL m_sequenceStart;
	
    CGPoint m_swordPosition;
	float	m_headDeformation;
	
	int		m_mappingFingerZeroToPuppet;
    // the two puppets.
	Puppet * m_puppet[2];
    
    // deformation of the pig puppet.
    float m_pigDeformation;
	
	CGPoint				m_skyDecay;     // scrolling.
	NSTimeInterval		m_time;         // timer.
    NSTimeInterval      m_timeBeforeEndSequence;
    NSTimeInterval      m_nextNoiseTimer;
}

// Launch the dialogue sequence.
-(void)LaunchSequence;

@end
