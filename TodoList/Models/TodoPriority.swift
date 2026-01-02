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
		case .low: return "Low"
		case .medium: return "Medium"
		case .high: return "High"
		}
	}
	
	var color: Color {
		switch self {
		case .low: return .secondary
		case .medium: return .orange
		case .high: return .red
		}
	}
	
	var systemImage: String {
		switch self {
		case .low: return "arrow.down"
		case .medium: return "minus"
		case .high: return "arrow.up"
		}
	}
}
