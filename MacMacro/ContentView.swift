import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @StateObject private var recorder = Recorder()
    @State private var text: String = ""
    
    @State private var engine = Engine()

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
//            Text("Select an item")
            VStack(spacing: 20) {
                        Button("Start Recording") {
                            recorder.startRecording()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Stop Recording") {
                            recorder.stopRecording()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Play Recording") {
//                            recorder.playBack()
                            recorder.infinitePlayback()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .frame(width: 200, height: 200)
                    .padding()
                    .toolbar {
                        ToolbarItem {
                            TextField(text: $engine.targetPID) {
                                Text("PID")
                            }
                        }
                        ToolbarItem {
                            Button(action: engine.stopPlayback) {
                                Label("Stop", systemImage: "stop")
                                    .symbolVariant(engine.isPlaying ? .fill : .none)
                            }
                        }
                        ToolbarItem {
                            Button(action: engine.playbackHard) {
                                Label("Play", systemImage: "play")
                                    .symbolVariant(engine.isPlaying ? .none : .fill)
                            }
                        }
                    }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
