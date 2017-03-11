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
        _coinNames = [[self coinsByRegionByName].allKeys copy];
        isRegionChanged = FALSE;
    }
    return _coinNames;
}

- (NSArray<NSNumber *> *)coinDiameters
{
    static NSArray *_coinDiameters = nil;
    if (!_coinDiameters || isRegionChanged)
    {
        _coinDiameters = [[self coinsByRegionByDiameter].allKeys copy];
        isRegionChanged = FALSE;
    }
    return _coinDiameters;
}

- (NSDictionary *)coinsByRegionByName
{
    static NSDictionary *_coinsByRegionByName = nil;
    if (!_coinsByRegionByName || isRegionChanged)
    {
        NSMutableDictionary *coinsByName = [NSMutableDictionary dictionary];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CoinsByRegion" ofType:@"plist"];
        NSArray *regions = [NSArray arrayWithContentsOfFile:plistPath];
        for (NSDictionary* region in regions)
        {
            if ([[self regionCode] caseInsensitiveCompare:[region objectForKey:@"code"]] == 0)
            {
                NSArray *coins = [region objectForKey:@"coins"];
                for (NSDictionary *coin in coins)
                {
                    NSString *coinName = [coin objectForKey:@"common-name"];
                    NSNumber *diameter = [coin objectForKey:@"diameter"];
                    coinsByName[coinName] = diameter;
                }
                break;
            }
        }
        _coinsByRegionByName = [coinsByName copy];
    }
    return _coinsByRegionByName;
}

- (NSDictionary *)coinsByRegionByDiameter
{
    static NSDictionary *_coinsByRegionByDiameter = nil;
    if (!_coinsByRegionByDiameter || isRegionChanged)
    {
        NSDictionary *coinsByName = [self coinsByRegionByName];
        NSMutableDictionary *coinsByDiameter = [NSMutableDictionary dictionary];
        for (NSString *coinName in coinsByName)
        {
            coinsByDiameter[coinsByName[coinName]] = coinName;
        }
        _coinsByRegionByDiameter = [coinsByDiameter copy];
    }
    return _coinsByRegionByDiameter;
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

- (UIView *)pickerView:(__unused UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(__unused NSInteger)component reusingView:(UIView *)view
{
    if (!view)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, 245, 24)];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1;
        if (self.labelFont)
        {
            label.font = self.labelFont;
        }
        [view addSubview:label];

        /*
        UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 24, 24)];
        flagView.contentMode = UIViewContentModeScaleAspectFit;
        flagView.tag = 2;
        [view addSubview:flagView];
         */
    }

    ((UILabel *)[view viewWithTag:1]).text = [self coinNames][(NSUInteger)row];
    return view;
}

- (void)pickerView:(__unused UIPickerView *)pickerView
      didSelectRow:(__unused NSInteger)row
       inComponent:(__unused NSInteger)component
{
    __strong id<CoinsByRegionPickerDelegate> strongDelegate = delegate;
    [strongDelegate coinsByRegionPicker:self didSelectCoinWithName:self.selectedCoinName diameter:self.selectedCoinDiameter];
}

@end
