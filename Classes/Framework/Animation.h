//
//  Animation.h
//  Particles
//
//  Created by Baptiste Bohelay on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Animation : NSObject 
{
	uint m_firstFrame;
	uint m_lastFrame;
	uint m_currentFrame;	
	
	NSTimer				*m_animationTimer;
    NSTimeInterval		m_animationInterval;
	NSTimeInterval		m_timer;
}

// init.
-(id)initWithFirstFrame:(uint)a_firstFrame lastFrame:(uint)a_lastFrame duration:(double)a_duration;
// switch to next frame.
-(void)NextFrame;
// start animation.
-(void)startAnimation;
// stop animation.
-(void)stopAnimation;
// set interval between two frames.
- (void)setAnimationInterval:(NSTimeInterval)interval;
// Get the current frame id.
-(uint)GetCurrentFrame;


@end
