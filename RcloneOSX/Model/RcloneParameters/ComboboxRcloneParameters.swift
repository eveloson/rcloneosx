//
//  ComboboxRcloneParameters.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct ComboboxRcloneParameters {

     // Array storing combobox values
     private var comboBoxValues: [String]?
     private var config: Configuration?

     // Function for getting for rsync arguments to use in ComboBoxes in ViewControllerRsyncParameters
     // - parameter none: none
     // - return : array of String
     func getComboBoxValues() -> [String] {
         return self.comboBoxValues ?? [""]
     }

     // Returns Int value of argument
     private func indexofrcloneparameter(argument: String) -> Int {
        var index: Int = -1
        loop : for i in 0 ..< SuffixstringsRcloneParameters().rcloneArguments.count where argument == SuffixstringsRcloneParameters().rcloneArguments[i].0 {
            index = i
            break loop
         }
         return index
     }

     // Split an rclone argument into argument and value
     private func split(str: String) -> [String] {
         let argument: String?
         let value: String?
         var split = str.components(separatedBy: "=")
         argument = String(split[0])
         if split.count > 1 {
             if split.count > 2 {
                 split.remove(at: 0)
                 value = split.joined(separator: "=")
             } else {
                 value = String(split[1])
             }
         } else {
             value = argument
         }
         return [argument!, value!]
     }

     func indexandvaluercloneparameter(parameter: String?) -> (Int, String) {
        guard parameter != nil else { return (0, "") }
        let splitstr: [String] = self.split(str: parameter!)
        guard splitstr.count > 1 else { return (0, "")}
        let argument = splitstr[0]
        let value = splitstr[1]
        var returnvalue: String?
        var returnindex: Int?
        if argument != value && self.indexofrcloneparameter(argument: argument) >= 0 {
             returnvalue = value
            returnindex =  self.indexofrcloneparameter(argument: argument)
         } else {
            if self.indexofrcloneparameter(argument: splitstr[0]) >= 0 {
                 returnvalue = "\"" + argument + "\" " + "no arguments"
             } else {
                 if argument == value {
                     returnvalue = value
                 } else {
                     returnvalue = argument + "=" + value
                 }
             }
            if argument != value && self.indexofrcloneparameter(argument: argument) >= 0 {
                returnindex =  self.indexofrcloneparameter(argument: argument)
             } else {
                if self.indexofrcloneparameter(argument: splitstr[0]) >= 0 {
                    returnindex = self.indexofrcloneparameter(argument: argument)
                 } else {
                     returnindex = 0
                 }
             }
         }
         return (returnindex!, returnvalue!)
     }

     func getParameter(rcloneparameternumber: Int) -> (Int, String) {
         var indexandvalue: (Int, String)?
         guard self.config != nil else { return (0, "")}
         switch rcloneparameternumber {
         case 8:
            indexandvalue = self.indexandvaluercloneparameter(parameter: self.config!.parameter8)
         case 9:
            indexandvalue = self.indexandvaluercloneparameter(parameter: self.config!.parameter9)
         case 10:
            indexandvalue = self.indexandvaluercloneparameter(parameter: self.config!.parameter10)
         case 11:
            indexandvalue = self.indexandvaluercloneparameter(parameter: self.config!.parameter11)
         case 12:
            indexandvalue = self.indexandvaluercloneparameter(parameter: self.config!.parameter12)
         case 13:
            indexandvalue = self.indexandvaluercloneparameter(parameter: self.config!.parameter13)
         case 14:
            indexandvalue = self.indexandvaluercloneparameter(parameter: self.config!.parameter14)
         default:
             return (0, "")
         }
         return indexandvalue!
     }

     init(config: Configuration?) {
         self.config = config
         self.comboBoxValues = [String]()
         for i in 0 ..< SuffixstringsRcloneParameters().rcloneArguments.count {
             self.comboBoxValues!.append(SuffixstringsRcloneParameters().rcloneArguments[i].0)
         }
     }
}
