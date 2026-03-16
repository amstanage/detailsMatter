import SwiftUI

struct AppointmentDetailView: View {
    @State private var viewModel: AppointmentDetailViewModel
    @State private var showCancelConfirm = false

    init(appointment: Appointment) {
        _viewModel = State(initialValue: AppointmentDetailViewModel(appointment: appointment))
    }

    var body: some View {
        List {
            Section("Appointment") {
                LabeledContent("Date", value: viewModel.appointment.date)
                LabeledContent("Time", value: viewModel.appointment.displayTime)
                HStack {
                    Text("Status")
                    Spacer()
                    StatusBadge(status: viewModel.appointment.status)
                }
            }

            Section("Services") {
                ForEach(viewModel.appointment.services, id: \.self) { service in
                    ServiceTag(name: service)
                }
            }

            if let notes = viewModel.appointment.customRequest, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }

            Section("Vehicle") {
                VehicleInfoRow(info: viewModel.appointment.vehicleInfo)
            }

            if viewModel.canCancel {
                Section {
                    Button("Cancel Appointment", role: .destructive) {
                        showCancelConfirm = true
                    }
                    .disabled(viewModel.isCancelling)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Appointment Details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Cancel this appointment?", isPresented: $showCancelConfirm, titleVisibility: .visible) {
            Button("Cancel Appointment", role: .destructive) {
                Task { await viewModel.cancelAppointment() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppointmentDetailView(appointment: Appointment(
            userId: "u1", userName: "John", userPhone: "+1234567890",
            date: "2026-03-20", timeSlot: "09:00", timeSlotId: "s1",
            services: ["Full Detail", "Ceramic Coating"],
            vehicle: VehicleInfo(year: "2024", make: "BMW", model: "M3", color: "Black")
        ))
    }
}
