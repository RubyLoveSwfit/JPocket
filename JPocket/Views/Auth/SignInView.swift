import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isPasswordVisible = false
    @State private var showingResetPassword = false
    @State private var showingRegister = false
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
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
                }
                
                Section {
                    Button(action: signIn) {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(isFormValid ? Color.accentColor : Color.gray)
                    .disabled(!isFormValid || isLoading)
                }
                
                Section {
                    Button("Forgot Password?") {
                        showingResetPassword = true
                    }
                    .foregroundColor(.accentColor)
                    
                    Button("Create Account") {
                        showingRegister = true
                    }
                    .foregroundColor(.accentColor)
                }
            }
            .navigationTitle("Sign In")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
            .sheet(isPresented: $showingResetPassword) {
                ResetPasswordView(isPresented: $showingResetPassword)
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
                    .environmentObject(viewModel)
            }
            .onChange(of: viewModel.errorMessage) { error in
                if let error = error {
                    alertMessage = error
                    showingAlert = true
                    isLoading = false
                }
            }
            .onChange(of: viewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    dismiss()
                }
            }
        }
    }
    
    private func signIn() {
        guard isFormValid else { return }
        
        isLoading = true
        Task {
            await viewModel.signIn(email: email, password: password)
        }
    }
} 