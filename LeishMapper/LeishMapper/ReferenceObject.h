//
//  ReferenceObject.h
//  LeishMapper
//
//  Created by Daniel LaChance on 2017-03-18.
//  Copyright © 2017 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Reference Object class is responsible for encoding and decoding the reference object
 string such as "PREDEF|COIN|US|PENNY". It does not know how to load or store the string
 as it can exist in either the Standard User Defaults or in the Measurement object. 
 The concept is to allow other reference object types in the future without coupling
 to the Measurement object.
 */
@interface ReferenceObject : NSObject

+ (id)referenceObjectFromCustom:(NSNumber *)diameter;
+ (id)referenceObjectFromCountryCode:(NSString *)countryCode coin:(NSString *)coinName diameter:(NSNumber *)diameter;
+ (id)referenceObjectFromPlug:(NSString *)plugName diameter:(NSNumber *)diameter;

/**
 'name' is common name or display name for a reference object, for example 'Dime' for code 'PREDEF|COIN|US|Dime'.
 */
@property (readonly) NSString *name;

/**
 'code' is an encoded bar-separated string to identify a reference object and its type.
 The label in angle brackets would be a value from the static data:
 
 PREDEF|COIN|<COUNTRY_CODE>|<COIN_COMMON_NAME>
 PREDEF|PLUG|<PLUG_NAME>
 CUSTOM|
 
 For example:
 
 PREDEF|COIN|US|PENNY
 PREDEF|COIN|CA|LOONIE
 PREDEF|PLUG|USBA
 PREDEF|PLUG|LIGHTNING
 
 The diameter value is already stored in the absoluteReferenceDiameter attribute for Measurment in Core Data.
 The diameter could be looked-up from that attribute and copied to 'diameter' here for convenience.
 */
@property NSString *code;
@property NSNumber *diameter;
@property (readonly) BOOL isCustom;
@property (readonly) BOOL isPredefinedCoin;
@property (readonly) BOOL isPredefinedPlug;

// properties for country/coin object
@property NSString *countryCode;
@property NSString *coinName;

// property for plug object
@property NSString *plug;

- (id)initWithCode:(NSString *)code;
- (id)initWithCode:(NSString *)aCode diameter:(NSNumber *)aDiameter;

@end
