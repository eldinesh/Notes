//
//  ContentView.swift
//  Notes
//
//  Created by Dinesh Kumar on 08/11/22.
//

import SwiftUI

let dateFormatter = DateFormatter()

struct NoteItem: Codable, Hashable, Identifiable {
    let id: Int
    let text: String
    let title: String
    var date = Date()
    var dateText: String {
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }
}

struct ContentView : View {
    @State var items: [NoteItem] = {
        guard let data = UserDefaults.standard.data(forKey: "notes") else { return [] }
        if let json = try? JSONDecoder().decode([NoteItem].self, from: data) {
            return json
        }
        return []
    }()
    
    @State var taskText: String = ""
    
    @State var taskTitle: String = ""

    @State var showAlert = false
    
    @State var itemToDelete: NoteItem?
    
    var alert: Alert {
        Alert(title: Text("Hey!"),
              message: Text("Are you sure you want to delete this item?"),
              primaryButton: .destructive(Text("Delete"), action: deleteNote),
              secondaryButton: .cancel())
    }
    
    var inputView: some View {
        ZStack {
            VStack {
                TextField("Title", text: $taskTitle)
                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16))
                    .textFieldStyle(.roundedBorder)
                TextField("Description", text: $taskText, axis: .vertical)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .textFieldStyle(.roundedBorder)
                Button(action: didTapAddTask, label: { Text("Add") }).buttonStyle(.borderedProminent)
            }
        }
    }
    
    
    var body: some View {
        VStack {
            inputView
            List(items) { item in
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text(item.title).lineLimit(1).font(.headline)
                        Spacer()
                        Text(item.dateText).font(.caption2)
                    }
                    Text(item.text).lineLimit(nil).font(.caption).padding(/*@START_MENU_TOKEN@*/.top, -6.0/*@END_MENU_TOKEN@*/)
                }
                .onLongPressGesture {
                    self.itemToDelete = item
                    self.showAlert = true
                }
            }
            .alert(isPresented: $showAlert, content: {
                alert
            })
        }
    }
    
    func didTapAddTask() {
        let id = items.reduce(0) { max($0, $1.id) } + 1
        items.insert(NoteItem(id: id, text: taskText, title: taskTitle), at: 0)
        taskText = ""
        taskTitle = ""
        
        save()
    }
    
    func deleteNote() {
        guard let itemToDelete = itemToDelete else { return }
        items = items.filter { $0 != itemToDelete }
        save()
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: "notes")
    }
}
