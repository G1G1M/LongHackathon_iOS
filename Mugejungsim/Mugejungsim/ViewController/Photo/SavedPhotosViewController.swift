import UIKit
import SDWebImage // 네트워크 이미지 로드를 위해 필요

class SavedPhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var savedData: [PhotoData] = []
    var collectionView: UICollectionView!
    var recordID : String = ""

    private var imageCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 25"
        label.textColor = .black
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("한 줄 남기기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = false // 그림자가 잘리지 않도록 false로 설정
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.46, green: 0.45, blue: 0.76, alpha: 1)
        
        // 그림자 설정
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        return button
    }()
    
    let saveAndHomeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장하고 홈으로 돌아가기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.setTitleColor(UIColor(red: 85/255, green: 85/255, blue: 88/255, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = false // 그림자가 잘리지 않도록 false로 설정
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: "#F4F5FB")
        
        // 그림자 설정
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 내비게이션 바 설정
        setupCustomNavigationBar()
        setupCollectionView()
        
        loadPhotosForRecord()
        updateImageCountLabel()
        
        // UI 업데이트
        updateUI()
        
        view.addSubview(lineButton)
        view.addSubview(saveAndHomeButton)
        
        lineButton.addTarget(self, action: #selector(lineButtonTapped), for: .touchUpInside)
        saveAndHomeButton.addTarget(self, action: #selector(saveAndHomeButtonTapped), for: .touchUpInside)
        
        setupButtonsConstraints()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        savedData = DataManager.shared.loadData() // DataManager에서 데이터 로드
        loadPhotosForRecord()
        collectionView.reloadData() // 컬렉션 뷰 갱신
        updateImageCountLabel() // 이미지 카운트 업데이트
    }

    func setupButtonsConstraints() {
        NSLayoutConstraint.activate([
            lineButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            lineButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lineButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lineButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveAndHomeButton.bottomAnchor.constraint(equalTo: lineButton.topAnchor, constant: -10),
            saveAndHomeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveAndHomeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveAndHomeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCustomNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .clear
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "out"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(navBar)
        navBar.addSubview(backButton)
        navBar.addSubview(imageCountLabel)
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 65),

            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 24),
            
            imageCountLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            imageCountLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor)
        ])
    }
    
    // MARK: - Update Image Count Label
    private func updateImageCountLabel() {
        let currentCount = savedData.count
        imageCountLabel.text = "\(currentCount) / 25"
    }
    
    func updateUI() {
        guard let collectionView = collectionView else {
            print("collectionView가 nil입니다.")
            return
        }
        collectionView.reloadData()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        
        // 셀 크기를 컬렉션 뷰 너비를 기준으로 설정 (정사각형)
        let cellWidth = (UIScreen.main.bounds.width - 48 - (4 * 1.01)) / 5 // 화면 너비 - 좌우 패딩 - 간격
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        // 셀 간 간격
        layout.minimumLineSpacing = 1.01 // 줄 간격
        layout.minimumInteritemSpacing = 1.01 // 열 간격
        
        // 컬렉션 뷰 여백
        layout.sectionInset = UIEdgeInsets(top: 1.01, left: 24, bottom: 1.01, right: 24)
        
        // 컬렉션 뷰 생성
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SavedPhotoCell.self, forCellWithReuseIdentifier: "SavedPhotoCell")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        // 제약조건 설정
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
        
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedData.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedPhotoCell", for: indexPath) as! SavedPhotoCell
        let photoData = savedData[indexPath.row]
        cell.configure(with: photoData) // PhotoData를 통해 이미지, 텍스트, 카테고리를 표시
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 기존 코드 유지
        let selectedData = savedData[indexPath.row]
        let detailVC = PhotoDetailViewController()
        detailVC.currentIndex = indexPath.row // 현재 이미지의 인덱스를 전달
        detailVC.selectedPhotoData = selectedData // 데이터 전달
        detailVC.allPhotoData = savedData // 전체 데이터 전달
        detailVC.modalPresentationStyle = .fullScreen

        // 슬라이드 기능 추가
        let sliderVC = PhotoSliderViewController()
        sliderVC.allPhotoData = savedData // 모든 사진 데이터 전달
        sliderVC.initialIndex = indexPath.row // 시작할 사진 인덱스 전달
        sliderVC.modalPresentationStyle = .fullScreen

        // 슬라이드 모드에서 `SavedPhotosViewController`의 카운트 숫자를 숨김
        sliderVC.dismissCallback = { [weak self] in
            self?.updateImageCountLabel() // 슬라이드에서 빠져나온 후 다시 카운트 갱신
        }

        // 슬라이드 뷰 컨트롤러 호출
        present(sliderVC, animated: true, completion: nil)
    }
    
    @objc private func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func lineButtonTapped() {
        print("Line Button Tapped!")
        // 저장하고 한 줄 넘기기 페이지로 이동
        let OCVC = ObjeCreationViewController() // 이동할 ViewController 인스턴스 생성
        OCVC.recordID = recordID
        OCVC.modalTransitionStyle = .crossDissolve
        OCVC.modalPresentationStyle = .fullScreen
        self.present(OCVC, animated: true, completion: nil)
        print("OCVC로 이동 성공")
    }
        
    @objc func saveAndHomeButtonTapped() {
        print("Save and Home Button Tapped!")
        // 네비게이션 컨트롤러 확인
        guard let navigationController = self.navigationController else {
            print("NavigationController가 없습니다. 네비게이션 스택에 추가 후 다시 시도하세요.")
            // 네비게이션 컨트롤러가 없을 경우 루트 뷰 컨트롤러 변경
            let mainViewController = MyRecordsViewController()
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            window?.rootViewController = UINavigationController(rootViewController: MyRecordsViewController())
            window?.makeKeyAndVisible()
            return
        }
        // MainViewController로 이동
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MyRecordsViewController {
            navigationController.setViewControllers([mainViewController], animated: true)
        } else {
            print("MainViewController를 초기화할 수 없습니다. 스토리보드 ID를 확인하세요.")
        }
    }
    
    private func loadPhotosForRecord() {
        guard let postId = TravelRecordManager.shared.postId else {
            print("postId is nil!")
            return
        }
        print("Requesting images for postId: \(postId)")
        APIService.shared.getUploadedImages(postId: postId) { result in
            DispatchQueue.main.async { // UI 갱신은 메인 스레드에서
                switch result {
                case .success(let images):
                    print("Uploaded Images: \(images)")
                    self.savedData = images // 서버에서 받은 이미지 데이터를 저장
                    self.collectionView.reloadData() // 컬렉션 뷰 갱신
                    self.updateImageCountLabel()
                case .failure(let error):
                    print("Failed to fetch images: \(error.localizedDescription)")
                    // 실패했을 경우 사용자에게 오류 메시지를 알릴 수 있습니다.
                    self.savedData.removeAll() // 실패시 데이터를 초기화
                    self.collectionView.reloadData() // 컬렉션 뷰 갱신
                    self.updateImageCountLabel()
                }
            }
        }
    }
}

