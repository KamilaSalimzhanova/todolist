import UIKit

protocol ToDoTableViewCellProtocol: AnyObject {
    func updateTracker(id: UUID, toDo: ToDo)
    func updateTable()
    func handleEditAction(indexPath: IndexPath)
    func handleShareAction(indexPath: IndexPath)
    func handleDeleteAction(indexPath: IndexPath)
}

final class ToDoTableViewCell: UITableViewCell {
    static let reuseIdentifier = "trackerTableViewCell"
    
    weak var delegate: ToDoTableViewCellProtocol?
    
    private let circleButton = UIButton(type: .system)
    private let checkmarkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    
    var id: UUID?
    var indexPath: IndexPath?
    var isCompleted: Bool?
    var title: String?
    var descriptionString: String?
    var createdAt: Date?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
        let contextMenu = UIContextMenuInteraction(delegate: self)
        self.addInteraction(contextMenu)
        addSubviews()
        makeConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with task: ToDo, indexPath: IndexPath) {
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        dateLabel.text = task.createdAt.dateTimeString
        self.id = task.id
        self.indexPath = indexPath
        self.isCompleted = task.isCompleted
        self.title = task.title
        self.descriptionString = task.description
        self.createdAt = task.createdAt
        
        if task.isCompleted {
            checkmarkImageView.isHidden = false
            circleButton.layer.borderColor = UIColor.yellow.cgColor
            titleLabel.attributedText = NSAttributedString(
                string: task.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.rgbColors(red: 244, green: 244, blue: 244, alpha: 1)
                ]
            )
            titleLabel.textColor = UIColor.rgbColors(red: 244, green: 244, blue: 244, alpha: 1)
            descriptionLabel.textColor =  UIColor.rgbColors(red: 244, green: 244, blue: 244, alpha: 1)
        } else {
            checkmarkImageView.isHidden = true
            circleButton.layer.borderColor = UIColor.white.cgColor
            titleLabel.attributedText = nil
            titleLabel.text = task.title
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white
        }
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
    
    @objc private func circleButtonTapped() {
        checkmarkImageView.isHidden.toggle()
        isCompleted?.toggle()
        guard let isCompleted = isCompleted,
              let id = id else { return }
        self.delegate?.updateTracker(id: id, toDo: ToDo(createdAt: createdAt ?? Date(), description: descriptionString ?? "", id: id, isCompleted: isCompleted, title: title ?? ""))
    }
}

extension ToDoTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = self.indexPath else {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                return UIMenu(title: "", children: [])
            }
        }
        
        let edit = UIAction(title: "Редактировать", image: UIImage(named: "Edit")) { [weak self] _ in
            self?.delegate?.handleEditAction(indexPath: indexPath)
        }
        
        let share = UIAction(title: "Поделиться", image: UIImage(named: "Share")) { [weak self] _ in
            self?.delegate?.handleShareAction(indexPath: indexPath)
        }
        
        
        let delete = UIAction(title: "Удалить", image: UIImage(named: "Delete"), attributes: .destructive) { [weak self] _ in
            self?.delegate?.handleDeleteAction(indexPath: indexPath)
        }
        
        let actions: [UIAction] = [edit, share, delete]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: actions)
        }
    }
}
