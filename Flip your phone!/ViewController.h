//
//  ViewController.h
//  Flip your phone!
//
//  Created by Abel Pascual on 04/03/14.
//  Copyright (c) 2014 Abel Pascual. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleAnalytics-iOS-SDK/GAITrackedViewController.h>

@interface ViewController : GAITrackedViewController

@property (strong, nonatomic) NSTimer *stopWatchTimer;
@property (strong, nonatomic) NSDate *startDate;
@property (nonatomic) NSInteger last_position;
@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger step1;
@property (nonatomic) NSInteger step2;

@property (nonatomic) double seconds;

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *flipsCounterLabel;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;


@end
