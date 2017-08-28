//
//  SCHPPPResult.m
//  SafechargePP
//
//  Created by Bozhidar Dimitrov on 2/12/15.
//  Copyright (c) 2015-2016 SafeCharge. All rights reserved.
//


#import "SCHPPResult.h"
#import "SCHItem.h"
#import "SCHExceptionHelper.h"
#import "SCHPaymentData.h"

@implementation SCHPPResult


#pragma mark - Object Lifecycle

- (instancetype)init
{
    [SCHExceptionHelper throwInternalInconsistencyExceptionWithReason:@"-init is not a valid initializer for the class SCHPPPResult."];
    
    return nil;
}

- (instancetype)initWithURL:(NSURL *)resultURL
{
    if (resultURL == nil)
        [SCHExceptionHelper throwInternalInconsistencyExceptionWithReason:@"resultURL cannot be nil."];
    
    if (self = [super init])
    {
        _resultURL = resultURL;
        
        if ([self parseResultURL] == NO)
            return nil;
    }
    
    return self;
}

-(instancetype) initWithEventData:(SCHPaymentData *)data {
    self = [super init];
    if( self ){
        [self parsePaymentData:data];
        
    }
    return self;
}

#pragma mark - Private Methods

-(void) parsePaymentData:(SCHPaymentData*) data {
    _status = data->status;
    _isApplePayResult = TRUE;
}

- (BOOL)parseResultURL
{
    NSMutableDictionary *queryStringDictionary = [NSMutableDictionary dictionary];
    NSArray *urlComponents = [self.resultURL.query componentsSeparatedByString:@"&"];
    
    for (NSString *keyValiePair in urlComponents)
    {
        NSArray *pairComponents = [keyValiePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        
        if (key == nil)
            continue;
        
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    
    _PPPStatus =                    queryStringDictionary[@"ppp_status"];
    
    if (_PPPStatus == nil)
        return NO;
    
    _status =                       queryStringDictionary[@"Status"];
    _totalAmount =              [   queryStringDictionary[@"totalAmount"] doubleValue];
    _transactionID =            [   queryStringDictionary[@"TransactionID"] intValue];
    _clientUniqueID =               queryStringDictionary[@"ClientUniqueID"];
    _errorCode =                [   queryStringDictionary[@"ErrCode"] intValue];
    _extendedErrorCode =        [   queryStringDictionary[@"ExErrCode"] intValue];
    _authenticationCode =       [   queryStringDictionary[@"AuthCode"] intValue];
    _reason =                       queryStringDictionary[@"Reason"];
    _cardToken =                    queryStringDictionary[@"Token"];
    _reasonCode =               [   queryStringDictionary[@"ReasonCode"] intValue];
    _responseChecksum =             queryStringDictionary[@"responsechecksum"];
    _advanceResponseChecksum =      queryStringDictionary[@"advanceResponseChecksum"];
    _ECI =                      [   queryStringDictionary[@"ECI"] intValue];
    _nameOnCard =                   queryStringDictionary[@"nameOnCard"];
    _currency =                     queryStringDictionary[@"currency"];
    _totalDiscount =            [   queryStringDictionary[@"total_discount"] doubleValue];
    _totalHandling =            [   queryStringDictionary[@"total_handling"] doubleValue];
    _totalShipping =            [   queryStringDictionary[@"total_shipping"] doubleValue];
    _totalTax =                 [   queryStringDictionary[@"total_tax"] doubleValue];
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (int i = 1; ; i++)
    {
        double itemAmount = [queryStringDictionary[[NSString stringWithFormat:@"item_amount_%i", i]] doubleValue];
        
        if (!itemAmount)
        {
            if (items.count == 0)
                items = nil;
            
            break;
        }
        
        SCHItem *item = [SCHItem itemWithName:[NSString stringWithFormat:@"[Item %i]", i]
                                           amount:itemAmount
                                         quantity:[queryStringDictionary[[NSString stringWithFormat:@"item_quantity_%i", i]] longLongValue]];
        
        item.number =    queryStringDictionary[[NSString stringWithFormat:@"item_number_%i", i]];
        
        item.shipping = queryStringDictionary[[NSString stringWithFormat:@"item_shipping_%i", i]] ;
        item.handling = queryStringDictionary[[NSString stringWithFormat:@"item_handling_%i", i]] ;
        item.discount = queryStringDictionary[[NSString stringWithFormat:@"item_discount_%i", i]] ;
        
        [items addObject:item];
    }
    
    _items = items;
    _customData =                   queryStringDictionary[@"customData"];
    _merchantUniqueID =             queryStringDictionary[@"merchant_unique_id"];
    _merchantSiteID =           [   queryStringDictionary[@"merchant_site_id"] longLongValue];
    _merchantID =               [   queryStringDictionary[@"merchant_id"] longLongValue];
    _requestVersion =               queryStringDictionary[@"requestVersion"];
    _message =                      queryStringDictionary[@"message"];
    _error =                        queryStringDictionary[@"Error"];
    _instantDMNStatus =             queryStringDictionary[@"instantDmnStatus"];
    _PPPTransactionID =         [   queryStringDictionary[@"PPP_TransactionID"] longLongValue];
    _userID =                       queryStringDictionary[@"UserID"];
    _productID =                    queryStringDictionary[@"ProductID"];
    _merchantLocale =               queryStringDictionary[@"merchantLocale"];
    _unknownParameters =            queryStringDictionary[@"unknownParameters"];
    _webMasterID =                  queryStringDictionary[@"webMasterId"];
    _customField1 =                 queryStringDictionary[@"customField1"];
    _customField2 =                 queryStringDictionary[@"customField2"];
    _customField3 =                 queryStringDictionary[@"customField3"];
    _customField4 =                 queryStringDictionary[@"customField4"];
    _customField5 =                 queryStringDictionary[@"customField5"];
    _customField6 =                 queryStringDictionary[@"customField6"];
    _customField7 =                 queryStringDictionary[@"customField7"];
    _customField8 =                 queryStringDictionary[@"customField8"];
    _customField9 =                 queryStringDictionary[@"customField9"];
    _customField10 =                queryStringDictionary[@"customField10"];
    _customField11 =                queryStringDictionary[@"customField11"];
    _customField12 =                queryStringDictionary[@"customField12"];
    _customField13 =                queryStringDictionary[@"customField13"];
    _customField14 =                queryStringDictionary[@"customField14"];
    _customField15 =                queryStringDictionary[@"customField15"];
    
    return YES;
}

@end
