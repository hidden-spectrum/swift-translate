//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


struct TranslatableFileFinder {
    
    // MARK: Internal
    
    enum FileType: String {
        case stringCatalog = "xcstrings"
    }
    
    // MARK: Private
    
    private let fileManager = FileManager.default
    private let fileOrDirectoryURL: URL
    private let type: FileType

    // MARK: Lifecycle

    init(fileOrDirectoryURL: URL, type: FileType) {
        self.fileOrDirectoryURL = fileOrDirectoryURL
        self.type = type
    }
    
    // MARK: Main
    
    func findTranslatableFiles() throws -> [URL] {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: fileOrDirectoryURL.path, isDirectory: &isDirectory) else {
            throw SwiftTranslateError.noTranslatableFilesFoundAt(fileOrDirectoryURL)
        }
        
        if isDirectory.boolValue {
            return try searchDirectory(at: fileOrDirectoryURL)
        } else if isTranslatable(fileOrDirectoryURL) {
            return [fileOrDirectoryURL]
        } else {
            throw SwiftTranslateError.noTranslatableFilesFoundAt(fileOrDirectoryURL)
        }
    }
    
    private func isTranslatable(_ fileUrl: URL) -> Bool {
        fileUrl.pathExtension == type.rawValue
    }
    
    private func searchDirectory(at directoryUrl: URL) throws -> [URL] {
        guard let fileEnumerator = fileManager.enumerator(at: directoryUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
            throw SwiftTranslateError.couldNotSearchDirectoryAt(directoryUrl)
        }
        
        var translatableUrls = [URL]()
        for case let fileURL as URL in fileEnumerator {
            if isTranslatable(fileURL) {
                translatableUrls.append(fileURL)
            }
        }
        if translatableUrls.isEmpty {
            throw SwiftTranslateError.noTranslatableFilesFoundAt(fileOrDirectoryURL)
        }
        return translatableUrls
    }
}
