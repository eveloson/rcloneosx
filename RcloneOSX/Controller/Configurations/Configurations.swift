//
//  Configurations.swift
//
//  This object stays in memory runtime and holds key data and operations on Configurations.
//  The obect is the model for the Configurations but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  The object also holds various configurations for rcloneOSX and references to
//  some of the ViewControllers used in calls to delegate functions.
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class Configurations: ReloadTable, SetSchedules {
    // reference to Process, used for kill in executing task
    var process: Process?
    private var profile: String?
    // The main structure storing all Configurations for tasks
    private var configurations: [Configuration]?
    // Array to store argumenst for all tasks.
    // Initialized during startup
    private var argumentAllConfigurations: [ArgumentsOneConfiguration]?
    // Datasource for NSTableViews
    private var configurationsDataSource: [NSMutableDictionary]?
    // backup list from remote info view
    var quickbackuplist: [Int]?
    // Estimated backup list, all backups
    var estimatedlist: [NSDictionary]?
    // remote info tasks
    var remoteinfoestimation: RemoteinfoEstimation?

    func setestimatedlistnil() -> Bool {
        if (self.estimatedlist?.count ?? 0) == (self.configurations?.count ?? 0) {
            return false
        } else {
            return true
        }
    }

    /// Function for getting the profile
    func getProfile() -> String? {
        return self.profile
    }

    /// Function for getting Configurations read into memory
    /// - parameter none: none
    /// - returns : Array of configurations
    func getConfigurations() -> [Configuration] {
        return self.configurations ?? []
    }

    /// Function for getting arguments for all Configurations read into memory
    /// - parameter none: none
    /// - returns : Array of arguments
    func getargumentAllConfigurations() -> [ArgumentsOneConfiguration] {
        return self.argumentAllConfigurations ?? []
    }

    /// Function for getting the number of configurations used in NSTableViews
    /// - parameter none: none
    /// - returns : Int
    func configurationsDataSourcecount() -> Int {
        if self.configurationsDataSource == nil {
            return 0
        } else {
            return self.configurationsDataSource!.count
        }
    }

    /// Function for getting Configurations read into memory
    /// as datasource for tableViews
    /// - parameter none: none
    /// - returns : Array of Configurations
    func getConfigurationsDataSource() -> [NSDictionary]? {
        return self.configurationsDataSource
    }

    /// Function for getting all Configurations
    /// - parameter none: none
    /// - returns : Array of NSMutableDictionary
    func getConfigurationsSyncandCopy() -> [NSMutableDictionary]? {
        let configurations: [Configuration] = self.configurations!.filter { ($0.task == ViewControllerReference.shared.copy || $0.task == ViewControllerReference.shared.sync) }
        var data = [NSMutableDictionary]()
        for i in 0 ..< configurations.count {
            let row: NSMutableDictionary = ConvertOneConfig(config: self.configurations![i]).dict
            if self.quickbackuplist != nil {
                let quickbackup = self.quickbackuplist!.filter { $0 == configurations[i].hiddenID }
                if quickbackup.count > 0 {
                    row.setValue(1, forKey: "selectCellID")
                }
            }
            data.append(row)
        }
        return data
    }

    /// Function computes arguments for rclone, either arguments for
    /// real runn or arguments for --dry-run for Configuration at selected index
    /// - parameter index: index of Configuration
    /// - parameter argtype : either .arg or .argdryRun (of enumtype argumentsrclone)
    /// - returns : array of Strings holding all computed arguments
    func arguments4rclone(index: Int, argtype: ArgumentsRclone) -> [String] {
        let allarguments = self.argumentAllConfigurations![index]
        switch argtype {
        case .arg:
            return allarguments.arg ?? []
        case .argdryrun:
            return allarguments.argdryRun ?? []
        case .arglistfiles:
            return allarguments.argslistRemotefiles ?? []
        case .argrestore:
            return allarguments.argsRestorefiles ?? []
        case .argrestoredryrun:
            return allarguments.argsRestorefilesdryRun ?? []
        case .argrestoredisplaydryrun:
            return allarguments.argsRestorefilesdryRunDisplay ?? []
        }
    }

    func arguments4tmprestore(index: Int, argtype: ArgumentsRclone) -> [String] {
        let allarguments = self.argumentAllConfigurations![index]
        switch argtype {
        case .arg:
            return allarguments.tmprestore ?? []
        case .argdryrun:
            return allarguments.tmprestoredryRun ?? []
        default:
            return []
        }
    }

    func arguments4restore(index: Int, argtype: ArgumentsRclone) -> [String] {
        let allarguments = self.argumentAllConfigurations![index]
        switch argtype {
        case .arg:
            return allarguments.restore ?? []
        case .argdryrun:
            return allarguments.restoredryRun ?? []
        default:
            return []
        }
    }

    /// Function is adding new Configurations to existing in memory.
    /// - parameter dict : new record configuration
    func appendconfigurationstomemory(dict: NSDictionary) {
        let config = Configuration(dictionary: dict)
        self.configurations!.append(config)
    }

    /// Function sets currentDate on Configuration when executed on task
    /// stored in memory and then saves updated configuration from memory to persistent store.
    /// Function also notifies Execute view to refresh data
    /// in tableView.
    /// - parameter index: index of Configuration to update
    func setCurrentDateonConfiguration(index: Int, outputprocess: OutputProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        let hiddenID = self.gethiddenID(index: index)
        let numbers = number.stats()
        self.schedules!.addlog(hiddenID, result: numbers)
        let currendate = Date()
        let dateformatter = Dateandtime().setDateformat()
        self.configurations![index].dateRun = dateformatter.string(from: currendate)
        // Saving updated configuration in memory to persistent store
        _ = PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
        // Call the view and do a refresh of tableView
        self.reloadtable(vcontroller: .vctabmain)
        _ = Logging(outputprocess: outputprocess)
    }

    /// Function is updating Configurations in memory (by record) and
    /// then saves updated Configurations from memory to persistent store
    /// - parameter config: updated configuration
    /// - parameter index: index to Configuration to replace by config
    func updateConfigurations(config: Configuration, index: Int) {
        self.configurations![index] = config
        _ = PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
    }

    /// Function deletes Configuration in memory at hiddenID and
    /// then saves updated Configurations from memory to persistent store.
    /// Function computes index by hiddenID.
    /// - parameter hiddenID: hiddenID which is unique for every Configuration
    func deleteConfigurationsByhiddenID(hiddenID: Int) {
        let index = self.getIndex(hiddenID: hiddenID)
        self.configurations!.remove(at: index)
        _ = PersistentStorageConfiguration(profile: self.profile).saveconfigInMemoryToPersistentStore()
    }

    // Add new configurations
    func addNewConfigurations(dict: NSMutableDictionary) {
        _ = PersistentStorageConfiguration(profile: self.profile).newConfigurations(dict: dict)
    }

    func getResourceConfiguration(hiddenID: Int, resource: ResourceInConfiguration) -> String {
        let result = self.configurations!.filter { ($0.hiddenID == hiddenID) }
        guard result.count > 0 else { return "" }
        switch resource {
        case .localCatalog:
            return result[0].localCatalog
        case .remoteCatalog:
            return result[0].offsiteCatalog
        case .offsiteServer:
            if result[0].offsiteServer.isEmpty {
                return "localhost"
            } else {
                return result[0].offsiteServer
            }
        case .task:
            return result[0].task
        case .backupid:
            return result[0].backupID
        case .offsiteusername:
            return result[0].offsiteUsername
        }
    }

    func getIndex(hiddenID: Int) -> Int {
        var index: Int = -1
        loop: for i in 0 ..< self.configurations!.count where self.configurations![i].hiddenID == hiddenID {
            index = i
            break loop
        }
        return index
    }

    func gethiddenID(index: Int) -> Int {
        guard index < (self.configurations?.count ?? -1) else { return -1 }
        return self.configurations![index].hiddenID
    }

    /// Function is reading all Configurations into memory from permanent store and
    /// prepare all arguments for rclone. All configurations are stored in the private
    /// variable within object.
    /// Function is destroying any previous Configurations before loading new and computing new arguments.
    /// - parameter none: none
    private func readconfigurations() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        let store: [Configuration]? = PersistentStorageConfiguration(profile: self.profile).getConfigurations()
        guard store != nil else { return }
        for i in 0 ..< store!.count {
            self.configurations!.append(store![i])
            let rcloneArgumentsOneConfig = ArgumentsOneConfiguration(config: store![i])
            self.argumentAllConfigurations!.append(rcloneArgumentsOneConfig)
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var data = [NSMutableDictionary]()
        for i in 0 ..< self.configurations!.count {
            data.append(ConvertOneConfig(config: self.configurations![i]).dict)
        }
        self.configurationsDataSource = data
    }

    init(profile: String?) {
        self.configurations = [Configuration]()
        self.argumentAllConfigurations = nil
        self.configurationsDataSource = nil
        self.profile = profile
        self.readconfigurations()
    }
}
