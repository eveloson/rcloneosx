//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length type_body_length

import Cocoa
import Foundation

class ViewControllerMain: NSViewController, ReloadTable, Deselect, VcMain, ErrorMessage, Remoterclonesize, Setcolor, Checkforrclone {
    @IBOutlet var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var estimating: NSTextField!
    // Displays the rcloneCommand
    @IBOutlet var rcloneCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    @IBOutlet var dryRunOrRealRun: NSTextField!
    // total number of files in remote volume
    @IBOutlet var totalNumber: NSTextField!
    // total size of files in remote volume
    // Showing info about profile
    @IBOutlet var profilInfo: NSTextField!
    // Showing info about double clik or not
    @IBOutlet var rcloneversionshort: NSTextField!
    @IBOutlet var remoteinfonumber: NSTextField!
    @IBOutlet var remoteinfosize: NSTextField!
    @IBOutlet var info: NSTextField!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

    // Configurations object
    var configurations: Configurations?
    var schedules: Schedules?
    // Reference to the taskobjects
    var singletask: SingleTask?
    var executetasknow: ExecuteTaskNow?
    // Reference to Process task
    var process: Process?
    // Index to selected row, index is set when row is selected
    var index: Int?
    // Indexes, multiple selection
    var indexes: IndexSet?
    var multipeselection: Bool = false
    // Getting output from rclone
    var outputprocess: OutputProcess?

    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrclone() == false else { return }
        if self.configurations?.setestimatedlistnil() == true {
            self.configurations?.remoteinfoestimation = nil
            self.configurations?.estimatedlist = nil
        }
        self.multipeselection = false
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func quickbackup(_: NSButton) {
        guard self.checkforrclone() == false else { return }
        self.configurations?.remoteinfoestimation = nil
        self.configurations?.estimatedlist = nil
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }

    @IBAction func information(_: NSToolbarItem) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerInformation!)
        }
    }

    // Abort button
    @IBAction func abort(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.abortOperations()
            self.process = nil
        }
    }

    // Userconfig
    @IBAction func userconfiguration(_: NSToolbarItem) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        }
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        }
    }

    // Selecting About
    @IBAction func about(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAbout!)
    }

    // Selecting automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        guard self.checkforrclone() == false else { return }
        if self.configurations?.setestimatedlistnil() == true {
            self.configurations?.remoteinfoestimation = nil
            self.configurations?.estimatedlist = nil
        }
        self.multipeselection = false
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func getremoteinfo(_: NSButton) {
        guard self.checkforrclone() == false else { return }
        if self.index != nil {
            self.outputprocess = OutputProcess()
            self.working.startAnimation(nil)
            self.estimating.isHidden = false
            _ = RcloneSize(index: self.index!, outputprocess: self.outputprocess, updateprogress: self)
        } else {
            self.info(num: 1)
        }
    }

    @IBAction func edit(_: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.editViewController!)
        }
    }

    @IBAction func rcloneparams(_: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRcloneParams!)
        }
    }

    @IBAction func delete(_: NSButton) {
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        if let hiddenID = self.configurations?.gethiddenID(index: self.index!) {
            let answer = Alerts.dialogOKCancel("Delete selected task?", text: "Cancel or OK")
            if answer {
                // Delete Configurations and Schedules by hiddenID
                self.configurations!.deleteConfigurationsByhiddenID(hiddenID: hiddenID)
                self.schedules!.deletescheduleonetask(hiddenID: hiddenID)
                self.deselect()
                self.index = nil
                self.reloadtabledata()
            }
        }
        self.reset()
    }

    func info(num: Int) {
        switch num {
        case 1:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "Select a task...."
        case 2:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
            self.info.stringValue = "Possible error logging..."
        case 3:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
            self.info.stringValue = "No rclone in path..."
        case 4:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "⌘A to abort or wait..."
        case 5:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "New version is available - see About"
        case 6:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "Select one or more tasks..."
        default:
            self.info.stringValue = ""
        }
    }

    // Menus as Radiobuttons for Edit functions in tabMainView
    func reset() {
        self.process = nil
        self.singletask = nil
        self.setNumbers(outputprocess: nil)
    }

    @IBAction func executetasknow(_: NSButton) {
        guard self.checkforrclone() == false else { return }
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task != ViewControllerReference.shared.move ||
            self.configurations!.getConfigurations()[self.index!].task != ViewControllerReference.shared.check else {
            return
        }
        self.executetasknow = ExecuteTaskNow(index: self.index!)
    }

    // Function for display rclone command
    // Either --dry-run or real run
    @IBOutlet var displaysynccommand: NSButton!
    @IBOutlet var displayRealRun: NSButton!
    @IBAction func displayRcloneCommand(_: NSButton) {
        self.showrclonecommandmainview()
    }

    // Display correct rclone command in view
    func showrclonecommandmainview() {
        if let index = self.index {
            guard index <= self.configurations!.getConfigurations().count else {
                return
            }
            if self.displaysynccommand.state == .on {
                self.rcloneCommand.stringValue = Displayrclonepath(index: index, display: .sync).rclonepath ?? ""
            } else {
                self.rcloneCommand.stringValue = Displayrclonepath(index: index, display: .restore).rclonepath ?? ""
            }
        } else {
            self.rcloneCommand.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.mainTableView.allowsMultipleSelection = true
        self.working.usesThreadedAnimation = true
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabmain, nsviewcontroller: self)
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllerMain.tableViewDoubleClick(sender:))
        self.displaysynccommand.state = .on
        // configurations and schedules
        self.createandreloadconfigurations()
        self.createandreloadschedules()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if ViewControllerReference.shared.initialstart == 0 {
            self.view.window?.center()
            ViewControllerReference.shared.initialstart = 1
            _ = Checkfornewversion()
        }
        if self.configurations!.configurationsDataSourcecount() > 0 {
            globalMainQueue.async { () -> Void in
                self.mainTableView.reloadData()
            }
        }
        self.rcloneischanged()
        self.displayProfile()
        self.initpopupbutton(button: self.profilepopupbutton)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.multipeselection = false
        self.configurations?.remoteinfoestimation = nil
        self.configurations?.estimatedlist = nil
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        self.executeSingleTask()
    }

    // Single task can be activated by double click from table
    func executeSingleTask() {
        guard self.checkforrclone() == false else { return }
        guard self.index != nil else { return }
        guard self.singletask != nil else {
            // Dry run
            self.singletask = SingleTask(index: self.index!)
            self.singletask?.executeSingleTask()
            return
        }
        // Real run
        self.singletask?.executeSingleTask()
    }

    @IBAction func executemultipleselectedrows(_: NSToolbarItem) {
        guard self.checkforrclone() == false else { return }
        guard self.indexes != nil else {
            self.info(num: 6)
            return
        }
        self.multipeselection = true
        self.configurations?.remoteinfoestimation = nil
        self.configurations?.estimatedlist = nil
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    // Function for setting profile
    func displayProfile() {
        weak var localprofileinfo: SetProfileinfo?
        if let profile = self.configurations!.getProfile() {
            self.profilInfo.stringValue = "Profile: " + profile
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .black)
        } else {
            self.profilInfo.stringValue = "Profile: default"
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .green)
        }
        localprofileinfo = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
        localprofileinfo?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        self.showrclonecommandmainview()
    }

    // Setting remote info
    func remoteinfo(reset: Bool) {
        guard self.outputprocess?.getOutput()?.count ?? 0 > 0 || reset == false else {
            self.remoteinfonumber.stringValue = ""
            self.remoteinfosize.stringValue = ""
            return
        }
        let size = self.remoterclonesize(input: self.outputprocess!.getOutput()![0])
        guard size != nil else { return }
        NumberFormatter.localizedString(from: NSNumber(value: size!.count), number: NumberFormatter.Style.decimal)
        self.remoteinfonumber.stringValue = String(NumberFormatter.localizedString(from: NSNumber(value: size!.count), number: NumberFormatter.Style.decimal))
        self.remoteinfosize.stringValue = String(NumberFormatter.localizedString(from: NSNumber(value: size!.bytes / 1024), number: NumberFormatter.Style.decimal))
    }

    func createandreloadschedules() {
        self.process = nil
        guard self.configurations != nil else {
            self.schedules = Schedules(profile: nil)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.schedules = nil
            self.schedules = Schedules(profile: profile)
        } else {
            self.schedules = nil
            self.schedules = Schedules(profile: nil)
        }
    }

    func createandreloadconfigurations() {
        guard self.configurations != nil else {
            self.configurations = Configurations(profile: nil)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.configurations = nil
            self.configurations = Configurations(profile: profile)
        } else {
            self.configurations = nil
            self.configurations = Configurations(profile: nil)
        }
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
        if let reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcallprofiles) as? ViewControllerAllProfiles {
            reloadDelegate.reloadtable()
        }
    }

    private func initpopupbutton(button: NSPopUpButton) {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getDirectorysStrings()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        button.removeAllItems()
        button.addItems(withTitles: profilestrings ?? [])
        button.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = self.profilepopupbutton.titleOfSelectedItem
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            profile = nil
        }
        _ = Selectprofile(profile: profile)
    }
}
