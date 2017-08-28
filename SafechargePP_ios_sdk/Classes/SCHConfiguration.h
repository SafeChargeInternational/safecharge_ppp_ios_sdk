//
//  SCHConfiguration.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/31/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>
#import "Enums.h"
#import "SCHConfigurationData.h"

@interface SCHConfiguration : NSObject
+(SCHConfiguration*) configurationInstance;

//reinit configuration from dictionary
-(BOOL) initConfigurationDataFromDictionary:(NSDictionary*) dict;
-(BOOL) updateApplePayMerchantCapabilities:(NSUInteger) capabilities;
-(void) mergeConfigurationFromDictionary:(NSDictionary*) dict;

@property (nonatomic,strong,readonly) SCHConfigurationData      *configurationData;

//common
@property (nonatomic,strong,readonly) NSString                  *RequestTextEncoding;

//Apple pay support
@property (nonatomic,assign,readonly) BOOL                      allowApplePay;
@property (nonatomic,assign,readonly) SCHApplePaySupport        applePaySupport;
@property (nonatomic,retain,readonly) NSArray<NSString*>        *supportedNetworks;
@property (nonatomic,assign,readonly) PKMerchantCapability      merchantCapabilities;
@property (nonatomic,strong,readonly) NSString                  *applePayTitile;

//webview
@property (nonatomic,strong,readonly) NSNumber                  *enableWebViewScroll;
@property (nonatomic,assign,readonly) BOOL                      redirectsOnCompletion;

@property (nonatomic,assign) E_SCH_CHECKSUM_METHODS    paymentCheckSumMethod;
@property (nonatomic,assign) E_SCH_CHECKSUM_METHODS    whitdrawCheckSumMethod;


@end
