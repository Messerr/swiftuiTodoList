//
//  AddTodoView.swift
//  TodoList
//
//  Created by David Messer on 12/30/25.
//

import Foundation
import SwiftUI

struct AddTodoView: View {
	enum Field: Hashable {
		case todoTitle
	}
    let vm: TodoListViewModel
	@State private var dueDate = Date()
    @State private var todoTitle: String = ""
	@State private var showDueDateAdd: Bool = false
	@State private var priority: TodoPriority = .medium
	@State private var notes: String = ""
    @Environment(\.dismiss) private var dismissAdd
	@FocusState private var isFocused: Field?
	var addDisabled: Bool {
		todoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

    var body: some View {
        NavigationStack {
            Form {
                TextField("Add Todo", text: $todoTitle)
					.focused($isFocused, equals: .todoTitle)
				TextField("Notes", text: $notes)
                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
				Toggle("Add Due Date", isOn: $showDueDateAdd)
				if showDueDateAdd {
					DatePicker(
						"Due Date",
						selection: $dueDate,
						displayedComponents: [.date]
					)
					.transition(.opacity.combined(with: .move(edge: .top)))
				}
				Section("Priority") {
					Picker("Priority", selection: $priority) {
						ForEach(TodoPriority.allCases) { priority in
							Text(priority.title)
								.tag(priority)
						}
					}
					.pickerStyle(.segmented)
				}
            }
			.animation(.easeInOut, value: showDueDateAdd)
			.onAppear {
				isFocused = .todoTitle
			}
            .navigationTitle("Add Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        if vm.addTodo(
							title: todoTitle,
							dueDate: showDueDateAdd ? dueDate : nil,
							priority: priority,
							notes: notes
						) {
                            dismissAdd()
                        }
                    }
					.disabled(addDisabled)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
						vm.clearError()
                        dismissAdd()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddTodoView(vm: TodoListViewModel())
    }
}
