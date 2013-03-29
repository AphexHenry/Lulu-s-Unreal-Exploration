//
//  StateIntro.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatre.h"
#import "PhysicPendulum.h"
#import "Puppet.h"

// texture enumeration
//TEXTURE_INTRO_SHADOW_FRONT    : front trees
//TEXTURE_INTRO_CURTAIN_RIGHT   : right curtain
//TEXTURE_INTRO_CURTAIN_LEFT    : left curtain
//TEXTURE_INTRO_TITLE           : title panel
//TEXTURE_INTRO_THANKS          : thanks panel
//TEXTURE_INTRO_LULU            : Lulu puppet
//TEXTURE_INTRO_MARKER          : marker to tell that we can control the puppet
//TEXTURE_INTRO_ARROW_ENTER     : arraw to show the direction
typedef enum TextureIntro
{ 
	TEXTURE_INTRO_SHADOW_FRONT = TEXTURE_THEATRE_COUNT,
	TEXTURE_INTRO_CURTAIN_RIGHT,
	TEXTURE_INTRO_CURTAIN_LEFT,
	TEXTURE_INTRO_TITLE,
	TEXTURE_INTRO_THANKS,
	TEXTURE_INTRO_LULU,
	TEXTURE_INTRO_MARKER,
	TEXTURE_INTRO_ARROW_ENTER,
	TEXTURE_INTRO_COUNT
}TextureIntro;

@interface StateIntro : StateTheatre
{
	// datas of the arrow panel.
	CGPoint m_panelPosition;
	CGPoint m_panelSpeed;
	float	m_panelAngle;
	
    // if true, we open the curtain.
	BOOL m_curtainOpened;
	
	// pointor to the head of the pendulum.
	PhysicPendulum * m_pendulumTitle;
	Puppet * m_puppet;
	
	// datas of the title.
	CGPoint				m_titlePosition;
	CGPoint				m_titleSpeed;
    // datas of the thanks panel.
	CGPoint				m_helpSpeed;
	CGPoint				m_helpPosition;
	// if true, the puppet is turning on the left.
	BOOL				m_luluLeft;
    // pevious orientation of the puupet.
	float				m_luluTurnLast;
    // speed of rotation of the puppet.
	float				m_luluTurnSpeed;
    // timer for the curtain to open.
	NSTimeInterval		m_curtainOpenTimer;
	// scrolling of the background (positions).
	CGPoint				m_skyDecay;
}

// init pendulum.
-(void)InitStick;

// Update help panel.
-(void)UpdateHelpPanel:(NSTimeInterval)a_timeInterval;

// updtate the positions of the snake parts and draw them.
-(BOOL)UpdateTitle:(NSTimeInterval)a_timeInterval;

@end
