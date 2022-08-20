//
//  ProjectAddPanel.swift
//  LocalizableManager
//
//  Created by litiezhu on 2022/8/19.
//

import SwiftUI

struct ProjectAddPanel: View {
    @Environment(\.dismiss) var dismiss
    
    /// 提示框内容
    @State private var alertContent = ""
    
    /// 是否显示提示框
    @State private var isPresentAlert = false
    
    /// 项目名
    @State private var projectName = ""
    
    var body: some View {
        
        VStack {
            Text("添加项目")
            
            HStack {
                Text("项目名:")
                    .frame(width: 80, alignment: .trailing)
                TextField("项目名", text: $projectName, prompt: nil)
            }
            
            HStack {
                
                Button("确定") {
                    confirm()
                }
                
                Button("取消") {
                    dismiss()
                }
            }.padding()
            
        }.frame(width: 300)
        .padding()
        .alert(alertContent, isPresented: $isPresentAlert) {
            
        }
    }
    
    /// 确认
    func confirm() {
        guard self.projectName.count > 0 else {
            self.alertContent = "请输入项目名"
            self.isPresentAlert.toggle()
            return
        }
        
        guard !ProjectManager.isExist(self.projectName) else {
            self.alertContent = "项目名重复"
            self.isPresentAlert.toggle()
            return
        }
        
        ProjectManager.addProject(self.projectName)
        dismiss()
    }
}

struct ProjectAddPanel_Previews: PreviewProvider {
    static var previews: some View {
        ProjectAddPanel()
    }
}
