//
//  FieldingInterfaceController.m
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

#import "FieldingInterfaceController.h"


@interface FieldingInterfaceController()
{
    NSTimer *timer;
    NSInteger score;
    NSInteger highScore;
    NSString *container;
    NSUserDefaults *defaults;
    NSInteger strikeNumber;
    NSInteger ballNumber;
    NSInteger outNumber;
    NSString *statusNumber;
}

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *numberDisplayLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *strikeButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *ballButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *outButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *statusLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *returnButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *bestScoreLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *currentSocreLabel;

@end

@implementation FieldingInterfaceController

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    container = @"group.ca.amesf.3strikes";
    defaults = [[NSUserDefaults alloc] initWithSuiteName:container];
    [defaults setValue:@"000" forKey:@"hitNumbersFromServer"];
    score = 0;
    highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreFielding"];
    [self displayScore];
    //[defaults setValue:@"000" forKey:@"hitNumbersFromServer"];
    [self.statusLabel setText:@"Wait for reponse"];
    [self sendStatusToServer:@"000"];
}
- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getHitNumbersFromUserInfo) userInfo:nil repeats:true];
}
- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [timer invalidate];
    timer = nil;
}

- (void)dismissController {
    
}

- (void)displayScore {
    if (highScore > 0)
        [self.bestScoreLabel setText:[NSString stringWithFormat:@"Best: %d", (int)highScore]];
    
    [self.currentSocreLabel setText:[NSString stringWithFormat:@"Try: %d", (int)score]];
}

- (void)getHitNumbersFromUserInfo {
    NSString *hitNumbers = [defaults valueForKey:@"hitNumbersFromServer"];
    [self.numberDisplayLabel setText:hitNumbers];
}

- (NSInteger)getCurrentSum {
    NSInteger currentSum = strikeNumber + ballNumber + outNumber;
    
    if (currentSum == 2)
        [self.returnButton setEnabled:YES];
    
    return currentSum;
}

- (IBAction)strikeButtonTapped:(id)sender {
    if ([self getCurrentSum] < 3)
        strikeNumber++;
    else
        strikeNumber = 0;
    [self setCountNumbers];
}
- (IBAction)ballButtonTapped:(id)sender {
    if ([self getCurrentSum] < 3)
        ballNumber++;
    else
        ballNumber = 0;
    [self setCountNumbers];
}
- (IBAction)outButtonTapped:(id)sender {
    if ([self getCurrentSum] < 3)
        outNumber++;
    else
        outNumber = 0;
    [self setCountNumbers];
}

- (void)setCountNumbers
{
    [self.strikeButton setTitle:[NSString stringWithFormat:@"%d", (int)strikeNumber]];
    [self.ballButton setTitle:[NSString stringWithFormat:@"%d", (int)ballNumber]];
    [self.outButton setTitle:[NSString stringWithFormat:@"%d", (int)outNumber]];
}

- (IBAction)returnButtonTapped:(id)sender {
    if ([statusNumber isEqualToString:@"100"]) {
        [self sendStatusToServer:@"400"];
        score = 0;
        highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreFielding"];
        [self.returnButton setTitle:@"Return"];
        statusNumber = @"000";
        strikeNumber = ballNumber = outNumber = 0;
        [self setCountNumbers];
    }
    
    if (strikeNumber + ballNumber + outNumber == 3) {
        [self.statusLabel setText:@"Count your numbers."];
        [self.returnButton setEnabled:YES];
        score++;
        [self.currentSocreLabel setText:[NSString stringWithFormat:@"Try: %d", (int)score]];
        if (score < highScore) {
            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highScoreFielding"];
        }
        NSString *resultString = [NSString stringWithFormat:@"%d%d%d", (int)strikeNumber, (int)ballNumber, (int)outNumber];
        [self sendStatusToServer:resultString];
        strikeNumber = ballNumber = outNumber = 0;
        [self setCountNumbers];
    } else {
        [self.statusLabel setText:@"Must fill all counts. Sum them 3."];
        [self.returnButton setEnabled:NO];
    }
    [self displayScore];
}

- (void)sendStatusToServer:(NSString *)resultString {
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[resultString] forKeys:@[@"fieldStatusFromWatch"]];
    [WKInterfaceController openParentApplication:applicationData reply:^(NSDictionary *replyInfo, NSError *error)
     {
         NSString *response = [replyInfo objectForKey:@"actionReply"];
         NSLog(@"%@", response);
         if([response isEqualToString:@"notReady"]) {
             [self.statusLabel setText:@"Other player is not ready."];
             [defaults setValue:@"000" forKey:@"fieldStatusFromWatch"];
         }
     }];
    
    if ([resultString isEqualToString:@"300"]) {
        if (score > highScore) {
            highScore = score;
            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highScoreFielding"];
        }
        score = 0;
        [self.statusLabel setText:[NSString stringWithFormat:@"I knew yours was %@", [defaults valueForKey:@"hitNumbersFromServer"]]];
         [self.returnButton setTitle:@"Play again?"];
        statusNumber = @"100";
    }
}

@end



