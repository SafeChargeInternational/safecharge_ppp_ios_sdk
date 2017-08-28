//
//  Enums.m
//  SafechargePP
//
//  Created by Bozhidar Dimitrov on 5/19/15.
//  Copyright (c) 2015-2016 SafeCharge. All rights reserved.
//


#import "Enums.h"


NSString * NSStringFromUserTokenType(SCHUserTokenType userTokenType)
{
    switch (userTokenType) {
        case SCHUserTokenTypeAuto:
            return @"auto";
        case SCHUserTokenTypeRegister:
            return @"register";
        case SCHUserTokenTypeReadonly:
            return @"readonly";
        default:
            return @"";
    }
}