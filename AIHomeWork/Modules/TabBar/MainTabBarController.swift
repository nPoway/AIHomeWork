import UIKit

class MainTabBarController: UITabBarController {
    
    private let customTabBarView = BlurredGradientView()
    private let centralButton = UIButton()
    
    private let homeButton = UIButton()
    private let historyButton = UIButton()
    
    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var coordinator: TabBarCoordinator
    
    init(coordinator: TabBarCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        
        setupCustomTabBar()
        selectedIndex = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTabButtonSelection()
    }
    
    func setupViewControllers(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        self.selectedIndex = 0
        updateTabButtonSelection()
    }

    private func setupCustomTabBar() {
        customTabBarView.clipsToBounds = false
        
        view.addSubview(customTabBarView)
        view.addSubview(bottomLine)
        customTabBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBarView.heightAnchor.constraint(equalToConstant: 90),
            bottomLine.leadingAnchor.constraint(equalTo: customTabBarView.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: customTabBarView.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: customTabBarView.topAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])
        setupCentralButton()
        setupTabButtons()
    }

    private func setupCentralButton() {
        let size: CGFloat = 60
        
        centralButton.backgroundColor = .clear
        let image = UIImage(named: "scanButtonImage")
        centralButton.setImage(image, for: .normal)
        centralButton.imageView?.contentMode = .scaleAspectFit
        
        centralButton.frame.size = CGSize(width: size, height: size)
        centralButton.layer.cornerRadius = size / 2
        centralButton.clipsToBounds = false
        
        view.addSubview(centralButton)
        centralButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            centralButton.centerXAnchor.constraint(equalTo: customTabBarView.centerXAnchor),
            centralButton.centerYAnchor.constraint(equalTo: customTabBarView.centerYAnchor, constant: -5),
            centralButton.widthAnchor.constraint(equalToConstant: size),
            centralButton.heightAnchor.constraint(equalToConstant: size)
        ])
        
        centralButton.addTarget(self, action: #selector(centralButtonTapped), for: .touchUpInside)
    }
    
    private func setupTabButtons() {
        configureTabButton(button: homeButton, tag: 0)
        configureTabButton(button: historyButton, tag: 1)
        
        [homeButton, historyButton].forEach {
            customTabBarView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            homeButton.leadingAnchor.constraint(equalTo: customTabBarView.leadingAnchor, constant: 50),
            homeButton.centerYAnchor.constraint(equalTo: customTabBarView.centerYAnchor),
            homeButton.widthAnchor.constraint(equalToConstant: 50),
            homeButton.heightAnchor.constraint(equalToConstant: 50),
            
            historyButton.trailingAnchor.constraint(equalTo: customTabBarView.trailingAnchor, constant: -50),
            historyButton.centerYAnchor.constraint(equalTo: customTabBarView.centerYAnchor),
            historyButton.widthAnchor.constraint(equalToConstant: 50),
            historyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureTabButton(button: UIButton, tag: Int) {
        button.tag = tag
        if tag == 0 {
            let image = UIImage(named: "homeImage")
            let selectedImage = UIImage(named: "homeImageSelected")
            button.setImage(image, for: .normal)
            button.setImage(selectedImage, for: .selected)
        }
        else {
            let image = UIImage(named: "historyImage")
            let selectedImage = UIImage(named: "historyImageSelected")
            button.setImage(image, for: .normal)
            button.setImage(selectedImage, for: .selected)
        }
        
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
    }

    private func updateTabButtonSelection() {
        homeButton.isSelected = (selectedIndex == 0)
        historyButton.isSelected = (selectedIndex == 1)
    }
    
    @objc private func centralButtonTapped() {
        coordinator.pushScanViewController()
    }
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateTabButtonSelection()
    }
}
