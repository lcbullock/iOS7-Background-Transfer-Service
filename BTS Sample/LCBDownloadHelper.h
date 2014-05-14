//
//  LCBDownloadHelper.h
//  BTS Sample
//
//  Created by Lance Bullock on 5/12/14.
//  Copyright (c) 2014 Lance Bullock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LCBDownloadStatusDelegate <NSObject>

-(void)bytesReceived:(long long)receivedBytes ofTotal:(long long)totalBytes;
-(void)downloadFinished;
-(void)downloadError;
-(void)sessionActive;

@end

@interface LCBDownloadHelper : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) NSObject<LCBDownloadStatusDelegate> *delegate;
@property (copy) void (^backgroundCompletionHandler)();

+(instancetype)downloadHelperForIdentifier:(NSString*)identifier;

-(void)addDownloadTask:(NSString*)urlString;
-(id)initWithIdentifier:(NSString*)identifier;

@end
