//
//  BWLiveLogViewController.h
//  TravisCI
//
//  Created by Bradley Grzesiak on 1/17/12.
//  Refer to MIT-LICENSE file at root of project for copyright info
//

#import <UIKit/UIKit.h>

@class BWJob;

@interface BWLiveLogViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) BWJob *job;

@end
