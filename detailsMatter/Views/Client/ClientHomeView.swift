import SwiftUI

struct ClientHomeView: View {
    @State private var viewModel = ClientHomeViewModel()
    @State private var showBooking = false
    let user: DMUser

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                }

                if !viewModel.upcomingAppointments.isEmpty {
                    Section("Upcoming") {
                        ForEach(viewModel.upcomingAppointments) { appt in
                            NavigationLink(value: appt.id) {
                                AppointmentRow(appointment: appt)
                            }
                        }
                    }
                }

                if !viewModel.pastAppointments.isEmpty {
                    Section("Past") {
                        ForEach(viewModel.pastAppointments) { appt in
                            NavigationLink(value: appt.id) {
                                AppointmentRow(appointment: appt)
                            }
                        }
                    }
                }

                if !viewModel.isLoading && viewModel.upcomingAppointments.isEmpty && viewModel.pastAppointments.isEmpty {
                    ContentUnavailableView("No Appointments", systemImage: "calendar.badge.plus",
                                           description: Text("Book your first detail appointment!"))
                    .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("My Appointments")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBooking = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        AuthService.shared.signOut()
                    }
                    .font(.footnote)
                }
            }
            .navigationDestination(for: String.self) { apptId in
                if let appt = findAppointment(apptId) {
                    AppointmentDetailView(appointment: appt)
                }
            }
            .sheet(isPresented: $showBooking) {
                BookingFlow(user: user)
            }
            .task {
                await viewModel.loadAppointments(for: user.id)
            }
            .refreshable {
                await viewModel.loadAppointments(for: user.id)
            }
        }
    }

    private func findAppointment(_ id: String) -> Appointment? {
        viewModel.upcomingAppointments.first { $0.id == id } ??
        viewModel.pastAppointments.first { $0.id == id }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(appointment.date)
                    .font(.headline)
                Spacer()
                StatusBadge(status: appointment.status)
            }
            Text(appointment.displayTime)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(appointment.services.joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }
}

struct BookingFlow: View {
    @State private var viewModel = BookingViewModel()
    @Environment(\.dismiss) private var dismiss
    let user: DMUser

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.step {
                case .selectDate:
                    CalendarView(onDateSelected: { viewModel.selectDate($0) })
                case .selectTime:
                    TimeSlotPickerView(
                        slots: viewModel.availableSlots,
                        isLoading: viewModel.isLoading,
                        onSelect: { viewModel.selectSlot($0) }
                    )
                case .details:
                    BookingFormView(viewModel: viewModel)
                case .confirm:
                    BookingConfirmView(viewModel: viewModel, user: user, onDismiss: { dismiss() })
                }
            }
            .navigationTitle("Book Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.step == .selectDate {
                        Button("Cancel") { dismiss() }
                    } else {
                        Button("Back") { viewModel.goBack() }
                    }
                }
            }
            .task { await viewModel.loadServices() }
        }
    }
}

struct BookingConfirmView: View {
    @Bindable var viewModel: BookingViewModel
    let user: DMUser
    let onDismiss: () -> Void

    var body: some View {
        if let appointment = viewModel.bookedAppointment {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                Text("Booking Confirmed!")
                    .font(.title2.bold())
                Text("\(appointment.date) at \(appointment.displayTime)")
                    .foregroundStyle(.secondary)
                Button("Done") { onDismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SummarySection(title: "Date & Time", icon: "calendar") {
                        Text("\(viewModel.selectedDate) at \(viewModel.selectedSlot?.displayTime ?? "")")
                    }

                    SummarySection(title: "Services", icon: "wrench.and.screwdriver") {
                        ForEach(viewModel.selectedServices) { service in
                            HStack {
                                Text(service.name)
                                Spacer()
                                Text(service.formattedPrice)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Divider()
                        HStack {
                            Text("Total").bold()
                            Spacer()
                            Text(String(format: "$%.0f", viewModel.totalPrice)).bold()
                        }
                    }

                    SummarySection(title: "Vehicle", icon: "car") {
                        Text(viewModel.vehicle.displayString)
                    }

                    if !viewModel.customRequest.isEmpty {
                        SummarySection(title: "Notes", icon: "note.text") {
                            Text(viewModel.customRequest)
                        }
                    }

                    if let error = viewModel.bookingError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task {
                            await viewModel.book(userId: user.id, userName: user.name, userPhone: user.phone)
                        }
                    } label: {
                        if viewModel.isBooking {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Confirm Booking").frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isBooking)
                }
                .padding()
            }
        }
    }
}

struct SummarySection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ClientHomeView(user: DMUser(id: "test", phone: "+1234567890", name: "Test User"))
}
