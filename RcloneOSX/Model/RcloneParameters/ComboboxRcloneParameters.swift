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
        return SuffixstringsRcloneParameters().rcloneArguments.firstIndex(where: { $0.0 == argument }) ?? -1
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
        guard splitstr.count > 1 else { return (0, "") }
        let argument = splitstr[0]
        let value = splitstr[1]
        var returnvalue: String?
        var returnindex: Int?
        if argument != value, self.indexofrcloneparameter(argument: argument) >= 0 {
            returnvalue = value
            returnindex = self.indexofrcloneparameter(argument: argument)
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
            if argument != value, self.indexofrcloneparameter(argument: argument) >= 0 {
                returnindex = self.indexofrcloneparameter(argument: argument)
            } else {
                if self.indexofrcloneparameter(argument: splitstr[0]) >= 0 {
                    returnindex = self.indexofrcloneparameter(argument: argument)
                } else {
                    returnindex = 0
                }
            }
        }
        return (returnindex ?? 0, returnvalue ?? "")
    }

    func getParameter(rcloneparameternumber: Int) -> (Int, String) {
        if let config = self.config {
            switch rcloneparameternumber {
            case 8:
                return self.indexandvaluercloneparameter(parameter: config.parameter8)
            case 9:
                return self.indexandvaluercloneparameter(parameter: config.parameter9)
            case 10:
                return self.indexandvaluercloneparameter(parameter: config.parameter10)
            case 11:
                return self.indexandvaluercloneparameter(parameter: config.parameter11)
            case 12:
                return self.indexandvaluercloneparameter(parameter: config.parameter12)
            case 13:
                return self.indexandvaluercloneparameter(parameter: config.parameter13)
            case 14:
                return self.indexandvaluercloneparameter(parameter: config.parameter14)
            default:
                return (0, "")
            }
        }

        return (0, "")
    }

    init(config: Configuration?) {
        self.config = config
        self.comboBoxValues = [String]()
        for i in 0 ..< SuffixstringsRcloneParameters().rcloneArguments.count {
            self.comboBoxValues?.append(SuffixstringsRcloneParameters().rcloneArguments[i].0)
        }
    }
}
