
import UIKit

final class IntroScreenController: UIViewController {

    // MARK: - Subviews

    private let backdropView: UIView = {
        let iv = UIView()
        iv.backgroundColor = .primaryExtraDark
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emblemView: UIImageView = {
        let iv = UIImageView(image: .logo)
        iv.layer.cornerRadius = 20
        iv.clipsToBounds    = true
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        launchPulse()
    }

    // MARK: - UI Setup

    private func configureLayout() {
        view.addSubview(backdropView)
        view.addSubview(emblemView)

        let backdropSize: CGFloat = 681
        let emblemSize: CGFloat   = 183

        NSLayoutConstraint.activate([
            // Backdrop
            backdropView.widthAnchor .constraint(equalToConstant: backdropSize),
            backdropView.heightAnchor.constraint(equalToConstant: 1108),
            backdropView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backdropView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Emblem
            emblemView.widthAnchor .constraint(equalToConstant: emblemSize),
            emblemView.heightAnchor.constraint(equalToConstant: emblemSize),
            emblemView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emblemView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Animations

    private func launchPulse() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue           = 1.0
        pulse.toValue             = 1.1
        pulse.autoreverses        = true
        pulse.duration            = 1.0
        pulse.repeatCount         = .infinity
        pulse.timingFunction      = CAMediaTimingFunction(name: .easeInEaseOut)
        emblemView.layer.add(pulse, forKey: "intro-pulse")
    }
}
