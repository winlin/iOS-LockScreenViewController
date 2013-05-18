//
//  WSDBObject.m
//  ManagerClient
//
//  Created by gtliu on 1/28/13.
//  Copyright (c) 2013 WS. All rights reserved.
//

#import "WSDBObject.h"
#import "NSDate+Reporting.h"
#import <AddressBook/AddressBook.h>
#import "Tools.h"
#import "NSDate+Reporting.h"

//Passcode
#define PASSCODE_LENGTH             4
#define PASSCODE_DEFAUT_CODE        @"1234"
#define VALID_DAYS_MUN              30
#define SETTING_FILE_NAME           @"settingfile"
#define PASSCODE_KEY                0x23
#define SETTING_SEPARATED_STRING    @","
#define SETTING_DATE_STYLE          @"yyyy-MM-dd"
#define SETTING_LEFT_DAYS           3

@implementation WSDBObject

static WSDBObject *sharedDBObject = nil;

#pragma mark - WSDBObject
+(WSDBObject *)sharedDBObject
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDBObject = [[WSDBObject alloc] init];
    });
    return sharedDBObject;
}

+(void)deallocDBobject
{
    if (sharedDBObject) {
        [sharedDBObject release];
        sharedDBObject = nil;
    }
}

#pragma mark - passcode api
-(NSMutableData *)readSettingFileContent
{
    NSString *appDocPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [appDocPath stringByAppendingPathComponent:SETTING_FILE_NAME];
    //WS_dprintf("filePath:%s", filePath.UTF8String);
    NSMutableData *data = [NSMutableData dataWithContentsOfFile:filePath];
    if (data.length == 0) {
        //"ERROR read file:%@ failed", filePath
        return nil;
    }
    return data;
}

-(BOOL)saveSettingFileContent:(NSData *)data
{
    NSString *appDocPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [appDocPath stringByAppendingPathComponent:SETTING_FILE_NAME];
    //"filePath:%s", filePath.UTF8String
    return [data writeToFile:filePath atomically:YES];
}

-(BOOL)checkPasscode:(NSString *)passcode
{
    if (passcode.length != PASSCODE_LENGTH) {
        return NO;
    }
    
    NSMutableData *data = [self readSettingFileContent];
    int count = data.length;
    if (count == 0) {
        return NO;
    }
    for (int i=0; i<count; ++i) {
        unsigned char one = ((unsigned char *)data.mutableBytes)[i];
        ((unsigned char *)data.mutableBytes)[i] = one^PASSCODE_KEY;
    }
    NSString *strData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString *passStr = [[strData componentsSeparatedByString:SETTING_SEPARATED_STRING] objectAtIndex:0];
    BOOL flag = [passStr isEqualToString:passcode];
    [strData release];
    return flag;
}

-(BOOL)setPasscode:(NSString *)passcode
{
    if (passcode.length != PASSCODE_LENGTH) {
        WSLog(@"ERROR  paramter illegal");
        return NO;
    }
    NSMutableData *data = [self readSettingFileContent];
    int count = data.length;
    if (count == 0) {
        return NO;
    }
    NSMutableData *newPasscodeData = [NSMutableData dataWithData:[passcode dataUsingEncoding:NSASCIIStringEncoding]];
    count = newPasscodeData.length;
    for (int i=0; i<count; ++i) {
        unsigned char one = ((unsigned char *)newPasscodeData.mutableBytes)[i];
        ((unsigned char *)newPasscodeData.mutableBytes)[i] = one^PASSCODE_KEY;
    }
    [data replaceBytesInRange:NSMakeRange(0, count) withBytes:newPasscodeData.bytes];
    return [self saveSettingFileContent:data];
}

-(int)checkTimeoutDate
{
    NSMutableData *data = [self readSettingFileContent];
    int count = data.length;
    if (count == 0) {
        return 0;
    }
    for (int i=0; i<count; ++i) {
        unsigned char one = ((unsigned char *)data.mutableBytes)[i];
        ((unsigned char *)data.mutableBytes)[i] = one^PASSCODE_KEY;
    }
    NSString *strData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString *expireDateStr = [[strData componentsSeparatedByString:SETTING_SEPARATED_STRING] objectAtIndex:1];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:SETTING_DATE_STYLE];
    NSDate *expireDate = [formatter dateFromString:expireDateStr];
    NSDate *tomorrowMidNight = [NSDate midnightTomorrow];
    //WSMSGLog(@"tomorrowMidNight:%@", [formatter stringFromDate:tomorrowMidNight]);
    [formatter release];
    int leftDays = (expireDate.timeIntervalSince1970 - tomorrowMidNight.timeIntervalSince1970)/24/3600 + 1;
    [strData release];
    //WSMSGLog(@"expireDate:%@  leftDays:%d", expireDateStr, leftDays);
    return leftDays;
}

-(BOOL)generateSettingFileWithPasscode:(NSString *)passcode TimeoutDate:(NSString *)endDate
{
    if (passcode.length != 4) {
        passcode = PASSCODE_DEFAUT_CODE;
    }
    if (endDate.length == 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:SETTING_DATE_STYLE];
        int tmpNum = [NSDate midnightToday].timeIntervalSince1970 + VALID_DAYS_MUN*24*3600;
        endDate = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:tmpNum]];
        [formatter release];
    }
    NSString *setting = [NSString stringWithFormat:@"%@%@%@", passcode, SETTING_SEPARATED_STRING, endDate];
    WS_dprintf("Genrate setting:%s", setting.UTF8String);
    NSMutableData *data = [NSMutableData dataWithData:[setting dataUsingEncoding:NSASCIIStringEncoding]];
    int count = data.length;
    for (int i=0; i<count; ++i) {
        unsigned char one = ((unsigned char *)data.mutableBytes)[i];
        ((unsigned char *)data.mutableBytes)[i] = one^PASSCODE_KEY;
    }
    BOOL flag = [self saveSettingFileContent:data];
    
    return flag;
}

@end

































