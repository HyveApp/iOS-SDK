//
//  AKFoundationMethods.m
//  AnahitaKit
//
//  Created by Arash  Sanieyan on 2012-11-01.
//  Copyright (c) 2012 Peerglobe Technology. All rights reserved.
//

#import <objc/runtime.h>

#pragma mark -

NSString * AKLocalizedString(NSBundle *bundle, NSString *key, NSString *comment)
{
    // default localized string loading
    NSString * localizedString = [bundle localizedStringForKey:key value:key table:nil];

    // if (value == key) and comment is not nil -> returns comment
    if([localizedString isEqualToString:key] && comment !=nil)
        return comment;

    return localizedString;
}

#pragma mark -

NSString* AKNSRegularExpressionReplace(NSString *string, NSString *pattern, NSString *replacement, NSError **error)
{
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:error];
    [expr replaceMatchesInString:mutableString options:0 range:NSMakeRange(0, [string length]) withTemplate:replacement];
    return (NSString*)mutableString;
}

BOOL AKNSRegularExpressionMatch(NSString *string, NSString *pattern, NSError **error)
{
    NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:error];
    return [expr numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0;
}


#pragma mark - 

Class AKNSClassFromListOfStrings(NSString * class1,...)
{
    va_list args;
    va_start(args, class1);    
    NSString* className = class1;
    Class class  = NULL;
    while (className != nil) {
        class = NSClassFromString(className);
        if ( NULL != class )
            break;
        className = va_arg(args, NSString*);
    }
    va_end(args);
    return class;
}

#pragma mark - 

NSArray *AKSubclassesOfClass(Class class)
{
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    classes = (Class *) malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
     
    NSMutableArray *result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++)
    {
        Class superClass = classes[i];
        do
        {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != class);
         
        if (superClass == nil)
        {
            continue;
        }
         
        [result addObject:classes[i]];
    }
 
    free(classes);
     
    return result;
}

BOOL class_selectorInMethodList(Class class, SEL selector) {
    return class_getInstanceMethod(class, selector) != class_getInstanceMethod(class_getSuperclass(class), selector);
}


Class class_getImplementingClass(Class class, SEL selector)
{
    Class target = NULL;
    
    do {
        if ( !class_selectorInMethodList(class, selector) ) {
            class = class_getSuperclass(class);
        } else {
            target = class;
        }
    } while (class && !target);
    
    return target;
}

BOOL class_copyMethod(Class sourceClass, SEL sourceSelector, Class targetClass, SEL targetSelector){
    BOOL copied = NO;
    if ( class_getInstanceMethod(sourceClass, sourceSelector) )
    {
        IMP methodImp = class_getMethodImplementation(sourceClass, sourceSelector);
        const char *encoding = method_getTypeEncoding(class_getInstanceMethod(sourceClass, sourceSelector));
        copied = class_addMethod(targetClass, targetSelector, methodImp, encoding);        
    }
    return copied;
}

void class_copyMethods(Class sourceClass, Class targetClass, SEL method1, ...)
{
    va_list args;
    va_start(args, method1);
    for(SEL arg = method1; arg != nil; arg=va_arg(args, SEL)) {
        class_copyMethod(sourceClass, arg, targetClass, arg);
    }
    va_end(args);
    
}

NSArray *class_getMethodList(Class class) {
    Method *methods = nil;
    unsigned int count;
    methods = class_copyMethodList(class, &count);
    NSMutableArray *set = [NSMutableArray arrayWithCapacity:count];
    for(int i = 0;i<count;i++) {
        [set setObject:NSStringFromSelector(method_getName(methods[i])) atIndexedSubscript:i];
    }
    return set;
}
