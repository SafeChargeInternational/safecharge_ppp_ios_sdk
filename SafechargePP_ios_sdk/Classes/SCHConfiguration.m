//
//  SCHConfiguration.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/31/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHConfiguration.h"
#import "SCHLogging.h"

@interface SCHConfiguration()

@end


NSString *_SCHPlistConfigurationFile = @"schConfig";

@implementation SCHConfiguration

+(SCHConfiguration*) configurationInstance {
    
    static SCHConfiguration *s_instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        s_instance = [[SCHConfiguration alloc] init];
    });
    
    return s_instance;
}

-(id) init {
    self = [super init];
    if( self ) {
        //try load plist
        if ( [self loadFromPlist] == FALSE ) {
            SCHLog(@"plist file not provided, using default values!!!");
             [self initDefaultConfiguration];
        } else {
            SCHLog(@"plist file loaded");
        }
        
        [self configureCommon];
    }
    return self;
}

-(BOOL) loadFromPlist {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:_SCHPlistConfigurationFile ofType:@"plist"];
    if ( plistPath ) {
        
        NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
        if( plistData == nil ) {
            SCHLog(@"unable to load plist file");
            return FALSE;
        }
        
        NSError *error = nil;
        NSPropertyListFormat propertyListFormat;
        NSDictionary *dictPlist = [NSPropertyListSerialization propertyListWithData:plistData
                                                                            options:NSPropertyListImmutable
                                                                             format:&propertyListFormat
                                                                              error:&error];
        if (error) {
            SCHLog(@"unable to parse the plist file");
            return FALSE;
        }
        
        if( [self initConfigurationDataFromDictionary:dictPlist] == FALSE ) {
            return FALSE;
        }
        
    }
    return TRUE;
}

-(BOOL) initConfigurationDataFromDictionary:(NSDictionary*) dict {
    self->_configurationData = [[SCHConfigurationData alloc] initWithDictionary:dict];
    
    if (self->_configurationData == nil ) {
        SCHLog(@"configuration file not found,falling back to default");
        return FALSE;
    }
    return TRUE;
}

-(void) mergeConfigurationFromDictionary:(NSDictionary*) dict {
    [self->_configurationData mergeWithDictionary:dict];
}

-(void) initDefaultConfiguration {
    self->_configurationData = [[SCHConfigurationData alloc] initWithDefaultSettings];
    
}

-(void) configureCommon {
    //configure common
    self->_RequestTextEncoding = @"utf-8";
    self->_paymentCheckSumMethod = E_SCH_CHECKSUM_MD5;
    self->_whitdrawCheckSumMethod = E_SCH_CHECKSUM_MD5;
    
    //apple pay supp
    self->_supportedNetworks = @[PKPaymentNetworkAmex,PKPaymentNetworkChinaUnionPay,PKPaymentNetworkDiscover,
                                 PKPaymentNetworkInterac,PKPaymentNetworkMasterCard,PKPaymentNetworkPrivateLabel,
                                 PKPaymentNetworkVisa]; //ios 8.0 - 9.3 supported
    
                                //PKPaymentNetworkJCB NS_AVAILABLE_IOS(10_1)
                                //PKPaymentNetworkSuica NS_AVAILABLE_IOS(10_1)
    
    self->_allowApplePay = TRUE;
    self->_merchantCapabilities = PKMerchantCapabilityCredit|PKMerchantCapabilityDebit|PKMerchantCapability3DS; //default
    self->_applePaySupport = [self updateApplePaySupport];
    self->_applePayTitile = @"Total ammount:";
    self->_enableWebViewScroll = @1;
}

-(BOOL) updateApplePayMerchantCapabilities:(NSUInteger) capabilities {
    self->_merchantCapabilities = capabilities;
    return [self updateApplePaySupport] != SCHApplePaySupportNotSupported;
    
}

-(SCHApplePaySupport) updateApplePaySupport {
    if( !self.allowApplePay ) {
        return SCHApplePaySupportNotSupported;
    }
    if ( [PKPaymentAuthorizationViewController class] == nil || [PKPaymentAuthorizationViewController canMakePayments] == FALSE ) {
        return SCHApplePaySupportNotSupported;
    }
    
    if ( [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self->_supportedNetworks capabilities:self->_merchantCapabilities] == FALSE ) {
        return SCHApplePaySupportSupportedNoCard;
    }
    
    return SCHApplePaySupportSupported;
}

@end
