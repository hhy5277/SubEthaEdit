//
//  Categories.h
//  BEEPSample
//
//  Created by Martin Ott on Tue Feb 17 2004.
//  Copyright (c) 2004 TheCodingMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringNetworkingAdditions)

+ (NSString *)stringWithAddressData:(NSData *)aData;

@end