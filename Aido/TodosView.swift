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

struct TodosView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Todo.deadline) var todos: [Todo]

    @Observable
    class Model {
        var isShowingCreateTask = false
    }

    @State private var model = Model()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List(todos) { todo in
                    VStack(alignment: .leading) {
                        Text(todo.name)

                        if let deadline = todo.deadline {
                            Text(deadline.formatted(.relative(presentation: .named)).capitalized)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            modelContext.delete(todo)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

                }


                Button(action: {
                    model.isShowingCreateTask = true
                }, label: {
                    Circle()
                        .frame(width: 45, height: 45)
                        .overlay {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.white)
                        }
                        .padding()
                })
            }
            .sheet(isPresented: $model.isShowingCreateTask) {
                NavigationStack {
                    CreateTodoView()
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

    return TodosView()
        .modelContainer(container)
}
