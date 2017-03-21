//
//  CoinPicker.m
//  LeishMapper
//
//  Created by Daniel on 2017-03-05.
//  Copyright © 2017 Webster Apps. All rights reserved.
//

#import "CoinsByRegionPicker.h"

@interface CoinsByRegionPicker () <UIPickerViewDelegate, UIPickerViewDataSource>

@end


@implementation CoinsByRegionPicker

#pragma mark - Properties

bool isRegionChanged = TRUE;

// delegate doesn't use _ prefix to avoid name clash with superclass
@synthesize delegate, labelFont = _labelFont;


- (NSArray<NSString *> *)coinNames
{
    static NSArray *_coinNames = nil;
    if (!_coinNames || isRegionChanged)
    {
        _coinNames = [[[self coinNamesByDiameter].allValues sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] copy];
    }
    return _coinNames;
}

- (NSArray<NSNumber *> *)coinDiameters
{
    static NSArray *_coinDiameters = nil;
    if (!_coinDiameters || isRegionChanged)
    {
        _coinDiameters = [[[self coinDiametersByName] objectsForKeys:[self coinNames] notFoundMarker:@""] copy];
    }
    return _coinDiameters;
}

- (NSDictionary *)coinNamesByDiameter
{
    static NSDictionary *_coinNamesByDiameter = nil;
    if (!_coinNamesByDiameter || isRegionChanged)
    {
        NSMutableDictionary *coinNamesByDiameter = [NSMutableDictionary dictionary];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CoinsByRegion" ofType:@"plist"];
        NSArray *regions = [NSArray arrayWithContentsOfFile:plistPath];
        for (NSDictionary* region in regions)
        {
            if ([[self regionCode] caseInsensitiveCompare:[region objectForKey:@"code"]] == NSOrderedSame)
            {
                NSArray *coins = [region objectForKey:@"coins"];
                for (NSDictionary *coin in coins)
                {
                    NSString *coinName = [coin objectForKey:@"common-name"];
                    NSNumber *diameter = [coin objectForKey:@"diameter"];
                    coinNamesByDiameter[diameter] = coinName;
                }
                break;
            }
        }
        if (coinNamesByDiameter.count == 0)
        {
            NSString *noCoins = @"No coins";
            coinNamesByDiameter[@0] = noCoins;
        }
        _coinNamesByDiameter = [coinNamesByDiameter copy];
    }
    return _coinNamesByDiameter;
}

- (NSDictionary *)coinDiametersByName
{
    static NSDictionary *_coinDiametersByName = nil;
    if (!_coinDiametersByName || isRegionChanged)
    {
        NSDictionary *coinNamesByDiameter = [self coinNamesByDiameter];
        NSMutableDictionary *coinDiametersByName = [NSMutableDictionary dictionary];
        for (NSNumber *diameter in coinNamesByDiameter)
        {
            coinDiametersByName[coinNamesByDiameter[diameter]] = diameter;
        }
        _coinDiametersByName = [coinDiametersByName copy];
    }
    return _coinDiametersByName;
}

- (void)setUp
{
    super.dataSource = self;
    super.delegate = self;
    _regionCode = @"us";  // default regionCode to United States
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setDataSource:(__unused id<UIPickerViewDataSource>)dataSource
{
    //does nothing
}


- (NSString *)selectedCoinName
{
    NSUInteger index = (NSUInteger)[self selectedRowInComponent:0];
    if ([[self coinNames] count] > 0) {
        return [self coinNames][index];
    } else {
        return nil;
    }
}

- (void)setSelectedCoinName:(NSString *)coinName animated:(BOOL)animated
{
    NSUInteger index = [[self coinNames] indexOfObject:coinName];
    if (index != NSNotFound)
    {
        [self selectRow:(NSInteger)index inComponent:0 animated:animated];
    }
}

- (void)setSelectedCoinName:(NSString *)coinName
{
    [self setSelectedCoinName:coinName animated:nil];
}

- (NSNumber *)selectedCoinDiameter
{
    NSUInteger index = (NSUInteger)[self selectedRowInComponent:0];
    if ([[self coinDiameters] count] > 0) {
        return [self coinDiameters][index];
    } else {
        return nil;
    }
}


- (void)setSelectedCoinDiameter:(NSNumber *)coinDiameter animated:(BOOL)animated
{
    NSUInteger index = [[self coinDiameters] indexOfObject:coinDiameter];
    if (index != NSNotFound)
    {
        [self selectRow:(NSInteger)index inComponent:0 animated:animated];
    }
}

- (void)setSelectedCoinDiameter:(NSNumber *)coinDiameter
{
    [self setSelectedCoinDiameter:coinDiameter animated:nil];
}

- (void)setRegionCode:(NSString *)regionCode
{
    if (_regionCode != regionCode)
    {
        _regionCode = regionCode;
        isRegionChanged = TRUE;
        [self coinNames];
        [self coinDiameters];
        isRegionChanged = FALSE;
        [self reloadComponent:0];
    }
}

- (void)setLabelFont:(UIFont *)labelFont
{
    _labelFont = labelFont;
    [self reloadComponent:0];
}

#pragma mark UIPicker

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component
{
    return (NSInteger)[self coinNames].count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *titleText = [self coinNames][(NSUInteger)row];
    NSDictionary *attributes = nil;
    
    // Set the font if available
    if (self.labelFont)
    {
        attributes = @{
                 NSFontAttributeName: self.labelFont
                 };
    }
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:titleText attributes:attributes];
    
    return title;
    
}

- (void)pickerView:(__unused UIPickerView *)pickerView
      didSelectRow:(__unused NSInteger)row
       inComponent:(__unused NSInteger)component
{
    __strong id<CoinsByRegionPickerDelegate> strongDelegate = delegate;
    [strongDelegate coinsByRegionPicker:self didSelectCoinWithName:self.selectedCoinName diameter:self.selectedCoinDiameter];
}

@end
