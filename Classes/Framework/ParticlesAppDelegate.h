//
//  ParticlesAppDelegate.h
//  Particles
//
//  Created by Baptiste Bohelay on 1/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ParticleViewController;

@interface ParticlesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ParticleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ParticleViewController *viewController;

@end

