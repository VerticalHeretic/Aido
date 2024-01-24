//
//  Todo.swift
//  Aido
//
//  Created by Łukasz Stachnik on 22/01/2024.
//

import Foundation
import SwiftData

@Model
class Todo {
    var name: String
    var notes: String?
    var deadline: Date?
    var sentiment: Double?
    var isCompleted: Bool

    init(name: String,
         notes: String? = nil,
         deadline: Date? = nil,
         sentiment: Double? = nil,
         isCompleted: Bool = false)
    {
        self.name = name
        self.deadline = deadline
        self.notes = notes
        self.sentiment = sentiment
        self.isCompleted = isCompleted
    }
}
