//
//  ViewController.m
//  3 Strikes
//
//  Copyright (c) 2015 AME Software Factory. All rights reserved.
//
//
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "ViewController.h"
#import "Global.h"
#import "FieldingViewController.h"
#import "BattingViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *playModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *battingButton;
@property (weak, nonatomic) IBOutlet UIButton *fieldingButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController {
    NSString *container;
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.statusLabel setHidden:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openFieldingWindow:)
                                                 name:@"OpenFieldingWindow" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openBattingWindow:)
                                                 name:@"OpenBattingWindow" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissFieldingWindow:)
                                                 name:@"DismissFieldingWindow" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissBattingWindow:)
                                                 name:@"DismissBattingWindow" object:nil];
    
    container = @"group.ca.amesf.3strikes";
    defaults = [[NSUserDefaults alloc] initWithSuiteName:container];
    _playModeSegmentedControl.selectedSegmentIndex = 1;
    [self enableAI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enableAI
{
    g_isAI = YES;
    [self.battingButton setEnabled:NO];
    [self.fieldingButton setEnabled:NO];
    [self.statusLabel setHidden:NO];
}

- (IBAction)playModeChanged:(id)sender {
    if (_playModeSegmentedControl.selectedSegmentIndex == 0) {
        g_isAI = NO;
        [self.battingButton setEnabled:YES];
        [self.fieldingButton setEnabled:YES];
        [self.statusLabel setHidden:YES];
    } else if(_playModeSegmentedControl.selectedSegmentIndex == 1) {
        [self enableAI];
    }
}

- (void)dismissFieldingWindow:(NSNotification *)note {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)dismissBattingWindow:(NSNotification *)note {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)resetScore:(id)sender {
    
    if ([UIAlertController class])
    {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reset Score" message:@"Do you want to reset high socre?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *resetAction = [UIAlertAction
                                      actionWithTitle:NSLocalizedString(@"Reset Score", @"Reset action")
                                      style:UIAlertActionStyleDestructive
                                      handler:^(UIAlertAction *action)
                                      {
                                          NSLog(@"Reset action");
                                          [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"highScoreBatting"];
                                          [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"highScoreFielding"];
                                      }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
        [alertController addAction:resetAction];
        [alertController addAction:cancelAction];

        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else
    {
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert title" message:@"Alert message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
}

- (void)openFieldingWindow:(NSNotification *)note {
    [self performSegueWithIdentifier:@"fielding" sender:self];
}

- (void)openBattingWindow:(NSNotification *)note {
    [self performSegueWithIdentifier:@"batting" sender:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateStatusDisplayLabel" object:nil];
}

@end
