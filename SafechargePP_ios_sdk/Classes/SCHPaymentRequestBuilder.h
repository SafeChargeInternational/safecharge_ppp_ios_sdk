//
//  SCHRBuilder.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/27/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"
#import "SCHValidatable.h"
#import "SCHItem.h"

//FW
@class PKPaymentRequest;
@class SCHEventData;

@interface SCHPaymentRequestBuilder : SCHValidatable

//required
@property (nonatomic, strong)           NSURL*              baseURL;
@property (nonatomic, strong)           NSNumber*           merchantID;         // 64-bit integer
@property (nonatomic, strong)           NSNumber*           merchantSiteID;     // 64-bit integer
@property (nonatomic, strong)           NSString*           secretKey;
@property (nonatomic, strong)           NSString*           userTokenID;        // Char[255]
@property (nonatomic, strong)           NSString*           currency;           // Char[3]
@property (nonatomic, strong)           NSString*           version;
@property (nonatomic, strong)           NSNumber*           totalAmount;        // total_amount (double)

/* Optional Properties */

@property (nonatomic, strong)           NSString *          invoiceID;          // invoice_id (Char[400])
@property (nonatomic, strong)           NSString *          paymentMethod;      // payment_method (Char[256])
@property (nonatomic, strong)           NSString *          merchantLocale;     // merchantLocale (Char[5])
@property (nonatomic, strong)           NSString *          userID;             // userid (Char[50])
@property (nonatomic, strong)           NSString *          customData;         // customData (Char[255])
@property (nonatomic, strong)           NSString *          merchantUniqueID;   // merchant_unique_id (Char[64])
@property (nonatomic, strong)           NSString *          encoding;           // encoding (Char[20])
@property (nonatomic, strong)           NSString *          webMasterID;        // webMasterId (Char[255])
@property (nonatomic, strong)           NSNumber *          theme_id;           // min 0 max 99999999

@property (nonatomic, strong)           NSNumber *          useOpenAmount;      // item_open_amount_1
@property (nonatomic, strong)           NSNumber *          minAmount;          // item_min_amount_1 (double)
@property (nonatomic, strong)           NSNumber *          maxAmount;          // item_max_amount_1 (double)
@property (nonatomic, strong)           NSNumber *          totalDiscount;      // discount (double)
@property (nonatomic, strong)           NSNumber *          totalShipping;      // shipping (double)
@property (nonatomic, strong)           NSNumber *          totalHandling;      // handling (double)
@property (nonatomic, strong)           NSNumber *          totalTax;           // total_tax (double)
@property (nonatomic, strong)           NSString *          productID;          // productId (Char[50]

@property (nonatomic, strong)           NSString *          firstName;          // first_name (Char[30])
@property (nonatomic, strong)           NSString *          lastName;           // last_name (Char[40])
@property (nonatomic, strong)           NSString *          email;              // email (Char[100])
@property (nonatomic, strong)           NSString *          address1;           // address1 (Char[60])
@property (nonatomic, strong)           NSString *          address2;           // address2 (Char[60])
@property (nonatomic, strong)           NSString *          city;               // city (Char[30])
@property (nonatomic, strong)           NSString *          country;            // country (Char[20])
@property (nonatomic, strong)           NSString *          state;              // state (Char[20])
@property (nonatomic, strong)           NSString *          ZIP;                // zip (Char[10])
@property (nonatomic, strong)           NSString *          phone1;             // phone1 (Char[18])
@property (nonatomic, strong)           NSString *          phone2;             // phone2 (Char[18])
@property (nonatomic, strong)           NSString *          phone3;             // phone3 (Char[18])

@property (nonatomic, strong)           NSNumber *          skipBillingTab;     // skip_billing_tab
@property (nonatomic, strong)           NSNumber *          skipReviewTab;      // skip_review_tab
@property (nonatomic, strong)           NSURL *             successURL;         // success_url (max. length 2048)
@property (nonatomic, strong)           NSURL *             errorURL;           // error_url (max. length 2048)
@property (nonatomic, strong)           NSURL *             pendingURL;         // pending_url (max.length 2048)
@property (nonatomic, strong)           NSURL *             backURL;            // back_url (max. length 2048)
@property (nonatomic, strong)           NSURL *             notifyURL;          // notify_url (max. length 2048)

@property (nonatomic, strong)           NSString *          customSiteName;     // customSiteName (Char[50])
@property (nonatomic, strong)           NSString *          customField1;       // customField1 (Char[64])
@property (nonatomic, strong)           NSString *          customField2;       // customField2 (Char[64])
@property (nonatomic, strong)           NSString *          customField3;       // customField3 (Char[64])
@property (nonatomic, strong)           NSString *          customField4;       // customField4 (Char[64])
@property (nonatomic, strong)           NSString *          customField5;       // customField5 (Char[64])
@property (nonatomic, strong)           NSString *          customField6;       // customField6 (Char[64])
@property (nonatomic, strong)           NSString *          customField7;       // customField7 (Char[64])
@property (nonatomic, strong)           NSString *          customField8;       // customField8 (Char[64])
@property (nonatomic, strong)           NSString *          customField9;       // customField9 (Char[64])
@property (nonatomic, strong)           NSString *          customField10;      // customField10 (Char[64])
@property (nonatomic, strong)           NSString *          customField11;      // customField11 (Char[64])
@property (nonatomic, strong)           NSString *          customField12;      // customField12 (Char[64])
@property (nonatomic, strong)           NSString *          customField13;      // customField13 (Char[64])
@property (nonatomic, strong)           NSString *          customField14;      // customField14 (Char[64])
@property (nonatomic, strong)           NSString *          customField15;      // customField15 (Char[64])

@property (nonatomic, strong)           NSString *          cc_name_on_card;    // cc_name_on_card (Char[64])
@property (nonatomic, strong)           NSString *          cc_card_number;     // cc_card_number (Char[64])
@property (nonatomic, strong)           NSNumber *          cc_exp_month;       // cc_exp_month (min 1, max. 12)
@property (nonatomic, strong)           NSNumber *          cc_exp_year;        // cc_exp_year (min. 2000 , max 2099)
@property (nonatomic, strong)           NSNumber *          cc_cvv2;            // cc_cvv2 (min 100 max 999)


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//items
/////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic,strong)            NSMutableArray<SCHItem*>    *items;

@property (nonatomic,strong)            NSString                    *openState;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//user token type
/////////////////////////////////////////////////////////////////////////////////////////////////////////
@property (nonatomic, assign)           SCHUserTokenType    userTokenType;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// apple pay related
/////////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, assign)           SCHApplePaySupport  applePaySupport;    // apple_pay_support
@property (nonatomic, strong)           NSNumber *          allowsApplePay;     //
@property (nonatomic, strong)           NSString *          applePayMerchantId; //

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//public interface
/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (instancetype)initWithMerchantID:(NSNumber *) merchantID
                    merchantSiteID:(NSNumber *) merchantSiteID
                         secretKey:(NSString *) secretKey
                       userTokenID:(NSString *) userTokenID
                       totalAmount:(NSNumber *) totalAmount
                          currency:(NSString *) currency
                          itemName:(NSString *) itemName
                        itemAmount:(NSNumber *) itemAmount;

- (instancetype)initWithMerchantID:(NSNumber *) merchantID
                    merchantSiteID:(NSNumber *) merchantSiteID
                         secretKey:(NSString *) secretKey
                       userTokenID:(NSString *) userTokenID
                       totalAmount:(NSNumber *) totalAmount
                          currency:(NSString *) currency;


-(instancetype) initWithTotalAmount:(NSNumber*) totalAmount
                           currecny:(NSString*) currency;


////////////////////////////////////////////////////////////////////////////////////////////////////////
// add items interface
////////////////////////////////////////////////////////////////////////////////////////////////////////
-(SCHItem*) addItemWithName:(NSString*) name
                 withAmount:(NSNumber*) amount
               withQuantity:(NSNumber*) quantity;

-(void) addAndItem:(SCHItem *)item;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// NSURL and PKPaymentRequest interface
/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSURLRequest*) constructURLRequest;
-(PKPaymentRequest *) constructApplePayRequest:(SCHEventData*) eventData;

@end
