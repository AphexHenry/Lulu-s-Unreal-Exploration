//
//  StateIntro.h
//  Lulu
//
//  Created by Baptiste Bohelay on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "State.h"
#import "Animation.h"

// Letters particle group.
// MENU_TYPE_MAIN_NEW_GAME      :  new game button
// MENU_TYPE_MAIN_SELECT_LEVEL  :  select game button
// MENU_TYPE_LEVEL_SELECT       :  all levels buttons
typedef enum MenuType
{
	MENU_TYPE_MAIN_NEW_GAME,
	MENU_TYPE_MAIN_SELECT_LEVEL,
	MENU_TYPE_LEVEL_SELECT,
}MenuType;

// state in the menu.
//STATE_MAIN_INIT               : init the main menu.
//STATE_MAIN_UPDATE             : update the main menu.
//STATE_MAIN_END                : end of the main menu (when clicking).
//STATE_LEVEL_INIT              : init the level selection screen.
//STATE_LEVEL_UPDATE            : update the level selection screen.
//STATE_LEVEL_END               : end of the level selection screen (when clicking on a level or on the return button).
//STATE_BEGIN_GAME_INIT         : start a level init.
//STATE_BEGIN_GAME_UPDATE       : start a level update.
typedef enum MenuState
{
	STATE_MAIN_INIT,
	STATE_MAIN_UPDATE,
	STATE_MAIN_END,
	STATE_LEVEL_INIT,
	STATE_LEVEL_UPDATE,
	STATE_LEVEL_END,
	STATE_BEGIN_GAME_INIT,
	STATE_BEGIN_GAME_UPDATE,
}MenuState;

// plan enumeration
typedef enum TextureMenu
{ 
	TEXTURE_MENU_THEATRE = TEXTURE_COUNT,
	TEXTURE_RABBIT,
	TEXTURE_N,
	TEXTURE_E,
	TEXTURE_W,	
	TEXTURE_G,
	TEXTURE_A,
	TEXTURE_M,
	TEXTURE_D,
	TEXTURE_S,
	TEXTURE_V,
	TEXTURE_BACK,
	TEXTURE_LEVEL_1,
	TEXTURE_LEVEL_2,
	TEXTURE_LEVEL_3,
	TEXTURE_LEVEL_4,
    TEXTURE_LEVEL_5,
    TEXTURE_LEVEL_6,
	TEXTURE_LEVEL_FINAL,
	TEXTURE_MENU_STICK,
	TEXTURE_ANIM_WINGS_0,
	TEXTURE_ANIM_WINGS_1,
	TEXTURE_MENU_COUNT
}TextureMenu;

@interface StateMenu : State 
{
    // state of the menu.
	MenuState m_state;
    // level selected.
	int		m_levelSelect;
    // position of the looped clouds.
	float m_cloudPosition;
	float m_cloudDecay;
    // size of the clouds.
	float m_cloudSize;
	float m_cloudAngle;
    // current zoom of the moon.
	float m_zoom;
	
    // position of the click.
	CGPoint m_clickPosition;
	
    // distance of the previous rabbit.
	float m_rabbitDistance;
	float m_rabbitAlpha;
	
    // decay of the sky.
	CGPoint m_skyDecay;
    // timer before switching, the state.
	NSTimeInterval m_nextStateTimer;
}

@end
