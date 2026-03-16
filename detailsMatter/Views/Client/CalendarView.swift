import SwiftUI

struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    let onDateSelected: (String) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button { viewModel.goToPreviousMonth() } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(viewModel.monthTitle)
                    .font(.title3.bold())
                Spacer()
                Button { viewModel.goToNextMonth() } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.daysInMonth) { item in
                    if item.isPlaceholder {
                        Color.clear.frame(height: 40)
                    } else {
                        dayCell(item)
                    }
                }
            }
            .padding(.horizontal)

            if viewModel.isLoading {
                ProgressView()
            }

            Spacer()

            Text("Tap a highlighted date to see available times")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
        .task { await viewModel.loadAvailableDates() }
        .onChange(of: viewModel.currentMonth) {
            Task { await viewModel.loadAvailableDates() }
        }
    }

    private func dayCell(_ item: DayItem) -> some View {
        Button {
            if item.isAvailable && !item.isPast {
                onDateSelected(item.dateString)
            }
        } label: {
            Text("\(item.day)")
                .font(.body)
                .frame(width: 40, height: 40)
                .background(
                    item.isAvailable && !item.isPast ? Color.blue.opacity(0.2) : Color.clear,
                    in: Circle()
                )
                .foregroundStyle(
                    item.isPast ? .tertiary :
                    item.isAvailable ? .primary : .secondary
                )
        }
        .disabled(!item.isAvailable || item.isPast)
    }
}

#Preview {
    CalendarView(onDateSelected: { _ in })
}
