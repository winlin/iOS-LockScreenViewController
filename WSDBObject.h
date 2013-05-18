//
//  WSDBObject.h
//  ManagerClient
//
//  Created by gtliu on 1/28/13.
//  Copyright (c) 2013 WS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSDBObject : NSObject

+(WSDBObject *)sharedDBObject;
+(void)deallocDBobject;

#pragma mark - passcode api
-(BOOL)checkPasscode:(NSString *)passcode;
-(BOOL)setPasscode:(NSString *)passcode;
//return the left days
-(int)checkTimeoutDate;
//endDate: string like 2012-02-03
-(BOOL)generateSettingFileWithPasscode:(NSString *)passcode TimeoutDate:(NSString *)endDate;
@end







