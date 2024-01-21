//
//  ContentView.swift
//  Aido
//
//  Created by Łukasz Stachnik on 18/01/2024.
//

import SwiftData
import SwiftUI

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
    @Query(filter: #Predicate<Todo> { todo in
        todo.isCompleted == false
    }, sort: \Todo.deadline) var todos: [Todo]

    @State private var model = Model()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List(todos) { todo in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(todo.name)

                            if let deadline = todo.deadline {
                                Text(deadline.formatted(.relative(presentation: .named)).capitalized)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }

                        Spacer()

                        Button(action: {
                            todo.isCompleted = true
                        }, label: {
                            Image(systemName: "square")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.secondary)
                        })
                        .buttonStyle(.plain)
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
            .navigationTitle("Todos")
            .sheet(isPresented: $model.isShowingCreateTask) {
                NavigationStack {
                    CreateTodoView()
                }
            }
        }
    }
}

extension TodosView {
    @Observable
    class Model {
        var isShowingCreateTask = false
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
