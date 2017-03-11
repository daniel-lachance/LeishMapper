//
//  ReferenceSetterViewController.m
//
//  Created by Dan Webster on 12/24/13.
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//


#import "ReferenceSetterViewController.h"

@interface ReferenceSetterViewController ()

//**NOTE** The conversion from what is shown on the reference setter and stored in the database to what is shown in the relatively small
//textfield in the moleViewController must be accounted for as the referenceNames are updated and also in the Reference Converter class

-(void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end

@implementation ReferenceSetterViewController

#pragma mark - Properties

/*
-(NSArray *)referencesInPicker
{
    if (!_referencesInPicker)
    {
        _referencesInPicker =
        @[@"Penny", @"Nickel", @"Dime", @"Quarter"];
    }
    return _referencesInPicker;
}
*/

-(ReferenceConverter *)refConverter
{
    if (!_refConverter)
    {
        _refConverter = [[ReferenceConverter alloc] init];
    }
    return _refConverter;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.customReferenceTextField.delegate = self;
    self.pickerView.delegate = self;
    self.countryPickerView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    /*
    NSUInteger indexOfRef = [self.referencesInPicker indexOfObject:self.measurement.referenceObject];
    if (indexOfRef != NSNotFound)
    {
        [self.pickerView selectRow:indexOfRef inComponent:0 animated:YES];
    }
    else
    {
        [self.pickerView selectRow:2 inComponent:0 animated:YES];
    }
    */
    
    self.countryPickerVisible = NO;
    self.countryPickerView.hidden = YES;
    self.countryPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.coinPickerVisible = NO;
    self.pickerView.hidden = YES;
    self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.customReferenceTableViewCell addGestureRecognizer:tapGestureRecognizer];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *referenceCountryCode = [standardUserDefaults objectForKey:@"referenceCountryCode"];
    
    if (referenceCountryCode)
    {
        [self.countryPickerView setSelectedCountryCode:referenceCountryCode];
    } else {
        // default country picker to current device locale
        [self.countryPickerView setSelectedLocale:[NSLocale currentLocale]];
    }
    //call country picker delegate
    [self countryPicker:self.countryPickerView didSelectCountryWithName:self.countryPickerView.selectedCountryName code:self.countryPickerView.selectedCountryCode];
    
    // if a measurement exists, use its value to set the picker(s) and label
    if (self.measurement)
    {
        NSString *refObjTxt = self.measurement.referenceObject;
        [self.pickerView setSelectedCoinName:refObjTxt];
        self.currentReferenceObjectLabel.text = refObjTxt;
    }
    //call coin picker delegate
    [self coinsByRegionPicker:self.pickerView didSelectCoinWithName:self.pickerView.selectedCoinName diameter:self.pickerView.selectedCoinDiameter];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *referenceObject = self.currentReferenceObjectLabel.text;
    [standardUserDefaults setValue:referenceObject forKey:@"referenceObject"];
    [standardUserDefaults setValue:self.countryPickerView.selectedCountryCode forKey:@"referenceCountryCode"];
    
    NSNumber *absoluteReferenceDiameter = [self.refConverter millimeterValueForReference:self.currentReferenceObjectLabel.text];
    
    //FIX: need to load the coin diameter from the selected coin or the custom diameter, not the refConverter
    
    //Save the measurement reference object (leave the rest alone, which is what the nil's are doing)
    [Measurement moleMeasurementForMole:self.measurement.whichMole
                               withDate:nil
                              withPhoto:nil
                withMeasurementDiameter:nil
                       withMeasurementX:nil
                       withMeasurementY:nil
                  withReferenceDiameter:nil
                         withReferenceX:nil
                         withReferenceY:nil
                      withMeasurementID:self.measurement.measurementID
          withAbsoluteReferenceDiameter:absoluteReferenceDiameter
               withAbsoluteMoleDiameter:nil
                    withReferenceObject:self.currentReferenceObjectLabel.text
                 inManagedObjectContext:self.context];
}

#pragma mark - Methods

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self.customReferenceTextField becomeFirstResponder];
    }
}

//Allows the background view controller to pick up background events and dismiss
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.customReferenceTextField resignFirstResponder];
//}

- (void)showCountryPickerCell
{
    self.countryPickerVisible = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.countryPickerView.hidden = NO;
    self.countryPickerView.alpha = 0.0f;
    [UIView animateWithDuration:0.25 animations:^{
        self.countryPickerView.alpha = 1.0f;
    }];
}

- (void)hideCountryPickerCell
{
    self.countryPickerVisible = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.countryPickerView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.countryPickerView.hidden = YES;
                     }];
}

- (void)showCoinPickerCell
{
    self.coinPickerVisible = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.pickerView.hidden = NO;
    self.pickerView.alpha = 0.0f;
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerView.alpha = 1.0f;
    }];
}

- (void)hideCoinPickerCell
{
    self.coinPickerVisible = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.pickerView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.pickerView.hidden = YES;
                     }];
}

- (void)markCoinSelectionActive
{
    self.coinTableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.customReferenceTableViewCell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)markCustomSelectionActive
{
    self.coinTableViewCell.accessoryType = UITableViewCellAccessoryNone;
    self.customReferenceTableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    // end text field editing if user scrolls
    [[self view] endEditing:true];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.row == 1 && indexPath.section == 0){
        height = self.countryPickerVisible ? 216.0f : 0.0f;
    }
    if (indexPath.row == 3 && indexPath.section == 0){
        height = self.coinPickerVisible ? 148.0f : 0.0f;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        if (self.countryPickerVisible){
            [self hideCountryPickerCell];
        } else {
            [self showCountryPickerCell];
            if (self.coinPickerVisible) [self hideCoinPickerCell];
        }
    }
    if (indexPath.row == 2 && indexPath.section == 0) {
        if (self.coinPickerVisible){
            [self hideCoinPickerCell];
        } else {
            [self showCoinPickerCell];
            if (self.countryPickerVisible) [self hideCountryPickerCell];
        }
    }
    [[self view] endEditing:true];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hideCountryPickerCell];
    [self hideCoinPickerCell];
    [self markCustomSelectionActive];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *textFieldText = textField.text;
    if ([textFieldText isEqualToString:@""])
    {
        textFieldText = @"0.0";
    }
    textFieldText = [textFieldText stringByAppendingString:@" mm"];
    self.currentReferenceObjectLabel.text = textFieldText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        [self.view endEditing:YES];
        return YES;
    }
    else return NO;
}

# pragma mark - UIPickerViewDelegate
/*
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.currentReferenceObjectLabel.text = self.referencesInPicker[row];
    //set the reference value here in the label and in the MoleView or measurement core data
}

//This should be re-implemented with returning a view so that the text size and other components can be changed
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.referencesInPicker[row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.referencesInPicker count];
}
*/

#pragma mark - CountryPickerDelegate

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    self.countryRowLabel.text = name;
    // country was picked, reload coin picker with coins from new region
    [self.pickerView setRegionCode:code];
    // Note that the delegate method on UIPickerViewDelegate is not triggered when manually calling -[UIPickerView selectRow:inComponent:animated:].
    // To do this, we fire off the delegate method manually.
    [self.pickerView selectRow:0 inComponent:0 animated:TRUE];
    [self coinsByRegionPicker:self.pickerView didSelectCoinWithName:self.pickerView.selectedCoinName diameter:self.pickerView.selectedCoinDiameter];
    [self markCoinSelectionActive];
}

#pragma mark - CoinByRegionPickerDelegate

- (void)coinsByRegionPicker:(CoinsByRegionPicker *)picker didSelectCoinWithName:(NSString *)name diameter:(NSNumber *)diameter
{
    self.currentReferenceObjectLabel.text = name;
    self.coinRowLabel.text = name;
    [self markCoinSelectionActive];
}

@end
