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
#import "ReferenceObject.h"

@interface ReferenceSetterViewController ()

//**NOTE** The conversion from what is shown on the reference setter and stored in the database to what is shown in the relatively small
//textfield in the moleViewController must be accounted for as the referenceNames are updated and also in the Reference Converter class

@end

@implementation ReferenceSetterViewController

#pragma mark - Properties

typedef enum {
    CurrentReferenceSection = 0,
    CountryAndCoinPickerSection = 1,
    CustomReferenceSection = 2
} StaticTableSections;

typedef enum {
    CountryPickerLabelRow = 0,
    CountryPickerRow = 1,
    CoinPickerLabelRow = 2,
    CoinPickerRow = 3
} StaticCountryAndCoinTableSectionRows;

typedef enum {
    MIN_DIAMETER_MM = 10, // 1 cm = 10 mm, seems smallest sensible value
    MAX_DIAMETER_MM = 300 // a standard ruler, 30 centimeters = 300 mm

} AllowableDiameterRange;

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.customReferenceTextField.delegate = self;
    self.coinPickerView.delegate = self;
    self.countryPickerView.delegate = self;
    // enable AutoLayout for the table view
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.countryPickerVisible = NO;
    self.countryPickerView.hidden = YES;
    self.countryPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.coinPickerVisible = NO;
    self.coinPickerView.hidden = YES;
    self.coinPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.customReferenceTableViewCell addGestureRecognizer:tapGestureRecognizer];
    
    // disable done button until a value has changed
    self.doneBarButton.enabled = FALSE;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultReferenceCountryCode = [standardUserDefaults objectForKey:@"referenceCountryCode"];
    NSString *defaultReferenceObject = [standardUserDefaults objectForKey:@"referenceObject"];
    NSNumber *defaultReferenceDiameter = [standardUserDefaults objectForKey:@"referenceObjectDiameter"];
    
    ReferenceObject *refObjCoder = nil;
    if (self.measurement)
    {
        // a measurement exists, use stored reference object
        refObjCoder = [[ReferenceObject alloc] initWithCode:self.measurement.referenceObject diameter:self.measurement.absoluteReferenceDiameter];
    }
    else
    {
        // no measurement exists yet, use default reference object
        refObjCoder = [[ReferenceObject alloc] initWithCode:defaultReferenceObject diameter:defaultReferenceDiameter];
    }
    
    [self.countryPickerView setSelectedCountryCode:(refObjCoder.countryCode ? refObjCoder.countryCode : defaultReferenceCountryCode)];
    [self.coinPickerView setRegionCode:self.countryPickerView.selectedCountryCode];
    self.countryRowLabel.text = self.countryPickerView.selectedCountryName;
    
    //self.currentReferenceObjectLabel.text = refObj.name;
    [self updateCurrentReferenceObjectLabelText:(refObjCoder.isCustom ? @"Custom" : refObjCoder.name) diameter:refObjCoder.diameter];
    [self.coinPickerView setSelectedCoinName:refObjCoder.name];
    self.coinRowLabel.text = self.coinPickerView.selectedCoinName;
    
    // determine if a pre-set coin or custom reference was used and update checkmark display
    if (refObjCoder.isCustom)
    {
        self.customReferenceTextField.text = refObjCoder.diameter.stringValue;
        [self markCustomSelectionActive];
    } else {
        // is pre-set coin
        [self markCoinSelectionActive];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Methods

+ (NSNumber *)decimalNumberFromString:(NSString *)string
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    f.usesSignificantDigits = YES;
    f.minimumSignificantDigits = 2;
    NSNumber *myNumber = [f numberFromString:string];
    // if formatter fails conversion it returns nil, test return value
    return myNumber;
}

+ (NSString *)formatStringFromDiameterValue:(NSNumber *)diameter
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    f.usesSignificantDigits = YES;
    f.minimumSignificantDigits = 2;
    NSString *string = [f stringFromNumber:diameter];
    string = [string stringByAppendingString:@" mm"];
    return string;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self.customReferenceTextField becomeFirstResponder];
    }
}

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
    self.coinPickerView.hidden = NO;
    self.coinPickerView.alpha = 0.0f;
    [UIView animateWithDuration:0.25 animations:^{
        self.coinPickerView.alpha = 1.0f;
    }];
}

- (void)hideCoinPickerCell
{
    self.coinPickerVisible = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.coinPickerView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.coinPickerView.hidden = YES;
                     }];
}

- (void)markCoinSelectionActive
{
    self.isCustomReferenceMeasure = FALSE;
    self.coinTableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.customReferenceTableViewCell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)markCustomSelectionActive
{
    self.isCustomReferenceMeasure = TRUE;
    self.coinTableViewCell.accessoryType = UITableViewCellAccessoryNone;
    self.customReferenceTableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)showBasicAlertForTextField:(UITextField *)textField withMessage:(NSString *)message
{
    // A view can only present one other view at a time.
    // When presenting UIAlertController, need to determine if keyboard is currently presented
    // if so, need to remove presented keyboard in order to show alert correctly
    //[textField resignFirstResponder];
    
    // Create alert
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [textField becomeFirstResponder];
    }];
    [alert addAction:defaultAction];

    // present alert
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateCurrentReferenceObjectLabelText:(NSString *)aLabel diameter:(NSNumber *)aDiameter
{
    self.currentReferenceObjectLabel.text = [NSString stringWithFormat:@"%@ (%@ mm)", aLabel, aDiameter];
}

- (BOOL)isDiameterInValidRange:(NSNumber *)diameter
{
    if (!diameter)
    {
        // should never fail conversion due to using decimal pad keyboard
        // but string could have been empty
        return NO;
    }
    
    return ((MIN_DIAMETER_MM <= diameter.floatValue) && (diameter.floatValue <= MAX_DIAMETER_MM));
}

- (IBAction)cancelTapped:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)doneTapped:(UIBarButtonItem *)sender
{
    if (![self.view endEditing:NO]) return;
    
    ReferenceObject *refObjCoder = nil;
    if (self.isCustomReferenceMeasure)
    {
        refObjCoder = [ReferenceObject referenceObjectFromCustom:self.referenceObjectDiameter];
    }
    else
    {
        refObjCoder = [ReferenceObject referenceObjectFromCountryCode:self.countryPickerView.selectedCountryCode coin:self.coinPickerView.selectedCoinName diameter:self.referenceObjectDiameter];
    }
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *referenceObject = refObjCoder.code;
    [standardUserDefaults setValue:referenceObject forKey:@"referenceObject"];
    
    NSString *referenceCountryCode = self.countryPickerView.selectedCountryCode;
    [standardUserDefaults setValue:referenceCountryCode forKey:@"referenceCountryCode"];
    
    NSNumber *absoluteReferenceDiameter = self.referenceObjectDiameter;
    [standardUserDefaults setValue:absoluteReferenceDiameter forKey:@"referenceObjectDiameter"];
    
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
                    withReferenceObject:referenceObject
                 inManagedObjectContext:self.context];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
if (indexPath.row == CountryPickerRow && indexPath.section == CountryAndCoinPickerSection){
        height = self.countryPickerVisible ? 216.0f : 0.0f;
    }
    if (indexPath.row == CoinPickerRow && indexPath.section == CountryAndCoinPickerSection){
        height = self.coinPickerVisible ? 216.0f : 0.0f;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == CountryPickerLabelRow && indexPath.section == CountryAndCoinPickerSection) {
        if (self.countryPickerVisible){
            [self hideCountryPickerCell];
        } else {
            [self showCountryPickerCell];
            if (self.coinPickerVisible) [self hideCoinPickerCell];
        }
    }
    if (indexPath.row == CoinPickerLabelRow && indexPath.section == CountryAndCoinPickerSection) {
        if (self.coinPickerVisible){
            [self hideCoinPickerCell];
        } else {
            [self showCoinPickerCell];
            if (self.countryPickerVisible) [self hideCountryPickerCell];
        }
    }
    // ensure all text fields end editing
    [self.view endEditing:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hideCountryPickerCell];
    [self hideCoinPickerCell];
    [self markCustomSelectionActive];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    
    NSString *currentString = textField.text;
    NSString *proposedString = [currentString stringByReplacingCharactersInRange:range withString:string];
    
    // determine status of 'done' button from valid range
    NSNumber *diameter = [self.class decimalNumberFromString:proposedString];
    if ([self isDiameterInValidRange:diameter])
    {
        self.doneBarButton.enabled = TRUE;
    } else {
        self.doneBarButton.enabled = FALSE;
    }

    // determine if text should change
    // regEx format equals three digits followed by optional decimal then two digits
    NSString *regEx = @"^\\d{0,3}\\.?\\d{0,2}$";
    NSRange r = [proposedString rangeOfString:regEx options:NSRegularExpressionSearch];
    if (r.location == NSNotFound)
    {
        shouldChange = NO;
    }
        
    if (!proposedString || [proposedString isEqualToString:@""])
    {
        shouldChange = YES;
    }
    
    return shouldChange;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *textFieldText = textField.text;

    if (!textFieldText || [textFieldText isEqualToString:@""])
    {
        // field is blank, revert to selected coin
        [self updateCurrentReferenceObjectLabelText:[self.coinPickerView selectedCoinName] diameter:[self.coinPickerView selectedCoinDiameter]];
        self.referenceObjectDiameter = [self.coinPickerView selectedCoinDiameter];
        [self markCoinSelectionActive];
        self.doneBarButton.enabled = TRUE;
        return;
    }

    NSNumber *diameter = [self.class decimalNumberFromString:textFieldText];
    if (![self isDiameterInValidRange:diameter])
    {
        NSString *message = [NSString stringWithFormat:@"Diameter must be within %i to %i mm.", MIN_DIAMETER_MM, MAX_DIAMETER_MM];
        [self showBasicAlertForTextField:textField withMessage:message];
        self.doneBarButton.enabled = FALSE;
        return;
    }
    self.referenceObjectDiameter = diameter;
    
    [self updateCurrentReferenceObjectLabelText:@"Custom" diameter:diameter];
    self.doneBarButton.enabled = TRUE;
}

#pragma mark - CountryPickerDelegate

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    self.countryRowLabel.text = name;
    // country was picked, reload coin picker with coins from new region
    [self.coinPickerView setRegionCode:code];
    // Note that the delegate method on UIPickerViewDelegate is not triggered when manually calling -[UIPickerView selectRow:inComponent:animated:].
    // To do this, we fire off the delegate method manually.
    [self.coinPickerView selectRow:0 inComponent:0 animated:TRUE];
    [self coinsByRegionPicker:self.coinPickerView didSelectCoinWithName:self.coinPickerView.selectedCoinName diameter:self.coinPickerView.selectedCoinDiameter];
    [self markCoinSelectionActive];
    self.doneBarButton.enabled = TRUE;
}

#pragma mark - CoinByRegionPickerDelegate

- (void)coinsByRegionPicker:(CoinsByRegionPicker *)picker didSelectCoinWithName:(NSString *)name diameter:(NSNumber *)diameter
{
    [self updateCurrentReferenceObjectLabelText:name diameter:diameter];
    self.referenceObjectDiameter = diameter;
    self.coinRowLabel.text = name;
    [self markCoinSelectionActive];
    self.doneBarButton.enabled = TRUE;
}

@end
