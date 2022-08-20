//
//  ModuleListView.swift
//  LocalizableManager
//
//  Created by litiezhu on 2022/8/19.
//

import SwiftUI

struct ModuleListView: View {
    
    /// 项目model
    var projectModel: ProjectModel?
    
    /// 模块管理
    @ObservedObject private var manager: ModuleManager
    
    /// 是否弹出添加弹窗
    @State private var isPresentAddPanel = false
    
    /// table 选择id
    @State private var selectedId: ModuleModel.ID?
    
    /// 当前选择的model
    private var selectedModel: ModuleModel? {
        return self.manager.models.first(where: { $0.id == selectedId })
    }
    
    /// 初始化
    /// - Parameter projectModel: 项目model
    init(projectModel: ProjectModel? = nil) {
        self.projectModel = projectModel
        self._manager = .init(wrappedValue: ModuleManager(model: projectModel))
    }
    
    var body: some View {
         
        VStack {

            Table(self.manager.models, selection: $selectedId) {
                TableColumn("模块名", value: \.name).width(min: 100, ideal: 150, max: 200)
                TableColumn("代码目录", value: \.codeDirectory)
                TableColumn("语言目录", value: \.languageDirectory)
                
            }.contextMenu {
                
                if selectedModel != nil {
                    Button("打开代码目录") {
                        if let model = self.selectedModel {
                            NSWorkspace.shared.open(.init(fileURLWithPath: model.codeDirectory))
                        }
                    }

                    Button("打开语言目录") {
                        if let model = self.selectedModel {
                            NSWorkspace.shared.open(.init(fileURLWithPath: model.languageDirectory))
                        }
                    }

                    Divider()
                    Button("删除") {
                        if let model = self.selectedModel {
                            self.manager.remove(model)
                            self.selectedId = nil
                        }
                    }
                }
            }

        }.toolbar {
            
            Button("添加模块") {
                isPresentAddPanel.toggle()
            }.disabled(self.projectModel == nil)

            Button("导出xlsx") {
                self.manager.generateXLSX()
            }.disabled(self.projectModel == nil)

            Button("生成语言包") {
                self.manager.generateStrings()
            }.disabled(self.projectModel == nil)
            
        }.onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
            /// 拖动添加模块
            providers.forEach({
                guard let identifier = $0.registeredTypeIdentifiers.first else {
                    return
                }

                $0.loadItem(forTypeIdentifier: identifier, options: nil) { data, error in
                    guard let data = data as? Data,
                          let url = URL.init(dataRepresentation: data, relativeTo: nil, isAbsolute: true) else {
                        return
                    }

                    importFromUrl(url)
                }
            })

            return true
        }.sheet(isPresented: $isPresentAddPanel) {
            
        } content: {
            /// 弹出添加弹窗
            if let manager = manager {
                ModuleAddPanel(manager: manager)
            }
        }
    }
    
    /// 从文件路径倒入模块
    /// - Parameter url: 
    func importFromUrl(_ url: URL) {
        
        guard self.projectModel != nil, let tp = PodspecParser.parse(url) else {
            return
        }
        
        let model = ModuleModel(name: tp.name,
                                codeDirectory: tp.codePath,
                                languageDirectory: tp.languagePath)
        if self.manager.exist(model) == false {
            self.manager.add(model)
        }
    }
}

struct ModuleListView_Previews: PreviewProvider {
    static var previews: some View {
        ModuleListView()
    }
}
