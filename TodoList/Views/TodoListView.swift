//
//  TodoListView.swift
//  TodoList
//
//  Created by David Messer on 12/30/25.
//

import Foundation
import SwiftUI

struct TodoListView: View {
	@State private var isAddShowing: Bool = false
	@State private var isCompletedExpanded = false
	let vm: TodoListViewModel
	
	var body: some View {
		List {
			ForEach(vm.sections) { section in
				let todos = vm.todos(for: section)
				
				if section == .completed {
					Section {
						DisclosureGroup(
							isExpanded: $isCompletedExpanded
						) {
							if !todos.isEmpty {
								todoRows(for: todos)
							} else {
								Text("No completed tasks")
									.foregroundStyle(.secondary)
									.font(.caption)
							}
						} label: {
							HStack {
								Label("Completed", systemImage: "checkmark.circle")
								Spacer()
							}
							.contentShape(Rectangle()) // tap anywhere
						}
					}
				} else {
					if !todos.isEmpty {
						Section(section.title) {
							todoRows(for: todos)
						}
					}
				}
			}
		}
		.navigationTitle("Todos")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					isAddShowing = true
				} label: {
					Image(systemName: "plus")
				}
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					vm.sortMode = vm.sortMode == .manual ? .priority : .manual
				} label: {
					Image(systemName: vm.sortMode == .priority
						  ? "line.3.horizontal.decrease.circle.fill"
						  : "line.3.horizontal.decrease.circle")
				}
			}
		}
		.sheet(isPresented: $isAddShowing) {
			AddTodoView(vm: vm)
		}
	}

	
	@ViewBuilder
	private func todoRows(for todos: [Todo]) -> some View {
		ForEach(todos) { todo in
			NavigationLink {
				EditTodoView(vm: vm, todo: todo)
			} label: {
				TodoRowView(
					todo: todo,
					onToggle: vm.toggleCompletion
				)
			}
		}
		.onDelete { offsets in
			let toDelete = offsets.map { todos[$0] }
			toDelete.forEach(vm.deleteTodo)
		}
	}
}


#Preview {
    NavigationStack {
        TodoListView(vm: TodoListViewModel())
    }
}
