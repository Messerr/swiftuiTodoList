//
//  ContentView.swift
//  TodoList
//
//  Created by David Messer on 12/30/25.
//

import SwiftUI

struct ContentView: View {
    @State private var todoVM = TodoListViewModel()
    
    var body: some View {
        NavigationStack {
            TodoListView(vm: todoVM)
        }
    }
}
