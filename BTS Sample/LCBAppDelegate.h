//
//  LCBAppDelegate.h
//  BTS Sample
//
//  Created by Lance Bullock on 5/12/14.
//  Copyright (c) 2014 Lance Bullock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy) void (^backgroundCompletionHandler)();

@end
