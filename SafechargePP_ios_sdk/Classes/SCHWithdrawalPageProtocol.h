//
//  SCHWithdrawalPageDelegate.h
//  SafechargePP
//
//  Created by Bozhidar Dimitrov on 5/18/15.
//  Copyright (c) 2015-2016 SafeCharge. All rights reserved.
//


#import <Foundation/Foundation.h>

@class SCHWebKitWithdrawViewController;


@protocol SCHWithdrawalPageProtocol <NSObject>

- (void) withdrawalPageController:(SCHWebKitWithdrawViewController *)withdrawalPageController
         didFailLoadWithdrawalPageWithError:(NSError *)error;

@end
