//
//  SCHWRequestBuilder.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 2/14/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"
#import "SCHValidatable.h"
#import "SCHItem.h"

@interface SCHWithdrawRequestBuilder : SCHValidatable

-(instancetype) initWithMinAmount:(NSNumber*) minAmount
                        maxAmount:(NSNumber*) maxAmount
                    defaultAmount:(NSNumber*) defaultAmount
                         currency:(NSString*) currency;

@property (nonatomic, strong) NSURL              *baseURL;            // base url
@property (nonatomic, strong) NSNumber           *merchantID;         // merchant_id (64-bit integer)
@property (nonatomic, strong) NSNumber           *merchantSiteID;     // merchant_site_id (64-bit integer)
@property (nonatomic, strong) NSString           *secretKey;
@property (nonatomic, strong) NSString           *userTokenID;        // user_token_id (Char[255])
@property (nonatomic, strong) NSNumber           *minAmount;          // wd_min_amount (double)
@property (nonatomic, strong) NSNumber           *maxAmount;          // wd_max_amount (double)
@property (nonatomic, strong) NSNumber           *defaultAmount;      // wd_amount (double)
@property (nonatomic, strong) NSString           *currency;           // wd_currency (Char[3])
@property (nonatomic, strong) NSString           *version;            // version (4.0.0)

/* Optional Properties */

@property (nonatomic, assign) SCHUserTokenType   userTokenType;      // user_token
@property (nonatomic, strong) NSString           *merchantLocale;     // merchantLocale (Char[5])
@property (nonatomic, strong) NSString           *country;            // country (Char[20])
@property (nonatomic, strong) NSString           *userID;             // userID (string)


-(NSURLRequest*) constructURLRequest;

@end
