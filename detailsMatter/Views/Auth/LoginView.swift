import SwiftUI

struct LoginView: View {
    @State private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "car.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("detailsMatter")
                    .font(.largeTitle.bold())

                Text("Book your detail appointment")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                if viewModel.showAdminLogin {
                    AdminLoginView(viewModel: viewModel)
                } else {
                    clientLoginSection
                }

                Button(viewModel.showAdminLogin ? "Client Login" : "Admin Login") {
                    viewModel.showAdminLogin.toggle()
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: .init(
                get: { AuthService.shared.verificationID != nil && !viewModel.showAdminLogin },
                set: { _ in }
            )) {
                SMSVerificationView(viewModel: viewModel)
            }
        }
    }

    private var clientLoginSection: some View {
        VStack(spacing: 16) {
            TextField("Your Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .autocorrectionDisabled()

            TextField("Phone Number", text: $viewModel.phoneNumber)
                .textFieldStyle(.roundedBorder)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await viewModel.sendVerificationCode() }
            } label: {
                if viewModel.isSubmitting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Send Verification Code")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSendCode)
        }
    }
}

#Preview {
    LoginView()
}
