//
//  Enums.h
//  SafechargePP
//
//  Created by Bozhidar Dimitrov on 5/15/15.
//  Copyright (c) 2015-2016 SafeCharge. All rights reserved.
//


#include <Foundation/Foundation.h>

#pragma once


typedef NS_ENUM(NSInteger, SCHApplePaySupport)
{
    SCHApplePaySupportNotSupported,
    SCHApplePaySupportSupportedNoCard,
    SCHApplePaySupportSupported
};

typedef NS_ENUM(NSInteger, SCHUserTokenType)
{
    SCHUserTokenTypeAuto,
    SCHUserTokenTypeRegister,
    SCHUserTokenTypeReadonly
};

typedef NS_ENUM(NSInteger, SCHHTTPMethod)
{
    SCHHTTPMethodGET,
    SCHHTTPMethodPOST
};

typedef enum : NSUInteger {
    E_SCH_CHECKSUM_MD5 = 0, //default
    E_SCH_CHECKSUM_SHA256 = 1,
} E_SCH_CHECKSUM_METHODS;



extern NSString * NSStringFromUserTokenType(SCHUserTokenType userTokenType);
