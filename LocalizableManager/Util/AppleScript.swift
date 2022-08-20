//
//  AppleScript.swift
//  LocalizableManager
//
//  Created by Plumk on 2022/1/19.
//

import Foundation

class AppleScript {
    
    static func alert(_ text: String) {
        
        guard let script = NSAppleScript(source: "display alert \"\(text.replacingOccurrences(of: "\"", with: "\\\""))\"") else {
            return
        }
        script.executeAndReturnError(nil)
    }
    
    static func dialog(title: String) -> String? {
        
        let srouce = """
        display dialog "\(title)" buttons {"取消", "确定"} default button 2 default answer "" with icon 1
        """
        guard let script = NSAppleScript(source: srouce) else {
            return nil
        }
        
        let result = script.executeAndReturnError(nil)
        
        switch result.atIndex(1)?.stringValue {
        case "确定":
            return result.atIndex(2)?.stringValue
            
        default:
            break
        }
        return nil
    }
}
