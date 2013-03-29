//
//  NoteBook.h
//  Lulu
//
//  Created by Baptiste Bohelay on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StateTheatre.h"
#import "PhysicPendulum.h"

// plan enumeration
typedef enum TextureNoteBook
{ 
	TEXTURE_NOTEBOOK_BLACK = TEXTURE_THEATRE_COUNT,
	TEXTURE_NOTEBOOK_LULU_WRITING,
	TEXTURE_NOTEBOOK_COUNT
}TextureNoteBook;

@interface NoteBook : StateTheatre
{
	// input string.
	NSString * m_inString;
    // displayed string.
	NSMutableString * m_outString;
    // name of the music we have to fade.
	NSString * m_musicToFade;
    // timer of the state.
	NSTimeInterval  m_time;
	// timer for the display of the next letter.
	NSTimeInterval	m_nextLetterTimer;
    // index of the current letter to display.
	int				m_indexLetter;
    // if true, all the text is displayed.
	BOOL			m_endOfTheText;
}
// init the state with a text, and possibly a music to fade.
-(id)InitWithString:(NSString *)a_string MusicToFade:(NSString *)a_musicToFade;
-(id)InitWithString:(NSString *)a_string;
// update.
-(void)UpdateText;

@end
