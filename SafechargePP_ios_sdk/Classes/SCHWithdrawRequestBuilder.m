//
//  SCHWRequestBuilder.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 2/14/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHWithdrawRequestBuilder.h"
#import "SCHLogging.h"
#import "SCHConfiguration.h"
#import "RequestBuilderHelper.h"

@implementation SCHWithdrawRequestBuilder



-(instancetype) initWithMinAmount:(NSNumber*) minAmount
                        maxAmount:(NSNumber*) maxAmount
                    defaultAmount:(NSNumber*) defaultAmount
                         currency:(NSString*) currency {
    self = [super init];
    if ( self ) {
        [self initFromConfiuguration:[SCHConfiguration configurationInstance]];
        self.minAmount = minAmount;
        self.maxAmount = maxAmount;
        self.defaultAmount = defaultAmount;
        self.currency = currency;
    }
    return self;
}


-(void) initFromConfiuguration:(SCHConfiguration *) configInstance {
    
    self.baseURL = [NSURL URLWithString:configInstance.configurationData.SCHSafeChargeWithdrawServerURL];
    self.version = configInstance.configurationData.whitdrawRequestVersion;
    
    self.merchantID = [NSNumber numberWithLongLong:configInstance.configurationData.merchantId.longLongValue];
    self.merchantSiteID = [NSNumber numberWithLongLong:configInstance.configurationData.merchantSiteID.longLongValue];
    
    self.secretKey = configInstance.configurationData.secretKey;
    self.userTokenID = configInstance.configurationData.userTokenId;
    
    
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// generate NSURLRequest
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSURLRequest*) constructURLRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self constructURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    if( request == nil ) {
        SCHLog(@"bad request created");
        return nil;
    }
    [request setHTTPMethod:@"GET"];
    return request;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// generate URL
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSURL*) constructURL {
    if([self validateAllSet] == FALSE) {
        SCHLog(@"invalid request data provided");
        return nil;
    }
    SCHConfiguration *config = [SCHConfiguration configurationInstance];
    NSString *fullURL = [[NSString stringWithFormat:@"%@?%@",config.configurationData.SCHSafeChargeWithdrawServerURL,
                          [self deserializeToURLParams]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:fullURL];
}

-(NSString*) deserializeToURLParams {
    
    NSMutableArray<NSString*> *resultArray = [[NSMutableArray alloc] init];
    [resultArray addObjectsFromArray:[self deserializeToParts]];
    return [resultArray componentsJoinedByString:@"&"];
}

-(BOOL) validateAllSet {
    //tdl
    if( ![self validatePropertyRequired:_baseURL           withMinValue:@0 withMaxValue:@2048] )        { SCHLog(@"_baseURL validation failed"); return FALSE; }
    
    if( ![self validatePropertyRequired:_merchantID        withMinValue:@0 withMaxValue:@(LONG_MAX)] )  { SCHLog(@"_merchantID validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_merchantSiteID    withMinValue:@0 withMaxValue:@(LONG_MAX)] )  { SCHLog(@"_merchantSiteID validation failed"); return FALSE; }
    
    if( ![self validatePropertyRequired:_secretKey         withMinValue:@0 withMaxValue:@256] )         { SCHLog(@"_secretKey validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_userTokenID       withMinValue:@0 withMaxValue:@256] )         { SCHLog(@"_userTokenID validation failed"); return FALSE; }
    
    if( ![self validatePropertyRequired:_minAmount         withMinValue:@0 withMaxValue:@(DBL_MAX)] )   { SCHLog(@"_minAmount validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_maxAmount         withMinValue:@0 withMaxValue:@(DBL_MAX)] )   { SCHLog(@"_maxAmount validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_defaultAmount     withMinValue:@0 withMaxValue:@(DBL_MAX)] )   { SCHLog(@"_defaultAmount validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_currency          withMinValue:@0 withMaxValue:@3] )           { SCHLog(@"_currency validation failed"); return FALSE; }
    //tdl
    if( ![self validatePropertyRequired:_version           withMinValue:@0 withMaxValue:@8] )           { SCHLog(@"_version validation failed"); return FALSE; }

    if( ![self validatePropertyIfSet:_merchantLocale       withMinValue:@0 withMaxValue:@5] )           { SCHLog(@"_merchantLocale validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_country              withMinValue:@0 withMaxValue:@20] )          { SCHLog(@"_country validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_userID               withMinValue:@0 withMaxValue:@64] )          { SCHLog(@"_userID validation failed"); return FALSE; }
    
    return TRUE;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// deserialization
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSMutableArray<NSString*>*) deserializeToParts {
    NSMutableArray<NSString*> *resultArray = [[NSMutableArray alloc] initWithCapacity:100];
    
    NSString *timestamp = [RequestBuilderHelper generateTimestampFromNow];
    NSString *checksum =  [self calculateChecksum];
    
    [RequestBuilderHelper writeNumberAsLongLong:self.merchantID                       forKey:@"merchant_id"       targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsLongLong:self.merchantSiteID                   forKey:@"merchant_site_id"  targetArray:resultArray];
    [RequestBuilderHelper writeString:NSStringFromUserTokenType(self.userTokenType)   forKey:@"user_token"        targetArray:resultArray];
    [RequestBuilderHelper writeString:self.userTokenID                                forKey:@"user_token_id"     targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsDouble:self.minAmount                          forKey:@"wd_min_amount"     targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsDouble:self.maxAmount                          forKey:@"wd_max_amount"     targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsDouble:self.defaultAmount                      forKey:@"wd_amount"         targetArray:resultArray];
    [RequestBuilderHelper writeString:self.currency                                   forKey:@"wd_currency"       targetArray:resultArray];
    [RequestBuilderHelper writeString:timestamp                                       forKey:@"time_stamp"        targetArray:resultArray];
    [RequestBuilderHelper writeString:self.version                                    forKey:@"version"           targetArray:resultArray];
    [RequestBuilderHelper writeString:checksum                                        forKey:@"checksum"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.merchantLocale                             forKey:@"merchantLocale"    targetArray:resultArray];
    [RequestBuilderHelper writeString:self.country                                    forKey:@"country"           targetArray:resultArray];
    [RequestBuilderHelper writeString:self.userID                                     forKey:@"userID"            targetArray:resultArray];
    
    return resultArray;
}


- (NSString *)calculateChecksum
{
    NSString *timestamp = [RequestBuilderHelper generateTimestampFromNow];
    NSMutableArray<NSString*> *parameters = [[NSMutableArray alloc] initWithCapacity:20];
    
    [parameters addObject:self.secretKey];
    [parameters addObject:[NSString stringWithFormat:@"%lld", self.merchantID.longLongValue]];
    [parameters addObject:[NSString stringWithFormat:@"%lld", self.merchantSiteID.longLongValue]];
    [parameters addObject:NSStringFromUserTokenType(self.userTokenType)];
    [parameters addObject:self.userTokenID];
    [parameters addObject:[NSString stringWithFormat:@"%.02f", self.minAmount.doubleValue]];
    [parameters addObject:[NSString stringWithFormat:@"%.02f", self.maxAmount.doubleValue]];
    [parameters addObject:[NSString stringWithFormat:@"%.02f", self.defaultAmount.doubleValue]];
    [parameters addObject:self.currency];
    [parameters addObject:timestamp];
    [parameters addObject:self.version];
    
    if (self.merchantLocale)
        [parameters addObject:self.merchantLocale];
    
    if (self.country)
        [parameters addObject:self.country];
    
    if (self.userID)
        [parameters addObject:self.userID];
    
    return [RequestBuilderHelper calculateChecksumWithParameters:parameters
                                                       andMethod:[SCHConfiguration configurationInstance].whitdrawCheckSumMethod];
}


@end
