//
//  CreateTodoView.swift
//  Aido
//
//  Created by Łukasz Stachnik on 19/01/2024.
//

import NaturalLanguage
import OSLog
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
                    model.provider.generate(prompt: "\(model.name)") { response in
                        model.notes += response
                    }
                } label: {
                    Image(systemName: "text.badge.plus")
                }
                .disabled(model.name.isEmpty)
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
                        Task {
                            let todo = await model.createTodo()
                            modelContext.insert(todo)
                            dismiss()
                        }
                    }
                } label: {
                    Text("Save")
                }
            }

            ToolbarItem(placement: .topBarLeading) {
                if let data = model.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                } else {
                    Button(action: {
                        Task {
                            await model.generateTodoImage()
                        }
                    }, label: {
                        Label("Create Icon", systemImage: "photo.artframe")
                    })
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
        var imageData: Data?

        var isShowingDatePicker: Bool = false
        var showMissingFields: Bool = false

        let provider: TextToTextModelProvider
        let imageProvider: GPTTextToImageProvider

        init(
            provider: TextToTextModelProvider = AppConfiguration.shared.modelProvider,
            imageProvider: GPTTextToImageProvider = .init()
        ) {
            self.provider = provider
            self.imageProvider = imageProvider
        }

        func isValidForSaving() -> Bool {
            if name.isEmpty {
                showMissingFields = true
                return false
            }

            return true
        }

        func createTodo() async -> Todo {
            await Todo(
                name: name,
                notes: notes.isEmpty ? nil : notes,
                deadline: isShowingDatePicker ? deadline : nil,
                sentiment: retrieveSentiment(for: name),
                imageData: imageData
            )
        }

        func generateTodoImage() async {
            guard !name.isEmpty else {
                showMissingFields = true
                return
            }

            guard let imageData = await imageProvider.generate(prompt: name) else { return }
            self.imageData = imageData
        }

        private func retrieveSentiment(for text: String) async -> Double {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = text
            let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
            let score = Double(sentiment?.rawValue ?? "0") ?? 0
            Logger.general.debug("Sentiment score for text: \(text, privacy: .private), score: \(score)")
            return score
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
