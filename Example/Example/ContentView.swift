import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

struct ContentView: View {
    @Environment(ViewModel.self) private var viewModel

    var body: some View {
        NavigationSplitView {
            List {
                Section("Changes") {
                    ForEach(viewModel.changes) { change in
                        VStack(alignment: .leading) {
                            Text(String(describing: change.type))
                            Text(String(describing: change.model.name))
                                .font(.caption2)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                Section("Items") {
                    ForEach(viewModel.items) { item in
                        HStack {
                            cellHighlight(for: item)
                                .frame(width: 4)
                            Button {
                                updateItem(item)
                            } label: {
                                VStack(alignment: .leading) {
                                    if let changeType = viewModel
                                        .changes
                                        .first(where: { change in
                                            change.model == item
                                        })?
                                        .type
                                    {
                                        Text(changeType.rawValue)
                                            .bold()
                                            .font(.caption)
                                            .padding(.bottom, 4)
                                    }
                                    Text(String(describing: item.name))
                                        .font(.caption2)
                                    Text(item.timestamp, formatter: dateFormatter)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .listRowInsets(.init(.zero))
                        .listRowBackground(cellBackground(for: item))
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button(action: viewModel.deleteAll) {
                        Label("DeleteAll", systemImage: "trash")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    @ViewBuilder
    func cellHighlight(for item: Item) -> some View {
        if viewModel.changes.contains(where: { change in
            change.model == item
        }) {
            Color.red
        } else if item.name.contains("B") {
            Color.green
        } else {
            Color.gray
        }
    }

    @ViewBuilder
    func cellBackground(for item: Item) -> some View {
        if viewModel.changes.contains(where: { change in
            change.model == item
        }) {
            Color.red.opacity(0.1)
        } else if item.name.contains("B") {
            Color.gray.opacity(0.05)
        } else {
            Color.gray.opacity(0.05)
        }
    }

    private func addItem() {
        withAnimation {
            viewModel.insert()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewModel.delete(index)
            }
        }
    }

    private func updateItem(_ item: Item) {
        viewModel.updateItem(item)
    }
}
