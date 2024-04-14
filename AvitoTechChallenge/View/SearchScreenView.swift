import UIKit
import Combine

final class SearchScreenView: UIViewController {
    var suggestionsTableView: UITableView!
    var contentCollectionView: UICollectionView!
    var searchBar: UISearchBar!
    var loadingIndicator: UIActivityIndicatorView!
    
    var tableViewHeightConstraint: NSLayoutConstraint?
    
    private var viewModel: searchVM
    private var subscriptions = Set<AnyCancellable>()
    
    
    // MARK: - инициализаторы
    init(viewModel: searchVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        overrideUserInterfaceStyle = .light
        initializeSubviews()
        setupVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyConstraints()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        suggestionsTableView.reloadData()
        contentCollectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // отключим констрейнт для таблицы, подключим после возвращения на вью
        tableViewHeightConstraint?.isActive = false
    }
    
    // MAR: - внутренние методы
    // подписываемся на изменения от Publisher'ов в VM
    private func setupVM() {
        viewModel.viewStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loading:
                    DispatchQueue.main.async { [weak self] in
                        self?.loadingIndicator.startAnimating()
                    }
                case .loaded:
                    DispatchQueue.main.async { [weak self] in
                        self?.loadingIndicator.stopAnimating()
                    }
                case .error(let error):
                    DispatchQueue.main.async { [weak self] in
                        self?.loadingIndicator.stopAnimating()
                    }
                    let alert = UIAlertController(title: "Error", message: "\(error.rawValue)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.mediaPublisher
            .sink(receiveValue: { [weak self] data in
                DispatchQueue.main.async { [weak self] in
                    self?.contentCollectionView.reloadData()
                }
            })
            .store(in: &subscriptions)
        
        viewModel.suggestionsPublisher
            .sink { [weak self] val in
                DispatchQueue.main.async {
                    // нужно обновить констрейнт высоты, чтобы collectionView "подвинулась" вниз
                    self?.suggestionsTableView.reloadData()
                    self?.suggestionsTableView.heightAnchor.constraint(equalToConstant: 0).isActive = false
                    let numberOfRows = self?.suggestionsTableView.numberOfRows(inSection: 0)
                    
                    let newHeight = CGFloat(numberOfRows ?? 2) * 44
                    self?.tableViewHeightConstraint?.constant = newHeight
                    
                    UIView.animate(withDuration: 0.3) {
                        self?.view.layoutIfNeeded()
                    }
                }
                
            }
            .store(in: &subscriptions)
    }
    
    func initializeSubviews() {
        searchBar = UISearchBar()
        suggestionsTableView = UITableView()
        contentCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        loadingIndicator = UIActivityIndicatorView()
        let layout = UICollectionViewFlowLayout()
        // размер ячеек "примерно" как в приложении Авито
        let const = 1.45
        layout.itemSize = CGSize(width: 260/const, height: 490/const)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        suggestionsTableView.isScrollEnabled = false
        
        contentCollectionView.collectionViewLayout = layout
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        contentCollectionView.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.identifier)
        
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(suggestionsTableView)
        view.addSubview(contentCollectionView)
        view.addSubview(loadingIndicator)
    }
    
    
    func applyConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        suggestionsTableView.translatesAutoresizingMaskIntoConstraints = false
        contentCollectionView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        suggestionsTableView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        suggestionsTableView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        contentCollectionView.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentCollectionView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: suggestionsTableView.leadingAnchor, constant: 0),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: contentCollectionView.leadingAnchor, constant: 0),
            contentCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 0),
            searchBar.bottomAnchor.constraint(equalTo: suggestionsTableView.topAnchor, constant: 0),
            suggestionsTableView.bottomAnchor.constraint(equalTo: contentCollectionView.topAnchor, constant: 0),
            contentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            loadingIndicator.topAnchor.constraint(equalTo: suggestionsTableView.bottomAnchor, constant: 20),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        tableViewHeightConstraint = suggestionsTableView.heightAnchor.constraint(equalToConstant: CGFloat(44 * viewModel.suggestions.count))
        tableViewHeightConstraint!.isActive = true
    }
}

// MARK: - расширения для таблицы с рекомендациями
extension SearchScreenView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = viewModel.suggestions[indexPath.row].query
        // загружаем контент
        searchBar.endEditing(true)
        viewModel.fetchContentWithImages(with: viewModel.suggestions[indexPath.row].query)
        //убираем список предложенных запросов
        viewModel.voidSuggestions()
    }
}

extension SearchScreenView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.suggestions.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel.suggestions[indexPath.row].query
        return cell
    }
}


// MARK: - расширения для collectionView
extension SearchScreenView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let view = DetailedInfoView(with: viewModel.media[indexPath.item],
                                    vm: DetailedInfoViewModel(model: iTunesApi()))
        navigationController?.pushViewController(view, animated: true)
    }
}


extension SearchScreenView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.identifier, for: indexPath) as? ContentCell else { return UICollectionViewCell() }
        cell.setDataWithImages(with: viewModel.media[indexPath.item])
        return cell
    }
    
}

// MARK: - делегат для поисковой строки
extension SearchScreenView: UISearchBarDelegate {
    // вызывается когда отправляем запрос на поиск
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchBar.endEditing(true) // сворачиваем клавиатуру
        loadingIndicator.startAnimating() // включаем анимацию загрузки
        viewModel.fetchContentWithImages(with: text) // подгрузаем контент по запросу
        viewModel.createNewSuggestion(with: text) // добавляем новое предложение
        viewModel.voidSuggestions() // убираем предложения из вм, чтобы они не отображались в таблице
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {return}
        guard text != "" else {
            // фетчим рекомендации и пустой контент
            viewModel.fetchSuggestions(with: "")
            viewModel.clearMedia()
            return
        }
        // если строка не пуста, подгружаем рекомендации по введенному тексту
        viewModel.fetchSuggestions(with: text)
    }
}


