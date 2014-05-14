//
//  LCBViewController.m
//  BTS Sample
//
//  Created by Lance Bullock on 5/12/14.
//  Copyright (c) 2014 Lance Bullock. All rights reserved.
//

#import "LCBViewController.h"

@interface LCBViewController ()

@end

@implementation LCBViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.downloadLabel.text = @"";
	self.downloadProgressView.progressViewStyle = UIProgressViewStyleDefault;
	self.downloadProgressView.progress = 0.0;
	self.downloadProgressView.hidden = YES;
	
	// We need this to sync up with the running session after a crash (not just suspended/backgrounded)
	[self getDownloadHelper].delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDownload:(id)sender
{
	self.downloadProgressView.hidden = NO;
	self.downloadProgressView.progress = 0.0;
	self.downloadLabel.text = @"Starting Download...";
	[[self getDownloadHelper] addDownloadTask:@"http://www.wswd.net/testdownloadfiles/10MB.zip"];
	
}

-(LCBDownloadHelper*)getDownloadHelper
{
	LCBDownloadHelper *downloadHelper = [LCBDownloadHelper downloadHelperForIdentifier:@"com.lcb.ui.download.task"];
	downloadHelper.delegate = self;
	return downloadHelper;
}

- (IBAction)crashApp:(id)sender
{
	// Download will still be in progress after relaunching app.
	NSException *nse = [NSException exceptionWithName:@"App Crash" reason:@"Simulated" userInfo:nil];
	[nse raise];
}


#pragma mark - LCBDownloadStatusDelegate implementation.

- (void)bytesReceived:(long long)receivedBytes ofTotal:(long long)totalBytes
{
	self.downloadProgressView.progress = (float)receivedBytes / (float)totalBytes;
	self.downloadLabel.text = [NSString stringWithFormat:@"%lld of %lld bytes received.", receivedBytes, totalBytes];
}

-(void)downloadFinished
{
	self.downloadLabel.text = @"Download Complete!";
	self.downloadProgressView.Hidden = YES;
}

-(void)downloadError
{
	self.downloadLabel.text = @"Error in download.";
	self.downloadProgressView.hidden = YES;
}

-(void)sessionActive
{
	self.downloadLabel.text = @"Connecting to running session...";
	self.downloadProgressView.hidden = NO;
	
}

@end
