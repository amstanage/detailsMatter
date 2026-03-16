import SwiftUI

struct StatusBadge: View {
    let status: AppointmentStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(backgroundColor.opacity(0.15), in: Capsule())
            .foregroundStyle(backgroundColor)
    }

    private var backgroundColor: Color {
        switch status {
        case .confirmed: .blue
        case .completed: .green
        case .cancelled: .red
        }
    }
}

struct ServiceTag: View {
    let name: String

    var body: some View {
        HStack {
            Image(systemName: "wrench.and.screwdriver")
                .font(.caption)
                .foregroundStyle(.blue)
            Text(name)
        }
    }
}

struct VehicleInfoRow: View {
    let info: VehicleInfo

    var body: some View {
        HStack {
            Image(systemName: "car.fill")
                .foregroundStyle(.secondary)
            if info.isComplete {
                Text(info.displayString)
            } else {
                Text("No vehicle info")
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                Text(message)
                    .font(.subheadline)
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview("StatusBadge") {
    VStack(spacing: 8) {
        StatusBadge(status: .confirmed)
        StatusBadge(status: .completed)
        StatusBadge(status: .cancelled)
    }
}

#Preview("ServiceTag") {
    ServiceTag(name: "Full Detail")
}
