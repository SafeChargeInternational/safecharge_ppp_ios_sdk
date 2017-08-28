//
//  SCHPPResult.h
//  SafechargePP
//
//  Created by Bozhidar Dimitrov on 2/12/15.
//  Copyright (c) 2015-2016 SafeCharge. All rights reserved.
//


#import <Foundation/Foundation.h>

@class SCHPaymentData;

/// Represents result from payment page.
@interface SCHPPResult : NSObject

@property (nonatomic, strong, readonly) NSString *  status;                     // Status
@property (nonatomic, assign, readonly) double      totalAmount;                // totalAmount
@property (nonatomic, assign, readonly) int         transactionID;              // TransactionID
@property (nonatomic, strong, readonly) NSString *  clientUniqueID;             // ClientUniqueID
@property (nonatomic, assign, readonly) int         errorCode;                  // ErrCode
@property (nonatomic, assign, readonly) int         extendedErrorCode;          // ExErrCode
@property (nonatomic, assign, readonly) int         authenticationCode;         // AuthCode
@property (nonatomic, strong, readonly) NSString *  reason;                     // Reason
@property (nonatomic, strong, readonly) NSString *  cardToken;                  // Token
@property (nonatomic, assign, readonly) int         reasonCode;                 // ReasonCode
@property (nonatomic, strong, readonly) NSString *  responseChecksum;           // responsechecksum (deprecated)
@property (nonatomic, strong, readonly) NSString *  advanceResponseChecksum;    // advanceResponseChecksum
@property (nonatomic, assign, readonly) int         ECI;                        // ECI
@property (nonatomic, strong, readonly) NSString *  nameOnCard;                 // nameOnCard
@property (nonatomic, strong, readonly) NSString *  currency;                   // currency;
@property (nonatomic, assign, readonly) double      totalDiscount;              // total_discount
@property (nonatomic, assign, readonly) double      totalHandling;              // total_handling
@property (nonatomic, assign, readonly) double      totalShipping;              // total_shipping
@property (nonatomic, assign, readonly) double      totalTax;                   // total_tax
@property (nonatomic, strong, readonly) NSArray *   items;
@property (nonatomic, strong, readonly) NSString *  customData;                 // customData
@property (nonatomic, strong, readonly) NSString *  merchantUniqueID;           // merchant_unique_id
@property (nonatomic, assign, readonly) long long   merchantSiteID;             // merchant_site_id
@property (nonatomic, assign, readonly) long long   merchantID;                 // merchant_id
@property (nonatomic, strong, readonly) NSString *  requestVersion;             // requestVersion
@property (nonatomic, strong, readonly) NSString *  message;                    // message
@property (nonatomic, strong, readonly) NSString *  error;                      // Error
@property (nonatomic, strong, readonly) NSString *  instantDMNStatus;           // instantDmnStatus
@property (nonatomic, assign, readonly) long long   PPPTransactionID;           // PPP_TransactionID
@property (nonatomic, strong, readonly) NSString *  userID;                     // UserID
@property (nonatomic, strong, readonly) NSString *  productID;                  // ProductID
@property (nonatomic, strong, readonly) NSString *  PPPStatus;                  // ppp_status
@property (nonatomic, strong, readonly) NSString *  merchantLocale;             // merchantLocale
@property (nonatomic, strong, readonly) NSString *  unknownParameters;          // unknownParameters
@property (nonatomic, strong, readonly) NSString *  webMasterID;                // webMasterID
@property (nonatomic, strong, readonly) NSString *  customField1;               // customField1
@property (nonatomic, strong, readonly) NSString *  customField2;               // customField2
@property (nonatomic, strong, readonly) NSString *  customField3;               // customField3
@property (nonatomic, strong, readonly) NSString *  customField4;               // customField4
@property (nonatomic, strong, readonly) NSString *  customField5;               // customField5
@property (nonatomic, strong, readonly) NSString *  customField6;               // customField6
@property (nonatomic, strong, readonly) NSString *  customField7;               // customField7
@property (nonatomic, strong, readonly) NSString *  customField8;               // customField8
@property (nonatomic, strong, readonly) NSString *  customField9;               // customField9
@property (nonatomic, strong, readonly) NSString *  customField10;              // customField10
@property (nonatomic, strong, readonly) NSString *  customField11;              // customField11
@property (nonatomic, strong, readonly) NSString *  customField12;              // customField12
@property (nonatomic, strong, readonly) NSString *  customField13;              // customField13
@property (nonatomic, strong, readonly) NSString *  customField14;              // customField14
@property (nonatomic, strong, readonly) NSString *  customField15;              // customField15

@property (nonatomic, strong, readonly) NSURL *resultURL;

@property (nonatomic,assign, readonly ) BOOL        isApplePayResult;

- (instancetype)initWithURL:(NSURL *)resultURL;
- (instancetype)initWithEventData:(SCHPaymentData*) data;

@end
