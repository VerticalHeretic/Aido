//
//  ContentView.swift
//  Aido
//
//  Created by Łukasz Stachnik on 18/01/2024.
//

import SwiftUI
import SwiftData

@Model
class Todo {
    var name: String
    var deadline: Date?
    var isCompleted: Bool

    init(name: String, deadline: Date? = nil, isCompleted: Bool = false) {
        self.name = name
        self.deadline = deadline
        self.isCompleted = isCompleted
    }
}

struct ContentView: View {
    @Query(sort: \Todo.deadline) var todos: [Todo]

    var body: some View {
        NavigationStack {
            List(todos) { todo in
                VStack(alignment: .leading) {
                    Text(todo.name)
                    
                    if let deadline = todo.deadline {
                        Text(deadline.formatted(.relative(presentation: .named)).capitalized)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Todo.self, configurations: config)

    for i in 1..<10 {
        let user = Todo(name: "Example Todo \(i)")
        container.mainContext.insert(user)
    }

    for i in 1..<10 {
        let user = Todo(name: "Example Todo With Deadline \(i)", deadline: .distantFuture)
        container.mainContext.insert(user)
    }

    return ContentView()
        .modelContainer(container)
}
