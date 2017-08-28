//
//  SCHConfigurationData.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 2/10/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHConfigurationData.h"
#import "Enums.h"
#import "SCHLogging.h"
#import "SCHConstants.h"

@implementation SCHConfigurationData

-(id) initWithDefaultSettings {
    self = [super init];
    if( self ) {
        [self loadDefaultsIfNotSet];
    }
    return self;
}

-(NSString*) stringFromChecksumEnum:(E_SCH_CHECKSUM_METHODS) method {
    if( method == E_SCH_CHECKSUM_MD5 ) {
        return @"MD5";
    } else if ( method == E_SCH_CHECKSUM_SHA256 ) {
        return @"SHA256";
    }
    SCHAssert(false);
    return @"";
}

-(E_SCH_CHECKSUM_METHODS) checkSumMethodFromString:(NSString*) inputStr {
    if ( inputStr == nil || [inputStr isKindOfClass:[NSString class] ] == FALSE ){
        SCHLog(@"invalid ehecksum entry, using default");
        return E_SCH_CHECKSUM_MD5; //default
    }
    
    if ( [inputStr isEqualToString:@"MD5"] ) {
        return E_SCH_CHECKSUM_MD5;
    } else if ( [inputStr isEqualToString:@"SHA256"] ) {
        return E_SCH_CHECKSUM_SHA256;
    } else {
        return E_SCH_CHECKSUM_MD5; //default
    }
}

-(void) loadDefaultsIfNotSet {
    if( self->_PPPRequestVersion==nil ) {
        self->_PPPRequestVersion = DefaultPPPRequestVersion;
    }
    if( self->_SCHSafeChargePPPServerURL == nil ) {
        self->_SCHSafeChargePPPServerURL = DefaultSCHSafeChargePPPServerURL;
    }
    if( self->_SCHSafeChargeWithdrawServerURL == nil ) {
        self->_SCHSafeChargeWithdrawServerURL = DefaultSCHSafeChargeWithdrawServerURL;
    }
    if( self->_whitdrawRequestVersion == nil ) {
        self->_whitdrawRequestVersion = DefaultWhitdrawRequestVersion;
    }
    
    //checksum methods are always reinitialized
    self->_paymentCheckSumMethod = [self checkSumMethodFromString:DefaultcheckSumMethod];
    self->_whitdrawCheckSumMethod = [self checkSumMethodFromString:DefaultcheckSumMethod];

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//NSCoding
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)supportsSecureCoding {
    return TRUE;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    if ( aCoder ){
        [aCoder encodeObject:self->_PPPRequestVersion                            forKey:@"PPPRequestVersion"];
        [aCoder encodeObject:self->_SCHSafeChargePPPServerURL                    forKey:@"SCHSafeChargePPPServerURL"];
        [aCoder encodeObject:self->_SCHSafeChargeWithdrawServerURL               forKey:@"SCHSafeChargeWithdrawServerURL"];
        
        [aCoder encodeObject:self->_whitdrawRequestVersion                       forKey:@"WhitdrawRequestVersion"];
        
        [aCoder encodeObject:self->_secretKey                                    forKey:@"SecretKey"];
        [aCoder encodeObject:self->_merchantId                                   forKey:@"MerchantId"];
        [aCoder encodeObject:self->_merchantSiteID                               forKey:@"MerchantSiteID"];
        [aCoder encodeObject:self->_userTokenId                                  forKey:@"UserTokenId"];
        
        [aCoder encodeObject:[self stringFromChecksumEnum:self->_paymentCheckSumMethod]  forKey:@"PaymentCheckSumMethod"];
        [aCoder encodeObject:[self stringFromChecksumEnum:self->_whitdrawCheckSumMethod] forKey:@"WhitdrawCheckSumMethod"];
    }
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if( self ){
        
        id pRequestVersion = [aDecoder decodeObjectForKey:@"PPPRequestVersion"];
        if( pRequestVersion && [pRequestVersion isKindOfClass:[NSString class]] ) {
            self->_PPPRequestVersion              = pRequestVersion;
        }
        
        id pPServerUrl = [aDecoder decodeObjectForKey:@"SCHSafeChargePPPServerURL"];
        if( pPServerUrl && [pPServerUrl isKindOfClass:[NSString class]] ) {
            self->_SCHSafeChargePPPServerURL      = pPServerUrl;
        }
        
        id pWithdrawUrl = [aDecoder decodeObjectForKey:@"SCHSafeChargeWithdrawServerURL"];
        if ( pWithdrawUrl && [pWithdrawUrl isKindOfClass:[NSString class]] ) {
            self->_SCHSafeChargeWithdrawServerURL = pWithdrawUrl;
        }
        
        id pWithdrawVersion = [aDecoder decodeObjectForKey:@"WhitdrawRequestVersion"];
        if( pWithdrawVersion && [pWithdrawVersion isKindOfClass:[NSString class]] ) {
            self->_whitdrawRequestVersion         = pWithdrawVersion;
        }
        
        id pSecretKey = [aDecoder decodeObjectForKey:@"SecretKey"];
        if ( pSecretKey && [pSecretKey isKindOfClass:[NSString class]] ){
             self->_secretKey                      = pSecretKey;
        }
        
        id pMerchantId =  [aDecoder decodeObjectForKey:@"MerchantId"];
        if ( pMerchantId && [pMerchantId isKindOfClass:[NSString class]] ) {
            self->_merchantId                     = pMerchantId;
        }
        
        id pMerchantSiteID =  [aDecoder decodeObjectForKey:@"MerchantSiteID"];
        if( pMerchantSiteID && [pMerchantSiteID isKindOfClass:[NSString class]] ){
            self->_merchantSiteID                 = pMerchantSiteID;
        }
        
        id pUserTokenId = [aDecoder decodeObjectForKey:@"UserTokenId"];
        if ( pUserTokenId && [pUserTokenId isKindOfClass:[NSString class]] ) {
            self->_userTokenId                    = pUserTokenId;
        }
        
        id pPaymentChecksum = [aDecoder decodeObjectForKey:@"PaymentCheckSumMethod"];
        if( pPaymentChecksum && [pPaymentChecksum isKindOfClass:[NSString class]] ) {
            self->_paymentCheckSumMethod          = [self checkSumMethodFromString:pPaymentChecksum];
        }
        
        id pWhitdrawChecksum = [aDecoder decodeObjectForKey:@"WhitdrawCheckSumMethod"];
        if ( pWhitdrawChecksum && [pWhitdrawChecksum isKindOfClass:[NSString class]] ) {
            self->_whitdrawCheckSumMethod         = [self checkSumMethodFromString:pWhitdrawChecksum];
        }
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Init with Dictionary
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(nullable instancetype) initWithDictionary:(NSDictionary*) dict {
    self = [super init];
    if( self ){
        [self mergeWithDictionary:dict];
        
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Merge with Dictionary
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) mergeWithDictionary:(NSDictionary*) dict {
    id pRequestVersion = [dict objectForKey:@"PPPRequestVersion"];
    if( pRequestVersion && [pRequestVersion isKindOfClass:[NSString class]] ) {
        self->_PPPRequestVersion              = pRequestVersion;
    }
    
    id pPServerUrl = [dict objectForKey:@"SCHSafeChargePPPServerURL"];
    if( pPServerUrl && [pPServerUrl isKindOfClass:[NSString class]] ) {
        self->_SCHSafeChargePPPServerURL      = pPServerUrl;
    }
    
    id pWithdrawUrl = [dict objectForKey:@"SCHSafeChargeWithdrawServerURL"];
    if ( pWithdrawUrl && [pWithdrawUrl isKindOfClass:[NSString class]] ) {
        self->_SCHSafeChargeWithdrawServerURL = pWithdrawUrl;
    }
    
    id pWithdrawVersion = [dict objectForKey:@"WhitdrawRequestVersion"];
    if( pWithdrawVersion && [pWithdrawVersion isKindOfClass:[NSString class]] ) {
        self->_whitdrawRequestVersion         = pWithdrawVersion;
    }
    
    id pSecretKey = [dict objectForKey:@"SecretKey"];
    if ( pSecretKey && [pSecretKey isKindOfClass:[NSString class]] ){
        self->_secretKey                      = pSecretKey;
    }
    
    id pMerchantId =  [dict objectForKey:@"MerchantId"];
    if ( pMerchantId && [pMerchantId isKindOfClass:[NSString class]] ) {
        self->_merchantId                     = pMerchantId;
    }
    
    id pMerchantSiteID =  [dict objectForKey:@"MerchantSiteID"];
    if( pMerchantSiteID && [pMerchantSiteID isKindOfClass:[NSString class]] ){
        self->_merchantSiteID                 = pMerchantSiteID;
    }
    
    id pUserTokenId = [dict objectForKey:@"UserTokenId"];
    if ( pUserTokenId && [pUserTokenId isKindOfClass:[NSString class]] ) {
        self->_userTokenId                    = pUserTokenId;
    }
    
    id pPaymentChecksum = [dict objectForKey:@"PaymentCheckSumMethod"];
    if( pPaymentChecksum && [pPaymentChecksum isKindOfClass:[NSString class]] ) {
        self->_paymentCheckSumMethod          = [self checkSumMethodFromString:pPaymentChecksum];
    }
    
    id pWhitdrawChecksum = [dict objectForKey:@"WhitdrawCheckSumMethod"];
    if ( pWhitdrawChecksum && [pWhitdrawChecksum isKindOfClass:[NSString class]] ) {
        self->_whitdrawCheckSumMethod         = [self checkSumMethodFromString:pWhitdrawChecksum];
    }

}
@end
