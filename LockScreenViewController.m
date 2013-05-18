//
//  LockScreenViewController.m
//  Manager
//
//  Created by gtliu on 3/12/13.
//  Copyright (c) 2013 shang bo. All rights reserved.
//

#import "LockScreenViewController.h"
#import "LogInfo.h"
#import "Configuration.h"
#import "WSDBObject.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NSDate+Reporting.h"
#import "Content.h"

#define TODAY_HAVE_HINT_LEFT_DAYS      @"TODAY_HAVE_HINT_LEFT_DAYS"

@interface LockScreenViewController ()
@property (assign, nonatomic)WSDBObject *dbObject;
@property (assign, nonatomic)BOOL expireFlag;
@end

static LockScreenViewController *sharedLock = nil;

@implementation LockScreenViewController
@synthesize passcode;
@synthesize dbObject;
@synthesize expireFlag;

int haveInputCodeNum;

+(LockScreenViewController *)sharedLockViewController
{
    @synchronized(self) {
        if (sharedLock == nil) {
            sharedLock = [[LockScreenViewController alloc] initWithNibName:@"LockScreenViewController" bundle:nil];
        }
    }
    return sharedLock;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    WSLogEnter
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    haveInputCodeNum = 0;
    passcode = [[NSMutableString alloc] initWithCapacity:4];
    dbObject = [WSDBObject sharedDBObject];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     NSUserDefaults *defaut = [NSUserDefaults standardUserDefaults];
    //set today key
    int todayMidNight = [[NSDate midnightToday] timeIntervalSince1970];
    NSString *todayKey = [NSString stringWithFormat:@"%d", todayMidNight];
    
    [defaut setBool:NO forKey:todayKey];
    //BOOL toadyValue = [defaut boolForKey:todayKey];
    //if (!toadyValue) {
        //delete yesterday key
        int numKey = todayMidNight - 24*3600;
        NSString *yesterdayKey = [NSString stringWithFormat:@"%d", numKey];
        [defaut removeObjectForKey:yesterdayKey];
        //set today key
        [defaut setBool:YES forKey:todayKey];
        int leftDays = [dbObject checkTimeoutDate];
        if (leftDays <= SETTING_LEFT_DAYS && leftDays >0) {
            NSString *content = [NSString stringWithFormat:@"您的使用期限还有 %d 天.\n请及时更新授权文件,否则将无法继续使用本系统.", leftDays];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"到期提醒"
                                  message:content
                                  delegate:nil
                                  cancelButtonTitle:ALERT_SURE_BUT
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else if (leftDays == 0){
            expireFlag = YES;
            NSString *content = [NSString stringWithFormat:@"您的使用期限已过期.\n请及时更新授权文件,否则将无法继续使用本系统."];
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"过期提醒"
                                  message:content
                                  delegate:nil
                                  cancelButtonTitle:ALERT_SURE_BUT
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else {
            expireFlag = NO;
        }
    //}
    self.view.userInteractionEnabled = !expireFlag;
}

-(IBAction)keyNumberButDown:(UIButton *)sender
{
    switch (haveInputCodeNum) {
        case 0:
            [_firstCodeBut setTitle:@"*" forState:UIControlStateNormal];
            [passcode appendString:sender.titleLabel.text];
            ++haveInputCodeNum;
            break;
        case 1:
            [_secondCodeBut setTitle:@"*" forState:UIControlStateNormal];
            [passcode appendString:sender.titleLabel.text];
            ++haveInputCodeNum;
            break;
        case 2:
            [_thridCodeBut setTitle:@"*" forState:UIControlStateNormal];
            [passcode appendString:sender.titleLabel.text];
            ++haveInputCodeNum;
            break;
        case 3:
            [_fourthCodeBut setTitle:@"*" forState:UIControlStateNormal];
            [passcode appendString:sender.titleLabel.text];
            ++haveInputCodeNum;
            break;
        default:
            haveInputCodeNum = 1;
            [_firstCodeBut setTitle:@"*" forState:UIControlStateNormal];
            [passcode setString:sender.titleLabel.text];
            [_secondCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [_thridCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [_fourthCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            break;
    }
    //WS_dprintf("%s", [passcode UTF8String]);
    if (passcode.length == 4) {
        WS_dprintf("input passcode:%s", [passcode UTF8String]);
        if ([dbObject checkPasscode:passcode] && !expireFlag) {
            [self.view.window setHidden:YES];
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        [self resetContent];
    }
}

-(void)resetContent
{
    haveInputCodeNum = 0;
    [_firstCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
    [_secondCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
    [_thridCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
    [_fourthCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
    [passcode setString:EMPTY_DEFAULT_STRING];
}

- (IBAction)delButDown:(UIButton *)sender {
    switch (haveInputCodeNum) {
        case 0:
            [_firstCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [passcode setString:EMPTY_DEFAULT_STRING];
            haveInputCodeNum = 0;
            break;
        case 1:
            [_firstCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [passcode setString:[passcode substringToIndex:passcode.length-1]];
            --haveInputCodeNum;
            break;
        case 2:
            [_secondCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [passcode setString:[passcode substringToIndex:passcode.length-1]];
            --haveInputCodeNum;
            break;
        case 3:
            [_thridCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [passcode setString:[passcode substringToIndex:passcode.length-1]];
            --haveInputCodeNum;
            break;
        case 4:
            [_fourthCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [passcode setString:[passcode substringToIndex:passcode.length-1]];
            --haveInputCodeNum;
            break;
        default:
            haveInputCodeNum = 0;
            [_firstCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [_secondCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [_thridCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [_fourthCodeBut setTitle:EMPTY_DEFAULT_STRING forState:UIControlStateNormal];
            [passcode setString:EMPTY_DEFAULT_STRING];
            break;
    }
    WS_dprintf("%s", [passcode UTF8String]);
}

- (void)dealloc {
    [passcode release];
    [_firstCodeBut release];
    [_secondCodeBut release];
    [_thridCodeBut release];
    [_fourthCodeBut release];
    [super dealloc];
}
@end
