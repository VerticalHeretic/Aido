//
//  TodoDetailsView.swift
//  Aido
//
//  Created by Łukasz Stachnik on 28/01/2024.
//

import SwiftData
import SwiftUI

struct TodoDetailsView: View {

    let todo: Todo

    var body: some View {
        List {
            Section("Details") {
                Text(todo.name)

                if let notes = todo.notes {
                    Text(notes)
                }

                HStack {
                    Image(systemName: "calendar")
                        .padding(4)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .foregroundStyle(Color.white)

                    if let deadline = todo.deadline {
                        Text(deadline.formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Todo.self, configurations: config)

    return TodoDetailsView(todo: .init(
        name: "Do a laundry",
        notes: """
1. Put it all in to the laundry bin
2. Put it all in to the washing machine
3. Turn it on
""",
        deadline: .distantFuture
    )).modelContainer(container)
}
