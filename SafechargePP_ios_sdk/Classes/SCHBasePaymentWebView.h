//
//  SCHBasePaymentWebView.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 4/27/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <UIKit/UIKit.h>

//base payment callbackss
@protocol SCHBaseProtocol <NSObject>

@end

@interface SCHBasePaymentWebView : UIViewController

-(id) initWithRequest:(NSURLRequest*) request;

@end
