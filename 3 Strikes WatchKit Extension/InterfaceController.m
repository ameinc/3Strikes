//
//  InterfaceController.m
//  3 Strikes WatchKit Extension
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

#import "InterfaceController.h"

@interface InterfaceController() {
    NSString *container;
    NSUserDefaults *defaults;
}

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    container = @"group.ca.amesf.3strikes";
    defaults = [[NSUserDefaults alloc] initWithSuiteName:container];
}
- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self sendNumbersToServer:@"9999"];
    [self sendStatusToServer:@"9999"];
}
- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)sendNumbersToServer:(NSString *)numberString {
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[numberString] forKeys:@[@"hitNumbersFromWatch"]];
    [WKInterfaceController openParentApplication:applicationData reply:^(NSDictionary *replyInfo, NSError *error)
     {
         NSString *response = [replyInfo objectForKey:@"actionReply"];
         NSLog(@"%@", response);
         if([response isEqualToString:@"notReady"]) {
             [defaults setValue:@"000" forKey:@"statusForBatting"];
         }
     }];
}

- (void)sendStatusToServer:(NSString *)resultString {
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[resultString] forKeys:@[@"fieldStatusFromWatch"]];
    [WKInterfaceController openParentApplication:applicationData reply:^(NSDictionary *replyInfo, NSError *error)
     {
         NSString *response = [replyInfo objectForKey:@"actionReply"];
         NSLog(@"%@", response);
         if([response isEqualToString:@"notReady"]) {
             [defaults setValue:@"000" forKey:@"fieldStatusFromWatch"];
         }
     }];
}

- (IBAction)resetScore {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"highScoreFielding"];
    [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"highScoreBatting"];
}
- (IBAction)keepPlaying {
    //do nothing
}

@end



