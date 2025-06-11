import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    func viewDidLoad()
    func viewDidLayoutSubviews()
    func numberOfPhotos() -> Int
    func photo(at index: Int) -> Photo?
    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat
    func didSelectRow(at index: Int)
    func willDisplayCell(at index: Int)
    func toggleLike(at index: Int, completion: @escaping (Bool) -> Void)
    func formattedDate(for photo: Photo) -> String
}
