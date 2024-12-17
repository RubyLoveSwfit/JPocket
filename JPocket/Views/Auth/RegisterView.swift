import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty && 
        password == confirmPassword &&
        password.count >= 6
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        if isConfirmPasswordVisible {
                            TextField("Confirm Password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
                        }
                        
                        Button(action: { isConfirmPasswordVisible.toggle() }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    Button(action: register) {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                        } else {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(isFormValid ? Color.accentColor : Color.gray)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if !alertMessage.contains("Error") {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.errorMessage) { error in
                if let error = error {
                    alertMessage = error
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
    
    private func register() {
        guard isFormValid else { return }
        
        isLoading = true
        Task {
            await viewModel.signUp(email: email, password: password)
            await MainActor.run {
                if viewModel.errorMessage == nil {
                    dismiss()
                }
                isLoading = false
            }
        }
    }
} 