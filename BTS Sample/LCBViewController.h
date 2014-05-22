//
//  LCBViewController.h
//  BTS Sample
//
//  Created by Lance Bullock on 5/12/14.
//  Copyright (c) 2014 Lance Bullock. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LCBDownloadHelper.h"

@protocol LCBDownloadStatusDelegate;


@interface LCBViewController : UIViewController <LCBDownloadStatusDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

- (IBAction)startDownload:(id)sender;
- (IBAction)crashApp:(id)sender;

@end
