//
//  BattingInterfaceController.m
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

#import "BattingInterfaceController.h"


@interface BattingInterfaceController()
{
    NSTimer *timer;
    NSInteger firstNumber;
    NSInteger secondNumber;
    NSInteger thirdNumber;
    NSString *resultStringForBatting;
    NSString *statusNumber;
    NSString *container;
    NSUserDefaults *defaults;
    NSInteger score;
    NSInteger highScore;
}

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *scoreLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *displayStatusLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *firstUpButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *firstLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *firstDownButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *secondUpButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *secondLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *secondDownButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *thirdUpButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *thirdLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *thirdDownButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *hitButton;

@end

@implementation BattingInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    firstNumber = secondNumber = thirdNumber = 0;
    container = @"group.ca.amesf.3strikes";
    defaults = [[NSUserDefaults alloc] initWithSuiteName:container];
    [defaults setValue:@"000" forKey:@"statusForBatting"];
    score = 0;
    highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreBatting"];
    if (highScore == 0)
        highScore = 1000;
    [self displayScore];
    [self.displayStatusLabel setText:@"Guess numbers"];
    [defaults setValue:@"000" forKey:@"statusForBatting"];
}
- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self displayNumbers];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getStatusFromUSerInfo) userInfo:nil repeats:true];
}
- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [timer invalidate];
    timer = nil;
}

- (void)sendNumbersToServer:(NSString *)numberString {
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[numberString] forKeys:@[@"hitNumbersFromWatch"]];
    [WKInterfaceController openParentApplication:applicationData reply:^(NSDictionary *replyInfo, NSError *error)
     {
         NSString *response = [replyInfo objectForKey:@"actionReply"];
         NSLog(@"%@", response);
         if([response isEqualToString:@"notReady"]) {
             [self.displayStatusLabel setText:@"Other player is not ready."];
             [defaults setValue:@"000" forKey:@"statusForBatting"];
         }
     }];
}

- (void)displayScore {
    NSString *scoreString = [NSString stringWithFormat:@"Best: %d Try: %d", (int)highScore, (int)score];
    if (highScore == 0 || highScore == 1000)
        scoreString = [NSString stringWithFormat:@"Try: %d", (int)score];
    
    [self.scoreLabel setText:scoreString];
}

- (void)getStatusFromUSerInfo {
    resultStringForBatting = [defaults valueForKey:@"resultStringForBatting"];
    [self displayResult];
}

- (IBAction)hitButtonTapped {
    if ([statusNumber isEqualToString:@"100"]) {
        score = 0;
        highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreBatting"];
        [self.hitButton setTitle:@"Hit!"];
        [self.displayStatusLabel setText:@"Guess numbers"];
        [defaults setValue:@"000" forKey:@"resultStringForBatting"];
        resultStringForBatting = [defaults valueForKey:@"resultStringForBatting"];
        statusNumber = @"000";
    } else {
        score++;
        [self.displayStatusLabel setText:@"Wait for response"];
        NSString *numberString = [NSString stringWithFormat:@"%d%d%d", (int)firstNumber, (int)secondNumber, (int)thirdNumber];
        [self sendNumbersToServer:numberString];
    }
    [self displayScore];
}

- (IBAction)firstUpButtonTapped {
    if (firstNumber < 9)
        firstNumber++;
    else
        firstNumber = 0;
    [self displayNumbers];
}
- (IBAction)firstDownButtonTapped {
    if (firstNumber > 0)
        firstNumber--;
    else
        firstNumber = 9;
    [self displayNumbers];
}
- (IBAction)secondUpButtonTapped {
    if (secondNumber < 9)
        secondNumber++;
    else
        secondNumber = 0;
    [self displayNumbers];
}
- (IBAction)secondDownButtonTapped {
    if (secondNumber > 0)
        secondNumber--;
    else
        secondNumber = 9;
    [self displayNumbers];
}
- (IBAction)thirdUpButtonTapped {
    if (thirdNumber < 9)
        thirdNumber++;
    else
        thirdNumber = 0;
    [self displayNumbers];
}
- (IBAction)thirdDownButtonTapped {
    if (thirdNumber > 0)
        thirdNumber--;
    else
        thirdNumber = 9;
    [self displayNumbers];
}

- (void)displayNumbers {
    [self.firstLabel setText:[NSString stringWithFormat:@"%d", (int)firstNumber]];
    [self.secondLabel setText:[NSString stringWithFormat:@"%d", (int)secondNumber]];
    [self.thirdLabel setText:[NSString stringWithFormat:@"%d", (int)thirdNumber]];
}

- (void)displayResult {
    NSMutableString *statusString = [[NSMutableString alloc]init];
    
    if ([resultStringForBatting isEqualToString:@"300"]) {
        [statusString appendString:@"Hooray! you beat the player."];
        if (score < highScore) {
            highScore = score;
            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highScoreBatting"];
        }
        [self.hitButton setTitle:@"Play again?"];
        statusNumber = @"100";
        [self.displayStatusLabel setText:statusString];
    } else {
        if ([[defaults valueForKey:@"statusForBatting"] isEqualToString:@"200"]) {
            NSInteger strikeNumber = [[resultStringForBatting substringWithRange:NSMakeRange(0, 1)] integerValue];
            NSInteger ballNumber = [[resultStringForBatting substringWithRange:NSMakeRange(1, 1)] integerValue];
            NSInteger outNumber = [[resultStringForBatting substringWithRange:NSMakeRange(2, 1)] integerValue];
            
            if (strikeNumber > 0) {
                if (strikeNumber > 1) {
                    [statusString appendString:[NSString stringWithFormat:@"%d Strikes", (int)strikeNumber]];
                } else {
                    [statusString appendString:[NSString stringWithFormat:@"%d Strike", (int)strikeNumber]];
                }
            }
            if (ballNumber > 0) {
                if (ballNumber > 1) {
                    [statusString appendString:[NSString stringWithFormat:@" %d Balls", (int)ballNumber]];
                } else {
                    [statusString appendString:[NSString stringWithFormat:@" %d Ball", (int)ballNumber]];
                }
            }
            if (outNumber > 0) {
                if (outNumber > 1) {
                    [statusString appendString:[NSString stringWithFormat:@" %d Outs", (int)outNumber]];
                } else {
                    [statusString appendString:[NSString stringWithFormat:@" %d Out", (int)outNumber]];
                }
            }
            
            if ([statusString length] < 1) {
                [statusString appendString:@"Guess numbers"];
            }
            [self.displayStatusLabel setText:statusString];
        }
    }
}


@end