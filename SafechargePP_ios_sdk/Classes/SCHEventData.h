//
//  SCHEventData.h
//  SafechargePP
//
//  Created by Miroslav Chernev on 1/26/17.
//  Copyright © 2017 SafeCharge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHEventData : NSObject
{
@public
    NSString *event;
    NSNumber *amount;
    NSString *currency;
    NSString *onTokenAvaible;
    NSString *onCancel;
    
    BOOL updatedOnce;
}

-(id) initFromPayload:(NSDictionary*) payload;
-(BOOL) isReady;
-(void) updateWithPayload:(NSDictionary*) payload;
@end
