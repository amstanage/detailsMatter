import SwiftUI

struct AdminAppointmentDetailView: View {
    let appointment: Appointment
    let onUpdate: () -> Void
    @State private var isCompleting = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Client") {
                LabeledContent("Name", value: appointment.userName)
                LabeledContent("Phone", value: appointment.userPhone)
            }

            Section("Appointment") {
                LabeledContent("Date", value: appointment.date)
                LabeledContent("Time", value: appointment.displayTime)
                HStack {
                    Text("Status")
                    Spacer()
                    StatusBadge(status: appointment.status)
                }
            }

            Section("Services") {
                ForEach(appointment.services, id: \.self) { service in
                    ServiceTag(name: service)
                }
            }

            if let notes = appointment.customRequest, !notes.isEmpty {
                Section("Custom Request") {
                    Text(notes)
                }
            }

            Section("Vehicle") {
                VehicleInfoRow(info: appointment.vehicleInfo)
            }

            if appointment.status == .confirmed {
                Section {
                    Button {
                        Task {
                            isCompleting = true
                            let success = await FirestoreService.shared.completeAppointment(appointment.id)
                            isCompleting = false
                            if success {
                                onUpdate()
                                dismiss()
                            }
                        }
                    } label: {
                        if isCompleting {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Mark as Completed")
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                    }
                    .disabled(isCompleting)
                }
            }
        }
        .navigationTitle("Appointment")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AdminAppointmentDetailView(
            appointment: Appointment(
                userId: "u1", userName: "John Doe", userPhone: "+1234567890",
                date: "2026-03-20", timeSlot: "09:00", timeSlotId: "s1",
                services: ["Full Detail"],
                vehicle: VehicleInfo(year: "2024", make: "Tesla", model: "Model 3", color: "White")
            ),
            onUpdate: {}
        )
    }
}
