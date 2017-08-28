//
//  SCHItem.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/30/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHItem.h"
#import "SCHValidatable.h"
#import "SCHLogging.h"

@interface SCHItem()

@end

@implementation SCHItem


+ (instancetype)itemWithName:(NSString *)name
                      amount:(double)amount
                    quantity:(long long)quantity;
{
    return [[SCHItem alloc] initItemWithName:name
                                      amount:[NSNumber numberWithDouble:amount]
                                    quantity:[NSNumber numberWithLongLong:quantity]];
}


- (instancetype) initItemWithName:(NSString *)name
                      amount:(NSNumber *)amount
                    quantity:(NSNumber *)quantity {
    self = [super init];
    if(self) {
        self.name = name;
        self.amount = amount;
        self.quantity = quantity;        
    }
    return self;
}

-(BOOL) validateAllSet {
    
    //required
    if( ![self validatePropertyRequired:self->_name               withMinValue:@0 withMaxValue:@400] )                 { SCHLog(@"_name validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:self->_amount             withMinValue:@0 withMaxValue:@(DBL_MAX)] )           { SCHLog(@"_amount validation failed"); return FALSE; }
    if( ![self validatePropertyRequired:self->_quantity           withMinValue:@0 withMaxValue:@(DBL_MAX)] )           { SCHLog(@"_quantity validation failed"); return FALSE; }
    
    //optional
    if( ![self validatePropertyIfSet:self->_number             withMinValue:@0 withMaxValue:@(LONG_MAX)] )          { SCHLog(@"_number validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:self->_shipping           withMinValue:@0 withMaxValue:@(DBL_MAX)] )           { SCHLog(@"_shipping validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:self->_handling           withMinValue:@0 withMaxValue:@(DBL_MAX)] )           { SCHLog(@"_handling validation failed"); return FALSE; }
    if( ![self validatePropertyIfSet:self->_discount           withMinValue:@0 withMaxValue:@(DBL_MAX)] )           { SCHLog(@"_discount validation failed"); return FALSE; }
    
    return TRUE;
}

@end
