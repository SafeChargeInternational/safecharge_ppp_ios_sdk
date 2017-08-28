//
//  SCHApplePayment.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/26/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

@interface SCHApplePayment : NSObject
{
@public
    void (^completitionBlock)(PKPaymentAuthorizationStatus);
}
@end
