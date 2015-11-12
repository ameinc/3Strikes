//
//  BattingViewController.m
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

#import "BattingViewController.h"
#import "Global.h"
#import "Candidate.h"

@interface BattingViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSInteger firstNumber;
    NSInteger secondNumber;
    NSInteger thirdNumber;
    NSString *status;
    NSString *container;
    NSUserDefaults *defaults;
    NSInteger score;
    NSInteger highScore;
    NSString *statusNumber;
    NSString *numbersForAI;
    NSString *random1;
    NSString *random2;
    NSString *random3;
    bool isNewGame;
    NSInteger strikeNumber;
    NSInteger ballNumber;
    NSInteger outNumber;
    NSMutableArray *candidates;
    NSMutableArray *exceptedNumbers;
}

@property (weak, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayStatusLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *firstPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *secondPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *thirdPickerView;
@property (weak, nonatomic) IBOutlet UIButton *hitButton;

@property (nonatomic, strong) NSArray *firstArray;
@property (nonatomic, strong) NSArray *secondArray;
@property (nonatomic, strong) NSArray *thirdArray;

@end

@implementation BattingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Global setSelectedWindow:@"batting"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStatusDisplayLabel:)
                                                 name:@"UpdateStatusDisplayLabel" object:nil];
    
    container = @"group.ca.amesf.3strikes";
    defaults = [[NSUserDefaults alloc] initWithSuiteName:container];
    
    score = 0;
    highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScoreBatting"];
    if (highScore == 0)
        highScore = 1000;
    
    self.firstArray = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    self.secondArray = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    self.thirdArray = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    
    if (g_isAI) {
        exceptedNumbers = [NSMutableArray arrayWithCapacity:9];
        [self.displayStatusLabel setText:@"I think you got..."];

        candidates = [NSMutableArray arrayWithCapacity:5];
        for (int i = 0; i < 5; i++) {
            [self addNewCandiate];
        }
        score++;
        [self setPickerViews:[[candidates objectAtIndex:0] hitNumber]];
        [self sendNumbersToWatch:[[candidates objectAtIndex:0] hitNumber]];
        
        [self.firstPickerView setUserInteractionEnabled:NO];
        [self.secondPickerView setUserInteractionEnabled:NO];
        [self.thirdPickerView setUserInteractionEnabled:NO];
        [self.hitButton setHidden:YES];
        [self.hitButton setEnabled:NO];
    } else {
        [self.displayStatusLabel setText:@"Guess numbers"];

        [self.firstPickerView setUserInteractionEnabled:YES];
        [self.secondPickerView setUserInteractionEnabled:YES];
        [self.thirdPickerView setUserInteractionEnabled:YES];
        [self.hitButton setHidden:NO];
        [self.hitButton setEnabled:YES];
    }
    
    [self displayScore];
}

- (void)viewDidDisappear:(BOOL)animated {
    [Global setSelectedWindow:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)getNumberWithoutException {
    bool found = YES;
    int temp = 0;
    while (found) {
        temp = (int)[Global randomValueBetween:0 and:9];
        NSPredicate *valuePredicate = [NSPredicate predicateWithFormat:@"self.intValue == %d", temp];
        if ([[exceptedNumbers filteredArrayUsingPredicate:valuePredicate] count]!=0) {
            found = YES;
        } else  {
            found = NO;
        }
    }
    
    return temp;
}

- (NSString *)generateNumbersForAI {
    random1 = [NSString stringWithFormat:@"%d", [self getNumberWithoutException]];
    random2 = [NSString stringWithFormat:@"%d", [self getNumberWithoutException]];
    random3 = [NSString stringWithFormat:@"%d", [self getNumberWithoutException]];
    return [NSString stringWithFormat:@"%@%@%@", random1, random2, random3];
}

- (void)addNewCandiate {
    Candidate *c = [[Candidate alloc] initWithHitNumber:[self generateNumbersForAI] cost:0];
    [candidates addObject:c];
}

- (void)updateStatusDisplayLabel:(NSNotification *)note {
    if ([[Global fieldStatusFromWatch] isEqualToString:@"1000"]) {
        [defaults setValue:@"" forKey:@"fieldStatusFromWatch"];
        [[self navigationController] popViewControllerAnimated:YES];  // goes back to previous view
    }
    [self displayResult];
}

- (void)displayScore {
    [self.currentScoreLabel setText:[NSString stringWithFormat:@"Try: %d", (int)score]];
        
    if (highScore != 0 && highScore != 1000)
        [self.bestScoreLabel setText:[NSString stringWithFormat:@"Best: %d", (int)highScore]];
}

- (IBAction)hitButtonTapped:(id)sender {
    if ([statusNumber isEqualToString:@"100"]) {
        score = 0;
        [self.hitButton setTitle:@"Hit!" forState:UIControlStateNormal];
        [self.displayStatusLabel setText:@"Guess numbers"];
        statusNumber = @"000";
    } else {
        score++;
        [self.displayStatusLabel setText:@"Wait for response"];
        NSString *numberString = [NSString stringWithFormat:@"%d%d%d", (int)firstNumber, (int)secondNumber, (int)thirdNumber];
        [self sendNumbersToWatch:numberString];
    }
    [self displayScore];
}

- (void)sendNumbersToWatch:(NSString *)hitNumber {
    [defaults setValue:hitNumber forKey:@"hitNumbersFromServer"];
}

- (void)displayResult {
    
    NSMutableString *statusString = [[NSMutableString alloc]init];
    NSString *resultString = [Global fieldStatusFromWatch];
    
    if ([resultString isEqualToString:@"300"]) {
        if (g_isAI) {
            [statusString appendString:@"I knew I can beat you!!!"];
            [[self navigationController] popViewControllerAnimated:YES];  // goes back to previous view
        } else {
            [statusString appendString:@"Hooray! you beat the player."];
            [self.displayStatusLabel setText:statusString];
            [self.hitButton setTitle:@"Play again?" forState:UIControlStateNormal];
            statusNumber = @"100";
        }
        if (score < highScore)
            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highScoreBatting"];
        
    } else {
        strikeNumber = [[resultString substringWithRange:NSMakeRange(0, 1)] integerValue];
        ballNumber = [[resultString substringWithRange:NSMakeRange(1, 1)] integerValue];
        outNumber = [[resultString substringWithRange:NSMakeRange(2, 1)] integerValue];
        
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
        [self.displayStatusLabel setText:statusString];
        if (g_isAI)
            [self prepareHitNumber];
    }
}

- (void)prepareHitNumber {
    
    score++;
    
    NSString *newGen = @"";

    NSInteger energy = strikeNumber * 2 + ballNumber * 1 + outNumber * -1;
    
    NSInteger selectedRow1 = [_firstPickerView selectedRowInComponent:0];
    NSInteger selectedRow2 = [_secondPickerView selectedRowInComponent:0];
    NSInteger selectedRow3 = [_thirdPickerView selectedRowInComponent:0];
    NSString *numberString = [NSString stringWithFormat:@"%d%d%d",
                              (int)[[_firstArray objectAtIndex:selectedRow1] integerValue],
                              (int)[[_secondArray objectAtIndex:selectedRow2] integerValue],
                              (int)[[_thirdArray objectAtIndex:selectedRow3] integerValue]];
    
    NSInteger matchedIndex = 0;
    for (Candidate *c in candidates) {
        if ([c.hitNumber isEqualToString:numberString]) {
            matchedIndex = [candidates indexOfObject:c];
        }
    }
    
    if (energy == -3) {
        [exceptedNumbers addObject:[_firstArray objectAtIndex:selectedRow1]];
        [exceptedNumbers addObject:[_firstArray objectAtIndex:selectedRow2]];
        [exceptedNumbers addObject:[_firstArray objectAtIndex:selectedRow3]];
        [candidates removeObjectAtIndex:matchedIndex];
        [self addNewCandiate];
    } else {
        Candidate *updated = [[Candidate alloc] initWithHitNumber:numberString cost:(int)energy];
        [candidates replaceObjectAtIndex:matchedIndex withObject:updated];
    }
    
    [candidates sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"cost" ascending:YES]]];

    //Candidate *tempCandidate = [candidates lastObject];
    Candidate *tempCandidate = [candidates objectAtIndex:[Global randomValueBetween:0 and:4]];
    newGen = [self mutate:tempCandidate.hitNumber numberOfMutation:1];
    
    // display current numbers
    [self setPickerViews:newGen];

    [self sendNumbersToWatch:newGen];
    
    [self displayScore];
}

- (void)setPickerViews:(NSString *)numbers {
    [_firstPickerView selectRow:(int)[[numbers substringWithRange:NSMakeRange(0, 1)] integerValue] inComponent:0 animated:YES];
    [_secondPickerView selectRow:(int)[[numbers substringWithRange:NSMakeRange(1, 1)] integerValue] inComponent:0 animated:YES];
    [_thirdPickerView selectRow:(int)[[numbers substringWithRange:NSMakeRange(2, 1)] integerValue] inComponent:0 animated:YES];
}

- (NSString *)mutate:(NSString *)currentGen numberOfMutation:(int)count {
    int position = (int)[Global randomValueBetween:0 and:2];

    int mutated[3];
    for (int i = 0; i < 3; i++)
    {
        if (i != position) {
            mutated[i] = (int)[[currentGen substringWithRange:NSMakeRange(0, 1)] integerValue];
        } else {
            mutated[i] = [self getNumberWithoutException];
        }
    }
    NSString *mutatedNumber = [NSString stringWithFormat:@"%d%d%d", mutated[0], mutated[1], mutated[2]];
    return mutatedNumber;
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _firstPickerView) {
        return [_firstArray count];
    } else if (pickerView == _secondPickerView) {
        return [_secondArray count];
    } else if (pickerView == _thirdPickerView) {
        return [_thirdArray count];
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _firstPickerView) {
        return [_firstArray objectAtIndex:row];
    } else if (pickerView == _secondPickerView) {
        return [_secondArray objectAtIndex:row];
    } else if (pickerView == _thirdPickerView) {
        return [_thirdArray objectAtIndex:row];
    } else {
        return 0;
    }
}

#pragma mark PickerView Delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _firstPickerView) {
        firstNumber = [[_firstArray objectAtIndex:row] integerValue];
    } else if (pickerView == _secondPickerView) {
        secondNumber = [[_secondArray objectAtIndex:row] integerValue];
    } else if (pickerView == _thirdPickerView) {
        thirdNumber = [[_thirdArray objectAtIndex:row] integerValue];
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