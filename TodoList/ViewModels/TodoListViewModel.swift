//
//  TodoListViewModel.swift
//  TodoList
//
//  Created by David Messer on 12/30/25.
//

import Foundation
import SwiftUI

@Observable
final class TodoListViewModel{
	enum TodoSection: Identifiable, CaseIterable {
		case overdue
		case today
		case upcoming
		case completed
		
		var id: Self { self }
		
		var title: String {
			switch self {
			case .overdue: return "Overdue"
			case .today: return "Today"
			case .upcoming: return "Upcoming"
			case .completed: return "Completed"
			}
		}
	}

	enum TodoSortMode {
		case manual
		case priority
	}

    var todos: [Todo] = []
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
	
	var overDueTodos: [Todo] {
			todos
			.filter { isOverdue($0) && !$0.isCompleted }
			.sorted { $0.sortOrder < $1.sortOrder }
	}
	
	var todayTodos: [Todo] {
			todos
			.filter { isDueToday($0) && !$0.isCompleted }
			.sorted { $0.sortOrder < $1.sortOrder }
	}
	
	var upcomingTodos: [Todo] {
			todos
			.filter { isUpcoming($0) && !$0.isCompleted }
			.sorted { $0.sortOrder < $1.sortOrder }
	}
	
	var completedTodos: [Todo] {
			todos
			.filter(isCompleted)
			.sorted { $0.sortOrder < $1.sortOrder }
	}
    
    init() {
        loadTodos()
    }
    
	func addTodo(title: String, dueDate: Date?, priority: TodoPriority) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
		
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Title cannot be empty"
            return false
        }
        
        errorMessage = nil
        let newTodo = Todo(
            id: UUID(),
            title: trimmedTitle,
			dueDate: dueDate,
            isCompleted: false,
			priority: priority,
			sortOrder: todos.count
        )
        todos.append(newTodo)
        saveTodos()
        return true
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
	
	func isCompleted(_ todo: Todo) -> Bool {
		todo.isCompleted
	}
	
	func todos(for section: TodoSection) -> [Todo] {
		let baseTodos: [Todo]
		
		switch section {
		case .overdue:
			baseTodos = todos.filter { isOverdue($0) && !$0.isCompleted }
		case .today:
			baseTodos = todos.filter { isDueToday($0) && !$0.isCompleted }
		case .upcoming:
			baseTodos = todos.filter { isUpcoming($0) && !$0.isCompleted }
		case .completed:
			baseTodos = todos.filter { $0.isCompleted }
		}
		
		return sortedTodos(baseTodos)
	}

	
	func title(for section: TodoSection) -> String {
		switch section {
		case .completed:
			return "Completed"
		default:
			return section.title
		}
	}
	
	func sortedTodos(_ todos: [Todo]) -> [Todo] {
		print(sortMode)
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
