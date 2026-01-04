//
//  Todo.swift
//  TodoList
//
//  Created by David Messer on 12/30/25.
//

import Foundation

struct Todo: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let title: String
	let dueDate: Date?
    var isCompleted: Bool
	let priority: TodoPriority
	var sortOrder: Int
	let notes: String?
    let parentID: UUID?
	
	enum CodingKeys: String, CodingKey {
		case id, title, dueDate, isCompleted, priority, sortOrder, notes, parentID
	}
	
	init(
		id: UUID,
		title: String,
		dueDate: Date?,
		isCompleted: Bool,
		priority: TodoPriority,
		sortOrder: Int,
		notes: String?,
        parentID: UUID?
	) {
		self.id = id
		self.title = title
		self.dueDate = dueDate
		self.isCompleted = isCompleted
		self.priority = priority
		self.sortOrder = sortOrder
		self.notes = notes
        self.parentID = parentID
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		id = try container.decode(UUID.self, forKey: .id)
		title = try container.decode(String.self, forKey: .title)
		dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
		isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
		priority = try container.decodeIfPresent(TodoPriority.self, forKey: .priority) ?? .medium
		sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
		notes = try container.decodeIfPresent(String.self, forKey: .notes)
        parentID = try container.decodeIfPresent(UUID.self, forKey: .parentID)
	}
}

