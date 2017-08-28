//
//  SCHExceptionHelper.h
//  SafechargePPP
//
//  Created by Bozhidar Dimitrov on 2/9/15.
//  Copyright (c) 2015-2016 SafeCharge. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface SCHExceptionHelper : NSObject

+ (void)throwInternalInconsistencyExceptionWithReason:(NSString *)reason;
+ (void)throwInvalidArgumentExceptionWithReason:(NSString *)reason;

@end
