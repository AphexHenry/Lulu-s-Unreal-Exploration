//
//  StateTheatre.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "State.h"
#import "PhysicPendulum.h"

// texture enumeration.
//TEXTURE_THEATRE_BACKGROUND_AROUND : curtain.
//TEXTURE_THEATRE_PANEL_HAPPY       : Happy icon
//TEXTURE_THEATRE_PANEL_POKER_FACE  : poker face icon
//TEXTURE_THEATRE_PANEL_PRESENT     : present icon
//TEXTURE_THEATRE_PANEL_SURPRISE    : surprise icon
//TEXTURE_THEATRE_PANEL_SCARED      : scared icon
//TEXTURE_THEATRE_PANEL_CIRCLE      : circle icon
//TEXTURE_THEATRE_PANEL_EGUAL       : equal sign icon
//TEXTURE_THEATRE_PANEL_SQUARE      : square icon
//TEXTURE_THEATRE_PANEL_YOKAI       : yokaï icon
//TEXTURE_THEATRE_PANEL_UP          : up sign icon
//TEXTURE_THEATRE_PANEL_DOWN        : down sign icon
//TEXTURE_THEATRE_STICK             : puppet stick
//TEXTURE_THEATRE_WING_0            : wings animation frame 0
//TEXTURE_THEATRE_WING_1            : wings animation frame 1
//TEXTURE_THEATRE_FINGER_GUI        : touch available symbol
//TEXTURE_THEATRE_ARROW             : direction sign
typedef enum TextureTheatre
{ 
	TEXTURE_THEATRE_BACKGROUND_AROUND = TEXTURE_COUNT,
	TEXTURE_THEATRE_PANEL_HAPPY,
	TEXTURE_THEATRE_PANEL_POKER_FACE,
	TEXTURE_THEATRE_PANEL_PRESENT,
	TEXTURE_THEATRE_PANEL_SURPRISE,
	TEXTURE_THEATRE_PANEL_SCARED,
    TEXTURE_THEATRE_PANEL_CIRCLE,
    TEXTURE_THEATRE_PANEL_EGUAL,
    TEXTURE_THEATRE_PANEL_SQUARE, 
    TEXTURE_THEATRE_PANEL_YOKAI, 
    TEXTURE_THEATRE_PANEL_UP, 
    TEXTURE_THEATRE_PANEL_DOWN, 
	TEXTURE_THEATRE_STICK,
	TEXTURE_THEATRE_WING_0,
	TEXTURE_THEATRE_WING_1,
	TEXTURE_THEATRE_FINGER_GUI,
	TEXTURE_THEATRE_ARROW,
	TEXTURE_THEATRE_COUNT
}TextureTheatre;

@interface StateTheatre : State
{
	// position of the finger on the screen.
	CGPoint				m_fingerPosition[2];
    // number of finger touching ghte screen.
	int					m_fingerCount;
    // go :  end of the act.
	BOOL				m_go;
    // these two objects are used for the "cinema" effect.
	float				m_moonDistance[2];
    // luminosity variation, to make a "old" effect.
	float				m_luminosityFluctuationCoeff;
	// pendulum for the go panel.
	PhysicPendulum *	m_goPendulum;
    // timer for the go panel.
	NSTimeInterval		m_goTimer;
}

// updtate the puppet.
-(BOOL)UpdatePuppet:(NSTimeInterval)a_timeInterval;

@end
