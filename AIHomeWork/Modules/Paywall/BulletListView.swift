import UIKit

// MARK: – Bullet list component
final class BulletListView: UIStackView {

    private let bulletColor = UIColor("#3577F2")

    init(lines: [String], font: UIFont = .systemFont(ofSize: 17, weight: .regular)) {
        super.init(frame: .zero)
        axis         = .vertical
        spacing      = 10
        alignment    = .leading
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false

        lines.forEach { addArrangedSubview(makeLine(text: $0, font: font)) }
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: – Private helpers

    private func makeLine(text: String, font: UIFont) -> UIView {
        let bullet = UIView()
        bullet.translatesAutoresizingMaskIntoConstraints = false
        bullet.backgroundColor = bulletColor
        bullet.layer.cornerRadius = 3   
        NSLayoutConstraint.activate([
            bullet.widthAnchor .constraint(equalToConstant: 6),
            bullet.heightAnchor.constraint(equalToConstant: 6)
        ])

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor("#F6F8FE")?.withAlphaComponent(0.75)
        label.font      = font
        label.numberOfLines = 0
        label.text = text

        let line = UIStackView(arrangedSubviews: [bullet, label])
        line.axis      = .horizontal
        line.alignment = .center
        line.spacing   = 16
        return line
    }
}
