//
//  Copyconfigfilestonewhome.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28/08/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable function_body_length

import Files
import Foundation

struct Copyconfigfilestonewhome: FileErrors {
    var oldpath: String?
    var newpath: String?
    var newprofilecatalogs: [String]?
    var oldprofilecatalogs: [String]?

    // Move all plistfiles from old profile catalog
    // to new profile catalog.
    func moveplistfilestonewhome() -> Bool {
        if let oldpath = self.oldpath,
            let newpath = self.newpath
        {
            var originFolder: Folder?
            var targetFolder: Folder?

            // root of profile catalog
            do {
                originFolder = try Folder(path: oldpath)
            } catch let e {
                let error = e as NSError
                self.fileerror(error: error.description, errortype: .profilecreatedirectory)
                return false
            }
            do {
                targetFolder = try Folder(path: newpath)
            } catch let e {
                let error = e as NSError
                self.fileerror(error: error.description, errortype: .profilecreatedirectory)
                return false
            }
            do {
                if let targetFolder = targetFolder {
                    try originFolder?.files.move(to: targetFolder)
                }
            } catch let e {
                let error = e as NSError
                self.fileerror(error: error.description, errortype: .profilecreatedirectory)
                return false
            }
            // profile catalogs
            for i in 0 ..< (self.oldprofilecatalogs?.count ?? 0) {
                do {
                    originFolder = try Folder(path: oldpath + "/" + (self.oldprofilecatalogs?[i] ?? ""))
                } catch let e {
                    let error = e as NSError
                    self.fileerror(error: error.description, errortype: .profilecreatedirectory)
                    return false
                }
                do {
                    targetFolder = try Folder(path: newpath + "/" + (self.oldprofilecatalogs?[i] ?? ""))
                } catch let e {
                    let error = e as NSError
                    self.fileerror(error: error.description, errortype: .profilecreatedirectory)
                    return false
                }
                do {
                    if let targetFolder = targetFolder {
                        try originFolder?.files.move(to: targetFolder)
                    }
                } catch let e {
                    let error = e as NSError
                    self.fileerror(error: error.description, errortype: .profilecreatedirectory)
                    return false
                }
            }
            return true
        }
        return false
    }

    // Collect all catalognames from old profile catalog.
    // Profilenames are used to create new profile catalogs
    private func getoldcatalogsasstringnames() -> [String]? {
        if let atpath = self.oldpath {
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

    // Collect all catalognames from old profile catalog.
    // Profilenames are used to create new profile catalogs
    private func getnewcatalogsasstringnames() -> [String]? {
        if let atpath = self.newpath {
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

    // Create new profile catalogs at new profile root
    // ahead of moving profile files.
    mutating func createnewprofilecatalogs() {
        if let atpath = self.newpath {
            var newpath: Folder?
            do {
                newpath = try Folder(path: atpath)
            } catch {}
            for i in 0 ..< (self.oldprofilecatalogs?.count ?? 0) {
                do {
                    try newpath?.createSubfolder(at: self.oldprofilecatalogs?[i] ?? "")
                } catch {
                    return
                }
            }
        }
        // Collect the newly created catalogs
        self.newprofilecatalogs = self.getnewcatalogsasstringnames()
    }

    // Verify ready for move
    func verifycatalogsnewprofiles() -> Bool {
        return self.getnewcatalogsasstringnames() == self.getoldcatalogsasstringnames()
    }

    func veriyreadytomoveprofiles() -> Bool {
        return self.oldprofilecatalogs == self.newprofilecatalogs
    }

    init() {
        ViewControllerReference.shared.usenewconfigpath = false
        self.oldpath = NamesandPaths().fullroot
        // Create new profileroot
        ViewControllerReference.shared.usenewconfigpath = true
        let root = Catalogsandfiles()
        root.createrootprofilecatalog()
        self.newpath = root.fullroot
        // Catalogs in oldpath
        self.oldprofilecatalogs = self.getoldcatalogsasstringnames()
    }
}
