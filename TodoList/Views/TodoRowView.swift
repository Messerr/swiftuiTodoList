//
//  TodoRowView.swift
//  TodoList
//
//  Created by David Messer on 12/30/25.
//

import SwiftUI

struct TodoRowView: View {
	let todo: Todo
	let onToggle: (Todo) -> Void
	private var isDimmed: Bool { todo.isCompleted }
	private var isCompletedColor: Color {
		todo.isCompleted ? .green : .primary
	}
	private var dueDateText: String? {
		guard let dueDate = todo.dueDate else { return nil }
		
		let calendar = Calendar.current
		let startOfToday = calendar.startOfDay(for: Date())
		let startOfDueDate = calendar.startOfDay(for: dueDate)
		
		let dayDifference = calendar.dateComponents(
			[.day],
			from: startOfToday,
			to: startOfDueDate
		).day ?? 0
		
		switch dayDifference {
		case ..<0:
			return "Overdue"
		case 0:
			return "Due today"
		case 1:
			return "Due tomorrow"
		case 2...:
			return "Due in \(dayDifference) days"
		default:
			return nil
		}
	}
	private var dueDateColor: Color {
		guard let dueDate = todo.dueDate else { return .secondary }
		
		let calendar = Calendar.current
		let startOfToday = calendar.startOfDay(for: Date())
		let startOfDueDate = calendar.startOfDay(for: dueDate)
		
		let dayDifference = calendar.dateComponents(
			[.day],
			from: startOfToday,
			to: startOfDueDate
		).day ?? 0
		
		if dayDifference < 0 {
			return .red
		} else if dayDifference <= 1 {
			return .orange
		} else {
			return .secondary
		}
	}

    var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				Text(todo.title)
					.strikethrough(todo.isCompleted)
					.foregroundStyle(todo.isCompleted ? .secondary : .primary)
				
				HStack(spacing: 8) {
					if let dueDate = todo.dueDate {
						Text(dueDate, format: .dateTime.month().day())
							.font(.caption)
							.foregroundStyle(.secondary)
					}
					
					Label(todo.priority.title, systemImage: todo.priority.systemImage)
						.font(.caption)
						.foregroundStyle(todo.priority.color)
				}
			}
			
			Spacer()
			
			Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
				.foregroundStyle(todo.isCompleted ? .green : .secondary)
				.onTapGesture {
					onToggle(todo)
				}
		}
        .animation(.easeInOut, value: todo.isCompleted)
		.animation(.easeInOut, value: todo.dueDate)
    }
}

#Preview {
    let previewTodo = Todo(
        id: UUID(),
        title: "Hello",
		dueDate: .now,
        isCompleted: false,
		priority: .medium,
		sortOrder: 1
    )

    TodoRowView(todo: previewTodo, onToggle: { value in })
}
