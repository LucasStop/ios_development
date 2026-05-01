import UIKit

final class LoginView: UIView {

    let logoImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        let image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = .systemGray2
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let tituloLabel: UILabel = {
        let label = UILabel()
        label.text = "Bem-vindo"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let userTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Usuário"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Senha"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Entrar", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray3
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) não implementado")
    }

    private func setupHierarchy() {
        addSubview(logoImageView)
        addSubview(tituloLabel)
        addSubview(userTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 80),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),

            tituloLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            tituloLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            tituloLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            userTextField.topAnchor.constraint(equalTo: tituloLabel.bottomAnchor, constant: 40),
            userTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            userTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            userTextField.heightAnchor.constraint(equalToConstant: 48),

            passwordTextField.topAnchor.constraint(equalTo: userTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: userTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: userTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),

            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: userTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: userTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    func setLoginEnabled(_ isEnabled: Bool) {
        loginButton.isEnabled = isEnabled
        UIView.animate(withDuration: 0.2) {
            self.loginButton.backgroundColor = isEnabled ? .systemBlue : .systemGray3
        }
    }
}
