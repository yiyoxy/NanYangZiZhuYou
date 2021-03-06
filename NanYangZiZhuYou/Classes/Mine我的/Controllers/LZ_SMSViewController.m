//
//  LZ_SMSViewController.m
//  NanYangZiZhuYou
//
//  Created by scjy on 16/3/25.
//  Copyright © 2016年 李志鹏. All rights reserved.
//

#import "LZ_SMSViewController.h"
#import <BmobSDK/Bmob.h>
#import <SMS_SDK/SMSSDK.h>
#import "ProgressHUD.h"
#import "LZPValidate.h"
#import "LZPButtonTimer.h"

@interface LZ_SMSViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UIButton * countdownButton;
@property (weak, nonatomic) IBOutlet UITextField *SecurityCode;
@property (nonatomic, strong) UIButton *btn;

@end

@implementation LZ_SMSViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame = CGRectMake(0, 0, self.countdownButton.frame.size.width, self.countdownButton.frame.size.height);
    self.btn.backgroundColor = [UIColor orangeColor];
    [self.btn addTarget:self action:@selector(maketimeout:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.countdownButton addSubview:self.btn];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.phoneNumber becomeFirstResponder];
    
}
- (BOOL)checkout {
    //用户名不能为空且不能为空格
    if (self.phoneNumber.text.length <= 0 || [self.phoneNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""].length <= 0) {
        //alert提示框
        
        return NO;
    }
    
    if (![LZPValidate validatePhoneNumber:self.phoneNumber.text]) {
        return NO;
    }
    
    //输入的密码不能为空
    if (self.passWord.text.length <= 0 || [self.passWord.text stringByReplacingOccurrencesOfString:@" " withString:@""].length <= 0) {
        //alert输入密码不能为空
        return NO;
    }
    
    return YES;
}

- (void)maketimeout:(UIButton *)btn{
    if ([LZPValidate validatePhoneNumber:self.phoneNumber.text]){
        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.phoneNumber.text zone:@"86" customIdentifier:@"" result:^(NSError *error) {
            if (!error) {
                fSLog(@"获取验证码成功");
            }
            else
            {
                fSLog(@"获取验证码失败");
            }
            [LZPButtonTimer buttonWithTimerButton:btn TimeOut:60 timeOutRem:61];
        }];
    }else{
        [ProgressHUD show:@"请输入正确的手机号!"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ProgressHUD dismiss];
        });
    }
}
- (IBAction)bmobLogin:(id)sender {
    if (![self checkout]) {
        return;
    }
    [SMSSDK commitVerificationCode:self.SecurityCode.text phoneNumber:self.phoneNumber.text zone:@"86" result:^(NSError *error) {
        if (!error) {
            fSLog(@"验证成功");
            BmobUser *bUser = [[BmobUser alloc] init];
            bUser.username = self.phoneNumber.text;
            bUser.password = self.passWord.text;
            [bUser signUpInBackgroundWithBlock:^ (BOOL isSuccessful, NSError *error){
                if (isSuccessful){
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [ProgressHUD showSuccess:@"注册成功"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [ProgressHUD dismiss];
                    });
                } else {
                    [ProgressHUD showError:@"注册失败"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [ProgressHUD dismiss];
                    });
                }
            }];
            
        }
        else
        {
            fSLog(@"验证失败");
        }
    }];
    
    
    
    
}
//点击右下角回收键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
//点击页面空白处回收键盘
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
}


@end



























