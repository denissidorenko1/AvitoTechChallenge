import UIKit

final class ContentCell: UICollectionViewCell {    
    private let image = UIImageView()
    private let name = UILabel()
    private let price = UILabel()
    private let artist = UILabel()
    private let mediaType = UIImageView()
    
    static let identifier = "ContentCell"
    
    // MARK: - методы жизненного цикла
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupStyles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyConstraints()
        
    }
    
    // MARK: - внешние методы
    // вызываем эту функцию при переиспользовании ячеек, наполняем данными
    public func setDataWithImages(with data: Media) {
        name.text = data.result.trackName ?? data.result.collectionName
        price.text = priceFormatter(with: data)
        artist.text = data.result.artistName
        image.image = data.image
        mediaType.image = contentTypeSelector(with: data.result.kind ?? .other).withRenderingMode(.alwaysOriginal)
    }
    
    // MARK: - внутренние методы
    private func setupStyles() {
        name.numberOfLines = 2
        name.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        image.layer.cornerRadius = 15
        image.clipsToBounds = true
        price.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        artist.numberOfLines = 2
    }
    
    private func addSubviews() {
        contentView.addSubview(image)
        contentView.addSubview(name)
        contentView.addSubview(price)
        contentView.addSubview(artist)
        contentView.addSubview(mediaType)
    }
    
    private func applyConstraints() {
        image.translatesAutoresizingMaskIntoConstraints = false
        name.translatesAutoresizingMaskIntoConstraints = false
        price.translatesAutoresizingMaskIntoConstraints = false
        artist.translatesAutoresizingMaskIntoConstraints = false
        mediaType.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: image.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: image.trailingAnchor),
            image.heightAnchor.constraint(equalToConstant: contentView.bounds.width),
            
            contentView.leadingAnchor.constraint(equalTo: name.leadingAnchor, constant: 0),
            name.trailingAnchor.constraint(equalTo: mediaType.leadingAnchor, constant: -5),
            mediaType.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            mediaType.heightAnchor.constraint(equalToConstant: 25),
            mediaType.widthAnchor.constraint(equalToConstant: 25),
            
            mediaType.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10),
            
            name.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10),
            
            name.bottomAnchor.constraint(equalTo: price.topAnchor, constant: -5),
            contentView.leadingAnchor.constraint(equalTo: price.leadingAnchor, constant: 0),
            
            contentView.leadingAnchor.constraint(equalTo: artist.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: artist.trailingAnchor, constant: 0),
            price.bottomAnchor.constraint(equalTo: artist.topAnchor, constant: -5)
        ])
    }
    
    // форматтер для строки с ценой
    private func priceFormatter(with data: Media) -> String? {
        guard !(data.result.trackPrice == nil && data.result.collectionPrice == nil) else {return "Free"}
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = data.result.currency
        let price = formatter.string(from: NSDecimalNumber(string: String(data.result.trackPrice ?? data.result.collectionPrice ?? 0)))
        return price
    }
    
    // возвращаем иконку в соответствии с типом
    private func contentTypeSelector(with type: Kind) -> UIImage {
        switch type {
        case .featureMovie:
            return UIImage(systemName: "popcorn")!
        case .song:
            return UIImage(systemName: "music.note")!
        case .book:
            return UIImage(systemName: "book")!
        case .album:
            return UIImage(systemName: "rectangle.stack")!
        case .artist:
            return UIImage(systemName: "person.2.wave.2.fill")!
        case .audioBook:
            return UIImage(systemName: "book")!
        case .other:
            return UIImage(systemName: "arrow.3.trianglepath")!
        }
    }

}
