//
//  ProjectListView.swift
//  LocalizableManager
//
//  Created by litiezhu on 2022/8/19.
//

import SwiftUI

struct ProjectListView: View {
    
    /// 同步外部
    @Binding var selectedModel: ProjectModel?
    
    
    /// 项目管理器
    @StateObject private var projectMgr = ProjectManager.shared
    
    /// 是否显示弹窗
    @State private var isPresentAddPanel = false
    
    /// 当前选中id
    @State private var selectedId: ModuleModel.ID?
    
    init() {
        self._selectedModel = Binding.constant(nil)
    }
    
    init(selectedModel: Binding<ProjectModel?>) {
        self._selectedModel = selectedModel
    }
    
    
    var body: some View {
        Table(projectMgr.models, selection: $selectedId) {
            TableColumn("项目", value: \.name).width(min: 200, ideal: nil, max: .infinity)
        }.contextMenu {
            
            Button("新建项目") {
                isPresentAddPanel.toggle()
            }
            
            if selectedId != nil {
                Button("删除项目") {
                    deleteProject()
                }
            }
            
        }.sheet(isPresented: $isPresentAddPanel) {
            ProjectAddPanel()
        }.onChange(of: self.selectedId) { newValue in
            self.selectedModel = self.projectMgr.models.first(where: { $0.id == selectedId})
        }
        
    }
    
    func deleteProject() {
        guard let selectedId = selectedId else {
            return
        }

        guard let model = projectMgr.models.first(where: { $0.id == selectedId }) else {
            return
        }
        ProjectManager.removeProject(model.name)
        self.selectedId = nil
        self.selectedModel = nil
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView()
    }
}
