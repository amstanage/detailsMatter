import SwiftUI

struct AdminDashboardView: View {
    @State private var viewModel = AdminDashboardViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                List {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    }

                    ForEach(viewModel.groupedByDate, id: \.0) { date, appointments in
                        Section(date) {
                            ForEach(appointments) { appt in
                                NavigationLink(value: appt.id) {
                                    AdminAppointmentRow(appointment: appt)
                                }
                            }
                        }
                    }

                    if !viewModel.isLoading && viewModel.filteredAppointments.isEmpty {
                        ContentUnavailableView("No Appointments", systemImage: "calendar",
                                               description: Text("No appointments match your filter."))
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: "slotManager") {
                        Image(systemName: "clock.badge.plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        AuthService.shared.signOut()
                    }
                    .font(.footnote)
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "slotManager" {
                    AdminSlotManagerView()
                } else {
                    if let appt = viewModel.appointments.first(where: { $0.id == value }) {
                        AdminAppointmentDetailView(appointment: appt) {
                            Task { await viewModel.loadAppointments() }
                        }
                    }
                }
            }
            .task {
                await viewModel.seedServicesIfNeeded()
                await viewModel.loadAppointments()
            }
            .refreshable {
                await viewModel.loadAppointments()
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppointmentFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.filter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.filter == filter ? Color.blue : Color.gray.opacity(0.2),
                                        in: Capsule())
                            .foregroundStyle(viewModel.filter == filter ? .white : .primary)
                    }
                }

                if !viewModel.filterDate.isEmpty {
                    Button {
                        viewModel.clearDateFilter()
                    } label: {
                        Label(viewModel.filterDate, systemImage: "xmark.circle.fill")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.2), in: Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct AdminAppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(appointment.displayTime)
                    .font(.headline)
                Spacer()
                StatusBadge(status: appointment.status)
            }
            Text(appointment.userName)
                .font(.subheadline)
            Text(appointment.services.joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            if !appointment.vehicleDisplayString.isEmpty {
                Text(appointment.vehicleDisplayString)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    AdminDashboardView()
}
