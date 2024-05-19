//
//  FileManager+Utils.swift
//
//
//  Created by Jonas Bromö on 2024-05-19.
//

import Foundation

@available(macOS 13.0, *)
public extension FileManager {

    func find(_ filename: String, in directoryURL: URL) throws -> URL {
        let fileURL = try _find(filename, in: directoryURL)
        guard let fileURL else {
            // Maybe we didn't succeed to avoid .xcstrings processing,
            // consider reverting to .json
            throw CocoaError(.fileNoSuchFile)
        }
        return fileURL
    }

    private func _find(_ filename: String, in directoryURL: URL) throws -> URL? {
        var isDir: ObjCBool = false
        guard
            fileExists(atPath: directoryURL.path(), isDirectory: &isDir),
            isDir.boolValue
        else {
            return nil
        }
        let directoryContents = try contentsOfDirectory(atPath: directoryURL.path())
        for content in directoryContents {
            let contentURL = directoryURL.appendingPathComponent(content)
            if content == filename {
                return contentURL
            } else {
                return try find(filename, in: contentURL)
            }
        }
        return nil
    }

    func findProjectRoot(_ path: String = #file) throws -> URL? {
        let url = URL(fileURLWithPath: path)
        let directoryURL = url.deletingLastPathComponent()

        let contents = try contentsOfDirectory(atPath: directoryURL.path())
        if contents.contains("Package.swift") {
            return directoryURL
        }
        return try findProjectRoot(directoryURL.path())
    }

}
