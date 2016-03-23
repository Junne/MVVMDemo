//
//  ViewController.m
//  MVVMDemo
//
//  Created by baijf on 3/23/16.
//  Copyright © 2016 Junne. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACDelegateProxy.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) Person *person;

@property (nonatomic) RACDelegateProxy *proxy;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self userName];
    [self nameKvo];
    [self textFieldCombine];
    [self buttonAction];
    [self delegateTest];
    [self notificationTest];
    // Do any additional setup after loading the view, typically from a nib.
}

- (Person *)person {
    if (!_person) {
        _person = [[Person alloc] init];
    }
    return _person;
}

- (void)notificationTest
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"NotificationTest  =  %@", x);
    }];
}

- (void)delegateTest
{
    @weakify(self)
    self.proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UITextFieldDelegate)];
    [[self.proxy rac_signalForSelector:@selector(textFieldShouldReturn:)] subscribeNext:^(id x) {
        @strongify(self)
        if (self.userNameTextField.hasText) {
            [self.passwordTextfield becomeFirstResponder];
        }
    }];
    self.userNameTextField.delegate = (id<UITextFieldDelegate>)self.proxy;
    
}

- (void)buttonAction
{
    @weakify(self);
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"person.user = %@ person.password = %@", self.person.userString,self.person.passwordString);
              }];
}

- (void)textFieldCombine
{
    id signals = @[[self.userNameTextField rac_textSignal], [self.passwordTextfield rac_textSignal]];
    @weakify(self);
    [[RACSignal combineLatest:signals] subscribeNext:^(RACTuple *x) {
        @strongify(self);
        NSString *user = [x first];
        NSString *password = [x second];
        
        if (user.length > 0 && password.length > 0) {
            self.loginButton.enabled = YES;
            self.person.userString = user;
            self.person.passwordString = password;
        } else {
            self.loginButton.enabled = NO;
        }
    }];
}

- (void)userName
{
    @weakify(self);
    [[self.userNameTextField rac_textSignal]
     subscribeNext:^(id x) {
         @strongify(self);
         NSLog(@"userName x = %@", x);
         self.person.userString = x;
     }];
}

- (void)nameKvo {
    @weakify(self)
    [RACObserve(self.person, userString)
     subscribeNext:^(id x) {
         @strongify(self)
         self.tipLabel.text = x;
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
