//
//  FieldingViewController.m
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

#import "FieldingViewController.h"
#import "Global.h"

@interface FieldingViewController () {
    NSInteger score;
    NSInteger highScore;
    NSString *container;
    NSUserDefaults *defaults;
    NSInteger strikeNumber;
    NSInteger ballNumber;
    NSInteger outNumber;
    NSString *numbersForAI;
    NSString *random1;
    NSString *random2;
    NSString *random3;
    bool isNewGame;
}

@property (weak, nonatomic) IBOutlet UILabel *numberDisplayLabel;
@property (weak, nonatomic) IBOutlet UIButton *strikeButton;
@property (weak, nonatomic) IBOutlet UIButton *ballButton;
@property (weak, nonatomic) IBOutlet UIButton *outButton;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentScoreLabel;

@end

@implementation FieldingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Global setSelectedWindow:@"fielding"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNumberDisplayLabel:)
                                                 name:@"UpdateNumberDisplayLabel" object:nil];
    
    container = @"group.ca.amesf.3strikes";
    defaults = [[NSUserDefaults alloc] initWithSuiteName:container];
    [defaults setValue:@"000" forKey:@"statusForBatting"];
    highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreFielding"];
    
    [self displayScore];
    
    if (g_isAI) {
        [self updateFieldingWindow];
        [self.strikeButton setEnabled:NO];
        [self.ballButton setEnabled:NO];
        [self.outButton setEnabled:NO];
        [self.returnButton setHidden:YES];
        [self.returnButton setEnabled:NO];
    } else {
        [self.strikeButton setEnabled:YES];
        [self.ballButton setEnabled:YES];
        [self.outButton setEnabled:YES];
        [self.returnButton setHidden:NO];
        [self.returnButton setEnabled:YES];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [Global setSelectedWindow:@""];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)generateNumbersForAI
{
    random1 = [NSString stringWithFormat:@"%d", (int)[Global randomValueBetween:0 and:9]];
    random2 = [NSString stringWithFormat:@"%d", (int)[Global randomValueBetween:0 and:9]];
    random3 = [NSString stringWithFormat:@"%d", (int)[Global randomValueBetween:0 and:9]];
    return [NSString stringWithFormat:@"%@%@%@", random1, random2, random3];
}

- (void)updateNumberDisplayLabel:(NSNotification *)note {
    if ([[Global hitNumbersFromWatch] isEqualToString:@"1000"]) {
        [defaults setValue:@"" forKey:@"hitNumbersFromWatch"];
        [[self navigationController] popViewControllerAnimated:YES];  // goes back to previous view
    }
    [self updateFieldingWindow];
}

- (void)updateFieldingWindow {
    [self.numberDisplayLabel setText:[Global hitNumbersFromWatch]];
    score++;
    [self displayScore];
    if (g_isAI) {
        if (numbersForAI == nil)
            numbersForAI = [self generateNumbersForAI];
        
        [self displayContingByAI];
    } else {
        [self.statusLabel setText:@"Count the numbers."];
    }
}

- (void)displayContingByAI {
    strikeNumber = 0;
    ballNumber = 0;
    outNumber = 0;

    NSString *hitNumbers = [Global hitNumbersFromWatch];
    NSString *hitNumber1 = [hitNumbers substringWithRange:NSMakeRange(0, 1)];
    NSString *hitNumber2 = [hitNumbers substringWithRange:NSMakeRange(1, 1)];
    NSString *hitNumber3 = [hitNumbers substringWithRange:NSMakeRange(2, 1)];
    
    NSMutableDictionary *hitNumberDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *randomNumberDic = [NSMutableDictionary dictionary];
    
    // compare with random1
    if ([hitNumber1 isEqualToString:random1]) {
        strikeNumber++;
        [hitNumberDic setValue:@"1" forKey:@"1"];
        [randomNumberDic setValue:@"1" forKey:@"1"];
    }
    
    // compare with random2
    if ([hitNumber2 isEqualToString:random2]) {
        strikeNumber++;
        [hitNumberDic setValue:@"1" forKey:@"2"];
        [randomNumberDic setValue:@"1" forKey:@"2"];
    }
    
    // compare with random3
    if ([hitNumber3 isEqualToString:random3]) {
        strikeNumber++;
        [hitNumberDic setValue:@"1" forKey:@"3"];
        [randomNumberDic setValue:@"1" forKey:@"3"];
    }
    
    if (![[randomNumberDic valueForKey:@"1"] isEqual: @"1"]) {
        if (![[hitNumberDic valueForKey:@"2"] isEqual: @"1"] && [hitNumber2 isEqualToString:random1]) {
            ballNumber++;
            [hitNumberDic setValue:@"1" forKey:@"2"];
            [randomNumberDic setValue:@"1" forKey:@"1"];
        } else if (![[hitNumberDic valueForKey:@"3"] isEqual: @"1"] && [hitNumber3 isEqualToString:random1]) {
            ballNumber++;
            [hitNumberDic setValue:@"1" forKey:@"3"];
            [randomNumberDic setValue:@"1" forKey:@"1"];
        } else {
            outNumber++;
        }
    }
    
    if (![[randomNumberDic valueForKey:@"2"] isEqual: @"1"]) {
        if (![[hitNumberDic valueForKey:@"1"] isEqual: @"1"] && [hitNumber1 isEqualToString:random2]) {
            ballNumber++;
            [hitNumberDic setValue:@"1" forKey:@"1"];
            [randomNumberDic setValue:@"1" forKey:@"2"];
        } else if (![[hitNumberDic valueForKey:@"3"] isEqual: @"1"] && [hitNumber3 isEqualToString:random2]) {
            ballNumber++;
            [hitNumberDic setValue:@"1" forKey:@"3"];
            [randomNumberDic setValue:@"1" forKey:@"2"];
        } else {
            outNumber++;
        }
    }
    
    if (![[randomNumberDic valueForKey:@"3"] isEqual: @"1"]) {
        if (![[hitNumberDic valueForKey:@"1"] isEqual: @"1"] && [hitNumber1 isEqualToString:random3]) {
            ballNumber++;
            [hitNumberDic setValue:@"1" forKey:@"1"];
            [randomNumberDic setValue:@"1" forKey:@"3"];
        } else if (![[hitNumberDic valueForKey:@"2"] isEqual: @"1"] && [hitNumber2 isEqualToString:random3]) {
            ballNumber++;
            [hitNumberDic setValue:@"1" forKey:@"2"];
            [randomNumberDic setValue:@"1" forKey:@"3"];
        } else {
            outNumber++;
        }
    }

    [self displayCounting];

    NSString *resultStringForBatting = [NSString stringWithFormat:@"%d%d%d", (int)strikeNumber, (int)ballNumber, (int)outNumber];
    [defaults setValue:resultStringForBatting forKey:@"resultStringForBatting"];
    [defaults setValue:@"200" forKey:@"statusForBatting"];
    
    if ([resultStringForBatting isEqualToString:@"300"]) {
        if (score > highScore) {
            highScore = score;
            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highScoreFielding"];
        }
        score = 0;
        [self.statusLabel setText:@"Snap, you made it."];
        numbersForAI = [self generateNumbersForAI];
        [[self navigationController] popViewControllerAnimated:YES];  // goes back to previous view
    } else {
        [self.statusLabel setText:@"Guess what I'm thinking..."];
    }
}

- (void)displayScore {
    [self.currentScoreLabel setText:[NSString stringWithFormat:@"Try: %d", (int)score]];

    if (highScore != 0)
        [self.bestScoreLabel setText:[NSString stringWithFormat:@"Best: %d", (int)highScore]];
}

- (void)displayCounting
{
    [self.strikeButton setTitle:[NSString stringWithFormat:@"%d", (int)strikeNumber] forState:UIControlStateNormal];
    [self.ballButton setTitle:[NSString stringWithFormat:@"%d", (int)ballNumber] forState:UIControlStateNormal];
    [self.outButton setTitle:[NSString stringWithFormat:@"%d", (int)outNumber] forState:UIControlStateNormal];
}

- (IBAction)buttonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = (int)button.tag;
    NSInteger currentSum = strikeNumber + ballNumber + outNumber;
    switch (tag) {
        case 0:
            if (currentSum < 3)
                strikeNumber++;
            else
                strikeNumber = 0;
            break;
        case 1:
            if (currentSum < 3)
                ballNumber++;
            else
                ballNumber = 0;
            break;
        case 2:
            if (currentSum < 3)
                outNumber++;
            else
                outNumber = 0;
            break;
        default:
            break;
    }
    
    [self displayCounting];
    
    if (currentSum == 2)
        [self.returnButton setEnabled:YES];
}

- (IBAction)returnButtonTapped:(id)sender {
    if (strikeNumber + ballNumber + outNumber == 3) {
        [self.statusLabel setText:@"Wait for response."];
        [self.returnButton setEnabled:YES];
        NSString *resultStringForBatting = [NSString stringWithFormat:@"%d%d%d", (int)strikeNumber, (int)ballNumber, (int)outNumber];
        [defaults setValue:resultStringForBatting forKey:@"resultStringForBatting"];
        [defaults setValue:@"200" forKey:@"statusForBatting"];
        if ([resultStringForBatting isEqualToString:@"300"]) {
            if (score > highScore) {
                highScore = score;
                [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highScoreFielding"];
            }
            score = 0;
            [self.statusLabel setText:@"Game End."];
        }
    } else {
        [self.statusLabel setText:@"Must fill all counts. Sum them 3."];
        [self.returnButton setEnabled:NO];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
