//
//  ViewController.m
//  Flip your phone!
//
//  Created by Abel Pascual on 04/03/14.
//  Copyright (c) 2014 Abel Pascual. All rights reserved.
//

#import "ViewController.h"
#import "MyActivityItemProvider.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.resetButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startMyMotionDetect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.motionManager stopAccelerometerUpdates];
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)shareButtonPressed:(id)sender {
    
    if( NSClassFromString (@"UIActivityViewController") ) {
        
        /*UIImage *image = [self screenshot];
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            image = [image imageRotatedByDegrees:90.0];
        }
        else if(interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            image = [image imageRotatedByDegrees:-90.0];
        }
        
        
        NSData * data = UIImagePNGRepresentation(image);
        */

        double rpm = 0.0f;
        
        if(self.count>0 && self.seconds>0)
            rpm = (self.count*60)/self.seconds;
        
        NSString* someText = [NSString stringWithFormat:@"I have flipped my phone %ld times in %@, that is a speed of %.3f rpm. Do you think you can beat me?", (long)self.count, self.timerLabel.text, rpm];

        MyActivityItemProvider *maip = [[MyActivityItemProvider alloc] init];
        [maip setInicioMensaje:someText];
        
        NSArray* dataToShare = @[maip];
        
        UIActivityViewController* activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        [activityViewController setExcludedActivityTypes:
         @[UIActivityTypeMessage, UIActivityTypeAssignToContact]];
        [self presentViewController:activityViewController animated:YES completion:^{}];
    }
}


- (IBAction)startButtonPressed:(id)sender {
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    self.resetButton.enabled = NO;
    
    self.infoButton.enabled = NO;
    self.shareButton.enabled = NO;
    
    self.startDate = [NSDate date];
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                           target:self
                                                         selector:@selector(updateTimer)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (IBAction)stopButtonPressed:(id)sender {
    self.startButton.enabled = NO;
    self.stopButton.enabled = NO;
    self.resetButton.enabled = YES;
    
    self.infoButton.enabled = YES;
    self.shareButton.enabled = YES;
    
    [self.stopWatchTimer invalidate];
    self.stopWatchTimer = nil;
    [self updateTimer];
}

- (IBAction)resetButtonPressed:(id)sender {
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.resetButton.enabled = NO;
 
    self.flipsCounterLabel.text = @"0";
    self.count = 0;
    self.timerLabel.text = @"00:00.000";
}

- (void)updateTimer
{
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    self.seconds = timeInterval;
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.timerLabel.text = timeString;
}

/** Core Manager **/

- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    return motionManager;
}

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

- (void)startMyMotionDetect
{
    [self.motionManager
     startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMDeviceMotion *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            if(self.stopButton.enabled)
                            {
                                CMAttitude *currentAttitude = data.attitude;
                                float yaw = roundf((float)(RADIANS_TO_DEGREES(currentAttitude.pitch)));
                                
                                int positionIn360 = yaw;
                                if (positionIn360 < 0) {
                                    positionIn360 = 360 + positionIn360;
                                }
                                
                                //NSLog(@"360Pos: %d", positionIn360);
                                if(positionIn360!=self.last_position)
                                {
                                    if(positionIn360>self.last_position)
                                    {
                                        // Still spining
                                        self.last_position = positionIn360;
                                        //NSLog(@"360Pos: %d", positionIn360);
                                    }
                                    else
                                    {
                                        if(positionIn360>0&&positionIn360<45&&self.last_position>315&&self.last_position<=360&&self.step1&&self.step2)
                                        {
                                            self.last_position = positionIn360;
                                            self.count++;
                                            self.step1 = NO;
                                            self.step2 = NO;
                                            self.flipsCounterLabel.text = [NSString stringWithFormat:@"%ld", (long)self.count];
                                        }
                                    }
                                    
                                    if(positionIn360>45&&positionIn360<90)
                                    {
                                        //NSLog(@"Paso1: %d", positionIn360);
                                        self.step1 = YES;
                                    }
                                    
                                    if(positionIn360>270&&positionIn360<315)
                                    {
                                        //NSLog(@"Paso2: %d", positionIn360);
                                        self.step2 = YES;
                                    }
                                }
                            }
                        }
                        );
     }
     ];
    
}


@end
