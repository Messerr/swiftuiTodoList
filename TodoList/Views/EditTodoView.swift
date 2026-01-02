//
//  EditTodoView.swift
//  TodoList
//
//  Created by David Messer on 12/31/25.
//

import SwiftUI

struct EditTodoView: View {
	let vm: TodoListViewModel
	let todo: Todo
	
	@State private var title: String
	@State private var notes: String
	@State private var dueDate: Date
	@State private var hasDueDate: Bool
	@State private var showDiscardAlert: Bool = false
	@State private var isCompleted: Bool
	@State private var priority: TodoPriority
	
	@Environment(\.dismiss) private var dismiss
	
	private var saveDisabled: Bool {
		title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !hasChanges
	}
	
	private var hasChanges: Bool {
		let titleChanged = title != todo.title
		
		let dueDateChanged = hasDueDate != (todo.dueDate != nil)
		
		let dueDateValueChanged =
			hasDueDate &&
			todo.dueDate != nil &&
			dueDate != todo.dueDate
		
		let completionChanged =
		isCompleted != todo.isCompleted
		
		let priorityChanged = priority != todo.priority
		
		let notesChanged = notes != todo.notes
		
		return titleChanged || dueDateChanged || dueDateValueChanged || completionChanged || priorityChanged || notesChanged
	}

	
	init(vm: TodoListViewModel, todo: Todo) {
		self.vm = vm
		self.todo = todo
		
		_title = State(initialValue: todo.title)
		_hasDueDate = State(initialValue: todo.dueDate != nil)
		_dueDate = State(initialValue: todo.dueDate ?? Date())
		_isCompleted = State(initialValue: todo.isCompleted)
		_priority = State(initialValue: todo.priority)
		_notes = State(initialValue: todo.notes ?? "")
	}
	
	var body: some View {
		NavigationStack {
			Form {
				TextField("Title", text: $title)
				TextField("Notes", text: $notes)
				Toggle("Has Due Date", isOn: $hasDueDate)
				
				if hasDueDate {
					DatePicker(
						"Due Date",
						selection: $dueDate,
						displayedComponents: [.date]
					)
				}
				Toggle("Completed", isOn: $isCompleted)
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
			.navigationTitle("Edit Todo")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Save") {
						let updatedTodo = Todo(
							id: todo.id,
							title: title,
							dueDate: hasDueDate ? dueDate : nil,
							isCompleted: isCompleted,
							priority: priority,
							sortOrder: todo.sortOrder,
							notes: notes
						)
						vm.updateTodo(updatedTodo)
						dismiss()
					}
					.disabled(saveDisabled)
				}
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel") {
						if hasChanges {
							showDiscardAlert = true
						} else {
							dismiss()
						}
					}
				}
			}
			.alert("Discard Changes?", isPresented: $showDiscardAlert) {
				Button("Discard Changes", role: .destructive) {
					dismiss()
				}
				
				Button("Keep Editing", role: .cancel) { }
			} message: {
				Text("You have unsaved changes. Are you sure you want to discard them?")
			}
		}
	}
}

#Preview {
	let todo = Todo(
		id: UUID(),
		title: "New Todo",
		dueDate: nil,
		isCompleted: false,
		priority: .medium,
		sortOrder: 1,
		notes: "This is a note"
	)
	
	EditTodoView(vm: TodoListViewModel(), todo: todo)
}
