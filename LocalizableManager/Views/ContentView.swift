//
//  ContentView.swift
//  LocalizableManager
//
//  Created by Plumk on 2022/1/19.
//

import SwiftUI


struct ContentView: View {
    @State var projectModel: ProjectModel?
    
    var body: some View {
        HStack {
            ProjectListView(selectedModel: $projectModel).frame(maxWidth: 200)
            ModuleListView(projectModel: self.projectModel)
        }
    }
    
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(minWidth: 800, minHeight: 500)
    }
}
