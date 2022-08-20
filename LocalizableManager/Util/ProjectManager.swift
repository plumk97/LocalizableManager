//
//  ProjectManager.swift
//  LocalizableManager
//
//  Created by litiezhu on 2022/8/19.
//

import Foundation
import SwiftUI

class ProjectManager: ObservableObject {
    
    static let shared = ProjectManager()
    
    @Published private(set) var models = [ProjectModel]()
    
    private init() {
        self.readData()
    }
    
    private func readData() {
        if let data = UserDefaults.standard.object(forKey: "projects") as? Data {
            let decoder = PropertyListDecoder()
            if let x = try? decoder.decode([ProjectModel].self, from: data) {
                self.models = x
            }
        }
    }
 
    private func saveData() {
        
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(self.models) {
            UserDefaults.standard.set(data, forKey: "projects")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// 删除项目对应的模块
    /// - Parameter projectName:
    private func deleteModule(projectName: String) {
        UserDefaults.standard.removeObject(forKey: ModuleManager.generateCacheKey(projectName: projectName))
        UserDefaults.standard.synchronize()
    }
}


// MARK: - Static
extension ProjectManager {
    static func isExist(_ name: String) -> Bool {
        return self.shared.models.first(where: { $0.name == name }) != nil
    }
    
    static func addProject(_ name: String) {
        
        let model = ProjectModel(name: name)
        self.shared.models.append(model)
        self.shared.saveData()
    }
    
    static func removeProject(_ name: String) {
        self.shared.models.removeAll(where: { $0.name == name })
        self.shared.deleteModule(projectName: name)
        self.shared.saveData()
    }
}
