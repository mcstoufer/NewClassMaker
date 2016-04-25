//
//  main.m
//  NewClassMaker
//
//  Created by Martin Stoufer on 4/25/16.
//  Copyright © 2016 Martin Stoufer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewClassMaker.h"

void newClassMakerTest();

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        newClassMakerTest();
    }
    return 0;
}

void newClassMakerTest()
{
    [NewClassMaker buildClassFromDictionary:@[@"FirstName", @"LastName", @"Age", @"Salary"] withName:@"Employee"];
    
    id runtimeClassInstance = [[NSClassFromString(@"Employee") alloc] init];
//    [runtimeClassInstance addObserver:runtimeClassInstance forKeyPath:@"setAge:" options:NSKeyValueObservingOptionNew context:NULL];
    
    Class runtimeClass = [NSClassFromString(@"Employee") class];
    //    NSLog(@"%@", runtimeClassInstance);
    
    NSNumber *age = @(25);
//    [runtimeClassInstance setValue:age forKey:@"setAge:"];
//    NSLog(@"%@", runtimeClassInstance);
//    [runtimeClassInstance removeObserver:runtimeClassInstance forKeyPath:@"setAge:"];
//    return;
    
    SEL setAgeSelector = NSSelectorFromString(@"setAge");
    NSInvocation *call = [NSInvocation invocationWithMethodSignature:[runtimeClass instanceMethodSignatureForSelector:setAgeSelector]];
    call.target = runtimeClassInstance;
    call.selector = setAgeSelector;
    [call setArgument:&age atIndex:2];
    [call invoke];
    
    SEL setFirstNameSelector = NSSelectorFromString(@"setFirstName");
    call = [NSInvocation invocationWithMethodSignature:[runtimeClass instanceMethodSignatureForSelector:setFirstNameSelector]];
    call.target = runtimeClassInstance;
    call.selector = setFirstNameSelector;
    NSString *firstName = @"Bob";
    [call setArgument:&firstName atIndex:2];
    [call invoke];
    
    SEL setLastNameSelector = NSSelectorFromString(@"setLastName");
    call = [NSInvocation invocationWithMethodSignature:[runtimeClass instanceMethodSignatureForSelector:setLastNameSelector]];
    call.target = runtimeClassInstance;
    call.selector = setLastNameSelector;
    NSString *lastName = @"Newhart";
    [call setArgument:&lastName atIndex:2];
    [call invoke];
    
    SEL setSalarySelector = NSSelectorFromString(@"setSalary");
    call = [NSInvocation invocationWithMethodSignature:[runtimeClass instanceMethodSignatureForSelector:setSalarySelector]];
    call.target = runtimeClassInstance;
    call.selector = setSalarySelector;
    NSNumber *salary = @(25000);
    [call setArgument:&salary atIndex:2];
    [call invoke];
    
    NSLog(@"%@", runtimeClassInstance);
}
