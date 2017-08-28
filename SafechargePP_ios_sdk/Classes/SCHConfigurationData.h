//
//  SCHConfigurationData.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 2/10/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h" 

@interface SCHConfigurationData : NSObject < NSSecureCoding >

-(nullable id) initWithDefaultSettings;
-(nullable instancetype) initWithDictionary:(nonnull NSDictionary*) dict;

-(void) mergeWithDictionary:(nonnull NSDictionary*) dict;

-(nullable NSString*) stringFromChecksumEnum:(E_SCH_CHECKSUM_METHODS) method;
-(E_SCH_CHECKSUM_METHODS) checkSumMethodFromString:(nonnull NSString*) inputStr;

//merchant config
@property (nonatomic,strong,readonly,nonnull) NSString              *secretKey;
@property (nonatomic,strong,readonly,nonnull) NSString              *merchantId;
@property (nonatomic,strong,readonly,nonnull) NSString              *merchantSiteID;
@property (nonatomic,strong,readonly,nonnull) NSString              *userTokenId;

//PPP config
@property (nonatomic,strong,readonly,nonnull) NSString              *PPPRequestVersion;
@property (nonatomic,strong,readonly,nonnull) NSString              *SCHSafeChargePPPServerURL;

//Withdraw config
@property (nonatomic,strong,readonly,nonnull) NSString              *SCHSafeChargeWithdrawServerURL;
@property (nonatomic,strong,readonly,nonnull) NSString              *whitdrawRequestVersion;



//common
@property (nonatomic,strong,readonly,nonnull) NSString                  *RequestTextEncoding;
@property (nonatomic,assign,readonly)         E_SCH_CHECKSUM_METHODS    paymentCheckSumMethod;
@property (nonatomic,assign,readonly)         E_SCH_CHECKSUM_METHODS    whitdrawCheckSumMethod;

@end
