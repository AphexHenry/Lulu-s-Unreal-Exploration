//
//  ParticlesAppDelegate.m
//  Particles
//
//  Created by Baptiste Bohelay on 1/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ApplicationManager.h"
#import "ParticlesAppDelegate.h"
#import "ParticleViewController.h"


@implementation ParticlesAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
}

// When going home.
- (void)applicationWillResignActive:(UIApplication *)application 
{
	[[ApplicationManager sharedApplicationManager] Stop:TRUE];
}

// When return to the game.
- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	ApplicationManager * l_applicationManager = [ApplicationManager sharedApplicationManager];
	[l_applicationManager Stop:FALSE];
	
	// get current date/time

//	if(l_hour < 19 && l_hour > 8)
//	{
//		// day
//		[[viewController m_viewDay] setHidden:FALSE];
//	}
//	else
//	{
		// night.
//	}

}

-(void)applicationWillTerminate:(UIApplication *)application
{
	[[ApplicationManager sharedApplicationManager] Finnish];
}

- (void)dealloc 
{
	[super dealloc];
}

@end
