import UIKit

final class LoginViewController: UIViewController {

    private var loginView: LoginView { view as! LoginView }

    override func loadView() {
        view = LoginView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        hideKeyboardOnTap()
    }

    private func setupActions() {
        loginView.userTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        loginView.passwordTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        loginView.loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    private func hideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textChanged() {
        let user = loginView.userTextField.text ?? ""
        let password = loginView.passwordTextField.text ?? ""
        let isValid = user.count >= 3 && password.count >= 6
        loginView.setLoginEnabled(isValid)
    }

    @objc private func loginTapped() {
        let user = loginView.userTextField.text ?? ""
        let alert = UIAlertController(title: "Login realizado!",
                                      message: "Bem-vindo, \(user)!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
