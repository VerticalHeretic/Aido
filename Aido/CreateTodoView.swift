//
//  CreateTodoView.swift
//  Aido
//
//  Created by Łukasz Stachnik on 19/01/2024.
//

import SwiftUI
import SwiftData

struct CreateTodoView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var model = Model()

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Name of the task", text: $model.name)
                .background(.red.opacity(model.showMissingFields ? 1.0 : 0))

            HStack {
                Button(action: {
                    withAnimation {
                        model.isShowingDatePicker.toggle()
                    }
                }, label: {
                    if model.isShowingDatePicker {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(.red)

                    } else {
                        Image(systemName: "flag")
                            .foregroundStyle(.gray)
                    }
                })

                if model.isShowingDatePicker {
                    DatePicker(selection: $model.deadline, displayedComponents: .date) {

                    }
                }
            }

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if model.isValidForSaving() {
                        modelContext.insert(model.createTodo())
                        dismiss()
                    }
                } label: {
                    Text("Save")
                }

            }
        }
        .navigationTitle("Create Todo")
    }
}

extension CreateTodoView {

    @Observable
    class Model {
        var name: String = ""
        var deadline: Date = Date()

        var isShowingDatePicker: Bool = false
        var showMissingFields: Bool = false

        func isValidForSaving() -> Bool {
            if name.isEmpty {
                showMissingFields = true
                return false
            }

            return true
        }

        func createTodo() -> Todo {
            Todo(
                name: name,
                deadline: isShowingDatePicker ? deadline : nil
            )
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Todo.self, configurations: config)

    return NavigationStack {
        CreateTodoView()
    }
    .modelContainer(container)
}
