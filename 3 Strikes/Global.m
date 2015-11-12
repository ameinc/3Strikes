//
//  Global.m
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

#import "Global.h"

BOOL g_isAI;

int g_hitNumbers;

static NSString* selectedWindow;
static NSString* hitNumbersFromWatch;
static NSString* fieldStatusFromWatch;

@implementation Global

+ (NSString *)selectedWindow
{
    return selectedWindow;
}
+ (void)setSelectedWindow:(NSString *)newSelectedWindow
{
    if (selectedWindow != newSelectedWindow) {
        selectedWindow = [newSelectedWindow copy];
    }
}

+ (NSString *)hitNumbersFromWatch
{
    return hitNumbersFromWatch;
}
+ (void)setHitNumbersFromWatch:(NSString *)newHitNumbers
{
    if (hitNumbersFromWatch != newHitNumbers) {
        hitNumbersFromWatch = [newHitNumbers copy];
    }
}

+ (NSString *)fieldStatusFromWatch
{
    return fieldStatusFromWatch;
}
+ (void)setFieldStatusFromWatch:(NSString *)newFieldStatus
{
    if (fieldStatusFromWatch != newFieldStatus) {
        fieldStatusFromWatch = [newFieldStatus copy];
    }
}

+ (NSInteger)randomValueBetween:(int)min and:(int)max {
    return (NSInteger)(min + arc4random_uniform(max - min + 1));
}

@end
