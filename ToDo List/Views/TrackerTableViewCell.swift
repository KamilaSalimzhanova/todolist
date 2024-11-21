import UIKit

final class TrackerTableViewCell: UITableViewCell {
    static let reuseIdentifier = "trackerTableViewCell"
    
    private let circleButton = UIButton(type: .system)
    private let checkmarkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
        addSubviews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        backgroundColor = .black
        circleButton.backgroundColor = .clear
        circleButton.layer.borderColor = UIColor.gray.cgColor
        circleButton.layer.borderWidth = 2.0
        circleButton.layer.cornerRadius = 12
        circleButton.layer.masksToBounds = true

        circleButton.addTarget(self, action: #selector(circleButtonTapped), for: .touchUpInside)

        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .yellow
        checkmarkImageView.isHidden = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        circleButton.addSubview(checkmarkImageView)
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.text = "Полить цветы"
        titleLabel.textColor = .white
        
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = .white
        descriptionLabel.text = "Полить цветы в воскресенье!!!"
        descriptionLabel.numberOfLines = 2
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.text = Date().dateTimeString
        dateLabel.textColor = UIColor.rgbColors(red: 244, green: 244, blue: 244, alpha: 1)
        
        [circleButton, titleLabel, descriptionLabel, dateLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            circleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            circleButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            circleButton.widthAnchor.constraint(equalToConstant: 24),
            circleButton.heightAnchor.constraint(equalToConstant: 24),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: circleButton.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: circleButton.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 16),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: circleButton.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: circleButton.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            dateLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor)
        ])
    }
    
    @objc private func circleButtonTapped() {}
    
}

