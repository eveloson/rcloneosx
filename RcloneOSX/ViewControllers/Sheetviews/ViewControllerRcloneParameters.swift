//
//  ViewControllerRcloneParameters.swift
//
//  The ViewController for rclone parameters.
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Cocoa
import Foundation

// protocol for returning if userparams is updated or not
protocol RcloneUserParams: class {
    func rcloneuserparamsupdated()
}

// Protocol for sending selected index in tableView
// The protocol is implemented in ViewControllertabMain
protocol GetSelecetedIndex: class {
    func getindex() -> Int?
}

class ViewControllerRcloneParameters: NSViewController, SetConfigurations, SetDismisser, Index {
    // var parameters: RcloneParameters?
    weak var userparamsupdatedDelegate: RcloneUserParams?
    var comboBoxValues = [String]()
    var diddissappear: Bool = false

    @IBOutlet var param1: NSTextField!
    @IBOutlet var param2: NSTextField!
    // user selected parameter
    @IBOutlet var param8: NSTextField!
    @IBOutlet var param9: NSTextField!
    @IBOutlet var param10: NSTextField!
    @IBOutlet var param11: NSTextField!
    @IBOutlet var param12: NSTextField!
    @IBOutlet var param13: NSTextField!
    @IBOutlet var param14: NSTextField!
    // Comboboxes
    @IBOutlet var combo8: NSComboBox!
    @IBOutlet var combo9: NSComboBox!
    @IBOutlet var combo10: NSComboBox!
    @IBOutlet var combo11: NSComboBox!
    @IBOutlet var combo12: NSComboBox!
    @IBOutlet var combo13: NSComboBox!
    @IBOutlet var combo14: NSComboBox!

    @IBAction func close(_: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userparamsupdatedDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else { return }
        if let index = self.index() {
            // Create RcloneParameters object and load initial parameters
            let configurations: [Configuration] = self.configurations!.getConfigurations()
            let param = ComboboxRcloneParameters(config: configurations[index])
            self.comboBoxValues = param.getComboBoxValues()
            self.param1.stringValue = configurations[index].parameter1 ?? ""
            self.param2.stringValue = configurations[index].parameter2 ?? ""
            // There are seven user seleected rclone parameters
            let value8 = param.getParameter(rcloneparameternumber: 8).0
            self.initcombox(combobox: self.combo8, index: value8)
            self.param8.stringValue = param.getParameter(rcloneparameternumber: 8).1
            let value9 = param.getParameter(rcloneparameternumber: 9).0
            self.initcombox(combobox: self.combo9, index: value9)
            self.param9.stringValue = param.getParameter(rcloneparameternumber: 9).1
            let value10 = param.getParameter(rcloneparameternumber: 10).0
            self.initcombox(combobox: self.combo10, index: value10)
            self.param10.stringValue = param.getParameter(rcloneparameternumber: 10).1
            let value11 = param.getParameter(rcloneparameternumber: 11).0
            self.initcombox(combobox: self.combo11, index: value11)
            self.param11.stringValue = param.getParameter(rcloneparameternumber: 11).1
            let value12 = param.getParameter(rcloneparameternumber: 12).0
            self.initcombox(combobox: self.combo12, index: value12)
            self.param12.stringValue = param.getParameter(rcloneparameternumber: 12).1
            let value13 = param.getParameter(rcloneparameternumber: 13).0
            self.initcombox(combobox: self.combo13, index: value13)
            self.param13.stringValue = param.getParameter(rcloneparameternumber: 13).1
            let value14 = param.getParameter(rcloneparameternumber: 14).0
            self.initcombox(combobox: self.combo14, index: value14)
            self.param14.stringValue = param.getParameter(rcloneparameternumber: 14).1
        }
        self.backupbutton.state = .off
        self.suffixdatebutton.state = .off
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    // Function for saving changed or new parameters for one configuration.
    @IBAction func update(_: NSButton) {
        var configurations: [Configuration] = self.configurations!.getConfigurations()
        guard configurations.count > 0 else { return }
        if let index = self.index() {
            let param = SetRcloneParameter()
            configurations[index].parameter8 = param.setrcloneparameter(indexComboBox:
                self.combo8.indexOfSelectedItem, value: getValue(value: self.param8.stringValue))
            configurations[index].parameter9 = param.setrcloneparameter(indexComboBox:
                self.combo9.indexOfSelectedItem, value: getValue(value: self.param9.stringValue))
            configurations[index].parameter10 = param.setrcloneparameter(indexComboBox:
                self.combo10.indexOfSelectedItem, value: getValue(value: self.param10.stringValue))
            configurations[index].parameter11 = param.setrcloneparameter(indexComboBox:
                self.combo11.indexOfSelectedItem, value: getValue(value: self.param11.stringValue))
            configurations[index].parameter12 = param.setrcloneparameter(indexComboBox:
                self.combo12.indexOfSelectedItem, value: getValue(value: self.param12.stringValue))
            configurations[index].parameter13 = param.setrcloneparameter(indexComboBox:
                self.combo13.indexOfSelectedItem, value: getValue(value: self.param13.stringValue))
            configurations[index].parameter14 = param.setrcloneparameter(indexComboBox:
                self.combo14.indexOfSelectedItem, value: getValue(value: self.param14.stringValue))
            self.configurations!.updateConfigurations(config: configurations[index], index: index)
            self.userparamsupdatedDelegate?.rcloneuserparamsupdated()
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // There are eight comboboxes
    // All eight are initalized during ViewDidLoad and
    // the correct index is set.
    private func initcombox(combobox: NSComboBox, index: Int) {
        combobox.removeAllItems()
        combobox.addItems(withObjectValues: self.comboBoxValues)
        combobox.selectItem(at: index)
    }

    // Returns nil or value from stringvalue (rclone parameters)
    private func getValue(value: String) -> String? {
        if value.isEmpty {
            return nil
        } else {
            return value
        }
    }

    @IBOutlet var backupbutton: NSButton!
    @IBAction func backup(_: NSButton) {
        switch self.backupbutton.state {
        case .on:
            let hiddenID = self.configurations!.gethiddenID(index: (self.index())!)
            let remoteCatalog = self.configurations!.getResourceConfiguration(hiddenID: hiddenID, resource: .remoteCatalog)
            let offsiteServer = self.configurations!.getResourceConfiguration(hiddenID: hiddenID, resource: .offsiteServer)
            let backup = offsiteServer + ":" + remoteCatalog + "_backup"
            self.param13.stringValue = backup
            self.initcombox(combobox: self.combo13, index: ComboboxRcloneParameters(config: nil).indexandvaluercloneparameter(parameter: "--backup-dir").0)
        case .off:
            self.initcombox(combobox: self.combo13, index: 0)
            self.param13.stringValue = ""
        default: break
        }
    }

    @IBOutlet var suffixdatebutton: NSButton!
    @IBAction func suffixdate(_: NSButton) {
        switch self.suffixdatebutton.state {
        case .on:
            self.param14.stringValue = SuffixstringsRcloneParameters().suffixstringdate
            self.initcombox(combobox: self.combo14, index: ComboboxRcloneParameters(config: nil).indexandvaluercloneparameter(parameter: "--suffix").0)
        case .off:
            self.initcombox(combobox: self.combo14, index: 0)
            self.param14.stringValue = ""
        default: break
        }
    }
}
