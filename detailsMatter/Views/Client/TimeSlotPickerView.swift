import SwiftUI

struct TimeSlotPickerView: View {
    let slots: [TimeSlot]
    let isLoading: Bool
    let onSelect: (TimeSlot) -> Void

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                Spacer()
                ProgressView("Loading times...")
                Spacer()
            } else if slots.isEmpty {
                Spacer()
                ContentUnavailableView("No Times Available",
                                       systemImage: "clock.badge.xmark",
                                       description: Text("No open slots for this date. Try another day."))
                Spacer()
            } else {
                Text("Select a Time")
                    .font(.headline)
                    .padding(.top)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(slots) { slot in
                        Button {
                            onSelect(slot)
                        } label: {
                            Text(slot.displayTime)
                                .font(.body.bold())
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}

#Preview {
    TimeSlotPickerView(
        slots: [
            TimeSlot(date: "2026-03-20", time: "09:00"),
            TimeSlot(date: "2026-03-20", time: "10:00"),
            TimeSlot(date: "2026-03-20", time: "11:00"),
        ],
        isLoading: false,
        onSelect: { _ in }
    )
}
