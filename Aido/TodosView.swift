//
//  ContentView.swift
//  Aido
//
//  Created by Łukasz Stachnik on 18/01/2024.
//

import Observation
import SwiftData
import SwiftUI

@Observable
final class AppConfiguration {

    static let shared = AppConfiguration(modelProvider: OllamaTextToTextProvider())

    var modelProvider: TextToTextModelProvider

    init(modelProvider: TextToTextModelProvider) {
        self.modelProvider = modelProvider
    }
}

@Observable
final class NavigationStackManager {

    enum Destination: Hashable {
        case taskDetails(todo: Todo)
        case debugDashboard
    }

    var navPath = NavigationPath()

    func navigate(to destination: Destination) {
        navPath.append(destination)
    }

    func navigateBack() {
        navPath.removeLast()
    }

    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}

struct TodosView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Todo> { todo in
        todo.isCompleted == false
    }, sort: \Todo.deadline) var todos: [Todo]

    @State private var model = Model()

    @State private var navigationStackManager = NavigationStackManager()

    var body: some View {
        NavigationStack(path: $navigationStackManager.navPath) {
            ZStack(alignment: .bottomTrailing) {
                List(todos) { todo in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(todo.name)
                                .foregroundStyle(getColorBasedOnSentiment(todo.sentiment))

                            if let notes = todo.notes {
                                Text(notes)
                                    .lineLimit(3)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

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
                    .onTapGesture {
                        navigationStackManager.navigate(to: .taskDetails(todo: todo))
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        navigationStackManager.navigate(to: .debugDashboard)
                    } label: {
                        Label("Debug Dashboard", systemImage: "list.dash")
                    }
                }
            }
            .navigationDestination(for: NavigationStackManager.Destination.self) { destination in
                switch destination {
                case .debugDashboard:
                    DebugDashboard()
                case .taskDetails(let todo):
                    Text(todo.name)
                }
            }
        }
    }

    func getColorBasedOnSentiment(_ sentiment: Double?) -> Color {
        guard let sentiment else { return .primary }

        if sentiment >= 0.5 {
            return .green
        } else if sentiment <= -0.5 {
            return .red
        } else {
            return .primary
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
