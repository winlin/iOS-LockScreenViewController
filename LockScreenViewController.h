//
//  LockScreenViewController.h
//  Manager
//
//  Created by gtliu on 3/12/13.
//  Copyright (c) 2013 shang bo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LockScreenViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *firstCodeBut;
@property (retain, nonatomic) IBOutlet UIButton *secondCodeBut;
@property (retain, nonatomic) IBOutlet UIButton *thridCodeBut;
@property (retain, nonatomic) IBOutlet UIButton *fourthCodeBut;
@property (retain, nonatomic) NSMutableString *passcode;

-(IBAction)keyNumberButDown:(UIButton *)sender;
- (IBAction)delButDown:(UIButton *)sender;
+(LockScreenViewController *)sharedLockViewController;
-(void)resetContent;
@end
