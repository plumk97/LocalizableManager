//
//  ModuleManager.swift
//  LocalizableManager
//
//  Created by Plumk on 2022/1/19.
//

import Foundation
import SwiftUI


class ModuleManager: ObservableObject {
    
    /// 项目model
    let model: ProjectModel?
    
    /// 内部实际操作models
    private var innerModels = [ModuleModel]() {
        didSet {
            self.models = self.innerModels
        }
    }
    
    /// 用于外部显示
    @Published private(set) var models = [ModuleModel]()
    
    init(model: ProjectModel?) {
        self.model = model
        self.read()
        
        if self.innerModels.count <= 0 {
            self.objectWillChange.send()
        }
    }
    
    
    /// 读取缓存
    private func read() {
        guard let model = model else {
            return
        }

        if let data = UserDefaults.standard.object(forKey: "modules_" + model.name) as? Data {

            let decoder = PropertyListDecoder()
            if let x = try? decoder.decode([ModuleModel].self, from: data) {
                self.innerModels = x
            }
        }
    }
    
    /// 缓存到UserDefaults
    private func save() {
        guard let model = model else {
            return
        }
        
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(self.innerModels) {
            UserDefaults.standard.set(data, forKey: "modules_" + model.name)
            UserDefaults.standard.synchronize()
        }
    }
}

// MARK: - CURD
extension ModuleManager {
    
    /// 判断是否存在
    /// - Parameter model:
    /// - Returns:
    func exist(_ model: ModuleModel) -> Bool {
        return self.innerModels.first(where: { $0.id == model.id }) != nil
    }
    
    /// 添加一个模块
    /// - Parameter model:
    func add(_ model: ModuleModel) {
        DispatchQueue.main.async {
            self.innerModels.append(model)
            self.save()
        }
        
    }
    
    /// 删除一个模块
    /// - Parameter model:
    func remove(_ model: ModuleModel) {
        self.innerModels.removeAll(where: { $0.id == model.id })
        self.save()
    }
}


// MARK: - Export
extension ModuleManager {
    
    /// 生成xlsx表格
    func generateXLSX() {
        let panel = NSSavePanel()
        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [.init(filenameExtension: "xlsx")!]
        } else {
            panel.allowedFileTypes = ["xlsx"]
        }
        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }
        
        let xlsxPath = url.relativePath
        let modules = self.innerModels.map({ $0.name })
        let codeDirs = self.innerModels.map({ $0.codeDirectory })
        let languageDirs = self.innerModels.map({ $0.languageDirectory })
        
        let ret = self.execCommand(type: "xlsx", modules: modules, codeDirs: codeDirs, languageDirs: languageDirs, xlsxPath: xlsxPath)
        if ret.count > 0 {
            AppleScript.alert("导出失败")
        } else {
            AppleScript.alert("导出成功")
        }
    }
    
    
    /// 生成语言包
    func generateStrings() {
        let panel = NSOpenPanel()
        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [.init(filenameExtension: "xlsx")!]
        } else {
            panel.allowedFileTypes = ["xlsx"]
        }
        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }
        
        let xlsxPath = url.relativePath
        let modules = self.innerModels.map({ $0.name })
        
        let codeDirs = self.innerModels.map({ $0.codeDirectory })
        let languageDirs = self.innerModels.map({ $0.languageDirectory })
        
        let ret = self.execCommand(type: "strings", modules: modules, codeDirs: codeDirs, languageDirs: languageDirs, xlsxPath: xlsxPath)
        if ret.count > 0 {
            AppleScript.alert("生成失败")
        } else {
            AppleScript.alert("生成成功")
        }
    }
}


// MARK: - Command
extension ModuleManager {
    
    /// 执行cmd命令
    /// - Parameters:
    ///   - type: 生成文件类型 xlsx | strings
    ///   - modules: 模块
    ///   - codeDirs: 代码目录
    ///   - languageDirs: 语言包目录
    ///   - xlsxPath: 表格文件路径
    /// - Returns:
    private func execCommand(type: String, modules: [String], codeDirs: [String], languageDirs: [String], xlsxPath: String) -> String {
        let errorPipe = Pipe()
        let pipe = Pipe()
        
        let task = Process()
        task.launchPath = Bundle.main.resourcePath! + "/localize-generator"
        task.arguments = [
            "-t", type,
            "--module", modules.joined(separator: ","),
            "--code_dir", codeDirs.joined(separator: ","),
            "--language_dir", languageDirs.joined(separator: ","),
            "--xlsx", xlsxPath,
        ]
        
        
        task.standardOutput = pipe
        task.standardError = errorPipe
        
        if let argumentsString = task.arguments?.joined(separator: " ") {
            print(argumentsString)
        }
        
        let errorFile = errorPipe.fileHandleForReading
        
        task.resume()
        task.launch()
        task.waitUntilExit()
        
        
        let errorOutput = String.init(data: errorFile.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return errorOutput
    }
}
