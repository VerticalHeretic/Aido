//
//  CreateTodoView.swift
//  Aido
//
//  Created by Łukasz Stachnik on 19/01/2024.
//

import SwiftData
import SwiftUI

struct CreateTodoView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var model = Model()

    var body: some View {
        List {
            HStack {
                TextField("Name of the task", text: $model.name)
                    .background(.red.opacity(model.showMissingFields ? 1.0 : 0))

                Button {
                    model.notes = ""
                    model.provider.generate(prompt: "Create a action plan for given todo (simple form): \(model.name)") { response in
                        model.notes += response
                    }
                } label: {
                    Image(systemName: "text.badge.plus")
                }
            }

            if !model.notes.isEmpty {
                TextEditor(text: $model.notes)
            }

            VStack {
                Toggle(isOn: $model.isShowingDatePicker) {
                    HStack {
                        Image(systemName: "calendar")
                            .padding(4)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                            .foregroundStyle(Color.white)

                        VStack(alignment: .leading) {
                            Text("Deadline")

                            if model.isShowingDatePicker {
                                Text(model.deadline.formatted(date: .long, time: .omitted))
                                    .font(.footnote)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }

                if model.isShowingDatePicker {
                    DatePicker(selection: $model.deadline, displayedComponents: .date) {}
                        .datePickerStyle(.graphical)
                }
            }

            Spacer()
        }
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
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: model.isShowingDatePicker)
    }
}

extension CreateTodoView {
    @Observable
    class Model {
        var name: String = ""
        var deadline: Date = .init()
        var notes: String = ""

        var isShowingDatePicker: Bool = false
        var showMissingFields: Bool = false

        let provider: ModelProvider

        init(provider: ModelProvider = OllamaProvider()) {
            self.provider = provider
        }

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
                notes: notes.isEmpty ? nil : notes,
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
