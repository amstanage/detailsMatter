import Foundation
#if !DEMO_MODE
import FirebaseAuth
import FirebaseFirestore
#endif

@Observable
final class AuthService {
    static let shared = AuthService()

    var currentUser: DMUser?
    var isAuthenticated = false
    var isLoading = true
    var verificationID: String?
    var errorMessage: String?

    #if !DEMO_MODE
    private var authListener: AuthStateDidChangeListenerHandle?
    #endif

    private init() {
        #if DEMO_MODE
        isLoading = false
        #else
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        guard !isPreview else {
            isLoading = false
            return
        }
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self else { return }
            if let firebaseUser {
                Task { await self.fetchUserDoc(uid: firebaseUser.uid) }
            } else {
                self.currentUser = nil
                self.isAuthenticated = false
                self.isLoading = false
            }
        }
        #endif
    }

    // MARK: - Phone Auth (Clients)

    func sendVerificationCode(phoneNumber: String) async {
        errorMessage = nil
        #if DEMO_MODE
        try? await Task.sleep(for: .seconds(1))
        verificationID = "demo-verification-id"
        #else
        do {
            let id = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            verificationID = id
        } catch {
            errorMessage = error.localizedDescription
        }
        #endif
    }

    func verifySMSCode(_ code: String, name: String) async {
        guard verificationID != nil else {
            errorMessage = "No verification ID. Please request a new code."
            return
        }
        errorMessage = nil
        isLoading = true
        #if DEMO_MODE
        try? await Task.sleep(for: .seconds(0.5))
        var user = DemoData.clientUser
        user.name = name
        currentUser = user
        isAuthenticated = true
        isLoading = false
        #else
        do {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: code)
            let result = try await Auth.auth().signIn(with: credential)
            let uid = result.user.uid
            let phone = result.user.phoneNumber ?? ""

            let db = Firestore.firestore()
            let doc = try await db.collection("users").document(uid).getDocument()

            if doc.exists {
                if let data = doc.data(), let user = DMUser(from: data, id: uid) {
                    currentUser = user
                }
            } else {
                let user = DMUser(id: uid, phone: phone, name: name, role: "client")
                try await db.collection("users").document(uid).setData(user.toDictionary())
                currentUser = user
            }
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
        #endif
    }

    // MARK: - Email Auth (Admin)

    func signInAdmin(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        #if DEMO_MODE
        try? await Task.sleep(for: .seconds(0.5))
        currentUser = DemoData.adminUser
        isAuthenticated = true
        isLoading = false
        #else
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let uid = result.user.uid
            let db = Firestore.firestore()
            let doc = try await db.collection("users").document(uid).getDocument()

            guard let data = doc.data(),
                  let user = DMUser(from: data, id: uid),
                  user.isAdmin else {
                errorMessage = "This account is not authorized as admin."
                try Auth.auth().signOut()
                isLoading = false
                return
            }
            currentUser = user
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
        #endif
    }

    // MARK: - Session

    func signOut() {
        #if !DEMO_MODE
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
            return
        }
        #endif
        currentUser = nil
        isAuthenticated = false
        verificationID = nil
    }

    #if !DEMO_MODE
    private func fetchUserDoc(uid: String) async {
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            if let data = doc.data(), let user = DMUser(from: data, id: uid) {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    #endif
}
