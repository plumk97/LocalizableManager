//
//  PodspecParser.swift
//  LocalizableManager
//
//  Created by Plumk on 2022/1/26.
//

import Foundation


class PodspecParser {
    
    
    static func parse(_ url: URL) -> (name: String, codePath: String, languagePath: String)? {
        
        var isDirectory = ObjCBool(false)
        let isExist = FileManager.default.fileExists(atPath: url.relativePath, isDirectory: &isDirectory)
        
        if isDirectory.boolValue {
            
            guard let subpaths = try? FileManager.default.contentsOfDirectory(atPath: url.relativePath) else {
                return nil
            }
            
            guard let subpath = subpaths.first(where: { $0.hasSuffix(".podspec")}) else {
                return nil
            }
            
            return parse(url.appendingPathComponent(subpath))
            
            
        } else if isExist && url.pathExtension == "podspec" {
            
            
            guard let rawStr = try? String.init(contentsOf: url) else {
                return nil
            }
            
            if let range = rawStr.range(of: "\\.name.*'.*'", options: .regularExpression, range: nil, locale: nil) {
                guard let range = rawStr[range].range(of: "'.*'", options: .regularExpression, range: nil, locale: nil) else {
                    return nil
                }
                
                let name = String(rawStr[range].replacingOccurrences(of: "'", with: ""))
                let dir = url.deletingLastPathComponent().relativePath
                return (name, dir + "/\(name)/Classes", dir + "/\(name)/Assets")
            }
        }
        return nil
    }
}
