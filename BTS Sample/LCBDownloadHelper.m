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
	NSMutableDictionary *_resumeData;
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
			_helpers = [[NSMutableDictionary alloc] init];

			//TODO: persist resume data and load from filesystem
			_resumeData = [[NSMutableDictionary alloc] init];

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

-(void)downloadFile:(NSString*)urlString
{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	NSURLSessionDownloadTask *downloadTask;
	
	NSData *resumeData = [_resumeData objectForKey:urlString];
	
	if (resumeData != nil)
	{
		downloadTask = [_session downloadTaskWithResumeData:resumeData];
	}
	
	//(undocumented) downloadTaskWithResumeData returns nil if cannot be resumed (e.g. temp file deleted)
	if (downloadTask == nil)
	{
		//Throw away resume data, no good.
		[_resumeData removeObjectForKey:urlString];
		downloadTask = [_session downloadTaskWithRequest:request];
	}
	else
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_delegate downloadResumedForFile:urlString];
		});
	}
	
	[downloadTask resume];
}

-(void)setDelegate:(NSObject<LCBDownloadStatusDelegate> *)delegate
{
	// When we connect a UI delegate, the session could be running tasks if app previously crashed. Notify UI delegate asynchronously if so.
	if (_delegate != delegate)
	{
		_delegate = delegate;
		[_session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
			if (downloadTasks.count > 0)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					[_delegate sessionActive];
				});
				
			}
		}];
	}
}

#pragma mark - NSURLSessionDelegate implementation

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
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
		[_delegate downloadFinishedForFile:originalURL.absoluteString newFileLocation:destinationURL.absoluteString];
	});
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
	// iOS Bug? This callback never seems to be called.
	NSLog(@"%@",@"ResumeAtOffset delegate callback received.");
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[_delegate bytesReceived:totalBytesWritten ofTotal:totalBytesExpectedToWrite forFile:downloadTask.originalRequest.URL.absoluteString];
	});
	
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	//TODO: Check response code to report server side errors
	if (error == nil)
	{
		[_resumeData removeObjectForKey:task.originalRequest.URL.absoluteString];
	}
	else
	{
		//??: Linker cannot seem to find NSURLErrorBackgroundTaskCancelledReasonKey const, even though I see it in header.
		//id cancelReason = [error.userInfo objectForKey:NSURLErrorBackgroundTaskCancelledReasonKey];
		
		NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
		if (resumeData != nil)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[_resumeData setObject:resumeData forKey:task.originalRequest.URL.absoluteString];
				[_delegate downloadErrorForFile:task.originalRequest.URL.absoluteString];
			});
		}
	
	}
}





@end
