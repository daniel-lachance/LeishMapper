//
//  ReferenceObject.m
//  LeishMapper
//
//  Created by Daniel LaChance on 2017-03-18.
//  Copyright © 2017 Webster Apps. All rights reserved.
//

#import "ReferenceObject.h"

@implementation ReferenceObject

NSString *_SEPARATOR = @"|";
int _COUNTRYCODE_AT_INDEX = 2;
int _NUM_COMPONENTS_IN_COIN_CODE = 4;
NSString *_COIN_CODE_PREFIX = @"PREDEF|COIN";
NSString *_COIN_CODE_FORMAT = @"PREDEF|COIN|%@|%@";
NSString *_CUSTOM_CODE_PREFIX = @"CUSTOM";
NSString *_CUSTOM_CODE_FORMAT = @"CUSTOM";
NSString *_PLUG_CODE_PREFIX = @"PREDEF|PLUG";
NSString *_PLUG_CODE_FORMAT = @"PREDEF|PLUG|%@";

+ (id)referenceObjectFromCustom:(NSNumber *)diameter
{
    ReferenceObject *obj = [[self alloc] init];
    
    obj.code = _CUSTOM_CODE_FORMAT;
    obj.diameter = diameter;
    
    return obj;
}

+ (id)referenceObjectFromCountryCode:(NSString *)countryCode coin:(NSString *)coinName diameter:(NSNumber *)diameter
{
    ReferenceObject *obj = [[self alloc] init];
    
    obj.code = [NSString stringWithFormat:_COIN_CODE_FORMAT, countryCode, coinName];
    obj.diameter = diameter;
    
    return obj;
}

+ (id)referenceObjectFromPlug:(NSString *)plugName diameter:(NSNumber *)diameter
{
    ReferenceObject *obj = [[self alloc] init];
    
    obj.code = [NSString stringWithFormat:_PLUG_CODE_FORMAT, plugName];
    obj.diameter = diameter;
    
    return obj;
}

- (id)initWithCode:(NSString *)code
{
    return [self initWithCode:code diameter:nil];
}

- (id)initWithCode:(NSString *)aCode diameter:(NSNumber *)aDiameter
{
    self = [super init];
    
    if (self) {
        _code = aCode;
        _diameter = aDiameter;
    }
    
    return self;
}

- (NSString *)name
{
    if (self.isCustom)
    {
        return [self nameAsCustom];
    }
    else
    {
        NSString *aName = nil;
        NSArray *components = [self.code componentsSeparatedByString:_SEPARATOR];
        NSString *lastComponent = [components lastObject];
        aName = lastComponent;
        return aName;
    }
}

- (BOOL)isCustom
{
    return [self.code containsString:_CUSTOM_CODE_PREFIX];
}

- (BOOL)isPredefinedCoin
{
    return [self.code containsString:_COIN_CODE_PREFIX];
}

- (BOOL)isPredefinedPlug
{
    return [self.code containsString:_PLUG_CODE_PREFIX];
}

- (NSString *)nameAsCustom
{
    // a custom reference object only consists of a diameter value
    // format diameter appending "mm"
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    f.usesSignificantDigits = YES;
    f.minimumSignificantDigits = 2;
    return [NSString stringWithFormat:@"%@ mm", [f stringFromNumber:self.diameter]];
}

- (void)setCountryCode:(NSString *)countryCode
{
    NSString *coinComponent = self.name;
    self.code = [NSString stringWithFormat:_COIN_CODE_FORMAT, countryCode, coinComponent];
}

- (NSString *)countryCode
{
    NSString *aCountryCode = nil;
    NSArray *components = [self.code componentsSeparatedByString:_SEPARATOR];
    if ([components count] == _NUM_COMPONENTS_IN_COIN_CODE) {
        NSString *component = [components objectAtIndex:_COUNTRYCODE_AT_INDEX];
        aCountryCode = component;
    }
    return aCountryCode;
}

- (void)setCoinName:(NSString *)coinName
{
    NSString *countryCodeComponent = self.countryCode;
    self.code = [NSString stringWithFormat:_COIN_CODE_FORMAT, countryCodeComponent, coinName];
}

- (NSString *)coinName
{
    return self.name;
}

- (void)setPlug:(NSString *)plugName
{
    self.code = [NSString stringWithFormat:_PLUG_CODE_FORMAT, plugName];
}

- (NSString *)plug
{
    return self.name;
}

@end
