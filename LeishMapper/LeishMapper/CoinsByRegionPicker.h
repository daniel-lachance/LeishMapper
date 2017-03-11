//
//  CoinsByRegionPicker.h
//  LeishMapper
//
//  Created by Daniel on 2017-03-05.
//  Copyright © 2017 Adaptive Aptitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoinsByRegionPicker;


@protocol CoinsByRegionPickerDelegate <UIPickerViewDelegate>

/// This method is called whenever a coin is selected in the picker.
- (void)coinsByRegionPicker:(CoinsByRegionPicker *)picker didSelectCoinWithName:(NSString *)name diameter:(NSNumber *)diameter;

@end

@interface CoinsByRegionPicker : UIPickerView

/// Returns an array of all coins in current region in denominational order.
- (NSArray<NSString *> *)coinNames;

/// Returns an array of all coin diameters in current region. The coin are sorted
/// by denominational order, and their indices match the indices of their respective
/// coin name in the 'coinNames' list.
- (NSArray<NSNumber *> *)coinDiameters;

/// The delegate. This implements the CoinsByRegionPickerDelegate protocol,
/// and is notified when a coin is selected.
@property (nonatomic, weak) id<CoinsByRegionPickerDelegate> delegate;

/// The currently selected coin name. This is a read-write property,
/// so it can be used to set the picker value. Setting the picker to a coin
/// name that does not appear in the `coinNames` array has no effect.
@property (nonatomic, copy) NSString *selectedCoinName;

/// The currently selected coin diameter. This is a read-write property, so it
/// can be used to set the picker value. Setting the picker to a coin diameter
/// that does not appear in the `coinDiameters` array has no effect.
@property (nonatomic, copy) NSNumber *selectedCoinDiameter;

/// This is a read-write property to set/get the current region (country) to list coins from.
@property (nonatomic, copy) NSString *regionCode;

/// The font used by the labels in the picker. Set this to change the font.
@property (nonatomic, copy) UIFont *labelFont;

/// These method allows you to set the current coin diameter.
/// It works exactly like the equivalent property setter, but has an optional
/// animated parameter to make the picker scroll smoothly to the selected coin.
- (void)setSelectedCoinDiameter:(NSNumber *)coinDiameter animated:(BOOL)animated;

/// As above, but for the selected coin name.
- (void)setSelectedCoinName:(NSString *)coinName animated:(BOOL)animated;

@end
