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

@property (strong, nonatomic) NSTimer *stopWatchTimer;
@property (strong, nonatomic) NSDate *startDate;
@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger step1;
@property (nonatomic) NSInteger step2;
@property (nonatomic) double seconds;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.screenName = [NSString stringWithFormat:@"%@", [self class]];
    
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

#pragma mark - Timer

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

#pragma mark - MotionManager

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

/**
 * So, the big main problem here is that pitch rotation does not go through all 360 degrees,
 * instead of that, the values are between -90 and 90 degrees, passing by 0 degrees twice for a full rotation.
 * Then, we cannot rely on checking how many times we pass by some value (because it would depend on 
 * the rotation speed and update frequency), some tricks are used in the following code in order to 'guess' 
 * if a full rotation has been completed.
 *
 * For better understanding of the following code, considering a halfAngle variable of 45 degrees, the zones are:
 * A) From -45 in the 4th quadrant to 45 in the 1st quadrant (315 to 45 for a full 360 degrees circumference).
 * B) From 45 in the 1st quadrant to 45 in the 2nd quadrant (45 to 135 for a full 360 degrees circumference).
 * C) From 45 in the 2nd quadrant to -45 in the 3rd quadrant (135 to 225 for a full 360 degrees circumference).
 * D) From -45 in the 3rd quadrant to -45 in the 4th quadrant (225 to 315 for a full 360 degrees circumference).
 */
- (void)startMyMotionDetect
{
    NSInteger halfAngle = 45;
    
    [self.motionManager
     startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMDeviceMotion *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            if(self.stopButton.enabled)
                            {
                                CMAttitude *currentAttitude = data.attitude;
                                
                                // Converted to degrees for easier understanding
                                NSInteger pitch = roundf((float)(RADIANS_TO_DEGREES(currentAttitude.pitch)));
                                
                                // Check if we have passed by the B zone
                                if(!self.step1 && pitch>90-halfAngle)
                                {
                                    self.step1 = YES;
                                }
                                // Check if we have passed by the D zone
                                else if(!self.step2 && pitch<-90+halfAngle)
                                {
                                    self.step2 = YES;
                                }
                                
                                // If we have been at least once in the B and D zones and we are now in either
                                // the A or C zones, then we can assume that one rotation has been completed.
                                if(pitch>(-90+halfAngle) && pitch<(90-halfAngle) && self.step1 && self.step2)
                                {
                                    self.count++;
                                    self.step1 = NO;
                                    self.step2 = NO;
                                    self.flipsCounterLabel.text = [NSString stringWithFormat:@"%ld", (long)self.count];
                                }
                            }
                        }
                    );
     }
     ];
    
}

#pragma mark - Share

- (IBAction)shareButtonPressed:(id)sender {
    
    if( NSClassFromString (@"UIActivityViewController") ) {
        
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
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
