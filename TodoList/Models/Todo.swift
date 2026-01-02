//
//  Todo.swift
//  TodoList
//
//  Created by David Messer on 12/30/25.
//

import Foundation

struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
	let dueDate: Date?
    var isCompleted: Bool
	let priority: TodoPriority
	var sortOrder: Int
}

