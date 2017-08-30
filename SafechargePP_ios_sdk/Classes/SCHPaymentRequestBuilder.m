//
//  SCHRBuilder.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/27/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHPaymentRequestBuilder.h"
#import <objc/runtime.h>
#import "SCHValidatable.h"
#import "SCHConfiguration.h"
#import "RequestBuilderHelper.h"
#import "SCHEventData.h"
#import "SCHLogging.h"

@implementation SCHPaymentRequestBuilder


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// initialization
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (instancetype)initWithMerchantID:(NSNumber *) merchantID
                    merchantSiteID:(NSNumber *) merchantSiteID
                         secretKey:(NSString *) secretKey
                       userTokenID:(NSString *) userTokenID
                       totalAmount:(NSNumber *) totalAmount
                          currency:(NSString *) currency
                          itemName:(NSString *) itemName
                        itemAmount:(NSNumber *) itemAmount
{
    self = [super init];
    if(self) {
        [self initFromConfiuguration:[SCHConfiguration configurationInstance]];

        self.items = [[NSMutableArray alloc] initWithCapacity:10];
        
        //initial setters
        self.merchantID = merchantID;
        self.merchantSiteID = merchantSiteID;
        self.secretKey = secretKey;
        self.userTokenID = userTokenID;
        self.totalAmount = totalAmount;
        self.currency = currency;
        
        //add item
        [self addAndItem:[[SCHItem alloc] initItemWithName:itemName amount:itemAmount quantity:@1]];
    }
    return self;
}

- (instancetype)initWithMerchantID:(NSNumber *) merchantID
                    merchantSiteID:(NSNumber *) merchantSiteID
                         secretKey:(NSString *) secretKey
                       userTokenID:(NSString *) userTokenID
                       totalAmount:(NSNumber *) totalAmount
                          currency:(NSString *) currency {
    self = [super init];
    if(self){
        [self initFromConfiuguration:[SCHConfiguration configurationInstance]];
        
        self.items = [[NSMutableArray alloc] initWithCapacity:10];
        
        //initial setters
        self.merchantID = merchantID;
        self.merchantSiteID = merchantSiteID;
        self.secretKey = secretKey;
        self.userTokenID = userTokenID;
        self.totalAmount = totalAmount;
        self.currency = currency;
    }
    return self;
}

-(instancetype) initWithTotalAmount:(NSNumber*) totalAmount
                           currecny:(NSString*) currency {
    self = [super init];
    if ( self ) {
        
        SCHConfiguration *configuration = [SCHConfiguration configurationInstance];
        [self initFromConfiuguration:configuration];
        
        self.items = [[NSMutableArray alloc] initWithCapacity:10];
        
        self.merchantID = [NSNumber numberWithLongLong:configuration.configurationData.merchantId.longLongValue];
        self.merchantSiteID = [NSNumber numberWithLongLong:configuration.configurationData.merchantSiteID.longLongValue];
        self.secretKey = configuration.configurationData.secretKey;
        self.userTokenID = configuration.configurationData.userTokenId;
        self.totalAmount = totalAmount;
        self.currency = currency;
    }
    return self;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
//extra initialialization
////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) initFromConfiuguration:(SCHConfiguration *) configInstance {
    self.baseURL = [NSURL URLWithString:configInstance.configurationData.SCHSafeChargePPPServerURL];
    self.version = configInstance.configurationData.PPPRequestVersion;
    self.encoding = configInstance.configurationData.RequestTextEncoding;
}

-(SCHItem*) addItemWithName:(NSString*) name
             withAmount:(NSNumber*) amount
           withQuantity:(NSNumber*) quantity {
    SCHItem *newItem = [[SCHItem alloc] initItemWithName:name
                                               amount:amount
                                             quantity:quantity];

    if( newItem == nil ) {
        SCHLog(@"newItem is nill");
        return nil;
    }
    
    if ( self.items == nil ) {
        self.items = [[NSMutableArray alloc] initWithCapacity:5];
    }
    
    [self.items addObject:newItem];
    return newItem;
}

-(void) addAndItem:(SCHItem *)item {
    
    if( item == nil) {
        SCHLog(@"null passed");
        return;
    }
    
    
    if ( self.items == nil ) {
        self.items = [[NSMutableArray alloc] initWithCapacity:5];
    }

    [self.items addObject:item];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// validation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) validateItems {
    __block BOOL isValid = TRUE;
    [self.items enumerateObjectsUsingBlock:^(SCHItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if( ![obj validateAllSet] ) {
            isValid = FALSE;
            *stop = TRUE;
            return;
        }
    }];
    return isValid;
}

-(BOOL) validateAllSet {
    
    //required
    if( ![self validatePropertyRequired:_baseURL           withMinValue:@0 withMaxValue:@2048] )       { SCHLog(@"_baseURL validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_merchantID        withMinValue:@0 withMaxValue:@(LONG_MAX)] ) { SCHLog(@"_merchantID validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_merchantSiteID    withMinValue:@0 withMaxValue:@(LONG_MAX)] ) { SCHLog(@"_merchantSiteID validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_secretKey         withMinValue:@0 withMaxValue:@256] )        { SCHLog(@"_secretKey validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_userTokenID       withMinValue:@0 withMaxValue:@256] )        { SCHLog(@"_userTokenID validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_currency          withMinValue:@0 withMaxValue:@3] )          { SCHLog(@"_currency validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_version           withMinValue:@0 withMaxValue:@8] )          { SCHLog(@"_version validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:_totalAmount       withMinValue:@0 withMaxValue:@(DBL_MAX)] )  { SCHLog(@"_totalAmount validation failed"); return FALSE; }
    
    //optional
    if( ![self validatePropertyIfSet:_invoiceID         withMinValue:@0 withMaxValue:@400] )        { SCHLog(@"_invoiceID validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_paymentMethod     withMinValue:@0 withMaxValue:@256] )        { SCHLog(@"_paymentMethod validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_merchantLocale    withMinValue:@0 withMaxValue:@5] )          { SCHLog(@"_merchantLocale validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_userID            withMinValue:@0 withMaxValue:@50] )         { SCHLog(@"_userID validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_customData        withMinValue:@0 withMaxValue:@255] )        { SCHLog(@"_customData validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_merchantUniqueID  withMinValue:@0 withMaxValue:@64] )         { SCHLog(@"_merchantUniqueID validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_encoding          withMinValue:@0 withMaxValue:@20] )         { SCHLog(@"_encoding validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_webMasterID       withMinValue:@0 withMaxValue:@255] )        { SCHLog(@"_webMasterID validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_theme_id          withMinValue:@0 withMaxValue:@999999999] )  { SCHLog(@"_theme_id validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_useOpenAmount     withMinValue:@0 withMaxValue:@1] )          { SCHLog(@"_useOpenAmount validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_minAmount         withMinValue:@0 withMaxValue:@(DBL_MAX)] )  { SCHLog(@"_minAmount validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_maxAmount         withMinValue:@0 withMaxValue:@(DBL_MAX)] )  { SCHLog(@"_maxAmount validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_totalDiscount     withMinValue:@0 withMaxValue:@(DBL_MAX)] )  { SCHLog(@"_totalDiscount validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_totalShipping     withMinValue:@0 withMaxValue:@(DBL_MAX)] )  { SCHLog(@"_totalShipping validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_totalHandling     withMinValue:@0 withMaxValue:@(DBL_MAX)] )  { SCHLog(@"_totalHandling validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_totalTax          withMinValue:@0 withMaxValue:@(DBL_MAX)] )  { SCHLog(@"_totalTax validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_productID         withMinValue:@0 withMaxValue:@50] )         { SCHLog(@"_productID validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_firstName         withMinValue:@0 withMaxValue:@30] )         { SCHLog(@"_firstName validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_lastName          withMinValue:@0 withMaxValue:@40] )         { SCHLog(@"_lastName validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_email             withMinValue:@0 withMaxValue:@100] )        { SCHLog(@"_email validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_address1          withMinValue:@0 withMaxValue:@60] )         { SCHLog(@"_address1 validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_address2          withMinValue:@0 withMaxValue:@60] )         { SCHLog(@"_address2 validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_city              withMinValue:@0 withMaxValue:@30] )         { SCHLog(@"_city validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_country           withMinValue:@0 withMaxValue:@20] )         { SCHLog(@"_country validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_state             withMinValue:@0 withMaxValue:@20] )         { SCHLog(@"_state validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_ZIP               withMinValue:@0 withMaxValue:@10] )         { SCHLog(@"_ZIP validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_phone1            withMinValue:@0 withMaxValue:@18] )         { SCHLog(@"_phone1 validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_phone2            withMinValue:@0 withMaxValue:@18] )         { SCHLog(@"_phone2 validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_phone3            withMinValue:@0 withMaxValue:@18] )         { SCHLog(@"_phone3 validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_skipBillingTab    withMinValue:@0 withMaxValue:@1] )          { SCHLog(@"_skipBillingTab validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_skipReviewTab     withMinValue:@0 withMaxValue:@1] )          { SCHLog(@"_skipReviewTab validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_successURL        withMinValue:@0 withMaxValue:@2048] )       { SCHLog(@"_successURL validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_errorURL          withMinValue:@0 withMaxValue:@2048] )       { SCHLog(@"_errorURL validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_pendingURL        withMinValue:@0 withMaxValue:@2048] )       { SCHLog(@"_pendingURL validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_backURL           withMinValue:@0 withMaxValue:@2048] )       { SCHLog(@"_backURL validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_notifyURL         withMinValue:@0 withMaxValue:@2048] )       { SCHLog(@"_notifyURL validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_customSiteName    withMinValue:@0 withMaxValue:@50] )         { SCHLog(@"_customSiteName validation failed"); return FALSE; }
    
    if( ![self validateItems] ) { return FALSE; }
    
    //validate openAmount
    if ( self.useOpenAmount.boolValue ) {
        
        if( self.minAmount == nil ) {
            return FALSE;
        }
        
        if( self.maxAmount == nil ) {
            return FALSE;
        }
        
        if( self.maxAmount.doubleValue < self.minAmount.doubleValue ){
            SCHLog(@"maxAmount should be greater than minAmount");
            return FALSE;
        }
    }
    
    
    const NSString *customFieldProp = @"customField";
    const NSUInteger maxCustomFields = 15;
    // validate all the custom fields if present
    for ( int i = 1 ; i <= maxCustomFields; ++i ) {
        NSString *iteratedFieldName = [NSString stringWithFormat:@"%@%d",customFieldProp,i];
        id property = [self valueForKey:iteratedFieldName];
        if( property && ![self validatePropertyIfSet:property    withMinValue:@0 withMaxValue:@64] ) {
            SCHLog(@"customField%d validation failed",i);
            return FALSE;
        }
    }
    
    if( ![self validatePropertyIfSet:_cc_name_on_card  withMinValue:@0    withMaxValue:@64] )         { SCHLog(@"_cc_name_on_card validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_cc_card_number   withMinValue:@0    withMaxValue:@64] )         { SCHLog(@"_cc_card_number validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_cc_exp_month     withMinValue:@0    withMaxValue:@12] )         { SCHLog(@"_cc_exp_month validation failed"); return FALSE; }
    
#if defined (USE_NUMERIC_VALIDATION_FOR_CC)
    if( ![self validatePropertyIfSet:_cc_exp_year      withMinValue:@2015 withMaxValue:@2099] )       { SCHLog(@"_cc_exp_year validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:_cc_cvv2          withMinValue:@100  withMaxValue:@999]   )      { SCHLog(@"_cc_cvv2 validation failed");
        return FALSE; }
#endif
    
    return TRUE;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// generate PKPaymentRequest
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(PKPaymentRequest *) constructApplePayRequest:(SCHEventData*) eventData {
    PKPaymentRequest *request = [PKPaymentRequest new];
    
    if ( eventData != nil && eventData->updatedOnce ) {
        request.paymentSummaryItems = [self constructApplePayFromEventData:eventData];
        request.currencyCode = eventData->currency;
        
    } else {
        request.paymentSummaryItems = [self constructApplePayItemsArray];
        request.currencyCode = self.currency;
    }
    
    request.merchantIdentifier = self.applePayMerchantId;
    request.countryCode = self.country;
    
    SCHConfiguration *config = [SCHConfiguration configurationInstance];
    request.merchantCapabilities = config.merchantCapabilities;
    request.supportedNetworks = config.supportedNetworks;
    
    return request;
}

-(NSArray<PKPaymentSummaryItem*>*) constructApplePayFromEventData:(SCHEventData*) eventData {
    
    PKPaymentSummaryItem *newItem = [PKPaymentSummaryItem summaryItemWithLabel:[SCHConfiguration configurationInstance].applePayTitile
                                                                        amount:[[NSDecimalNumber alloc] initWithDouble:eventData->amount.doubleValue]
                                                                          type:PKPaymentSummaryItemTypeFinal];
    double EPS_0 = 0.00000001;
    if( eventData->amount.doubleValue <= EPS_0 &&
        eventData->amount.doubleValue >= -EPS_0 ) {
        
        SCHItem *firstItem = self.items.firstObject;
        newItem.amount = [[NSDecimalNumber alloc] initWithDouble:firstItem.amount.doubleValue];        
        SCHLog(@"missing amount for the first data");
    }
    

    return @[newItem];
}

-(NSArray<PKPaymentSummaryItem*>*) constructApplePayItemsArray {
    NSMutableArray<PKPaymentSummaryItem*> *result = [[NSMutableArray alloc] initWithCapacity:self.items.count];
    
    [self.items enumerateObjectsUsingBlock:^(SCHItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *titlePtr = nil;
        if ( obj.applePayItemTitle ) {
            titlePtr = obj.applePayItemTitle;
        } else  {
            SCHLog(@"apple pay item title not specified for %@, using default one!!!",obj.name);
            titlePtr = [SCHConfiguration configurationInstance].applePayTitile;
        }
        
        double total_amount = obj.amount.doubleValue;
        if( self.useOpenAmount.boolValue == FALSE ) {
            total_amount *= obj.quantity.integerValue;
        }
        
        PKPaymentSummaryItem *newItem = [PKPaymentSummaryItem summaryItemWithLabel:titlePtr
                                                                            amount:[[NSDecimalNumber alloc] initWithDouble:total_amount]
                                                                              type:PKPaymentSummaryItemTypeFinal];
        
        [result addObject:newItem];
    }];
    
    return result;
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
    
    [self updateItems];
    [self updateBindedProperties];
    
    if([self validateAllSet] == FALSE) {
        SCHLog(@"invalid request data provided");
        return nil;
    }

    NSString *fullURL = [[NSString stringWithFormat:@"%@?%@",self.baseURL.absoluteString,
                          [self deserializeToURLParams]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [NSURL URLWithString:fullURL];
}

-(NSString*) deserializeToURLParams {
    
    NSMutableArray<NSString*> *resultArray = [[NSMutableArray alloc] init];
    [resultArray addObjectsFromArray:[self deserializeToParts]];        
    return [resultArray componentsJoinedByString:@"&"];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// update stuff
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) updateItems {
    //update the total amount based on open amount setting
    self.totalAmount = [self updateTotalAmount];
}

-(void) updateBindedProperties {
    self.openState = @"sdk";
}


-(NSNumber*) updateTotalAmount {
    if ( self.useOpenAmount.boolValue ){
        return @(self.items.firstObject.amount.doubleValue);
    } else {
        __block double result = 0.0;
        [self.items enumerateObjectsUsingBlock:^(SCHItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            result += obj.amount.doubleValue * obj.quantity.integerValue;
        }];
        
        return [NSNumber numberWithDouble:result];
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// checksum stuff
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(NSString*) calculcateChecksum:(NSArray<NSString*> *) inputArray {
    
    __block NSMutableArray<NSString*> *escapeValues = [[NSMutableArray alloc] initWithCapacity:inputArray.count];
    
    [escapeValues addObject:self.secretKey];
    
    [inputArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange eqFoundRange = [obj rangeOfString:@"="];
        NSString *valueToAdd = [obj substringFromIndex:eqFoundRange.location+1];
        [escapeValues addObject:valueToAdd];
    }];
    
    if ( escapeValues.count == 0 ) {
        SCHLog(@"no values found in the query");
        return @"";
    }
    
    return [RequestBuilderHelper calculateChecksumWithParameters:escapeValues
                                                       andMethod:[SCHConfiguration configurationInstance].paymentCheckSumMethod];
}

-(NSString*) calculateOlderChecksum {
    
    NSString *timestamp = [RequestBuilderHelper generateTimestampFromNow];
    NSMutableArray *parameters = [NSMutableArray array];
    
    
    [parameters addObject:self.secretKey];
    [parameters addObject:[NSString stringWithFormat:@"%lld", self.merchantID.longLongValue]];
    [parameters addObject:self.currency];
    [parameters addObject:[NSString stringWithFormat:@"%.02f", self.totalAmount.doubleValue]];
    
    /*if (self.useOpenAmount.boolValue) {
        [parameters addObject:[NSString stringWithFormat:@"%d", 1]];
    }
    else {
        [parameters addObject:[NSString stringWithFormat:@"%lu", (unsigned long)self.items.count]];
    }*/
    
    
    [self.items enumerateObjectsUsingBlock:^(SCHItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if(self.useOpenAmount.boolValue&&idx >=1 ) { //using open amount is valid for item 1 only
            *stop = TRUE;
            return;
        }
        
        [parameters addObject:item.name];
        [parameters addObject:[NSString stringWithFormat:@"%.02f", item.amount.doubleValue]];
        
        if (self.useOpenAmount.boolValue )
            [parameters addObject:[NSString stringWithFormat:@"%d",1]];
        else
            [parameters addObject:[NSString stringWithFormat:@"%lld", item.quantity.longLongValue]];
        
        
        /*
        if ( item.number ){
            [parameters addObject:[NSString stringWithFormat:@"%lld", item.number.longLongValue]];
        }
        if ( item.shipping ){
            [parameters addObject:[NSString stringWithFormat:@"%.02f", item.number.doubleValue]];
        }
        if ( item.handling ){
            [parameters addObject:[NSString stringWithFormat:@"%.02f", item.number.doubleValue]];
        }
        if ( item.discount ){
            [parameters addObject:[NSString stringWithFormat:@"%.02f", item.number.doubleValue]];
        } */

    }];
    
    if (self.useOpenAmount.boolValue)
    {
        [parameters addObject:@"true"];
        [parameters addObject:[NSString stringWithFormat:@"%.02f", self.minAmount.doubleValue]];
        [parameters addObject:[NSString stringWithFormat:@"%.02f", self.maxAmount.doubleValue]];
    }

    
    [parameters addObject:self.userTokenID];
    [parameters addObject:timestamp];
    
    return [RequestBuilderHelper calculateChecksumWithParameters:parameters
                                                       andMethod:[SCHConfiguration configurationInstance].paymentCheckSumMethod];

}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// deserialization
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSMutableArray<NSString*>*) deserializeToParts {
    NSMutableArray<NSString*> *resultArray = [[NSMutableArray alloc] initWithCapacity:100];
    
    BOOL usingOlderVersion = [self.version isEqualToString:@"3.0.0"];
    
    [RequestBuilderHelper writeNumberAsLongLong:self.merchantID     forKey:@"merchant_id"       targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsLongLong:self.merchantSiteID forKey:@"merchant_site_id"  targetArray:resultArray];
    [RequestBuilderHelper writeString:self.currency                 forKey:@"currency"          targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsDouble:self.totalAmount      forKey:@"total_amount"      targetArray:resultArray];
    
    // put items
    [resultArray addObjectsFromArray: [self deserializeItemsToURLParams]];
    
    if (self.useOpenAmount.boolValue)
    {
        [RequestBuilderHelper writeString:@"true"                     forKey:[NSString stringWithFormat:@"item_open_amount_1"] targetArray:resultArray];
        [RequestBuilderHelper writeNumberAsDouble:self.minAmount      forKey:[NSString stringWithFormat:@"item_min_amount_1"] targetArray:resultArray];
        [RequestBuilderHelper writeNumberAsDouble:self.maxAmount      forKey:[NSString stringWithFormat:@"item_max_amount_1"] targetArray:resultArray];
    }
    
    [RequestBuilderHelper writeString:self.userTokenID              forKey:@"user_token_id"         targetArray:resultArray];
    [RequestBuilderHelper writeString:[RequestBuilderHelper generateTimestampFromNow] forKey:@"time_stamp" targetArray:resultArray];
    
    if ( usingOlderVersion ){
        //calculate the checksum
        [RequestBuilderHelper writeString:[self calculateOlderChecksum] forKey:@"checksum" targetArray:resultArray];
    }
    
    [RequestBuilderHelper writeString:self.version                  forKey:@"version"               targetArray:resultArray];
    
    
    [RequestBuilderHelper writeNumberAsInteger:[NSNumber numberWithInt:[SCHConfiguration configurationInstance].applePaySupport]
                                        forKey:@"applePayDeviceSupport" targetArray:resultArray];
    
    [RequestBuilderHelper writeString:self.invoiceID          forKey:@"invoice_id"            targetArray:resultArray];
    [RequestBuilderHelper writeString:self.paymentMethod      forKey:@"payment_method"        targetArray:resultArray];
    [RequestBuilderHelper writeString:self.merchantLocale     forKey:@"merchantLocale"        targetArray:resultArray];
    [RequestBuilderHelper writeString:self.userID             forKey:@"userid"                targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customData         forKey:@"customData"            targetArray:resultArray];
    [RequestBuilderHelper writeString:self.merchantUniqueID   forKey:@"merchant_unique_id"    targetArray:resultArray];
    [RequestBuilderHelper writeString:self.encoding           forKey:@"encoding"              targetArray:resultArray];
    [RequestBuilderHelper writeString:self.webMasterID        forKey:@"webMasterID"           targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsInteger:self.theme_id  forKey:@"theme_id"                targetArray:resultArray];
    

    
    [RequestBuilderHelper writeNumberAsDouble:self.totalDiscount      forKey:@"discount"              targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsDouble:self.totalShipping      forKey:@"shipping"              targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsDouble:self.totalHandling      forKey:@"handling"              targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsDouble:self.totalTax           forKey:@"total_tax"             targetArray:resultArray];
    [RequestBuilderHelper writeString:self.productID          forKey:@"productId"             targetArray:resultArray];
    [RequestBuilderHelper writeString:NSStringFromUserTokenType(self.userTokenType)
                               forKey:@"user_token"            targetArray:resultArray];
    [RequestBuilderHelper writeString:self.firstName          forKey:@"first_name"            targetArray:resultArray];
    [RequestBuilderHelper writeString:self.lastName           forKey:@"last_name"             targetArray:resultArray];
    [RequestBuilderHelper writeString:self.email              forKey:@"email"                 targetArray:resultArray];
    [RequestBuilderHelper writeString:self.address1           forKey:@"address1"              targetArray:resultArray];
    [RequestBuilderHelper writeString:self.address2           forKey:@"address2"              targetArray:resultArray];
    [RequestBuilderHelper writeString:self.city               forKey:@"city"                  targetArray:resultArray];
    [RequestBuilderHelper writeString:self.country            forKey:@"country"               targetArray:resultArray];
    [RequestBuilderHelper writeString:self.state              forKey:@"state"                 targetArray:resultArray];
    [RequestBuilderHelper writeString:self.ZIP                forKey:@"zip"                   targetArray:resultArray];
    [RequestBuilderHelper writeString:self.phone1             forKey:@"phone1"                targetArray:resultArray];
    [RequestBuilderHelper writeString:self.phone2             forKey:@"phone2"                targetArray:resultArray];
    [RequestBuilderHelper writeString:self.phone3             forKey:@"phone3"                targetArray:resultArray];
    
    if (self.skipBillingTab.boolValue)
        [RequestBuilderHelper writeString:@"true"             forKey:@"skip_billing_tab"      targetArray:resultArray];
    
    if (self.skipReviewTab.boolValue)
        [RequestBuilderHelper writeString:@"true"             forKey:@"skip_review_tab"       targetArray:resultArray];
    
    [RequestBuilderHelper writeURL:self.successURL            forKey:@"success_url"           targetArray:resultArray];
    [RequestBuilderHelper writeURL:self.errorURL              forKey:@"error_url"             targetArray:resultArray];
    [RequestBuilderHelper writeURL:self.pendingURL            forKey:@"pending_url"           targetArray:resultArray];
    [RequestBuilderHelper writeURL:self.backURL               forKey:@"back_url"              targetArray:resultArray];
    [RequestBuilderHelper writeURL:self.notifyURL             forKey:@"notify_url"            targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customSiteName     forKey:@"customSiteName"        targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField1       forKey:@"customField1"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField2       forKey:@"customField2"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField3       forKey:@"customField3"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField4       forKey:@"customField4"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField5       forKey:@"customField5"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField6       forKey:@"customField6"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField7       forKey:@"customField7"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField8       forKey:@"customField8"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField9       forKey:@"customField9"          targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField10      forKey:@"customField10"         targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField11      forKey:@"customField11"         targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField12      forKey:@"customField12"         targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField13      forKey:@"customField13"         targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField14      forKey:@"customField14"         targetArray:resultArray];
    [RequestBuilderHelper writeString:self.customField15      forKey:@"customField15"         targetArray:resultArray];
    
    [RequestBuilderHelper writeString:self.cc_name_on_card    forKey:@"cc_name_on_card"        targetArray:resultArray];
    [RequestBuilderHelper writeString:self.cc_card_number     forKey:@"cc_card_number"         targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsInteger:self.cc_exp_month       forKey:@"cc_exp_month"  targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsInteger:self.cc_exp_year        forKey:@"cc_exp_year"   targetArray:resultArray];
    [RequestBuilderHelper writeNumberAsInteger:self.cc_cvv2            forKey:@"cc_cvv2"       targetArray:resultArray];
    
    [RequestBuilderHelper writeString:self.openState                   forKey:@"openState"       targetArray:resultArray];
    
    if ( !usingOlderVersion ){
        [RequestBuilderHelper writeString:[self calculcateChecksum:resultArray] forKey:@"checksum" targetArray:resultArray];
    }
    
    return resultArray;
}

-(NSArray*) deserializeItemsToURLParams {
    if( self.items.count > 0 ){
        NSMutableArray<NSString*> *resultArray = [[NSMutableArray alloc] initWithCapacity:15];
        
        if( self.useOpenAmount.boolValue ) {
            [RequestBuilderHelper writeNumberAsInteger:[NSNumber numberWithUnsignedInteger:1] forKey:@"numberofitems" targetArray:resultArray];
        }
        else {
            [RequestBuilderHelper writeNumberAsInteger:[NSNumber numberWithUnsignedInteger:self.items.count] forKey:@"numberofitems" targetArray:resultArray];
        }
        
        [self.items enumerateObjectsUsingBlock:^(SCHItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            
            int itemIndex = (int) (idx + 1); //items begin from 1
            
            if (self.useOpenAmount.boolValue && itemIndex >= 2 ) {
                *stop = true;
                return;
            }
                
            [RequestBuilderHelper writeString:item.name forKey:[NSString stringWithFormat:@"item_name_%i", itemIndex] targetArray:resultArray];
            [RequestBuilderHelper writeNumberAsDouble:item.amount forKey:[NSString stringWithFormat:@"item_amount_%i", itemIndex] targetArray:resultArray];
            
            if (self.useOpenAmount.boolValue )
                [RequestBuilderHelper writeNumberAsLongLong:@1 forKey:[NSString stringWithFormat:@"item_quantity_%i", itemIndex] targetArray:resultArray];
            else
                [RequestBuilderHelper writeNumberAsLongLong:item.quantity forKey:[NSString stringWithFormat:@"item_quantity_%i", itemIndex] targetArray:resultArray];
            
            [RequestBuilderHelper writeNumberAsLongLong:item.number forKey:[NSString stringWithFormat:@"item_number_%i", itemIndex] targetArray:resultArray];
            [RequestBuilderHelper writeNumberAsDouble:item.shipping forKey:[NSString stringWithFormat:@"item_shipping_%i", itemIndex] targetArray:resultArray];
            [RequestBuilderHelper writeNumberAsDouble:item.handling forKey:[NSString stringWithFormat:@"item_handling_%i", itemIndex] targetArray:resultArray];
            [RequestBuilderHelper writeNumberAsDouble:item.discount forKey:[NSString stringWithFormat:@"item_discount_%i", itemIndex] targetArray:resultArray];
        }];
        return resultArray;
    } else {
        return @[];
    }
}

@end
