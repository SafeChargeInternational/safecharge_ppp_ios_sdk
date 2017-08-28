//
//  SCHPaymentPageProtocol.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 2/14/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SCHPPResult;
@class SCHWebKitPaymentViewController;

@protocol SCHPaymentPageProtocol <NSObject>

- (void)paymentPageController:(SCHWebKitPaymentViewController *)paymentPageController
          didFinishWithResult:(SCHPPResult *)result;

- (void)paymentPageController:(SCHWebKitPaymentViewController *)paymentPageController
    didFailLoadPaymentPageWithError:(NSError *)error;

@end
