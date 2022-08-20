//
//  ProjectModel.swift
//  LocalizableManager
//
//  Created by litiezhu on 2022/8/19.
//

import Foundation


struct ProjectModel: Identifiable, Codable, Equatable {
    var id: Int {
        return self.name.hashValue
    }
    
    let name: String
}
