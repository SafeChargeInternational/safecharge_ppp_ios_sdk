//
//  SCHWebKitLocal.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/25/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import "SCHPaymentPageProtocol.h"

@class SCHPaymentRequestBuilder;

@interface SCHWebKitPaymentViewController : UIViewController <PKPaymentAuthorizationViewControllerDelegate>


-(instancetype) initWithSCHRequestBuilder:(SCHPaymentRequestBuilder *) schRequestBuilder;
-(instancetype) initWithURLRequest:(NSURLRequest*) request;

@property (nonatomic,weak) id<SCHPaymentPageProtocol> delegate;

@end
