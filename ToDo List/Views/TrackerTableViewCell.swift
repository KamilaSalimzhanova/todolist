import UIKit

final class TrackerTableViewCell: UITableViewCell {
    static let reuseIdentifier = "trackerTableViewCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        textLabel?.textColor = .blue
        backgroundColor = .black
        selectionStyle = .none
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    func configure(category: TrackerCategory) {
//        textLabel?.text = category.title
//    }
}
