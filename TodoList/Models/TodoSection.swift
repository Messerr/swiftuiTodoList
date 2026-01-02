//
//  TodoSection.swift
//  TodoList
//
//  Created by David Messer on 1/2/26.
//

import Foundation

enum TodoSection: Identifiable, CaseIterable {
	case overdue
	case today
	case upcoming
	case noDueDate
	case completed
	
	var id: Self { self }
	
	var title: String {
		switch self {
		case .overdue: return "Overdue"
		case .today: return "Today"
		case .upcoming: return "Upcoming"
		case .noDueDate: return "No Due Date"
		case .completed: return "Completed"
		}
	}
}
