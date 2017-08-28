//
//  SCHExceptionHelper.m
//  SafechargePP
//
//  Created by Bozhidar Dimitrov on 2/9/15.
//  Copyright (c) 2015-2016 SafeCharge. All rights reserved.
//


#import "SCHExceptionHelper.h"


@implementation SCHExceptionHelper


#pragma mark - Public Class Methods

+ (void)throwInternalInconsistencyExceptionWithReason:(NSString *)reason
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

+ (void)throwInvalidArgumentExceptionWithReason:(NSString *)reason
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
}

@end
