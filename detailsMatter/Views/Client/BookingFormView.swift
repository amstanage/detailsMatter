import SwiftUI

struct BookingFormView: View {
    @Bindable var viewModel: BookingViewModel

    var body: some View {
        Form {
            Section("Selected Slot") {
                HStack {
                    Image(systemName: "calendar")
                    Text(viewModel.selectedDate)
                    Spacer()
                    Image(systemName: "clock")
                    Text(viewModel.selectedSlot?.displayTime ?? "")
                }
                .foregroundStyle(.secondary)
            }

            Section("Services") {
                ForEach(viewModel.services) { service in
                    Button {
                        viewModel.toggleService(service.name)
                    } label: {
                        HStack {
                            Image(systemName: viewModel.selectedServiceNames.contains(service.name) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(viewModel.selectedServiceNames.contains(service.name) ? .blue : .secondary)
                            VStack(alignment: .leading) {
                                Text(service.name)
                                    .foregroundStyle(.primary)
                                Text("\(service.formattedPrice) · \(service.formattedDuration)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if !viewModel.selectedServiceNames.isEmpty {
                    HStack {
                        Text("Total")
                            .bold()
                        Spacer()
                        Text(String(format: "$%.0f", viewModel.totalPrice))
                            .bold()
                        Text("· \(viewModel.totalDuration)m")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Custom Request (Optional)") {
                TextField("Any special instructions...", text: $viewModel.customRequest, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Vehicle Information") {
                TextField("Year", text: $viewModel.vehicle.year)
                    .keyboardType(.numberPad)
                TextField("Make", text: $viewModel.vehicle.make)
                    .autocorrectionDisabled()
                TextField("Model", text: $viewModel.vehicle.model)
                    .autocorrectionDisabled()
                TextField("Color", text: $viewModel.vehicle.color)
                    .autocorrectionDisabled()
            }

            Section {
                Button {
                    viewModel.proceedToConfirm()
                } label: {
                    Text("Review Booking")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .disabled(!viewModel.canProceedToConfirm)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BookingFormView(viewModel: BookingViewModel())
    }
}
