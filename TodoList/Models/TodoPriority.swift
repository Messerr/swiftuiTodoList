//
//  TodoPriority.swift
//  TodoList
//
//  Created by David Messer on 1/1/26.
//

import Foundation
import SwiftUI

enum TodoPriority: Int, Codable, CaseIterable, Identifiable {
	case low
	case medium
	case high
	
	var id: Int { rawValue }
	
	var title: String {
		switch self {
		case .low: return "!"
		case .medium: return "!!"
		case .high: return "!!!"
		}
	}
	
	var color: Color {
		switch self {
		case .low: return .secondary
		case .medium: return .orange
		case .high: return .red
		}
	}
}
