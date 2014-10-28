//
//  LoginViewController.m
//  xmppDemo
//
//  Created by Mengying Xu on 14-10-22.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverTextField;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginAction:(id)sender {
    if  ([self validateWithUser:self.userTextField.text andPass:self.passwordTextField.text andServer:self.serverTextField.text]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.userTextField.text forKey:@"USERID"];
        [defaults setObject:self.passwordTextField.text forKey:@"PASS"];
        [defaults setObject:self.serverTextField.text forKey:@"SERVER"];
        //保存
        [defaults synchronize];
        
        [self.navigationController popViewControllerAnimated:YES];
    }else  {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@ "请输入用户名，密码和服务器"  delegate:nil cancelButtonTitle:@ "确定"  otherButtonTitles:nil, nil];
        [alert show];
    }

    
}

-(BOOL)validateWithUser:(NSString *)userText andPass:(NSString *)passText andServer:(NSString *)serverText{
    
    if  (userText.length >  0  && passText.length >  0  && serverText.length >  0 ) {
        return  YES;
    }
    
    return  NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.serverTextField resignFirstResponder];
}

@end
