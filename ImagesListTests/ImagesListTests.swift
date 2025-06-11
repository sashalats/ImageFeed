@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {

    var sut: ImagesList!
    var tableView: UITableView!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        sut = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesList
        sut.loadViewIfNeeded()
        tableView = sut.view.subviews.compactMap { $0 as? UITableView }.first
    }

    override func tearDown() {
        sut = nil
        tableView = nil
        super.tearDown()
    }

    func test_ViewLoads_TableViewNotNil() {
        XCTAssertNotNil(tableView, "TableView should be connected")
    }

    func test_TableViewDataSource_NumberOfRowsEqualsPhotosCount() {
        // Arrange
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        let mockPresenter = MockPresenter()
        mockPresenter.mockPhotos = [photo]

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesList
        viewController.presenter = mockPresenter
        mockPresenter.view = viewController
        viewController.loadViewIfNeeded()

        // Act
        let tableView = viewController.view.subviews.compactMap { $0 as? UITableView }.first!
        let rows = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0)
        
        // Assert
        XCTAssertEqual(rows, 1, "Number of rows should match photos count")
    }

    func test_CellForRow_ReturnsConfiguredCell() {
        // Arrange
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        let mockPresenter = MockPresenter()
        mockPresenter.mockPhotos = [photo]
        sut.presenter = mockPresenter
        sut.presenter?.view = sut
        let tableView = sut.view.subviews.compactMap { $0 as? UITableView }.first!
        tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)

        // Act
        let cell = sut.tableView(self.tableView, cellForRowAt: indexPath)
        
        // Assert
        XCTAssertTrue(cell is ImagesListCell, "Cell should be of type ImagesListCell")
    }

    func testToggleLike_callsPresenterAndUpdatesUI() {
        // Arrange
        let spyPresenter = SpyImagesListPresenter()
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        spyPresenter.photos = [photo]

        sut = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesList
        sut.presenter = spyPresenter
        spyPresenter.view = sut
        sut.loadViewIfNeeded()
        let tableView = sut.view.subviews.compactMap { $0 as? UITableView }.first!
        tableView.reloadData()

        let indexPath = IndexPath(row: 0, section: 0)
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first,
              let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {
            XCTFail("Expected ImagesListCell at indexPath")
            return
        }

        // Act
        sut.imageListCellDidTapLike(cell)

        // Assert
        XCTAssertTrue(spyPresenter.didCallToggleLike, "Expected toggleLike to be called on presenter")
    }
}

final class SpyImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    var photos: [Photo] = []
    var didCallToggleLike = false

    func viewDidLoad() {
        view?.reloadTable()
    }

    func viewDidLayoutSubviews() {}

    func numberOfPhotos() -> Int {
        return photos.count
    }

    func photo(at index: Int) -> Photo? {
        guard photos.indices.contains(index) else { return nil }
        return photos[index]
    }

    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        return 100
    }

    func didSelectRow(at index: Int) {}

    func willDisplayCell(at index: Int) {}

    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {
        didCallToggleLike = true
        completion(true)
    }

    func formattedDate(for photo: Photo) -> String {
        return "1 января 2024"
    }
}


// MARK: - MockPresenter
final class MockPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    var mockPhotos: [Photo] = []

    func viewDidLoad() {}
    func viewDidLayoutSubviews() {}
    func numberOfPhotos() -> Int { return mockPhotos.count }
    func photo(at index: Int) -> Photo? { return mockPhotos[index] }
    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat { return 100.0 }
    func didSelectRow(at index: Int) {}
    func willDisplayCell(at index: Int) {}
    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void) {}
    func formattedDate(for photo: Photo) -> String { return "1 января 2024" }
}
