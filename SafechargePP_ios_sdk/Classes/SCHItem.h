//
//  SCHItem.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/30/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHValidatable.h"

@interface SCHItem : SCHValidatable


//SCH Fields
@property (nonatomic, strong) NSString *name;       // item_name_N (Char[400])
@property (nonatomic, strong) NSNumber *amount;     // item_amount_N (double)
@property (nonatomic, strong) NSNumber *quantity;   // item_quantity_N

@property (nonatomic, strong) NSNumber *number;     // item_number_N (Char[400])
@property (nonatomic, strong) NSNumber *shipping;   // item_shipping_N (double)
@property (nonatomic, strong) NSNumber *handling;   // item_handling_N (double)
@property (nonatomic, strong) NSNumber *discount;   // item_discount_N (double)


//Apple pay fields
@property (nonatomic,strong) NSString *applePayItemTitle;

- (instancetype) initItemWithName:(NSString *)name
                           amount:(NSNumber *)amount
                         quantity:(NSNumber *)quantity;

//compat
+ (instancetype)itemWithName:(NSString *)name
                      amount:(double)amount
                    quantity:(long long)quantity;
-(BOOL) validateAllSet;

@end
