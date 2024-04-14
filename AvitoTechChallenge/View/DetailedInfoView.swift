import UIKit
import Combine

final class DetailedInfoView<T: MediaAPI>: UIViewController {
    private lazy var scrollView: UIScrollView =  {
        let scrollView = UIScrollView()
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        return contentView
    }()
    
    private let viewModel: DetailedInfoViewModel<T>
    private var subscriptions = Set<AnyCancellable>()
    private var data: Media!
    private var contentImage: UIImageView!
    private var name: UILabel!
    private var authorName: UILabel!
    private var link: UILabel!
    private var contentDescription: UILabel!
    
    private var detailedAuthorName: UILabel!
    private var detailedAuthorGenre: UILabel!
    private var detailedArtistLink: UITextView!
    private var artistsPage: UILabel!

    private var loadIndicator: UIActivityIndicatorView!
    
    // MARK: - методы жизненного цикла
    init(with data: Media, vm: DetailedInfoViewModel<T>) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
        self.data = data
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        initializeSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // симулируем задержку чтобы показать загрузку
        DispatchQueue.main.async { [weak self] in
            self?.bindVM()
        }
        fillWithData()
        setupStyles()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // приходится обновлять размеры именно здесь, потому что только при появлении вью на экране есть окончательные размеры сабвью контентвью
        adjustContentViewSize()
    }
    
    // MARK: - приватные методы
    // подпишемся на изменения в viewModel
    private func bindVM() {
        viewModel.fetchDetails(with: data.result.artistID)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.loadIndicator.stopAnimating()
                    // выведем ошибку с сообщением
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                case .finished:
                    self?.loadIndicator.stopAnimating()
                    self?.displayArtistInfo()
                    break
                }
            }, receiveValue: { [weak self] value in
                self?.fillArtistData(with: value)
            })
            .store(in: &subscriptions)
    }

    // заполним сабвью данными
    private func fillWithData() {
        contentImage.image = data.image
        name.text = data.result.trackName ?? data.result.collectionName ?? data.result.collectionCensoredName ?? "unknown"
        authorName.text = "\(data.result.wrapperType ?? data.result.kind?.rawValue ?? Kind.other.rawValue) by \(data.result.artistName ?? data.result.collectionArtistName ?? "someone")"
        contentDescription.text = data.result.description ?? data.result.longDescription ?? data.result.shortDescription ?? ""
        link.text = "Apple Music link"
    }

    private func initializeSubviews() {
        contentImage = UIImageView()
        name = UILabel()
        authorName = UILabel()
        link = UILabel()
        contentDescription = UILabel()
        detailedAuthorName = UILabel()
        detailedAuthorGenre = UILabel()
        detailedArtistLink = UITextView()
        artistsPage = UILabel()
        loadIndicator = UIActivityIndicatorView()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentImage)
        contentView.addSubview(name)
        contentView.addSubview(authorName)
        contentView.addSubview(link)
        contentView.addSubview(contentDescription)
        contentView.addSubview(loadIndicator)
        loadIndicator.startAnimating()
    }
    
    private func setupStyles() {
        view.backgroundColor = .white
        overrideUserInterfaceStyle = .light
        name.numberOfLines = 4
        name.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        
        authorName.numberOfLines = 2
        authorName.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        contentDescription.numberOfLines = 25 // чтобы точно хватило
        contentDescription.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        link.isUserInteractionEnabled = true
        // повесим gestureRecogniser для перехода на страницу трека
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openTrackLink))
        link.addGestureRecognizer(tapGesture)
    }
    
    // вызываем этот метод когда подгрузили инфо об исполнителе
    private func fillArtistData(with artistData: Artist) {
        detailedAuthorName.text = "Artist's name: \(artistData.artistName)"
        detailedAuthorGenre.text = "Artist's genre: \(artistData.primaryGenreName)"
        artistsPage.text = "Artist's page on "
        let customText = "Apple Music"
        let urlString = artistData.artistLinkUrl
        let attributedString = NSMutableAttributedString(string: customText)
        
        if let url = URL(string: urlString) {
            attributedString.addAttribute(.link, value: url, range: NSRange(location: 0, length: customText.count))
        }
        
        detailedArtistLink.attributedText = attributedString
        detailedArtistLink.isEditable = false
        detailedArtistLink.isUserInteractionEnabled = true
        detailedArtistLink.isScrollEnabled = false
        detailedArtistLink.isSelectable = true
    }

    // так как инфо о исполнителе опциональна (иногда id автора не содержится в ответе), выводим элементы только если инфо есть
    private func displayArtistInfo() {
        contentView.addSubview(detailedAuthorName)
        contentView.addSubview(detailedAuthorGenre)
        contentView.addSubview(artistsPage)
        contentView.addSubview(detailedArtistLink)
        
        detailedAuthorName.translatesAutoresizingMaskIntoConstraints = false
        detailedAuthorGenre.translatesAutoresizingMaskIntoConstraints = false
        artistsPage.translatesAutoresizingMaskIntoConstraints = false
        detailedArtistLink.translatesAutoresizingMaskIntoConstraints = false
        
        var lowestView = link
        // чаще всего для песни нет описания, но иногда есть: ищем самый нижний элемент и цепляемся за него
        if link.frame.origin.y < contentDescription.frame.origin.y {
            lowestView = contentDescription
        }
        
        NSLayoutConstraint.activate([
            detailedAuthorName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailedAuthorName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailedAuthorName.topAnchor.constraint(equalTo: lowestView!.bottomAnchor, constant: 10),
            
            detailedAuthorGenre.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailedAuthorGenre.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailedAuthorGenre.topAnchor.constraint(equalTo: detailedAuthorName.bottomAnchor, constant: 10),
            
            artistsPage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            artistsPage.topAnchor.constraint(equalTo: detailedAuthorGenre.bottomAnchor, constant: 10),
            
            detailedArtistLink.centerYAnchor.constraint(equalTo: artistsPage.centerYAnchor),
            detailedArtistLink.leadingAnchor.constraint(equalTo: artistsPage.trailingAnchor),
            detailedArtistLink.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
        ])
    }

    // констрейнты для основной части вью
    private func setupConstraints() {
        contentImage.translatesAutoresizingMaskIntoConstraints = false
        name.translatesAutoresizingMaskIntoConstraints = false
        authorName.translatesAutoresizingMaskIntoConstraints = false
        link.translatesAutoresizingMaskIntoConstraints = false
        contentDescription.translatesAutoresizingMaskIntoConstraints = false
        loadIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentImage.widthAnchor.constraint(equalToConstant: view.frame.width),
            contentImage.heightAnchor.constraint(equalToConstant: view.frame.width),
            
            name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            name.topAnchor.constraint(equalTo: contentImage.bottomAnchor, constant: 20),
            name.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            authorName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            authorName.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5),
            authorName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            link.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            link.topAnchor.constraint(equalTo: authorName.bottomAnchor, constant: 5),
            link.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            contentDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentDescription.topAnchor.constraint(equalTo: link.bottomAnchor, constant: 25),
            contentDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            loadIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadIndicator.topAnchor.constraint(equalTo: link.bottomAnchor, constant: 20)
        ])
    }
    
    // открываем ссылку на трех
    @objc private func openTrackLink() {
        if let url = URL(string: data.result.trackViewURL ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    // так как данных может быть много, принято решение использовать scrollView и подгонять его размеры под размер вложенного контента
    private func adjustContentViewSize() {
        let newHeight = contentView.calculateMaxHeight() + 50
        self.scrollView.contentSize = CGSize(width: view.frame.width, height: newHeight)
        self.contentView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: newHeight))
        // некрасивая синхронная операция которая фризит вью на пару кадров
        view.layoutIfNeeded()
    }
}

// расширение с функцией чтобы считать самую нижнюю точку сабвью у contentView
extension UIView {
    func calculateMaxHeight() -> CGFloat {
        var maxHeight: CGFloat = 0
        for view in subviews {
            if view.isHidden {
                continue
            }
            let newHeight = view.frame.origin.y + view.frame.height
            if newHeight > maxHeight {
                maxHeight = newHeight
            }
        }
        return maxHeight
    }
}

