//
//  SCHEventData.m
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/26/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import "SCHEventData.h"

@implementation SCHEventData

-(id) initFromPayload:(NSDictionary*) payload {
    self = [super init];
    if(self){
        [self updateWithPayload:payload];
    }
    
    return self;
}

-(BOOL) isReady {
    return self->updatedOnce;
}

-(void) updateWithPayload:(NSDictionary*) payload {
    self->event = [payload objectForKey:@"event"];        
    self->amount = [NSNumber numberWithDouble:((NSString*)[payload objectForKey:@"amount"]).doubleValue];
    self->currency = [payload objectForKey:@"currency"];
    self->onTokenAvaible = [payload objectForKey:@"onTokenAvailable"];
    self->onCancel = [payload objectForKey:@"onCancel"];
    self->updatedOnce = TRUE;
}

@end

