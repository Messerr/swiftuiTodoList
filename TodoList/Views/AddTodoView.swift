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
        case notes
	}
    
    let vm: TodoListViewModel
	
    @State private var todoTitle: String = ""
    @State private var notes: String = ""
    @State private var priority: TodoPriority = .medium
    
	@State private var showDueDateAdd: Bool = false
    @State private var dueDate = Date()
    
    @FocusState private var isFocused: Field?
    @Environment(\.dismiss) private var dismiss
	
    
	var addDisabled: Bool {
		todoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || vm.errorMessage != nil
	}

    var body: some View {
        Form {
            TextField("Add Todo", text: $todoTitle)
                .focused($isFocused, equals: .todoTitle)
            
            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Notes")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $notes)
                    .frame(minHeight: 80)
                    .focused($isFocused, equals: .notes)
            }
            
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
        .navigationTitle("Add Todo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    resetForm()
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    if vm.addTodo(
                        title: todoTitle,
                        dueDate: showDueDateAdd ? dueDate : nil,
                        priority: priority,
                        notes: notes.isEmpty ? nil : notes
                    ) {
                        resetForm()
                        dismiss()
                    }
                }
                .disabled(addDisabled)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isFocused = nil
                }
            }
        }
        .onAppear {
            isFocused = .todoTitle
        }
    }
    
    private func resetForm() {
        todoTitle = ""
        notes = ""
        priority = .medium
        showDueDateAdd = false
        dueDate = Date()
        vm.clearError()
    }
}

#Preview {
    NavigationStack {
        AddTodoView(vm: TodoListViewModel())
    }
}
