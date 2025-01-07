import UIKit

class PhotoSliderViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var allPhotoData: [PhotoData] = []
    var initialIndex: Int = 0
    var dismissCallback: (() -> Void)? // 슬라이드 종료 시 호출할 콜백

    private var currentIndex: Int = 0 {
        didSet {
            updateImageCountLabel()
        }
    }

    private let imageCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        setupCustomNavigationBar()
        setInitialViewController()
    }

    private func setupCustomNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .white
        navBar.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "X_Button"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        navBar.addSubview(backButton)
        navBar.addSubview(imageCountLabel)
        view.addSubview(navBar)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 65),

            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 24),

            imageCountLabel.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            imageCountLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
        ])
    }

    private func updateImageCountLabel() {
        imageCountLabel.text = "\(currentIndex + 1) / \(allPhotoData.count)"
    }

    private func setInitialViewController() {
        guard initialIndex >= 0, initialIndex < allPhotoData.count else { return }
        let initialViewController = createPhotoDetailViewController(for: initialIndex)
        setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        currentIndex = initialIndex
    }

    private func createPhotoDetailViewController(for index: Int) -> PhotoDetailViewController {
        let photoDetailVC = PhotoDetailViewController()
        photoDetailVC.selectedPhotoData = allPhotoData[index]
        photoDetailVC.currentIndex = index
        photoDetailVC.allPhotoData = allPhotoData
        return photoDetailVC
    }

    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PhotoDetailViewController else { return nil }
        let previousIndex = currentVC.currentIndex - 1
        guard previousIndex >= 0 else { return nil }
        return createPhotoDetailViewController(for: previousIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PhotoDetailViewController else { return nil }
        let nextIndex = currentVC.currentIndex + 1
        guard nextIndex < allPhotoData.count else { return nil }
        return createPhotoDetailViewController(for: nextIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = viewControllers?.first as? PhotoDetailViewController {
            currentIndex = currentVC.currentIndex
        }
    }

    @objc private func goBack() {
        dismiss(animated: true) {
            self.dismissCallback?() // 슬라이드 종료 시 콜백 호출
        }
    }
}
