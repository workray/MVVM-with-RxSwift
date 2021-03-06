//
//  MetadataTypes.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 02/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
MetadataTerritory object
- Parameter codeID: ISO 639 compliant region code
- Parameter countryCode: International country code
- Parameter internationalPrefix: International prefix. Optional.
- Parameter mainCountryForCode: Whether the current metadata is the main country for its country code.
- Parameter nationalPrefix: National prefix
- Parameter nationalPrefixFormattingRule: National prefix formatting rule
- Parameter nationalPrefixForParsing: National prefix for parsing
- Parameter nationalPrefixTransformRule: National prefix transform rule
- Parameter emergency: MetadataPhoneNumberDesc for emergency numbers
- Parameter fixedLine: MetadataPhoneNumberDesc for fixed line numbers
- Parameter generalDesc: MetadataPhoneNumberDesc for general numbers
- Parameter mobile: MetadataPhoneNumberDesc for mobile numbers
- Parameter pager: MetadataPhoneNumberDesc for pager numbers
- Parameter personalNumber: MetadataPhoneNumberDesc for personal number numbers
- Parameter premiumRate: MetadataPhoneNumberDesc for premium rate numbers
- Parameter sharedCost: MetadataPhoneNumberDesc for shared cost numbers
- Parameter tollFree: MetadataPhoneNumberDesc for toll free numbers
- Parameter voicemail: MetadataPhoneNumberDesc for voice mail numbers
- Parameter voip: MetadataPhoneNumberDesc for voip numbers
- Parameter uan: MetadataPhoneNumberDesc for uan numbers
- Parameter leadingDigits: Optional leading digits for the territory
*/
struct MetadataTerritory {
    let codeID: String
    let countryCode: UInt64
    let internationalPrefix: String?
    let mainCountryForCode: Bool
    let nationalPrefix: String?
    let nationalPrefixFormattingRule: String?
    let nationalPrefixForParsing: String?
    let nationalPrefixTransformRule: String?
    let preferredExtnPrefix: String?
    let emergency: MetadataPhoneNumberDesc?
    let fixedLine: MetadataPhoneNumberDesc?
    let generalDesc: MetadataPhoneNumberDesc?
    let mobile: MetadataPhoneNumberDesc?
    let pager: MetadataPhoneNumberDesc?
    let personalNumber: MetadataPhoneNumberDesc?
    let premiumRate: MetadataPhoneNumberDesc?
    let sharedCost: MetadataPhoneNumberDesc?
    let tollFree: MetadataPhoneNumberDesc?
    let voicemail: MetadataPhoneNumberDesc?
    let voip: MetadataPhoneNumberDesc?
    let uan: MetadataPhoneNumberDesc?
    let numberFormats: [MetadataPhoneNumberFormat]
    let leadingDigits: String?

}

extension MetadataTerritory {
    /**
    Parse a json dictionary into a MetadataTerritory.
    - Parameter jsondDict: json dictionary from attached json metadata file.
    */
    init(jsondDict: NSDictionary) {
        self.generalDesc = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "generalDesc") as? NSDictionary))
        self.fixedLine = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "fixedLine") as? NSDictionary))
        self.mobile = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "mobile") as? NSDictionary))
        self.tollFree = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "tollFree") as? NSDictionary))
        self.premiumRate = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "premiumRate") as? NSDictionary))
        self.sharedCost = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "sharedCost") as? NSDictionary))
        self.personalNumber = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "personalNumber") as? NSDictionary))
        self.voip = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "voip") as? NSDictionary))
        self.pager = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "pager") as? NSDictionary))
        self.uan = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "uan") as? NSDictionary))
        self.emergency = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "emergency") as? NSDictionary))
        self.voicemail = MetadataPhoneNumberDesc(jsondDict: (jsondDict.value(forKey: "voicemail") as? NSDictionary))
        self.codeID = jsondDict.value(forKey: "id") as! String
        self.countryCode = UInt64(jsondDict.value(forKey: "countryCode") as! String)!
        self.internationalPrefix = jsondDict.value(forKey: "internationalPrefix") as? String
        self.nationalPrefixTransformRule = jsondDict.value(forKey: "nationalPrefixTransformRule") as? String
        let possibleNationalPrefixForParsing = jsondDict.value(forKey: "nationalPrefixForParsing") as? String
        let possibleNationalPrefix = jsondDict.value(forKey: "nationalPrefix") as? String
        self.nationalPrefix = possibleNationalPrefix
        if (possibleNationalPrefixForParsing == nil && possibleNationalPrefix != nil) {
            self.nationalPrefixForParsing = self.nationalPrefix
        }
        else {
            self.nationalPrefixForParsing = possibleNationalPrefixForParsing
        }
        self.preferredExtnPrefix = jsondDict.value(forKey: "preferredExtnPrefix") as? String
        self.nationalPrefixFormattingRule = jsondDict.value(forKey: "nationalPrefixFormattingRule") as? String
        if let mainCountryForCode = jsondDict.value(forKey: "mainCountryForCode") as? NSString {
            self.mainCountryForCode = mainCountryForCode.boolValue
        } else {
            self.mainCountryForCode = false
        }
        var numberFormats = [MetadataPhoneNumberFormat]()
        
        if let availableFormats = (jsondDict.value(forKey: "availableFormats") as? NSDictionary)?.value(forKey: "numberFormat") {
            if let formatsArray = availableFormats as? NSArray {
                for format in formatsArray {
                    var processedFormat = MetadataPhoneNumberFormat(jsondDict: format as? NSDictionary)
                    if processedFormat.nationalPrefixFormattingRule == nil {
                        processedFormat.nationalPrefixFormattingRule = self.nationalPrefixFormattingRule
                    }
                    numberFormats.append(processedFormat)
                }
            }
            if let format = availableFormats as? NSDictionary {
                let processedFormat = MetadataPhoneNumberFormat(jsondDict: format)
                numberFormats.append(processedFormat)
            }
        }
        self.numberFormats = numberFormats
        self.leadingDigits = jsondDict.value(forKey: "leadingDigits") as? String
    }
}


/**
MetadataPhoneNumberDesc object
- Parameter exampleNumber: An example phone number for the given type. Optional.
- Parameter nationalNumberPattern:  National number regex pattern. Optional.
- Parameter possibleNumberPattern:  Possible number regex pattern. Optional.
*/
struct MetadataPhoneNumberDesc {
    let exampleNumber: String?
    let nationalNumberPattern: String?
    let possibleNumberPattern: String?
}

extension MetadataPhoneNumberDesc {
    /**
    Parse a json dictionary into a MetadataPhoneNumberDesc.
    - Parameter jsondDict: json dictionary from attached json metadata file.
    */
    init(jsondDict: NSDictionary?) {
        self.nationalNumberPattern = jsondDict?.value(forKey: "nationalNumberPattern") as? String
        self.possibleNumberPattern = jsondDict?.value(forKey: "possibleNumberPattern") as? String
        self.exampleNumber = jsondDict?.value(forKey: "exampleNumber") as? String
        
    }
}

/**
 MetadataPhoneNumberFormat object
 - Parameter pattern: Regex pattern. Optional.
 - Parameter format: Formatting template. Optional.
 - Parameter intlFormat: International formatting template. Optional.

 - Parameter leadingDigitsPatterns: Leading digits regex pattern. Optional.
 - Parameter nationalPrefixFormattingRule: National prefix formatting rule. Optional.
 - Parameter nationalPrefixOptionalWhenFormatting: National prefix optional bool. Optional.
 - Parameter domesticCarrierCodeFormattingRule: Domestic carrier code formatting rule. Optional.
 */
struct MetadataPhoneNumberFormat {
    let pattern: String?
    let format: String?
    let intlFormat: String?
    let leadingDigitsPatterns: [String]?
    var nationalPrefixFormattingRule: String?
    let nationalPrefixOptionalWhenFormatting: Bool?
    let domesticCarrierCodeFormattingRule: String?
}

extension MetadataPhoneNumberFormat {
    /**
     Parse a json dictionary into a MetadataPhoneNumberFormat.
     - Parameter jsondDict: json dictionary from attached json metadata file.
     */
    init(jsondDict: NSDictionary?) {
        self.pattern = jsondDict?.value(forKey: "pattern") as? String
        self.format = jsondDict?.value(forKey: "format") as? String
        self.intlFormat = jsondDict?.value(forKey: "intlFormat") as? String
        var leadingDigits = [String]()
        if let leadingDigitsPatterns = jsondDict?.value(forKey: "leadingDigits") {
            if let leadingDigitArray = leadingDigitsPatterns as? [String] {
                for leadingDigit in leadingDigitArray {
                    leadingDigits.append(leadingDigit)
                }
            }
            if let leadingDigit = leadingDigitsPatterns as? String {
                leadingDigits.append(leadingDigit)
            }
        }
        self.leadingDigitsPatterns = leadingDigits
        self.nationalPrefixFormattingRule = jsondDict?.value(forKey: "nationalPrefixFormattingRule") as? String
        if let _nationalPrefixOptionalWhenFormatting = jsondDict?.value(forKey: "nationalPrefixOptionalWhenFormatting") as? NSString {
            self.nationalPrefixOptionalWhenFormatting = _nationalPrefixOptionalWhenFormatting.boolValue
        } else {
            self.nationalPrefixOptionalWhenFormatting = false
        }
        self.domesticCarrierCodeFormattingRule = jsondDict?.value(forKey: "carrierCodeFormattingRule") as? String
    }
}
