//
//  LCBViewController.m
//  BTS Sample
//
//  Created by Lance Bullock on 5/12/14.
//  Copyright (c) 2014 Lance Bullock. All rights reserved.
//

#import "LCBViewController.h"



NSString * const FILE_TO_DOWNLOAD = @"http://www.wswd.net/testdownloadfiles/10MB.zip";

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
	self.statusLabel.text = FILE_TO_DOWNLOAD;
	self.downloadProgressView.hidden = NO;
	self.downloadProgressView.progress = 0.0;
	self.downloadLabel.text = @"Starting Download...";
	self.downloadButton.enabled = NO;
	[[self getDownloadHelper] downloadFile:FILE_TO_DOWNLOAD];
	
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

- (void)bytesReceived:(long long)receivedBytes ofTotal:(long long)totalBytes forFile:(NSString *)url
{
	self.downloadProgressView.progress = (float)receivedBytes / (float)totalBytes;
	self.downloadLabel.text = [NSString stringWithFormat:@"%lld of %lld KB received", receivedBytes>>10, totalBytes>>10];
}

-(void)downloadFinishedForFile:(NSString *)url newFileLocation:(NSString *)localFileUrl
{
	self.downloadButton.enabled = YES;
	self.statusLabel.text = url;
	self.downloadLabel.text = [NSString stringWithFormat:@"Download completed."];
	self.downloadProgressView.Hidden = YES;
}

-(void)downloadErrorForFile:(NSString *)url
{
	self.downloadButton.enabled = YES;
	self.statusLabel.text = url;
	self.downloadLabel.text = [NSString stringWithFormat:@"Error downloading"];
	self.downloadProgressView.hidden = YES;
}

-(void)downloadResumedForFile:(NSString *)url
{
	self.statusLabel.text = [NSString stringWithFormat:@"Resumed download for %@",url];
	
}

-(void)sessionActive
{
	self.downloadButton.enabled = NO;
	self.downloadLabel.text = @"Connecting to running session...";
	self.downloadProgressView.hidden = NO;
}

@end
