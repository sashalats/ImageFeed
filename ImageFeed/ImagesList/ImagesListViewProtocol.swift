import Foundation

protocol ImagesListViewProtocol: AnyObject {
    func reloadRows(at indexPaths: [IndexPath])
    func insertRows(at indexPaths: [IndexPath])
    func reloadTable()
}
