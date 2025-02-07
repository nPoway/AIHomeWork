//
//  CustomTabBarController.swift
//  AIHomeWork
//
//  Created by Никита on 04.02.2025.
//


import UIKit

class MainTabBarController: UITabBarController {
    
    private let customTabBarView = UIView()
    private let centralButton = UIButton()
  
    private let targetButton = UIButton()
    private let megaphoneButton = UIButton()
    private let firewoodButton = UIButton()
    private let trophyButton = UIButton()
   
    var coordinator: TabBarCoordinator
    
    init(coordinator: TabBarCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        
        setupCustomTabBar()
        selectedIndex = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTabButtonSelection()
    }
    
    func setupViewControllers(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        self.selectedIndex = 4
        updateTabButtonSelection()
    }

    // MARK: - Setup Custom Tab Bar
    
    private func setupCustomTabBar() {
        customTabBarView.clipsToBounds = false
        
        view.addSubview(customTabBarView)
        customTabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBarView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        customTabBarView.backgroundColor = .black
        customTabBarView.layer.shadowColor = UIColor.orange.cgColor
        customTabBarView.layer.shadowOffset = .zero
        customTabBarView.layer.shadowOpacity = 0.6
        customTabBarView.layer.shadowRadius = 10
        
        setupCentralButton()
        setupTabButtons()
    }

    private func setupCentralButton() {
        let size: CGFloat = 110
        
        centralButton.backgroundColor = .clear
        centralButton.setImage(UIImage(named: "treeLogo"), for: .normal)
        centralButton.imageView?.contentMode = .scaleAspectFit
        
        centralButton.frame.size = CGSize(width: size, height: size)
        centralButton.layer.cornerRadius = size / 2
        centralButton.clipsToBounds = false
        
        view.addSubview(centralButton)
        centralButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            centralButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centralButton.centerYAnchor.constraint(equalTo: customTabBarView.topAnchor, constant: 15),
            centralButton.widthAnchor.constraint(equalToConstant: size),
            centralButton.heightAnchor.constraint(equalToConstant: size)
        ])
        
        centralButton.addTarget(self, action: #selector(centralButtonTapped), for: .touchUpInside)
    }
    
    
    private func setupTabButtons() {
        configureTabButton(button: targetButton,
                           tag: 0,
                           normalImage: UIImage(named: "target"),
                           selectedImage: UIImage(named: "target_tinted"))
        
        configureTabButton(button: megaphoneButton,
                           tag: 1,
                           normalImage: UIImage(named: "megaphone"),
                           selectedImage: UIImage(named: "megaphone_tinted"))
        
        configureTabButton(button: firewoodButton,
                           tag: 2,
                           normalImage: UIImage(named: "bonfire"),
                           selectedImage: UIImage(named: "bonfire_tinted"))
        
        configureTabButton(button: trophyButton,
                           tag: 3,
                           normalImage: UIImage(named: "achivement"),
                           selectedImage: UIImage(named: "achivement_tinted"))
        
        [targetButton, megaphoneButton, firewoodButton, trophyButton].forEach {
            customTabBarView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            targetButton.leadingAnchor.constraint(equalTo: customTabBarView.leadingAnchor, constant: 20),
            targetButton.centerYAnchor.constraint(equalTo: customTabBarView.centerYAnchor),
            targetButton.widthAnchor.constraint(equalToConstant: 45),
            targetButton.heightAnchor.constraint(equalToConstant: 45),
            
            megaphoneButton.leadingAnchor.constraint(equalTo: targetButton.trailingAnchor, constant: 30),
            megaphoneButton.centerYAnchor.constraint(equalTo: targetButton.centerYAnchor),
            megaphoneButton.widthAnchor.constraint(equalToConstant: 45),
            megaphoneButton.heightAnchor.constraint(equalToConstant: 45),
            
            trophyButton.trailingAnchor.constraint(equalTo: customTabBarView.trailingAnchor, constant: -20),
            trophyButton.centerYAnchor.constraint(equalTo: customTabBarView.centerYAnchor),
            trophyButton.widthAnchor.constraint(equalToConstant: 45),
            trophyButton.heightAnchor.constraint(equalToConstant: 45),
            
            firewoodButton.trailingAnchor.constraint(equalTo: trophyButton.leadingAnchor, constant: -30),
            firewoodButton.centerYAnchor.constraint(equalTo: trophyButton.centerYAnchor),
            firewoodButton.widthAnchor.constraint(equalToConstant: 45),
            firewoodButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func configureTabButton(button: UIButton,
                                    tag: Int,
                                    normalImage: UIImage?,
                                    selectedImage: UIImage?) {
        button.tag = tag
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.imageView?.contentMode = .scaleAspectFit
        
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
    }

   
    private func updateTabButtonSelection() {
        targetButton.isSelected   = (selectedIndex == 0)
        megaphoneButton.isSelected = (selectedIndex == 1)
        firewoodButton.isSelected  = (selectedIndex == 2)
        trophyButton.isSelected    = (selectedIndex == 3)
    }

    // MARK: - Actions
    
    @objc private func centralButtonTapped() {
        selectedIndex = 4
        updateTabButtonSelection()
    }
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateTabButtonSelection()
    }
}
