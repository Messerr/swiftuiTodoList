//
//  TodoListViewModel.swift
//  TodoList
//
//  Created by David Messer on 12/30/25.
//

import Foundation
import SwiftUI

@Observable
final class TodoListViewModel {
	var todos: [Todo] = []
	var searchString: String = ""
	var errorMessage: String?

    private var directoryURL: URL {
        try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
	
	var sortMode: TodoSortMode = .manual
	
	var sections: [TodoSection] {
		TodoSection.allCases
	}
    
    private var fileURL: URL {
        directoryURL.appendingPathComponent("todos.json")
    }
	
	//MARK: - Search
	func matchesSearch(_ todo: Todo) -> Bool {
		guard !searchString.isEmpty else {
			return true
		}
		
		return todo.title.localizedCaseInsensitiveContains(searchString)
	}
	
	//MARK: - Filters
	var overDueTodos: [Todo] {
		todos
			.filter { isTopLevel($0) && isOverdue($0) && !$0.isCompleted  }
			.sorted { $0.sortOrder < $1.sortOrder }
	}
	
	var todayTodos: [Todo] {
		todos
			.filter { isTopLevel($0) && isDueToday($0) && !$0.isCompleted }
			.sorted { $0.sortOrder < $1.sortOrder }
	}
	
	var upcomingTodos: [Todo] {
		todos
			.filter { isTopLevel($0) && isUpcoming($0) && !$0.isCompleted }
			.sorted { $0.sortOrder < $1.sortOrder }
	}
	
	var completedTodos: [Todo] {
		todos
			.filter { isTopLevel($0) && isCompleted($0) }
			.sorted { $0.sortOrder < $1.sortOrder }
	}
	var todosWithNoDueDate: [Todo] {
		todos
			.filter { isTopLevel($0) && hasNoDueDate($0) }
	}
    
    init() {
        loadTodos()
    }
    
	// MARK: - CRUD functions
	func addTodo(
		title: String,
		dueDate: Date?,
		priority: TodoPriority,
		notes: String?,
		parentID: UUID?
	) -> Todo? {
		let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
		
		guard !trimmedTitle.isEmpty else {
			errorMessage = "Title cannot be empty"
			return nil
		}
		
		errorMessage = nil
		
		let newTodo = Todo(
			id: UUID(),
			title: trimmedTitle,
			dueDate: dueDate,
			isCompleted: false,
			priority: priority,
			sortOrder: todos.count,
			notes: notes,
			parentID: parentID
		)
		
		todos.append(newTodo)
		saveTodos()
		return newTodo
	}


	// Convenience wrapper
	func addTodo(
		title: String,
		dueDate: Date?,
		priority: TodoPriority,
		notes: String?
	) -> Bool {
		addTodo(
			title: title,
			dueDate: dueDate,
			priority: priority,
			notes: notes,
			parentID: nil
		) != nil
	}

	
	func deleteTodo(_ todo: Todo) {
		todos.removeAll { $0.id == todo.id }
		saveTodos()
	}

    func loadTodos() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let loadedTodos = try JSONDecoder().decode([Todo].self, from: data)
            self.todos = loadedTodos
        } catch {
            print("Cannot load todo file")
        }
    }
    
    func saveTodos() {
        do {
            let savedTodos = try JSONEncoder().encode(todos)
            try savedTodos.write(to: fileURL, options: .atomic)
        } catch {
            print("Cannot save todos")
        }
    }
    
    func toggleCompletion(for todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
			updateParentCompletionIfNeeded(for: todo)
            saveTodos()
        }
    }
	
	func clearError() {
		errorMessage = nil
	}
	
	func updateTodo(_ updatedTodo: Todo) {
		guard let index = todos.firstIndex(where: { $0.id == updatedTodo.id }) else {
			return
		}
		
		todos[index] = updatedTodo
		saveTodos()
	}
	
	func moveTodos(
		in bucket: [Todo],
		from source: IndexSet,
		to destination: Int
	) {
		var updatedBucket = bucket
		updatedBucket.move(fromOffsets: source, toOffset: destination)
		
		for (index, todo) in updatedBucket.enumerated() {
			if let mainIndex = todos.firstIndex(where: { $0.id == todo.id }) {
				todos[mainIndex].sortOrder = index
			}
		}
		
		saveTodos()
	}
    
	// MARK: - Todo Status
	func isOverdue(_ todo: Todo) -> Bool {
		guard let dueDate = todo.dueDate else {
			return false
		}
		
		let calendar = Calendar.current
		let startOfToday = calendar.startOfDay(for: Date())
		let startOfDueDate = calendar.startOfDay(for: dueDate)
		
		return startOfDueDate < startOfToday
	}
	
	func isDueToday(_ todo: Todo) -> Bool {
		guard let dueDate = todo.dueDate else {
			return false
		}
		
		let calendar = Calendar.current
		let startOfToday = calendar.startOfDay(for: Date())
		let startOfDueDate = calendar.startOfDay(for: dueDate)
		
		return startOfDueDate == startOfToday
	}
	
	func isUpcoming(_ todo: Todo) -> Bool {
		guard let dueDate = todo.dueDate else {
			return false
		}
		
		let calendar = Calendar.current
		let startOfToday = calendar.startOfDay(for: Date())
		let startOfDueDate = calendar.startOfDay(for: dueDate)
		
		return startOfDueDate > startOfToday
	}
	
	func hasNoDueDate(_ todo: Todo) -> Bool {
		todo.dueDate == nil && !todo.isCompleted
	}
	
	func isCompleted(_ todo: Todo) -> Bool {
		todo.isCompleted
	}
	
	func isTopLevel(_ todo: Todo) -> Bool {
		todo.parentID == nil
	}
	
	//MARK: - Subtasks
	func subtasks(for todo: Todo) -> [Todo] {
		todos
			.filter { $0.parentID == todo.id }
			.sorted { $0.sortOrder < $1.sortOrder }
	}
	
	func updateParentCompletionIfNeeded(for todo: Todo) {
		guard let parentID = todo.parentID else {
			return
		}
		
		guard let parentIndex = todos.firstIndex(where: { $0.id == parentID }) else {
			return
		}

		let subtasks = subtasks(for: todos[parentIndex])
		let shouldBeCompleted = !subtasks.isEmpty && subtasks.allSatisfy(isCompleted)
		if todos[parentIndex].isCompleted != shouldBeCompleted {
			todos[parentIndex].isCompleted = shouldBeCompleted
			saveTodos()
		}
	}
	
	// MARK: - Sections
	func todos(for section: TodoSection) -> [Todo] {
		let baseTodos: [Todo]
		
		switch section {
		case .overdue:
			baseTodos = todos.filter {
				isTopLevel($0) && isOverdue($0) && !$0.isCompleted
			}
		case .today:
			baseTodos = todos.filter {
				isTopLevel($0) && isDueToday($0) && !$0.isCompleted
			}
		case .upcoming:
			baseTodos = todos.filter {
				isTopLevel($0) && isUpcoming($0) && !$0.isCompleted
			}
		case .noDueDate:
			baseTodos = todos.filter {
				isTopLevel($0) && hasNoDueDate($0)
			}
		case .completed:
			baseTodos = todos.filter {
				isTopLevel($0) && isCompleted($0)
			}
		}
		
		let searchedTodos = baseTodos.filter(matchesSearch)
		return sortedTodos(searchedTodos)
	}

	func title(for section: TodoSection) -> String {
		switch section {
		case .completed:
			return "Completed"
		default:
			return section.title
		}
	}
	
	
	// MARK: - Sort
	func sortedTodos(_ todos: [Todo]) -> [Todo] {
		switch sortMode {
		case .manual:
			return todos.sorted { $0.sortOrder < $1.sortOrder }
			
		case .priority:
			return todos.sorted {
				if $0.priority != $1.priority {
					return $0.priority.rawValue > $1.priority.rawValue
				} else {
					return $0.sortOrder < $1.sortOrder
				}
			}
		}
	}
}
