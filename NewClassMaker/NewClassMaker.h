//
//  NewClassMaker.h
//  permutate
//
//  Created by Martin Stoufer on 4/24/16.
//  Copyright © 2016 Martin Stoufer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewClassMaker : NSObject

+(NSDictionary*)buildClassFromDictionary:(NSArray*)propNames withName:(NSString*)className;

@end
