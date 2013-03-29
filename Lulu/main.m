//
//  main.m
//  Particles
//
//  Created by Baptiste Bohelay on 1/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ParticlesAppDelegate.h"

int main(int argc, char *argv[]) 
{    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
//    return retVal;
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ParticlesAppDelegate class]));
    }
}
