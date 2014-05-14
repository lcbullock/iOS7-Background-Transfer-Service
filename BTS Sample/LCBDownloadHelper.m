//
//  LCBDownloadHelper.m
//  BTS Sample
//
//  Created by Lance Bullock on 5/12/14.
//  Copyright (c) 2014 Lance Bullock. All rights reserved.
//

#import "LCBDownloadHelper.h"

static NSMutableDictionary *_helpers;

@implementation LCBDownloadHelper
{
	NSURLSession *_session;
	NSData *_resumeData;
}

+(instancetype)downloadHelperForIdentifier:(NSString*)identifier
{
	@synchronized(self)
	{
		LCBDownloadHelper *helper = [_helpers objectForKey:identifier];
		return (helper != nil)?helper:[[self alloc] initWithIdentifier:identifier];
	}
}

-(id)init
{
	return [self initWithIdentifier:@"com.lcb.long_download_tasks"];
}


-(id)initWithIdentifier:(NSString*)identifier
{
	if (self = [super init])
	{
		@synchronized(self)
		{
			if (_helpers == nil)
			{
				_helpers = [[NSMutableDictionary alloc] init];
			}
			// We can have multiple helper classes using NSURLSession, so we cannot use dispatch_once here due to
			// static predicate requirement.
			if (_session == nil)
			{
				_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:identifier] delegate:self delegateQueue:nil];
				[_helpers setObject:self forKey:identifier];
			}
		};
	}
	return self;
}

-(void)addDownloadTask:(NSString*)urlString
{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithRequest:request];
	[downloadTask resume];
}

-(void)setDelegate:(NSObject<LCBDownloadStatusDelegate> *)delegate
{
	// When we connect a UI delegate, the session could be running tasks if app previously crashed. Notify UI delegate asynchronously if so.
	_delegate = delegate;
	[_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
		if (downloadTasks.count > 0)
		{
			NSLog(@"Queuing session active");
			dispatch_async(dispatch_get_main_queue(), ^{
				[_delegate sessionActive];
			});
			
		}
	}];
}

#pragma mark - NSURLSessionDelegate implementation

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
	NSLog(@"Session Complete");
	void (^completionHandler)() = self.backgroundCompletionHandler;
	self.backgroundCompletionHandler = nil;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		completionHandler();
	});
	
	[session invalidateAndCancel];
	[_helpers removeObjectForKey:session.configuration.identifier];
}

#pragma mark - NSURLSessionDownloadDelegate implementation

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
	
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
	
    [fileManager removeItemAtURL:destinationURL error:NULL];
    [fileManager copyItemAtURL:location toURL:destinationURL error:&errorCopy];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[_delegate downloadFinished];
	});
	NSLog(@"Finished Downloading");
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
	
	NSLog(@"Resuming");
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
	//NSLog(@"%lld of %lld bytes from session: %@", totalBytesWritten, totalBytesExpectedToWrite, downloadTask.description);

	dispatch_async(dispatch_get_main_queue(), ^{
		[_delegate bytesReceived:totalBytesWritten ofTotal:totalBytesExpectedToWrite];
	});
	
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	NSLog(@"Completed with error");
}





@end
