//
//  profiles.swift
//  RcloneOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

final class CatalogProfile: Catalogsandfiles {
    // Function for creating new profile directory
    func createprofilecatalog(profile: String) -> Bool {
        var rootpath: Folder?
        if let path = self.fullroot {
            do {
                rootpath = try Folder(path: path)
                do {
                    try rootpath?.createSubfolder(at: profile)
                    return true
                } catch let e {
                    let error = e as NSError
                    self.fileerror(error: error.description, errortype: .profiledeletedirectory)
                    return false
                }
            } catch {
                return false
            }
        }
        return false
    }

    // Function for deleting profile
    func deleteProfileDirectory(profileName: String) {
        let fileManager = FileManager.default
        if let path = self.fullroot {
            let profileDirectory = path + "/" + profileName
            if fileManager.fileExists(atPath: profileDirectory) == true {
                let answer = Alerts.dialogOKCancel("Delete profile: " + profileName + "?", text: "Cancel or OK")
                if answer {
                    do {
                        try fileManager.removeItem(atPath: profileDirectory)
                    } catch let e {
                        let error = e as NSError
                        self.fileerror(error: error.description, errortype: .profiledeletedirectory)
                    }
                }
            }
        }
    }

    override init() {
        super.init()
    }
}
