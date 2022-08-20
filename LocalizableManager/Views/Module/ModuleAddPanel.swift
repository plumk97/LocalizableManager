//
//  ModuleAddPanel.swift
//  LocalizableManager
//
//  Created by Plumk on 2022/1/19.
//

import SwiftUI

struct ModuleAddPanel: View {
    @Environment(\.dismiss) var dismiss
    
    let manager: ModuleManager?
    
    /// 模块名
    @State private var name: String = ""
    
    /// 代码路径
    @State private var codePath: String = ""
    
    /// 语音包路径
    @State private var languagePath: String = ""
    
    /// 是否显示提示框
    @State private var isPresentAlert = false
    
    /// 提示框内容
    @State private var alertContent = ""
    
    /// 初始化
    /// - Parameter manager: 模块管理器
    init(manager: ModuleManager? = nil) {
        self.manager = manager
    }
    
    var body: some View {
        VStack {
            Text("添加模块")
            VStack(alignment: .center, spacing: 10) {
                Button("从Podspec导入") {
                    pickPodspec()
                }
            }.padding()
            
            HStack {
                Text("模块名:")
                    .frame(width: 80, alignment: .trailing)
                TextField("模块名", text: $name, prompt: nil)
            }
            
            HStack {
                Text("代码目录:")
                    .frame(width: 80, alignment: .trailing)
                TextField("代码目录", text: $codePath, prompt: nil)
                Button("选取") {
                    pickDirectory(result: $codePath)
                }
                    

            }
            
            HStack {
                Text("语言目录:")
                    .frame(width: 80, alignment: .trailing)
                TextField("语言目录", text: $languagePath, prompt: nil)
                Button("选取") {
                    pickDirectory(result: $languagePath)
                }
            }
            
            HStack {
                
                Button("确定") {
                    confirm()
                }
                
                Button("取消") {
                    dismiss()
                }
            }.padding()
        }
        .padding()
        .frame(width: 500)
        .alert(alertContent, isPresented: $isPresentAlert) {
            
        }.onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
            
            guard let item = providers.first else {
                return false
            }
            
            guard let identifier = item.registeredTypeIdentifiers.first else {
                return false
            }
            
            item.loadItem(forTypeIdentifier: identifier, options: nil) { data, error in
                guard let data = data as? Data,
                      let url = URL.init(dataRepresentation: data, relativeTo: nil, isAbsolute: true) else {
                    return
                }
                
                parsePodspec(url)
            }
            return true
        }
        
    }
    
    
    /// 文件选择器
    /// - Parameter result:
    func pickDirectory(result: Binding<String>) {
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            result.wrappedValue = panel.urls.first?.relativePath ?? ""
            print(panel.urls)
        }
    }
    
    /// 选中Podspec文件
    func pickPodspec() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        
        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [.init(filenameExtension: "podspec")!]
        } else {
            panel.allowedFileTypes = ["podspec"]
        }
        if panel.runModal() == .OK, let url = panel.urls.first {
            self.parsePodspec(url)
        }
    }
    
    /// 解析Podspec文件
    /// - Parameter url:
    func parsePodspec(_ url: URL) {
        
        guard let tp = PodspecParser.parse(url) else {
            return
        }
        self.name = tp.name
        self.codePath = tp.codePath
        self.languagePath = tp.languagePath
    }
    
    
    /// 确认
    func confirm() {
        guard self.name.count > 0 else {
            self.alertContent = "请输入模块名"
            self.isPresentAlert.toggle()
            return
        }
        
        guard self.codePath.count > 0 else {
            self.alertContent = "请选取代码目录"
            self.isPresentAlert.toggle()
            return
        }
        
        guard self.languagePath.count > 0 else {
            self.alertContent = "请选取语言目录"
            self.isPresentAlert.toggle()
            return
        }
        
        let model = ModuleModel(name: self.name,
                                codeDirectory: self.codePath,
                                languageDirectory: self.languagePath)
        
        guard let manager = manager else {
            return
        }

        
        guard !manager.exist(model) else {
            self.alertContent = "重复的模块"
            self.isPresentAlert.toggle()
            return
        }
        
        manager.add(model)
        dismiss()
    }
}

struct ModuleAddPanel_Previews: PreviewProvider {
    static var previews: some View {
        ModuleAddPanel()
    }
}
