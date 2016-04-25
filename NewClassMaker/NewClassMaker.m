//
//  NewClassMaker.m
//  permutate
//
//  Created by Martin Stoufer on 4/24/16.
//  Copyright © 2016 Martin Stoufer. All rights reserved.
//

#import "NewClassMaker.h"
#import <objc/runtime.h>

@implementation NewClassMaker
/**
 *  @brief A Class method used for proper property formatting. Used in the initial configuration of property accessors.
 *  @discussion This is not added to the new class method list. It just calls a C function tha does the work
 *               for us.
 *  @param name The name of the property to get the proper format for
 *
 *  @return A properly formatted property name.
 */
+(NSString*)propName:(NSString*)name
{
    return propNameForString(nil, nil, name);
}

/**
 *  @brief Properly format a given property name.
 *  @discussion This function is added to the new Class instance as a dynamic method.
 *
 *  @param self The instance ref for this object
 *  @param _cmd The command that led to this dynamic method being called
 *  @param name The name of the property to format.
 *
 *  @return A properly formatted property name.
 */
NSString *propNameForString(id self, SEL _cmd, id name)
{
    name = [name stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSRange r;
    r.length = ((NSString *)name).length -1 ;
    r.location = 1;
    
    NSString* firstChar = [name stringByReplacingCharactersInRange:r withString:@""];
    
    if([firstChar isEqualToString:[firstChar lowercaseString]])
    {
        return name;
    }
    
    r.length = 1;
    r.location = 0;
    
    NSString* theRest = [name stringByReplacingCharactersInRange:r withString:@""];
    
    return [NSString stringWithFormat:@"%@%@", [firstChar lowercaseString] , theRest];
}

/**
 *  @brief A Class method used for proper property formatting. Used in the initial configuration of property accessors.
 *  @discussion This is not added to the new class method list. It just calls a C function tha does the work
 *               for us.
 *  @param name The name of the property to get the proper format for
 *
 *  @return A properly formatted property name.
 */
+(NSString*)setterName:(NSString*)name
{
    name = propNameForString(nil, nil, name);
    
    NSRange r;
    r.length = name.length -1 ;
    r.location = 1;
    
    NSString* firstChar = [name stringByReplacingCharactersInRange:r withString:@""];
    
    r.length = 1;
    r.location = 0;
    
    NSString* theRest = [name stringByReplacingCharactersInRange:r withString:@""];
    
    return [NSString stringWithFormat:@"set%@%@", [firstChar uppercaseString] , theRest];
}

/**
 *  @brief A Class method used for proper property formatting. Used in the initial configuration of property accessors.
 *  @discussion This is not added to the new class method list. It just calls a C function tha does the work
 *               for us.
 *  @param name The name of the property with the 'set' prefix appended to it.
 *
 *  @return A properly formatted property name suitable for accessor use.
 */
+(NSString*)propNameFromSetterName:(NSString*)name
{
    return propNameForString(nil, nil, name);
}

/**
 *  @brief Properly format the raw property setter name into a valid property name.
 *  @discussion This function is added to the new Class instance as a dynamic method. The 'set' prefix is removed and the trailing capitizlied letter is lowercased.
 *
 *  @param self The instance ref for this object
 *  @param _cmd The command that led to this dynamic method being called
 *  @param name The name of the property to format.
 *
 *  @return A properly formatted property name suitable for accessor use.
 */
NSString *propNameFromSetterNameString(id self, SEL _cmd, id name)
{
    NSRange r;
    r.length = 3 ;
    r.location = 0;
    
    NSString* propName = [name stringByReplacingCharactersInRange:r withString:@""];
    
    return propNameForString(self, _cmd, propName);
}

/**
 *  @brief  A Class method used for resolving the raw iVar name. Used in the initial configuration of property accessors.
 *  @discussion This is not added to the new class method list. It just calls a C function tha does the work
 *               for us.
 *
 *  @param name The name of the property to resolve its iVar for
 *
 *  @return An iVar name for the given property or nil if the property doesn't exisit in the current object instance.
 */
+(NSString*)ivarName:(NSString*)name
{
    return ivarNameForString(nil, nil, name);
}

/**
 @  @brief Resolve a property name into its iVar name.
 *  @discussion This function is added to the new Class instance as a dynamic method.
 *
 *  @param self The instance ref for this object
 *  @param _cmd The command that led to this dynamic method being called
 *  @param name The name of the property to find the iVar name for.
 *
 *  @return An iVar name for the given property or nil if the property doesn't exisit in the current object instance.
 */
NSString *ivarNameForString(id self, SEL _cmd, id name)
{
    NSRange r;
    r.length = ((NSString *)name).length -1 ;
    r.location = 1;
    
    NSString* firstChar = [name stringByReplacingCharactersInRange:r withString:@""].lowercaseString;
    
    if([firstChar isEqualToString:@"_"])
        return name;
    
    r.length = 1;
    r.location = 0;
    
    NSString* theRest = [name stringByReplacingCharactersInRange:r withString:@""];
    
    return [NSString stringWithFormat:@"_%@%@",firstChar, theRest];
}

/**
 *  @brief Dynamic method to handle the getter of any present property in the dynamic class.
 *
 *  @param self The instance reference to this object
 *  @param _cmd The command used to invoke this dynamic method.
 *
 *  @return The object that was associated with the getter property name. nil if the property doesn't exist
 *           or wasn't set.
 */
NSObject *getter(id self, SEL _cmd)
{
    NSString* name = NSStringFromSelector(_cmd);
    NSString* ivarName = [self ivarName:name];
    Ivar ivar = class_getInstanceVariable([self class], [ivarName UTF8String]);
    NSObject *obj =  object_getIvar(self, ivar);
    return obj;
}

/**
 *  @brief Dynamic method to handle the setter of any present property value in the dynamic class.
 *
 *  @param self   The instance reference to this object
 *  @param _cmd   The command used to invoke this dynamic method.
 *  @param newObj The object to set the property value to.
 */
void setter(id self, SEL _cmd, NSObject *newObj)
{
    NSString* name = [self propNameFromSetterName:NSStringFromSelector(_cmd)];
    NSString* ivarName = [self ivarName:name];
    Ivar ivar = class_getInstanceVariable([self class], [ivarName UTF8String]);
    id oldObj = object_getIvar(self, ivar);
    if (![oldObj isEqual: newObj])
    {
        if(oldObj != nil)
            oldObj = nil;
        
        object_setIvar(self, ivar, newObj);
    }
}

NSArray *ClassMethodNames(Class c)
{
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(c, &methodCount);
    unsigned int i;
    for(i = 0; i < methodCount; i++)
        [array addObject: NSStringFromSelector(method_getName(methodList[i]))];
    free(methodList);
    
    return array;
}

NSString *Description(id self, SEL _cmd)
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"<%@: %p, %@>\n", [self class], self, [ClassMethodNames([self class]) componentsJoinedByString:@", "]];
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    
    for (NSUInteger i = 0; i < numberOfProperties; i++)
    {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        
        NSObject *obj = getter(self, NSSelectorFromString(name));
        [desc appendFormat:@"\t%@: %@\n", name,  obj];
    }
    
    free(propertyArray);
    return desc;
}

void observeValueForKeyPath(id self, SEL _cmd, NSString * keyPath, id object, NSDictionary<NSString *,id> *change, void *context)
{
    //    NSLog(@"Observer keypath: %@ with change %@", keyPath, change);
    
    Class superclass = NSClassFromString(@"NSObject");
    void (*superIMP)(id, SEL) = (void *)[superclass instanceMethodForSelector: @selector(observeValueForKeyPath:ofObject:change:context:)];
    superIMP(self, _cmd);
}

BOOL accessInstanceVariablesDirectly()
{
    return NO;
}

+(NSDictionary*)buildClassFromDictionary:(NSArray*)propNames withName:(NSString*)className
{
    NSMutableDictionary* keys = [[NSMutableDictionary alloc]init];
    Class newClass = NSClassFromString(className);
    
    if(newClass == nil)
    {
        newClass = objc_allocateClassPair([NSObject class], [className UTF8String], 0);
        
        // For each property name, add a new iVar, getter, and setter method for it.
        for(NSString* key in propNames)
        {
            NSString* propName = [self propName: key];
            NSString* iVarName = [self ivarName:propName];
            
            class_addIvar(newClass, [iVarName UTF8String] , sizeof(NSObject*), log2(sizeof(NSObject*)), @encode(NSObject));
            
            objc_property_attribute_t a1 = { "T", "@\"NSObject\"" };
            objc_property_attribute_t a2 = { "&", "" };
            objc_property_attribute_t a3 = { "N", "" };
            objc_property_attribute_t a4 = { "V", [iVarName UTF8String] };
            objc_property_attribute_t attrs[] = { a1, a2, a3, a4};
            
            class_addProperty(newClass, [propName UTF8String], attrs, 4);
            class_addMethod(newClass, NSSelectorFromString(propName), (IMP)getter, "@@:");
            class_addMethod(newClass, NSSelectorFromString([self setterName:propName]), (IMP)setter, "v@:@");
            
            [keys setValue:key forKey:propName];
        }
        
        //        Class metaClass = object_getClass(newClass);
        //        class_addMethod(metaClass, @selector(accessInstanceVariablesDirectly), (IMP)accessInstanceVariablesDirectly, "B@:");
        
        // Auxilliary methods added to the new class instance so the accessor dynamic methods above can work.
        // Not sure if the initial impl of this class maker class worked.
        class_addMethod(newClass, @selector(ivarName:), (IMP)ivarNameForString, "@@:@");
        class_addMethod(newClass, @selector(propName:), (IMP)propNameForString, "@@:@");
        class_addMethod(newClass, @selector(propNameFromSetterName:), (IMP)propNameFromSetterNameString, "@@:@");
        
        //        class_addMethod(newClass, @selector(observeValueForKeyPath:ofObject:change:context:), (IMP)observeValueForKeyPath, "v@:@@@^v");
        
        // Add a customized description dynamic method to this class. It will dump out any list of properties added
        // to the object during init here.
        Method description = class_getInstanceMethod([NSObject class],
                                                     @selector(description));
        const char *types = method_getTypeEncoding(description);
        
        // now add
        class_addMethod(newClass, @selector(description), (IMP)Description, types);
        objc_registerClassPair(newClass);
    }
    return keys;
}

@end
