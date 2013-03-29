//
//  NoteBook.m
//  Lulu
//
//  Created by Baptiste Bohelay on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteBook.h"
#import "EAGLView.h"
#import "OpenALManager.h"
#import "ApplicationManager.h"
#import "ParticleViewController.h"

#define NOTE_WRITE_LETTER_INTERVAL 0.08

@implementation NoteBook

-(id)InitWithString:(NSString *)a_string MusicToFade:(NSString *)a_musicToFade
{
	if(a_musicToFade)
	{
		[[OpenALManager sharedOpenALManager] FadeWithKey:a_musicToFade duration:2. volume:0.2 stopEnd:NO];
		m_musicToFade = [[NSString alloc] initWithString:a_musicToFade];
	}
	else
	{
		m_musicToFade = nil;
	}

	m_inString = [[NSString alloc] initWithString:a_string];
	m_outString = [[NSMutableString alloc] init];//WithString:@""];
	return [super init];
}

-(id)InitWithString:(NSString *)a_string
{
	return [self InitWithString:a_string MusicToFade:nil];
}

-(void)StateInit
{
	m_index = 0;
	
	// Init the level datas.
	m_levelData.m_duplicate = 2;
	m_levelData.m_widthOnHeigth = 2.;
	m_levelData.m_size = 1.f;
	m_levelData.m_snakePartQuantity = 10;
	m_levelData.m_snakeLengthBetweenParts = 0.08;
	m_levelData.m_snakeLengthBetweenHeadAndBody = 0.08;
	m_levelData.m_snakeSizeHead = 0.2;
	m_levelData.m_snakeSizeBody = 0.15;
	m_levelData.m_arraySize = TEXTURE_NOTEBOOK_COUNT;
	
	m_levelData.m_textureArray = malloc(m_levelData.m_arraySize * sizeof(NSString *));
	m_levelData.m_textureArray[TEXTURE_BACKGROUND] = [[NSString alloc] initWithString:@"nightSky.png"];
	m_levelData.m_textureArray[TEXTURE_MOON] = [[NSString alloc] initWithString:@"moon.png"];
	m_levelData.m_textureArray[TEXTURE_SHADOW] = [[NSString alloc] initWithString:@"wallSulpiceShadow.png"];
	m_levelData.m_textureArray[TEXTURE_NOTEBOOK_BLACK] = [[NSString alloc] initWithString:@"black.png"];
	m_levelData.m_textureArray[TEXTURE_NOTEBOOK_LULU_WRITING] = [[NSString alloc] initWithString:@"luluIntroSit.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_BACKGROUND_AROUND] = [[NSString alloc] initWithString:@"introAround.png"];
	m_levelData.m_textureArray[TEXTURE_THEATRE_STICK] = [[NSString alloc] initWithString:@"stick.png"];

	m_time = 0.;
	m_nextLetterTimer = 2.;
	m_indexLetter = 0;
	m_endOfTheText = NO;
	
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"write" Volume:0.f];
	[[OpenALManager sharedOpenALManager] playSoundWithKey:@"erase" Volume:0.f];

	[[ApplicationManager sharedApplicationManager] SetBaptisteBlocked:YES];
	
	[[ParticleViewController sharedParticleViewController].m_noteBookTextView setHidden:NO];
	[[ParticleViewController sharedParticleViewController].m_noteBookTextViewDate setHidden:NO];
    [[ParticleViewController sharedParticleViewController].m_buttonSkipSpeak setHidden:NO];
	[[ParticleViewController sharedParticleViewController].m_noteBookTextView setFont:[UIFont fontWithName:@"Zapfino" size:14]];
	[[ParticleViewController sharedParticleViewController].m_noteBookTextViewDate setFont:[UIFont fontWithName:@"Zapfino" size:18]];
	[[ParticleViewController sharedParticleViewController].m_noteBookTextView setText:@""];
	
    // display the hour on the note book.
	NSDate *today = [NSDate date];
	NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:NSHourCalendarUnit fromDate:today];
	NSDateComponents *dateComponentsMinuts = [gregorian components:NSMinuteCalendarUnit fromDate:today];
	int l_hour   = [dateComponents hour];
	int l_minute = [dateComponentsMinuts minute];
	[gregorian release];
	
	[[ParticleViewController sharedParticleViewController].m_noteBookTextViewDate setText:[NSString stringWithFormat:@"%02dh%02d", l_hour, l_minute]];
	
	[super StateInit];
	
	m_luminosityFluctuationCoeff = 15.f;
}

-(void)UpdateWithTimeInterval:(NSTimeInterval)a_timeInterval
{
	m_time += a_timeInterval;
	
	[self UpdateText];
	
	EAGLView * l_sharedEAGLView = [EAGLView sharedEAGLView];
	float l_generalLuminosity = [l_sharedEAGLView GetLuminosity];
	[[ParticleViewController sharedParticleViewController].m_noteBookTextView setAlpha:l_generalLuminosity];
	[[ParticleViewController sharedParticleViewController].m_noteBookTextViewDate setAlpha:l_generalLuminosity];
	
	// black part down.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_NOTEBOOK_BLACK
								  plan:PLAN_BACKGROUND_CLOSE
								  size:	0.5
							 positionX:0.6f
							 positionY:-0.4f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.
							nightBlend:false
						   deformation:0.f
							  distance:-1.f
	 ];
	
	// black part up.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_NOTEBOOK_BLACK
								  plan:PLAN_BACKGROUND_CLOSE
								  size:	0.8
							 positionX:0.f
							 positionY:0.8f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:2.2
							nightBlend:false
						   deformation:0.f
							  distance:-1.f
	 ];
	
	[l_sharedEAGLView drawTextureIndex:TEXTURE_NOTEBOOK_LULU_WRITING
								  plan:PLAN_BACKGROUND_SHADOW
								  size:	0.4
							 positionX:-0.8f
							 positionY:-0.4f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.
							nightBlend:false
						   deformation:0.f
							  distance:30.f
	 ];
	
	// draw the head.
	[l_sharedEAGLView drawTextureIndex:TEXTURE_THEATRE_BACKGROUND_AROUND
								  plan:PLAN_BACKGROUND_SHADOW
								  size:	m_levelData.m_size * 1.1
							 positionX:0.f
							 positionY:0.18f
							 positionZ:0.
						 rotationAngle:0.
					   rotationCenterX:0.
					   rotationCenterY:0.
						  repeatNumber:1
						 widthOnHeight:1.8
							nightBlend:false
						   deformation:0.f
							  distance:30.f
	 ];
	
	if(m_time > 35.)
	{
		[[ApplicationManager sharedApplicationManager] ChangeState:nil];
	}
	
	[super UpdateWithTimeInterval:a_timeInterval];
}

-(void)UpdateText
{
	if(m_nextLetterTimer < m_time && !m_endOfTheText)
	{
		NSRange l_range = {m_indexLetter,1};
		NSString * l_tempString = [m_inString substringWithRange:l_range];
        // if the character is "£", we erase the previous letter.
        // if the character is "_", Lulu will make a pause.
        // else the caracter will be added to the displayed text.
		if([l_tempString isEqualToString:@"£"])
		{
			NSRange l_rangeToDelete = {[m_outString length] - 1, 1 };
			[m_outString deleteCharactersInRange:l_rangeToDelete];
			[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"write" Volume:0.f];
			[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"erase" Volume:.7f];
		}
		else if([l_tempString isEqualToString:@"_"])
		{
			m_nextLetterTimer += 4.5f * NOTE_WRITE_LETTER_INTERVAL;
			[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"write" Volume:0.f];
			[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"erase" Volume:0.f];
			[[OpenALManager sharedOpenALManager] playSoundWithKey:@"baptisteCoin" Volume:1.f];
		}
		else
		{
			[m_outString appendString:l_tempString];
			[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"write" Volume:.55f];
			[[OpenALManager sharedOpenALManager] SetVolumeWithKey:@"erase" Volume:0.f];
		}

		[[ParticleViewController sharedParticleViewController].m_noteBookTextView setText:m_outString];
		m_nextLetterTimer += NOTE_WRITE_LETTER_INTERVAL;
		m_indexLetter++;
		if(m_indexLetter >= [m_inString length])
		{
			m_endOfTheText = YES;
			[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"write"];
			[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"erase"];
		}
	}
}

-(void)SimpleClick:(CGPoint)a_touchLocation
{
	[[ApplicationManager sharedApplicationManager] ChangeState:nil];
}

-(void)SkipSpeaking
{
	[[ApplicationManager sharedApplicationManager] ChangeState:nil];
}

-(void)Terminate
{
	[m_inString release];
	[m_outString release];
	if(m_musicToFade)
	{
		[m_musicToFade release];
		[[OpenALManager sharedOpenALManager] FadeWithKey:m_musicToFade duration:2. volume:0.5 stopEnd:NO];
	}

	[[ParticleViewController sharedParticleViewController].m_buttonSkipSpeak setHidden:YES];
	[[ParticleViewController sharedParticleViewController].m_noteBookTextView setHidden:YES];
	[[ParticleViewController sharedParticleViewController].m_noteBookTextViewDate setHidden:YES];
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"write"];
	[[OpenALManager sharedOpenALManager] stopSoundWithKey:@"erase"];
}

@end
