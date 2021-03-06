//
//  ReferenceSetterViewController.h
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


#import <UIKit/UIKit.h>
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"
#import "CountryPicker.h"
#import "CoinsByRegionPicker.h"

@interface ReferenceSetterViewController : UITableViewController <UITextFieldDelegate, CoinsByRegionPickerDelegate, CountryPickerDelegate>

//**NOTE** The conversion from what is shown on the reference setter and stored in the database to what is shown in the relatively small
//textfield in the moleViewController must be accounted for as the referenceNames are updated and also in the Reference Converter class

@property (weak, nonatomic) IBOutlet UILabel *currentReferenceObjectLabel;
@property (weak, nonatomic) IBOutlet CoinsByRegionPicker *coinPickerView;
@property (weak, nonatomic) IBOutlet UITextField *customReferenceTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *customReferenceTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *coinTableViewCell;
@property (weak, nonatomic) IBOutlet CountryPicker *countryPickerView;
@property BOOL countryPickerVisible;
@property BOOL coinPickerVisible;
@property (weak, nonatomic) IBOutlet UILabel *countryRowLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinRowLabel;
@property BOOL isCustomReferenceMeasure;
@property NSNumber *referenceObjectDiameter;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) Measurement *measurement;

@end
