import SwiftUI

struct AdminSlotManagerView: View {
    @State private var viewModel = AdminSlotsViewModel()

    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }

            Section("Quick Add") {
                HStack(spacing: 12) {
                    Button("Morning Set") {
                        Task { await viewModel.addMorningSet() }
                    }
                    .buttonStyle(.bordered)

                    Button("Afternoon Set") {
                        Task { await viewModel.addAfternoonSet() }
                    }
                    .buttonStyle(.bordered)
                }

                HStack {
                    TextField("Time (HH:mm)", text: $viewModel.newTime)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                    Button("Add Slot") {
                        Task { await viewModel.addSlot() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }

            if !viewModel.availableSlots.isEmpty {
                Section("Available Slots") {
                    ForEach(viewModel.availableSlots) { slot in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(.green)
                            Text(slot.displayTime)
                            Spacer()
                            Text("Open")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    .onDelete { offsets in
                        let slotsToDelete = offsets.map { viewModel.availableSlots[$0] }
                        Task {
                            for slot in slotsToDelete {
                                await viewModel.removeSlot(slot)
                            }
                        }
                    }
                }
            }

            if !viewModel.bookedSlots.isEmpty {
                Section("Booked Slots") {
                    ForEach(viewModel.bookedSlots) { slot in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.red)
                            Text(slot.displayTime)
                            Spacer()
                            Text("Booked")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            if !viewModel.isLoading && viewModel.slots.isEmpty {
                ContentUnavailableView("No Slots", systemImage: "clock",
                                       description: Text("Add time slots for \(viewModel.dateString)"))
                .listRowSeparator(.hidden)
            }
        }
        .navigationTitle("Manage Slots")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadSlots() }
        .onChange(of: viewModel.selectedDate) {
            Task { await viewModel.loadSlots() }
        }
    }
}

#Preview {
    NavigationStack {
        AdminSlotManagerView()
    }
}
