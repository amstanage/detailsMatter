import SwiftUI

struct SMSVerificationView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)

            Text("Enter Verification Code")
                .font(.title2.bold())

            Text("We sent a 6-digit code to your phone")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("000000", text: $viewModel.smsCode)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title2.monospacedDigit())
                .frame(width: 200)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await viewModel.verifySMSCode() }
            } label: {
                if viewModel.isSubmitting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Verify")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canVerify)

            Button {
                Task { await viewModel.resendCode() }
            } label: {
                if viewModel.resendCooldown > 0 {
                    Text("Resend in \(viewModel.resendCooldown)s")
                } else {
                    Text("Resend Code")
                }
            }
            .disabled(viewModel.resendCooldown > 0)
            .font(.footnote)
        }
        .padding()
        .navigationTitle("Verify")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SMSVerificationView(viewModel: AuthViewModel())
    }
}
