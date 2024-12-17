import SwiftUI
import FirebaseAuth

struct ResetPasswordView: View {
    @EnvironmentObject var viewModel: AccountViewModel
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.largeTitle)
                    .bold()
                
                Text("Enter your email address and we'll send you instructions to reset your password.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                
                Button(action: resetPassword) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Send Reset Link")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .disabled(email.isEmpty || isLoading)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            })
            .alert(alertMessage, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if !alertMessage.contains("Error") {
                        isPresented = false
                    }
                }
            }
            .onChange(of: viewModel.errorMessage) { error in
                if let error = error {
                    alertMessage = error
                    showingAlert = true
                }
            }
            .onAppear {
                if let userEmail = viewModel.user?.email {
                    email = userEmail
                }
            }
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else { return }
        
        isLoading = true
        Task {
            await viewModel.resetPassword(email: email)
            await MainActor.run {
                if viewModel.errorMessage == nil {
                    alertMessage = "Password reset instructions have been sent to your email."
                    showingAlert = true
                }
                isLoading = false
            }
        }
    }
} 