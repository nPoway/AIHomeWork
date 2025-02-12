import UIKit

protocol LanguageSelectionDelegate: AnyObject {
    func didSelectLanguage(_ language: Language)
}

final class LanguageSelectionViewController: UIViewController {
    
    weak var delegate: LanguageSelectionDelegate?
    
    private let languages = Language.supportedLanguages
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(LanguageCell.self, forCellReuseIdentifier: LanguageCell.identifier)
        return tableView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Language"
        label.textColor = .white
        label.font = UIFont.plusJakartaSans(.semiBold, size: 22)
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let image = UIImage.customXmark
        button.setImage(image, for: .normal)
        return button
    }()
    
    override func loadView() {
        view = BlurredGradientView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(closeButton)
        view.addSubview(bottomLine)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            bottomLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    @objc private func dismissView() {
        dismiss(animated: true)
    }
}

extension LanguageSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageCell.identifier, for: indexPath) as! LanguageCell
        let language = languages[indexPath.row]
        cell.configure(with: language)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = languages[indexPath.row]
        delegate?.didSelectLanguage(selectedLanguage)
        dismiss(animated: true)
    }
}
