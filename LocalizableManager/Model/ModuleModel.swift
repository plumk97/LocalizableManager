//
//  ModuleModel.swift
//  LocalizableManager
//
//  Created by Plumk on 2022/1/19.
//

import Foundation


struct ModuleModel: Identifiable, Codable {
    
    var id: Int {
        return self.name.hashValue ^ self.codeDirectory.hashValue ^ self.languageDirectory.hashValue
    }
    
    /// 模块名
    let name: String
    
    /// 提取路径
    let codeDirectory: String
    
    /// 导出路径
    let languageDirectory: String
}
