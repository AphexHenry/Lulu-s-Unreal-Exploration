//
//  Animation.m
//  Particles
//
//  Created by Baptiste Bohelay on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Animation.h"

#define UPDATE_INTERVAL 1. / 40.


@implementation Animation

// init.
-(id)initWithFirstFrame:(uint)a_firstFrame lastFrame:(uint)a_lastFrame duration:(double)a_duration
{
	m_currentFrame = m_firstFrame = a_firstFrame;
	m_lastFrame = a_lastFrame;
	
    self = [super init];
    
	m_animationInterval = a_duration/(double)(a_lastFrame - a_firstFrame);
	m_timer = m_animationInterval;
	return self;
}

// switch to next frame.
-(void)NextFrame
{
	m_timer -= UPDATE_INTERVAL;
	if(m_timer <= 0.)
	{
		m_timer = m_animationInterval;
		m_currentFrame = (m_currentFrame >= m_lastFrame) ? m_firstFrame : (m_currentFrame + 1);
	}
}

// start animation.
-(void)startAnimation 
{
    m_animationTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_INTERVAL target:self selector:@selector(NextFrame) userInfo:nil repeats:YES];
}

// stop animation.
-(void)stopAnimation
{
    [m_animationTimer invalidate];
}

// set interval between two frames.
- (void)setAnimationInterval:(NSTimeInterval)a_interval
{    
    m_animationInterval = a_interval / (float)(m_lastFrame - m_firstFrame);
}

// Get the current frame id.
-(uint)GetCurrentFrame
{
	return m_currentFrame;
}

@end
