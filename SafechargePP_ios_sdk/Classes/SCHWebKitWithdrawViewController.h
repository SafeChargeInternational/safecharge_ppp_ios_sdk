//
//  SCHWebKitWithdrawViewController.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 2/10/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHWithdrawalPageProtocol.h"


//fw
@class SCHWithdrawRequestBuilder;

@interface SCHWebKitWithdrawViewController : UIViewController

- (instancetype) initWithSCHRequestBuilder:(SCHWithdrawRequestBuilder *) schRequest;

@property (nonatomic,weak) id<SCHWithdrawalPageProtocol> delegate;

@end
