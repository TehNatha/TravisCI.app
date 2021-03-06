//
//  BWPadJobDetailViewController.h
//  TravisCI
//
//  Created by Bradley Grzesiak on 1/16/12.
//  Refer to MIT-LICENSE file at root of project for copyright info
//

#import <UIKit/UIKit.h>

@class BWCDJob;

@interface BWPadJobDetailViewController : UIViewController

@property (nonatomic, strong) BWCDJob *job;

@property (readonly) UILabel *finishedLabel;
@property (readonly) UILabel *durationLabel;
@property (readonly) UILabel *commitLabel;
@property (readonly) UILabel *compareLabel;
@property (readonly) UILabel *authorLabel;
@property (readonly) UILabel *messageLabel;
@property (readonly) UILabel *configLabel;
@property (readonly) UILabel *logLabel;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UITextView *largeTextArea;
@property (strong, nonatomic) IBOutlet UISegmentedControl *largeTextAreaToggle;

- (void)askToViewSafariForCompare;

@end
