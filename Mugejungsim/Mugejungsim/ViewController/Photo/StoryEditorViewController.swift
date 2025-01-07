import UIKit
import PhotosUI
import Alamofire

class StoryEditorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, PHPickerViewControllerDelegate {

    // MARK: - Properties
    var images: [UIImage] = [] // 선택된 이미지 배열
    var texts: [String] = []   // 각 이미지에 대응하는 텍스트 배열
    var categories: [[String]] = [] // 각 이미지에 대응하는 카테고리 배열
    var selectedCategoriesForImages: [[String]] = [] // 각 사진에 대응하는 카테고리
    private var subHowLabel: UILabel! // 클래스 프로퍼티로 선언
    private var mainImageView: UIImageView!
    private var thumbnailCollectionView: UICollectionView!
    private var textView: UITextView!
    private var categoryContainer: UIView!
    private var contentView: UIView!
    private var currentIndex: Int = 0 // 현재 선택된 이미지 인덱스
    private var characterCountLabel: UILabel!
    private let maxCharacterCount = 100
    private var doneToolbar: UIToolbar!
    private var categoryIndex: Int? = 0
    private var categoryNumber : String = ""
    private var selectedSubCategory: String? // 선택된 서브 카테고리 저장
    private var originalViewY: CGFloat = 0 // 원래 뷰의 Y 위치를 저장

    
    // MARK: - 카테고리 관련 Properties
    private var categoryOverlayView: UIView? // Overlay View
    private var selectedSubCategories: [String] = [] // 선택된 세부 카테고리 저장
    private var selectedCategoriesForCurrentImage: [String] = [] // 현재 이미지에 선택된 카테고리

    weak var delegate: UploadViewControllerDelegate? // 이전 화면과 연결하기 위한 delegate
    
    var recordID : String = ""
    
    private var nextButton: UIButton!

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        let plusImageView = UIImageView()
        plusImageView.image = UIImage(named: "plus")
        plusImageView.contentMode = .scaleAspectFit
        plusImageView.translatesAutoresizingMaskIntoConstraints = false

        let countLabel = UILabel()
        countLabel.text = "0 / 25"
        countLabel.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        countLabel.font = UIFont(name: "Pretendard-Medium", size: 8.59)
        countLabel.textAlignment = .center
        
        // 자간 설정
        let attributedString = NSMutableAttributedString(string: "0 / 25")
        attributedString.addAttribute(.kern, value: -0.21, range: NSRange(location: 0, length: attributedString.length))
        countLabel.attributedText = attributedString

        let stackView = UIStackView(arrangedSubviews: [plusImageView, countLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: button.topAnchor, constant: 16),
            
            // plusImageView 크기 제약 추가
            plusImageView.widthAnchor.constraint(equalToConstant: 20),
            plusImageView.heightAnchor.constraint(equalToConstant: 20),
        ])

        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 3.3
        button.layer.borderWidth = 1.24
        button.layer.borderColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)

        return button
    }()

    private let imageCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/25"
        label.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        label.font = UIFont(name: "Pretendard-Medium", size: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Received images: \(images)")  // 전달된 이미지 확인
        originalViewY = view.frame.origin.y // 원래 Y 위치 저장
        setupKeyboardObservers() // 키보드 이벤트 감지 설정
        
        texts = Array(repeating: "", count: images.count)
        categories = Array(repeating: [], count: images.count) // 카테고리 초기화

        // 내비게이션 바 배경색을 흰색으로 설정
        if let navigationController = self.navigationController {
            let navBar = navigationController.navigationBar
            navBar.barTintColor = .white
            navBar.isTranslucent = false
            navBar.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 18, weight: .bold)
            ]
        }
        view.backgroundColor = .white
        
        addButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        
        setupCustomNavigationBar()
        updateImageCountLabels()
        setupUI()
        setupToolbar() // 키보드 위 툴바 설정
        setupKeyboardObservers() // 키보드 이벤트 감지 설정
        setupCategoryButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
        // 특정 뷰를 최상단으로 가져오기
        view.bringSubviewToFront(addButton)
        view.bringSubviewToFront(thumbnailCollectionView)
                
        // 네비게이션 바가 커스텀 뷰인 경우, 해당 뷰도 최상단으로
        if let navigationBar = self.navigationController?.navigationBar {
            view.bringSubviewToFront(navigationBar)
        }
                
        // zPosition으로 이미지와 썸네일, 버튼을 최상단으로 설정
        mainImageView.layer.zPosition = 100
        thumbnailCollectionView.layer.zPosition = 100
        addButton.layer.zPosition = 101 // 내비게이션 바보다 위로 설정
    }
    
    deinit {
        removeKeyboardObservers() // 옵저버 제거
    }

    @objc private func openGallery() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 25
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        var selectedImages: [UIImage] = []
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            selectedImages.append(image)
                            if selectedImages.count == results.count {
                                self?.addSelectedImages(selectedImages)
                            }
                        }
                    }
                }
            }
        }
    }

    private func addSelectedImages(_ newImages: [UIImage]) {
        images.append(contentsOf: newImages)
        texts.append(contentsOf: Array(repeating: "", count: newImages.count))
        selectedCategoriesForImages.append(contentsOf: Array(repeating: [], count: newImages.count)) // 각 이미지별 카테고리 초기화
        updateImageCountLabels()
        thumbnailCollectionView.reloadData()
    }

    private func setupUI() {
        setupMainImageView()
        setupThumbnailSection()
        setupScrollView()
    }
    
    
    private func setupScrollView() {
        // ScrollView 생성
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        // ScrollView ContentView 생성
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // ScrollView와 ContentView의 제약 조건
        NSLayoutConstraint.activate([
            // ScrollView 제약 조건
            scrollView.topAnchor.constraint(equalTo: thumbnailCollectionView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView 제약 조건
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 700)
        ])
        self.contentView = contentView // 스크롤 뷰 안에 카테고리, 텍스트뷰 등을 배치하기 위해 contentView를 사용
        setupCategorySection()
        setupHowLabel()
        setupExpressionField()
        setupTextInputField()
        setupButtonsAboutCategoryButton()
        setupNextButton()
    }
    

    private func setupCustomNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .white
        navBar.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "out"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

//        let saveButton = UIButton(type: .system)
//        saveButton.setTitle("임시저장", for: .normal)
//        saveButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
//        saveButton.setTitleColor(#colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), for: .normal)
//        saveButton.addTarget(self, action: #selector(saveTemporarily), for: .touchUpInside)
//        saveButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(navBar)
        navBar.addSubview(backButton)
//        navBar.addSubview(saveButton)
        navBar.addSubview(imageCountLabel)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -45),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 95),

            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor, constant: 25),
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 24),

//            saveButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor, constant: 25),
//            saveButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -24),

            imageCountLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            imageCountLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor)
        ])
        navBar.layer.zPosition = 100
    }
    
    @objc private func goBack() {
        delegate?.didTapBackButton() // 이전 화면의 동작 실행
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    private func setupToolbar() {
        doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        doneToolbar.barStyle = .default

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(dismissKeyboard))
        
        doneToolbar.items = [flexibleSpace, doneButton]
        doneToolbar.sizeToFit()

        textView.inputAccessoryView = doneToolbar
    }

    @objc private func dismissKeyboard() {
        textView.resignFirstResponder()
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height

        // 현재 포커스된 텍스트뷰 찾기
        if let activeTextView = view.findFirstResponder() as? UITextView {
            let textViewFrame = activeTextView.convert(activeTextView.bounds, to: self.view)
            let overlapHeight = (textViewFrame.maxY + 20) - (self.view.bounds.height - keyboardHeight) // 20은 여유 공간

            if overlapHeight > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -overlapHeight)
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
    }

    private func setupMainImageView() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        mainImageView = UIImageView()
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.backgroundColor = .white
        mainImageView.layer.borderWidth = 1
        mainImageView.layer.borderColor = UIColor.white.cgColor // 테두리 색 변경
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.image = images.first ?? UIImage()
        containerView.addSubview(mainImageView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 263), // 높이 설정
        ])
        NSLayoutConstraint.activate([
            mainImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            mainImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainImageView.heightAnchor.constraint(equalToConstant: 263)
        ])
    }

    private func setupThumbnailSection() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        view.addSubview(containerView)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 62.86, height: 62.86)
        layout.minimumLineSpacing = 11.45

        thumbnailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        thumbnailCollectionView.backgroundColor = UIColor.white
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.dataSource = self
        thumbnailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailCollectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: "ThumbnailCell")
        thumbnailCollectionView.backgroundColor = .white
        containerView.addSubview(thumbnailCollectionView)
        containerView.addSubview(addButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: mainImageView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 85),

            addButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            addButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 62.86),
            addButton.heightAnchor.constraint(equalToConstant: 62.86),

            thumbnailCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            thumbnailCollectionView.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 11.45),
            thumbnailCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            thumbnailCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    private func setupCategorySection() {
        categoryContainer = UIView()
        categoryContainer.translatesAutoresizingMaskIntoConstraints = false
        categoryContainer.backgroundColor = UIColor.systemGray6
        categoryContainer.layer.cornerRadius = 10
        contentView.addSubview(categoryContainer)

        let categoryLabel = UILabel()
        categoryLabel.text = "당신의 Moments는?"
        categoryLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        categoryLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryContainer.addSubview(categoryLabel)

        NSLayoutConstraint.activate([
            // 카테고리 컨테이너 제약 조건
            categoryContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            categoryContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), // addButton의 leading과 동일하게 설정
            categoryContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // 카테고리 라벨 제약 조건
            categoryLabel.centerYAnchor.constraint(equalTo: categoryContainer.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor)

        ])
    }
    
    private func setupHowLabel() {
        let howLabel = UILabel()
        howLabel.text = "어떤 이야기를 담고 있나요?"
        howLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        howLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        howLabel.translatesAutoresizingMaskIntoConstraints = false
        subHowLabel = UILabel()
        subHowLabel.text = "최대 3개까지 선택할 수 있어요. (0 / 3)"
        subHowLabel.font = UIFont(name: "Pretendard-Light", size: 12)
        subHowLabel.textColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1)
        subHowLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(howLabel)
        contentView.addSubview(subHowLabel)

        NSLayoutConstraint.activate([
            howLabel.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 76.5),
            howLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
            howLabel.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor),

            subHowLabel.topAnchor.constraint(equalTo: howLabel.bottomAnchor, constant: 5),
            subHowLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
            subHowLabel.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor),
        ])
    }
    
    private func setupButtonsAboutCategoryButton() {
        guard let categoryIndex = self.categoryIndex,
              let buttonTitles = MockData.shared.rows[categoryIndex] else {
            print("유효하지 않은 카테고리 인덱스입니다.")
            return
        }

        // StackView가 이미 존재하면 기존 버튼을 제거
        if let existingStackView = contentView.subviews.first(where: { $0 is UIStackView }) as? UIStackView {
            existingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            existingStackView.removeFromSuperview()
        }

        // StackView 생성
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        // 서브 카테고리 버튼 생성
        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = selectedSubCategories.contains(title) ? UIFont(name: "Pretendard-SemiBold", size: 14) : UIFont(name: "Pretendard-Medium", size: 14)
            button.setTitleColor(#colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3450980392, alpha: 1), for: .normal)
            button.layer.borderWidth = 1.25
            button.layer.cornerRadius = 4
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16) // 버튼 내부 패딩 설정
            button.layer.borderColor = selectedSubCategories.contains(title) ? UIColor(red: 0.431, green: 0.431, blue: 0.871, alpha: 1).cgColor : UIColor(red: 0.961, green: 0.961, blue: 0.973, alpha: 1).cgColor
            button.backgroundColor = selectedSubCategories.contains(title) ? UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1) : UIColor.white
            button.addTarget(self, action: #selector(categoryItemSelected(_:)), for: .touchUpInside)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 42)
            ])
        }

        // 서브 카테고리 버튼을 기존 categoryContainer 아래에 배치
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 125),
            stackView.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
        ])
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        print("Button tapped: \(title), Tag: \(sender.tag)")
    }

    private func setupExpressionField() {
        let expressionLabel = UILabel()
        expressionLabel.text = "감정으로 Moments를 채워주세요!"
        expressionLabel.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        expressionLabel.textColor = .black
        expressionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(expressionLabel)

        NSLayoutConstraint.activate([
            // "글로 표현해보세요!"를 categoryButtons 아래에 위치
            expressionLabel.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 400),
            expressionLabel.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor),
            expressionLabel.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor)

        ])
    }

    private func setupTextInputField() {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 7
        backgroundView.layer.borderWidth = 1.28
        backgroundView.layer.borderColor = #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
        view.addSubview(backgroundView)

        textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Pretendard-Medium", size: 15)
        textView.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        textView.text = texts.first ?? ""
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = true

        // 패딩 설정 (가로 24, 세로 22)
        textView.textContainerInset = UIEdgeInsets(top: 22, left: 24, bottom: 22, right: 24)
        textView.textContainer.lineFragmentPadding = 0 // 텍스트뷰 내부 여백 제거

        textView.inputAccessoryView = doneToolbar
        backgroundView.addSubview(textView)

        // Placeholder Label
        let placeholderLabel = UILabel()
        placeholderLabel.text = "순간의 감정을 글로 표현해보세요" // 플레이스홀더 텍스트
        placeholderLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
        placeholderLabel.textColor = #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)

        // 플레이스홀더는 텍스트가 비어 있을 때만 표시
        placeholderLabel.isHidden = !textView.text.isEmpty

        characterCountLabel = UILabel()
        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        characterCountLabel.text = "0 / \(maxCharacterCount)"
        characterCountLabel.textColor = #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
        characterCountLabel.font = UIFont(name: "Pretendard-Regular", size: 15)
        textView.addSubview(characterCountLabel)

        NSLayoutConstraint.activate([
            // Text Input Background
            backgroundView.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 430),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backgroundView.heightAnchor.constraint(equalToConstant: 163),

            // TextView
            textView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 5),
            textView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -8),
            
            // Placeholder Label
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: textView.textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: textView.textContainerInset.left),

            // Placeholder Label
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: textView.textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: textView.textContainerInset.left),

            // Character Count Label
            characterCountLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -23),
            characterCountLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -25)
        ])

        backgroundView.layer.zPosition = -1
    }

    private func updateImageCountLabels() {
        imageCountLabel.text = "\(currentIndex + 1) / \(images.count > 0 ? images.count : 25)"
        if let stackView = addButton.subviews.first as? UIStackView,
           let countLabel = stackView.arrangedSubviews.last as? UILabel {
            countLabel.text = "\(images.count) / 25"
        }
    }

//    @objc private func saveTemporarily() {
//        presentSaveDraftModal()
//    }
    
//    func presentSaveDraftModal() {
//        let saveDraftModal = SaveDraftModal() // 커스텀 모달 뷰 컨트롤러
//            saveDraftModal.modalPresentationStyle = .overFullScreen // 화면 전체에 표시
//            saveDraftModal.modalTransitionStyle = .crossDissolve // 전환 애니메이션 설정
//            present(saveDraftModal, animated: true, completion: nil)
//        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    // `didSelectItemAt`에서 placeholder 업데이트 추가
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 현재 선택된 이미지의 텍스트 및 카테고리 저장
        if currentIndex < texts.count {
            texts[currentIndex] = textView.text // 이전 사진의 텍스트 저장
        } else {
            while texts.count <= currentIndex {
                texts.append("")
            }
            texts[currentIndex] = textView.text
        }

        if currentIndex < selectedCategoriesForImages.count {
            selectedCategoriesForImages[currentIndex] = selectedSubCategories // 이전 사진의 카테고리 저장
        } else {
            while selectedCategoriesForImages.count <= currentIndex {
                selectedCategoriesForImages.append([])
            }
            selectedCategoriesForImages[currentIndex] = selectedSubCategories
        }

        // 새로운 이미지 선택
        currentIndex = indexPath.item

        // 데이터 배열 크기 맞추기
        if texts.count <= currentIndex {
            while texts.count <= currentIndex {
                texts.append("")
            }
        }

        if selectedCategoriesForImages.count <= currentIndex {
            while selectedCategoriesForImages.count <= currentIndex {
                selectedCategoriesForImages.append([])
            }
        }

        mainImageView.image = images[currentIndex]
        textView.text = texts[currentIndex]
        selectedSubCategories = selectedCategoriesForImages[currentIndex] // 선택한 사진의 카테고리 불러오기

        // Placeholder 업데이트
        updatePlaceholderVisibility()

        // 텍스트 카운트 라벨 업데이트
        updateCharacterCountLabel()

        // 업데이트된 데이터로 UI 갱신
        updateCategoryButtonsAppearance()
        setupButtonsAboutCategoryButton()
        updateSubHowLabel()
        updateImageCountLabels()
        updateNextButtonState(for: nextButton)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
        cell.imageView.image = images[indexPath.item]
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        return cell
    }

    @objc private func deleteImage(_ sender: UIButton) {
        guard images.count > 1 else {
            let alert = UIAlertController(title: "삭제 불가", message: "최소 1장의 사진은 남아있어야 합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        let index = sender.tag
        guard index >= 0 && index < images.count else { return }

        images.remove(at: index)
        texts.remove(at: index)
        
        if currentIndex == index {
            currentIndex = max(0, currentIndex - 1)
        }

        thumbnailCollectionView.reloadData()
        mainImageView.image = images[currentIndex]
        textView.text = texts[currentIndex]
        updateImageCountLabels()
    }
    
    private func updateCharacterCountLabel() {
        let characterCount = textView.text.count
        characterCountLabel.text = "\(characterCount) / \(maxCharacterCount)"
        characterCountLabel.textColor = characterCount > maxCharacterCount ? .systemRed : .systemGray
    }
    
    // Placeholder 업데이트 함수 추가
    private func updatePlaceholderVisibility() {
        if let placeholderLabel = textView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }

    // `textViewDidChange`에서 placeholder 업데이트
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.count

        // 현재 이미지의 텍스트 업데이트
        if currentIndex < texts.count {
            texts[currentIndex] = textView.text
        }

        // Placeholder 업데이트
        updatePlaceholderVisibility()

        // 텍스트 카운트 라벨 업데이트
        updateCharacterCountLabel()

        // 버튼 상태 업데이트
        updateNextButtonState(for: nextButton)
    }
    
    var selectedButton: UIButton?

    private func setupCategoryButtons() {
        // ScrollView 생성
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false // 세로 스크롤 비활성화
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = false // 세로 방향 바운스 비활성화
        scrollView.showsHorizontalScrollIndicator = false // 스크롤바 제거
        scrollView.layer.zPosition = -1 // 썸네일 컬렉션 뷰와 addButton보다 계층이 낮음
        scrollView.isUserInteractionEnabled = true // 스크롤 이벤트 활성화
        view.addSubview(scrollView)

        // StackView 생성
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        let buttonTitles = ["이동 · 여정", "사람 · 문화", "음식 · 맛", "자연 · 풍경", "도시 · 유산"] // 필요한 버튼 제목
        for (index, title) in buttonTitles.enumerated() { // `enumerated`로 인덱스 추가
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
            button.layer.cornerRadius = 18.5
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 13)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)

            // 초기화 시 첫 번째 버튼을 선택 상태로 설정
            if index == 0 {
                selectedButton = button
                button.backgroundColor = UIColor(#colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.7647058824, alpha: 1))
                button.setTitleColor(.white, for: .normal)
                
                categoryIndex = 0 // 첫 번째 카테고리 선택
            }
        }
        // ScrollView와 StackView 제약 조건
        NSLayoutConstraint.activate([
            // ScrollView 제약 조건
            scrollView.topAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // StackView 제약 조건
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        categoryIndex = 0  //첫 번째 카테고리 인덱스
        setupButtonsAboutCategoryButton() // 세부 카테고리 초기화
        // 터치 이벤트 설정
        scrollView.isUserInteractionEnabled = true
        view.bringSubviewToFront(scrollView) // 스크롤 뷰 터치 활성화를 위해
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        if let previousButton = selectedButton {
            previousButton.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
            previousButton.setTitleColor(.black, for: .normal)
        }
        // 새로 선택된 버튼 색상 변경
        sender.backgroundColor = UIColor(#colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.7647058824, alpha: 1))
        sender.setTitleColor(.white, for: .normal)
        sender.layer.borderWidth = 0
        // 현재 버튼을 선택된 버튼으로 설정
        selectedButton = sender

        guard let title = sender.titleLabel?.text else { return }
        let mockData = MockData()

        // 버튼 타이틀에 따라 인덱스 설정
        switch title {
            case "이동 · 여정": categoryIndex = 0
            case "사람 · 문화": categoryIndex = 1
            case "음식 · 맛": categoryIndex = 2
            case "자연 · 풍경": categoryIndex = 3
            case "도시 · 유산": categoryIndex = 4
        default: return
        }

        guard let index = categoryIndex, let data = mockData.rows[index] else {
            print("데이터 없음")
            return
        }
        
        setupButtonsAboutCategoryButton()
    }
    
    // 카테고리 버튼 선택/해제 시 호출되는 메서드
    @objc private func categoryItemSelected(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

        if selectedSubCategories.contains(title) {
            selectedSubCategories.removeAll { $0 == title }
            sender.backgroundColor = UIColor.white
            sender.layer.borderColor = UIColor(red: 0.961, green: 0.961, blue: 0.973, alpha: 1).cgColor
            sender.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 14)
        } else {
            guard selectedSubCategories.count < 3 else {
                print("최대 3개의 서브 카테고리만 선택할 수 있습니다.")
                return
            }
            selectedSubCategories.append(title)
            sender.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
            sender.layer.borderColor = UIColor(red: 0.431, green: 0.431, blue: 0.871, alpha: 1).cgColor
            sender.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 14)
//            sender.setTitleColor(.black, for: .normal)
        }

        if currentIndex < selectedCategoriesForImages.count {
            selectedCategoriesForImages[currentIndex] = selectedSubCategories
        } else {
            while selectedCategoriesForImages.count <= currentIndex {
                selectedCategoriesForImages.append([])
            }
            selectedCategoriesForImages[currentIndex] = selectedSubCategories
        }

        updateCategoryButtonsAppearance()
        updateNextButtonState(for: nextButton)
        updateSubHowLabel() // 여기서도 subHowLabel 업데이트
    }

    private func updateSubHowLabel() {
        // 현재 선택된 사진에 대응하는 서브 카테고리 수 가져오기
        let count = selectedSubCategories.count
        subHowLabel.text = "최대 3개까지 선택할 수 있어요. (\(count) / 3)"
        subHowLabel.textColor = count > 0
            ? UIColor(red: 0.431, green: 0.431, blue: 0.871, alpha: 1)
            : UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1)
        subHowLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
    }

    // 하위 카테고리 버튼 UI 업데이트 함수
    private func updateCategoryButtonsAppearance() {
        guard let stackView = contentView.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }

        for case let button as UIButton in stackView.arrangedSubviews {
            if let title = button.title(for: .normal) {
                button.backgroundColor = selectedSubCategories.contains(title) ? UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1) : UIColor.white
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupNextButton() {
        nextButton = UIButton(type: .system)
        nextButton.setTitle("다음", for: .normal)

        // 비활성화
        nextButton.isEnabled = false
        nextButton.setTitleColor(UIColor(red: 0.54, green: 0.54, blue: 0.54, alpha: 1), for: .normal)
        nextButton.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
        
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nextButton.layer.cornerRadius = 8
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

        contentView.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 23),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 52),
        ])
        updateNextButtonState(for: nextButton)  // 초기 상태 업데이트
    }
    
    
    private func updateNextButtonState(for button: UIButton) {
        // `texts`와 `selectedCategoriesForImages` 배열 크기를 `images` 크기에 맞추기
        if texts.count < images.count {
            texts.append(contentsOf: Array(repeating: "", count: images.count - texts.count))
        }
        if selectedCategoriesForImages.count < images.count {
            selectedCategoriesForImages.append(contentsOf: Array(repeating: [], count: images.count - selectedCategoriesForImages.count))
        }

        // 모든 사진이 유효한지 확인
        let isAllPhotosValid = images.indices.allSatisfy { index in
            let text = texts[index].trimmingCharacters(in: .whitespacesAndNewlines)
            let categories = selectedCategoriesForImages[index]
            return !text.isEmpty || !categories.isEmpty
        }

        // 버튼 상태 업데이트
        if isAllPhotosValid {
            // 활성화 상태
            button.isEnabled = true
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.7647058824, alpha: 1)
        } else {
            // 비활성화 상태
            button.isEnabled = false
            button.setTitleColor(UIColor(red: 0.54, green: 0.54, blue: 0.54, alpha: 1), for: .normal)
            button.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
        }
    }
    
    @objc private func nextButtonTapped() {
        guard let recordUUID = Int(recordID) else {
            print("유효하지 않은 Record ID: \(recordID)")
            return
        }

        // 저장된 데이터가 없을 경우 경고 메시지 출력
        guard !images.isEmpty else {
            print("이미지가 없습니다.")
            let alert = UIAlertController(title: "이미지 없음", message: "최소 한 장의 이미지를 추가해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // 현재 이미지를 저장
        if currentIndex < texts.count {
            texts[currentIndex] = textView.text
        }
        if currentIndex < selectedCategoriesForImages.count {
            selectedCategoriesForImages[currentIndex] = selectedSubCategories
        }
        print(selectedCategoriesForImages)
        
        // 각 이미지 관련 정보 출력
        var savedImagePaths: [String] = [] // 로컬에 저장된 이미지 경로들을 담을 배열
        
        print("현재 Record ID (\(recordID))의 이미지 정보:")
           for (index, image) in images.enumerated() {
               let text = texts[index]
               let categories = selectedCategoriesForImages[index].joined(separator: ", ")

               // 고유한 파일 이름 생성
               let fileName = "\(UUID().uuidString).jpg"  // UUID를 사용한 고유한 파일 이름
               if let savedImagePath = saveImageToLocalFile(image: image, fileName: fileName) {
                   savedImagePaths.append(savedImagePath) // 이미지 경로를 배열에 추가
                   print("사진 \(index + 1):")
                   print("  이미지 경로: \(savedImagePath)")
                   print("  텍스트: \(text)")
                   print("  카테고리: \(categories)")
               } else {
                   print("사진 \(index + 1): 이미지 저장 실패")
               }
           }
        
        print("저장된 이미지 경로들: \(savedImagePaths)")

        for (index, image) in images.enumerated() {
            let text = texts[index]
            let category = selectedCategoriesForImages[index].joined(separator: ", ")

            let success = TravelRecordManager.shared.addPhoto(
                to: Int(recordID)!,
                image: image,
                text: text,
                categories: category
            )
            if success {
                print("사진 \(index + 1) 추가 성공")
            } else {
                print("사진 \(index + 1) 추가 실패")
            }
        }
        // `metadata` 생성
        let metadata: [[String: Any]] = images.enumerated().map { index, _ in
            let imagePath = savedImagePaths[index]  // savedImagePaths에서 가져옴
            return [
                "postId": TravelRecordManager.shared.postId!,
                "content": texts[index],
                "categories": selectedCategoriesForImages[index],
                "pid": "unique_pid_\(index + 1)",
            ]
        }

        APIService.shared.uploadImages(
            endpoint: "/stories",
            images: images,
            metadata: metadata
        ) { result in
            switch result {
            case .success(let response):
                print("이미지 업로드 성공:", response)
                let savedPhotosVC = SavedPhotosViewController()
                savedPhotosVC.recordID = self.recordID
                savedPhotosVC.modalPresentationStyle = .fullScreen
                self.present(savedPhotosVC, animated: true)
            case .failure(let error):
                print("이미지 업로드 실패:", error.localizedDescription)
            }
        }
        if let record = TravelRecordManager.shared.getRecord(by: recordUUID) {
            for (index, photo) in record.stories.enumerated() {
                print("Photo \(index + 1):")
                print("    Image Path: \(photo.imagePath)")
                print("    content: \(photo.content)")
                print("    Category: \(photo.categories)")
            }
        }
    }

    func saveImageToLocalFile(image: UIImage, fileName: String) -> String? {
        // 이미지 데이터를 JPEG 형식으로 변환
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("이미지 데이터를 생성할 수 없습니다.")
            return nil
        }

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        do {// 파일을 저장
            try imageData.write(to: fileURL)
            return fileURL.path // 저장된 파일의 경로 반환
        } catch {
            print("이미지 저장 실패: \(error)")
            return nil
        }
    }
}

extension UIView {
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }

        for subview in self.subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }

        return nil
    }
}
