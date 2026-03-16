import Foundation

@Observable
final class AuthViewModel {
    var phoneNumber = ""
    var name = ""
    var smsCode = ""
    var adminEmail = ""
    var adminPassword = ""
    var showAdminLogin = false
    var isSubmitting = false
    var resendCooldown = 0

    private let auth = AuthService.shared
    private var cooldownTimer: Timer?

    var canSendCode: Bool {
        phoneNumber.count >= 10 && !name.isEmpty && !isSubmitting
    }

    var canVerify: Bool {
        smsCode.count == 6 && !isSubmitting
    }

    var canAdminLogin: Bool {
        !adminEmail.isEmpty && !adminPassword.isEmpty && !isSubmitting
    }

    var errorMessage: String? { auth.errorMessage }

    func sendVerificationCode() async {
        isSubmitting = true
        var formatted = phoneNumber.filter { $0.isNumber }
        if !formatted.hasPrefix("1") { formatted = "1" + formatted }
        formatted = "+" + formatted

        await auth.sendVerificationCode(phoneNumber: formatted)
        isSubmitting = false
        startResendCooldown()
    }

    func verifySMSCode() async {
        isSubmitting = true
        await auth.verifySMSCode(smsCode, name: name)
        isSubmitting = false
    }

    func signInAdmin() async {
        isSubmitting = true
        await auth.signInAdmin(email: adminEmail, password: adminPassword)
        isSubmitting = false
    }

    func resendCode() async {
        guard resendCooldown == 0 else { return }
        await sendVerificationCode()
    }

    private func startResendCooldown() {
        resendCooldown = 60
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            if self.resendCooldown > 0 {
                self.resendCooldown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
