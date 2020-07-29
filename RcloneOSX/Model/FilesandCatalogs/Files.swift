//
//  files.swift
//  RcloneOSX
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

// Protocol for reporting file errors
protocol Fileerror: AnyObject {
    func fileerrormessageandtype(errorstr: String, errortype: Fileerrortype)
}

protocol FileErrors {
    var errorDelegate: Fileerror? { get }
}

extension FileErrors {
    var errorDelegate: Fileerror? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func fileerror(error: String, errortype: Fileerrortype) {
        self.errorDelegate?.fileerrormessageandtype(errorstr: error, errortype: errortype)
    }
}

protocol ErrorMessage {
    func errordescription(errortype: Fileerrortype) -> String
}

extension ErrorMessage {
    func errordescription(errortype: Fileerrortype) -> String {
        switch errortype {
        case .writelogfile:
            return "Could not write to logfile"
        case .profilecreatedirectory:
            return "Could not create profile directory"
        case .profiledeletedirectory:
            return "Could not delete profile directory"
        case .filesize:
            return "Filesize of logfile is getting bigger"
        }
    }
}

class Files: NamesandPaths, FileErrors {
    // Function for returning profiles as array of Strings
    func getcatalogsasstringnames() -> [String]? {
        if let atpath = self.rootpath {
            var array = [String]()
            do {
                for folders in try Folder(path: atpath).subfolders {
                    array.append(folders.name)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    // Func that creates directory if not created
    func createprofilecatalog() {
        let fileManager = FileManager.default
        if let path = self.rootpath {
            // Profile root
            if fileManager.fileExists(atPath: path) == false {
                do {
                    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch let e {
                    let error = e as NSError
                    self.fileerror(error: error.description, errortype: .profilecreatedirectory)
                }
            }
        }
    }

    override init(configpath: String?) {
        super.init(configpath: configpath)
    }
}
