//
//  AppDelegate.h
//  Flip your phone!
//
//  Created by Abel Pascual on 04/03/14.
//  Copyright (c) 2014 Abel Pascual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    CMMotionManager *motionManager;
}

@property (readonly) CMMotionManager *motionManager;
@property (strong, nonatomic) UIWindow *window;

@end
