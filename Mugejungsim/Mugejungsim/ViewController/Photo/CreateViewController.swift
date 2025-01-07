import Alamofire
import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate {
    private let maxTitleLength = 10

    var startDateYear: String?
    var startDateMonth: String?
    var startDateDay: String?
    var endDateYear: String?
    var endDateMonth: String?
    var endDateDay: String?
    
    // Local Flow 위한 변수
    var travelRecordID: String = ""
    var travelTitle: String = ""
    var companion: String = ""
    var startDate: String = ""
    var endDate: String = ""
    var location: String = ""
    
    let startDateStackView = CreateViewController.createDateStackView(title: "시작일자")
    let endDateStackView = CreateViewController.createDateStackView(title: "종료일자")
    
    // TravelRecordManager를 통해 userId 설정
        var userId: Int? {
            didSet {
                TravelRecordManager.shared.userId = userId
            }
        }
    var recordID : String = ""
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "여행의 이름을 지어주세요!"
        label.font =  UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = #colorLiteral(red: 0.1879820824, green: 0.1879820824, blue: 0.1879820824, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let titleCount: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.textColor = #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
        
        let text = "0 / 10"
        let attributedString = NSMutableAttributedString(string: text)
        
        // 자간 설정 (-1px)
        attributedString.addAttribute(.kern, value: -1, range: NSRange(location: 4, length: 1)) // 숫자 1과 0 사이에 적용
        
        label.attributedText = attributedString
        return label
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목을 입력해주세요"
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        textField.borderStyle = .none
        textField.tintColor = UIColor(red: 0.43, green: 0.43, blue: 0.87, alpha: 1) // #6E6EDE
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
//    let saveButton: UIButton = {
//            let button = UIButton(type: .system)
//            button.setTitle("임시저장", for: .normal)
//            button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
//            button.setTitleColor(UIColor(red: 0.824, green: 0.824, blue: 0.824, alpha: 1), for: .normal)
//            button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            return button
//        }()
    
    let titleUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // 기본 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "언제 떠났나요?"
        label.font =  UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    @objc private func didTapSaveButton() {
//        print("SaveButton 누름")
//
//        // SaveDraftModal 모달을 생성
//        let saveDraftModal = SaveDraftModal()
//        saveDraftModal.modalPresentationStyle = .overFullScreen // 전체 화면 모달로 띄움
//        saveDraftModal.view.alpha = 0 // 초기 알파 값 설정
//
//        // 모달 추가 및 애니메이션
//        self.present(saveDraftModal, animated: false) {
//            UIView.animate(withDuration: 0.3) {
//                saveDraftModal.view.alpha = 1 // 서서히 등장
//            }
//        }
//    }

    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "어디로 떠났나요?"
        label.font =  UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let locationCount: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 12)
        label.textColor = #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let text = "0 / 10"
        let attributedString = NSMutableAttributedString(string: text)
        
        // 자간 설정 (-1px)
        attributedString.addAttribute(.kern, value: -1, range: NSRange(location: 4, length: 1)) // "1"과 "0" 사이
        
        label.attributedText = attributedString
        return label
    }()
    
    let locationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "여행지를 입력해주세요"
        textField.font = UIFont(name: "Pretendard-Regular", size: 16)
        textField.borderStyle = .none
        textField.tintColor = UIColor(red: 0.43, green: 0.43, blue: 0.87, alpha: 1) // #6E6EDE
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let locationUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // 기본 색상
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let companionLabel: UILabel = {
        let label = UILabel()
        label.text = "누구와 함께 했나요?"
        label.font =  UIFont(name: "Pretendard-Bold", size: 20)
        label.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var companionButtons: [UIButton] = []
    var selectedCompanion: UIButton?
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        if let customFont = UIFont(name: "Pretendard-SemiBold", size: 15) {
            button.titleLabel?.font = customFont
        }
        button.setTitleColor(UIColor(red: 0.541, green: 0.541, blue: 0.541, alpha: 1), for: .normal) // #8A8A8A
        button.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let clearButton1: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .lightGray
        button.isHidden = true // 초기에는 숨김 상태
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clearTextField(_:)), for: .touchUpInside)
        return button
    }()

    let clearButton2: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .lightGray
        button.isHidden = true // 초기에는 숨김 상태
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clearTextField(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - View Life Cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        view.addSubview(titleCount)
//        configureTextFieldDelegates(in: startDateStackView)
//        configureTextFieldDelegates(in: endDateStackView)
//
//        titleTextField.delegate = self
//        locationTextField.delegate = self
//
//        setupCustomNavigationBar()
//        setupUI()
//        setupCompanionButtons()
//        setupObservers()
//
//        titleCount.translatesAutoresizingMaskIntoConstraints = false
//        titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
//        titleTextField.delegate = self
//        locationTextField.delegate = self
//
//        titleCount.translatesAutoresizingMaskIntoConstraints = false
//
//
//    }
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            view.addSubview(titleCount)
            configureTextFieldDelegates(in: startDateStackView)
            configureTextFieldDelegates(in: endDateStackView)
        
            titleTextField.addTarget(self, action: #selector(updateClearButtonState(_:)), for: .editingChanged)
            locationTextField.addTarget(self, action: #selector(updateClearButtonState(_:)), for: .editingChanged)
            
            titleTextField.delegate = self
            locationTextField.delegate = self
            
            setupCustomNavigationBar()
            setupUI()
            setupCompanionButtons()
            setupObservers()
            setupDateFieldObservers()
        
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

            titleCount.translatesAutoresizingMaskIntoConstraints = false
            titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
            titleTextField.delegate = self
            locationTextField.delegate = self
            
            titleCount.translatesAutoresizingMaskIntoConstraints = false
        
        
            clearButton1.addTarget(self, action: #selector(clearTextField(_:)), for: .touchUpInside)
            clearButton2.addTarget(self, action: #selector(clearTextField(_:)), for: .touchUpInside)
        
        // userId 확인 (로그인에서 받은 userId가 잘 넘어왔는지 확인)
            if let userId = TravelRecordManager.shared.userId {
                print("CreateViewController에서 확인된 userId: \(userId)")
            } else {
                print("userId가 설정되지 않았습니다.")
            }
        }
    
    deinit {
            // 키보드 이벤트 해제
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        let textCount = textField.text?.count ?? 0

        // 제목 글자 수 제한
        if textCount > maxTitleLength {
            textField.text = String(textField.text?.prefix(maxTitleLength) ?? "")
        }

        titleCount.text = "\(textField.text?.count ?? 0) / \(maxTitleLength)"

        // 입력 여부에 따라 색상 변경
        let isTextEntered = textCount > 0
        let newColor = isTextEntered ? UIColor(red: 0.82, green: 0.82, blue: 0.96, alpha: 1) : UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // #D2D2F5 또는 기본 색상

        titleUnderline.backgroundColor = newColor
        titleCount.textColor = newColor

//        // "임시저장" 버튼 활성화 여부
//        validateInputsForSaveButton()
    }
    
    @objc private func locationTextFieldDidChange(_ textField: UITextField) {
        let textCount = textField.text?.count ?? 0

        // 여행지 글자 수 제한
        if textCount > 10 {
            textField.text = String(textField.text?.prefix(10) ?? "")
        }

        locationCount.text = "\(textField.text?.count ?? 0) / 10"

        // 입력 여부에 따라 색상 변경
        let isTextEntered = textCount > 0
        let newColor = isTextEntered ? UIColor(red: 0.82, green: 0.82, blue: 0.96, alpha: 1) : UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // #D2D2F5 또는 기본 색상

        locationUnderline.backgroundColor = newColor
        locationCount.textColor = newColor

//        // "임시저장" 버튼 활성화 여부
//        validateInputsForSaveButton()
    }
    
//    private func validateInputsForSaveButton() {
//        // 제목, 여행지, 동행자 상태 확인
//        let isTitleFilled = !(titleTextField.text?.isEmpty ?? true)
//        let isLocationFilled = !(locationTextField.text?.isEmpty ?? true)
//        let isCompanionSelected = selectedCompanion != nil
//
//        // 하나라도 입력 또는 선택된 경우 활성화
//        let isAnyFieldFilled = isTitleFilled || isLocationFilled || isCompanionSelected
//
////        // 버튼 활성화/비활성화 및 색상 업데이트
////        saveButton.setTitleColor(
////            isAnyFieldFilled
////                ? UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1) // #979797
////                : UIColor(red: 0.824, green: 0.824, blue: 0.824, alpha: 1), // 기본 색상
////            for: .normal
////        )
////
////        saveButton.isEnabled = isAnyFieldFilled // 버튼 활성화 상태 설정
//    }
    
    @objc private func updateClearButtonState(_ textField: UITextField) {
        if textField == titleTextField {
            clearButton1.isHidden = (textField.text ?? "").isEmpty
        } else if textField == locationTextField {
            clearButton2.isHidden = (textField.text ?? "").isEmpty
        }
    }
    
    private func setupCustomNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .clear
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        let separator = UIView()
        separator.backgroundColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "여행 기록 쓰기"
        titleLabel.font = UIFont(name: "Pretendard-SemiBold", size: 19)
        titleLabel.textColor = #colorLiteral(red: 0.1879820824, green: 0.1879820824, blue: 0.1879820824, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "back_button"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
//        let saveButton = UIButton(type: .system)
//        saveButton.setTitle("임시저장", for: .normal)
//        saveButton.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
//        saveButton.setTitleColor(UIColor(red: 0.824, green: 0.824, blue: 0.824, alpha: 1), for: .normal)
//        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add navBar and its subviews
        view.addSubview(navBar)
        navBar.addSubview(separator)
        navBar.addSubview(titleLabel)
        navBar.addSubview(backButton)
//        navBar.addSubview(saveButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Navigation Bar
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 48),
            
            // Separator Line
            separator.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 24),
            separator.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -24),
            separator.heightAnchor.constraint(equalToConstant: 0.3),
            
            // Title Label
            titleLabel.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            
            // Back Button
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 24),
            
            // Save Button
//            saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor), // Title Label과 Y축 정렬
//            saveButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -24),
        ])
    }
    
    @objc private func clearTextField(_ sender: UIButton) {
        if sender == clearButton1 {
            titleTextField.text = ""
            titleCount.text = "0 / \(maxTitleLength)" // 제목 글자 수 업데이트
            clearButton1.isHidden = true // 버튼 숨기기
            
            // 제목 텍스트 필드 관련 색상 초기화
            titleUnderline.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // 기본 색상
            titleCount.textColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // 기본 색상
        } else if sender == clearButton2 {
            locationTextField.text = ""
            locationCount.text = "0 / 10" // 여행 장소 글자 수 업데이트
            clearButton2.isHidden = true // 버튼 숨기기

            // 여행 장소 텍스트 필드 관련 색상 초기화
            locationUnderline.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // 기본 색상
            locationCount.textColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // 기본 색상
        }

        // 입력값 상태 재검토 및 버튼 활성화 여부 확인
        validateInputs()
//        validateInputsForSaveButton()
    }
    
    @objc private func didTapBackButton() {
        let stopWritingVC = StopWritingViewController()
        stopWritingVC.modalPresentationStyle = .overFullScreen
        stopWritingVC.delegate = self // Delegate 설정
        present(stopWritingVC, animated: false, completion: nil) // 애니메이션 제거
    }
    
    

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(titleTextField)
        view.addSubview(titleUnderline)
        view.addSubview(dateLabel)
        view.addSubview(startDateStackView)
        view.addSubview(endDateStackView)
        view.addSubview(locationLabel)
        view.addSubview(locationTextField)
        view.addSubview(locationUnderline)
        view.addSubview(locationCount)
        view.addSubview(companionLabel)
        view.addSubview(nextButton)
        view.addSubview(clearButton1) // X 버튼을 추가
        clearButton1.widthAnchor.constraint(equalToConstant: 20).isActive = true
        clearButton1.heightAnchor.constraint(equalToConstant: 20).isActive = true

        view.addSubview(clearButton2) // X 버튼을 추가
        clearButton2.widthAnchor.constraint(equalToConstant: 20).isActive = true
        clearButton2.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleCount.translatesAutoresizingMaskIntoConstraints = false

        titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)

        // titleLabel과 titleTextField가 동일한 부모 뷰에 속하도록 constraint 수정
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 75),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            titleUnderline.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 2),
            titleUnderline.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            titleUnderline.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            titleUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            
            clearButton1.topAnchor.constraint(equalTo: titleTextField.topAnchor, constant: 16), // X 버튼을 텍스트 필드 중앙에 배치
            clearButton1.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor), // 텍스트 필드의 오른쪽에 배치
            
            titleCount.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 5),
            titleCount.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleCount.bottomAnchor, constant: 25),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            startDateStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            startDateStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            startDateStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70),
            
            endDateStackView.topAnchor.constraint(equalTo: startDateStackView.bottomAnchor, constant: 16),
            endDateStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            endDateStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70),
            
            locationLabel.topAnchor.constraint(equalTo: endDateStackView.bottomAnchor, constant: 44),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            locationTextField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            locationTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            locationTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            locationTextField.heightAnchor.constraint(equalToConstant: 40),
            
            clearButton2.topAnchor.constraint(equalTo: locationTextField.topAnchor, constant: 16), // X 버튼을 텍스트 필드 중앙에 배치
            clearButton2.trailingAnchor.constraint(equalTo: locationTextField.trailingAnchor), // 텍스트 필드의 오른쪽에 배치
          
            locationUnderline.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 2),
            locationUnderline.leadingAnchor.constraint(equalTo: locationTextField.leadingAnchor),
            locationUnderline.trailingAnchor.constraint(equalTo: locationTextField.trailingAnchor),
            locationUnderline.heightAnchor.constraint(equalToConstant: 1.5),
            
            locationCount.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 5),
            locationCount.trailingAnchor.constraint(equalTo: locationTextField.trailingAnchor),
            
            companionLabel.topAnchor.constraint(equalTo: locationCount.bottomAnchor, constant: 25),
            companionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    
    private func setupCompanionButtons() {
        let options = ["혼자", "가족과", "친구와", "연인과", "기타"]
        let buttonWidth: CGFloat = 76
        let buttonHeight: CGFloat = 39
        let sidePadding: CGFloat = 24 // 좌우 고정 패딩
        let maxRowWidth: CGFloat = UIScreen.main.bounds.width - (sidePadding * 2) // 한 행에서 사용할 수 있는 최대 너비
        let firstRowButtonsCount = 4 // 첫 행에 배치할 버튼 개수
        let buttonSpacing: CGFloat = (maxRowWidth - (CGFloat(firstRowButtonsCount) * buttonWidth)) / CGFloat(firstRowButtonsCount - 1) // 버튼 간 동적 간격 계산

        var previousButton: UIButton?
        var previousRowFirstButton: UIButton?

        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 15) // 기본 상태 Regular 폰트

            button.layer.cornerRadius = buttonHeight / 2
            button.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(companionButtonTapped(_:)), for: .touchUpInside)
            companionButtons.append(button)
            view.addSubview(button)

            // 버튼 크기 고정
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: buttonHeight)
            ])

            if index < firstRowButtonsCount { // 첫 행
                if previousButton == nil {
                    // 첫 번째 버튼
                    button.topAnchor.constraint(equalTo: companionLabel.bottomAnchor, constant: 14).isActive = true
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding).isActive = true
                    previousRowFirstButton = button
                } else {
                    // 같은 행에 버튼 추가
                    button.topAnchor.constraint(equalTo: previousButton!.topAnchor).isActive = true
                    button.leadingAnchor.constraint(equalTo: previousButton!.trailingAnchor, constant: buttonSpacing).isActive = true
                }
            } else {
                // "기타" 버튼은 새 행으로 이동
                button.topAnchor.constraint(equalTo: previousRowFirstButton!.bottomAnchor, constant: 14).isActive = true
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding).isActive = true
            }

            previousButton = button
        }
//        validateInputsForSaveButton()
    }
    
    @objc func companionButtonTapped(_ sender: UIButton) {
        if selectedCompanion == sender {
            sender.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
            sender.setTitleColor(.black, for: .normal)
            sender.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 15) // 선택 해제 시 Regular 폰트
            selectedCompanion = nil
        } else {
            companionButtons.forEach {
                $0.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
                $0.setTitleColor(.black, for: .normal)
                $0.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 15) // 다른 버튼은 Regular 폰트로 변경
            }
            sender.backgroundColor = UIColor(red: 0.459, green: 0.451, blue: 0.765, alpha: 1)
            sender.setTitleColor(.white, for: .normal)
            sender.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 15) // 선택된 버튼은 Medium 폰트로 변경
            selectedCompanion = sender
        }
        validateInputs()
    }
    
    static func createDateStackView(title: String) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.textColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1)
        
        let yearField = CreateViewController.createDateField(placeholder: "YYYY")
        yearField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yearField.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        let yearLabel = UILabel()
        yearLabel.text = "년"
        yearLabel.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        yearLabel.textColor = .black
        
        let yearStack = UIStackView(arrangedSubviews: [yearField, yearLabel])
        yearStack.axis = .horizontal
        yearStack.spacing = 4
        yearStack.alignment = .center
        
        let monthField = CreateViewController.createDateField(placeholder: "MM")
        monthField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthField.widthAnchor.constraint(equalToConstant: 43)
        ])
        let monthLabel = UILabel()
        monthLabel.text = "월"
        monthLabel.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        monthLabel.textColor = .black
        
        let monthStack = UIStackView(arrangedSubviews: [monthField, monthLabel])
        monthStack.axis = .horizontal
        monthStack.spacing = 4
        monthStack.alignment = .center
        
        let dayField = CreateViewController.createDateField(placeholder: "DD")
        dayField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dayField.widthAnchor.constraint(equalToConstant: 43)
        ])
        let dayLabel = UILabel()
        dayLabel.text = "일"
        dayLabel.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        dayLabel.textColor = .black
        
        let dayStack = UIStackView(arrangedSubviews: [dayField, dayLabel])
        dayStack.axis = .horizontal
        dayStack.spacing = 4
        dayStack.alignment = .center
        
        let fieldsStack = UIStackView(arrangedSubviews: [yearStack, monthStack, dayStack])
        fieldsStack.axis = .horizontal
        fieldsStack.spacing = 8
        fieldsStack.isLayoutMarginsRelativeArrangement = true
        fieldsStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8) // 패딩 적용
        fieldsStack.distribution = .equalSpacing
        fieldsStack.alignment = .center
        
        let stack = UIStackView(arrangedSubviews: [label, fieldsStack])
        stack.axis = .vertical
        stack.spacing = 13
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }
    
    static func createDateField(placeholder: String) -> UITextField {
        let textField = UITextField()
            textField.placeholder = placeholder
            textField.font = UIFont(name: "Pretendard-Regular", size: 20)
            textField.textColor = UIColor(red: 0.141, green: 0.141, blue: 0.141, alpha: 1)
            textField.tintColor = UIColor(red: 0.43, green: 0.43, blue: 0.87, alpha: 1) // #6E6EDE
            textField.borderStyle = .none
            textField.textAlignment = .center
            textField.keyboardType = .numberPad

        // Set placeholder color to #D2D2D2
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // #D2D2D2
            ]
        )

        let underline = UIView()
        underline.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // #D2D2D2
        underline.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(underline)

        NSLayoutConstraint.activate([
            underline.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 6), // Padding of 6
            underline.heightAnchor.constraint(equalToConstant: 1.5) // Thickness of 1.5
        ])

        return textField
    }
    
    // Setup Observers에 여행 장소 텍스트 필드 변화 감지 추가
    func setupObservers() {
        [titleTextField, locationTextField].forEach {
            $0.addTarget(self, action: #selector(validateInputs), for: .editingChanged)
        }
        locationTextField.addTarget(self, action: #selector(locationTextFieldDidChange(_:)), for: .editingChanged)
        titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    /// `모든 텍스트 안에 delegate 설정
    private func configureTextFieldDelegates(in stackView: UIStackView) {
        for subview in stackView.arrangedSubviews {
            if let innerStackView = subview as? UIStackView {
                configureTextFieldDelegates(in: innerStackView)
            } else if let textField = subview as? UITextField {
                textField.delegate = self
                textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
                
                // 키보드 완료 버튼 추가
                let toolbar = UIToolbar()
                toolbar.sizeToFit()
                let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                toolbar.setItems([flexibleSpace, doneButton], animated: false)
                // 모든 키보드
                titleTextField.inputAccessoryView = toolbar
                locationTextField.inputAccessoryView = toolbar
                textField.inputAccessoryView = toolbar
            }
        }
    }
   


    @objc private func doneButtonTapped() {
        view.endEditing(true) // 키보드 닫기
    }

    private func getAllTextFields() -> [UITextField] {
        var allTextFields: [UITextField] = []
        allTextFields.append(titleTextField)
        collectTextFields(from: startDateStackView, into: &allTextFields)
        collectTextFields(from: endDateStackView, into: &allTextFields)
        allTextFields.append(locationTextField)
        return allTextFields
    }
    
    // date text가 입력되는지 확인하는 디버깅 function
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let placeholder = textField.placeholder else { return }
        
        // textField가 특정 stackView의 자손인지 확인
        func isTextFieldInViewHierarchy(_ textField: UITextField, parentView: UIView) -> Bool {
            var currentView: UIView? = textField
            while let superview = currentView?.superview {
                if superview == parentView {
                    return true
                }
                currentView = superview
            }
            return false
        }
        switch placeholder {
        case "YYYY":
            if isTextFieldInViewHierarchy(textField, parentView: startDateStackView) {
                startDateYear = text
            } else if isTextFieldInViewHierarchy(textField, parentView: endDateStackView) {
                endDateYear = text
            }
        case "MM":
            if isTextFieldInViewHierarchy(textField, parentView: startDateStackView) {
                startDateMonth = text
            } else if isTextFieldInViewHierarchy(textField, parentView: endDateStackView) {
                endDateMonth = text
            }
        case "DD":
            if isTextFieldInViewHierarchy(textField, parentView: startDateStackView) {
                startDateDay = text
            } else if isTextFieldInViewHierarchy(textField, parentView: endDateStackView) {
                endDateDay = text
            }
        default: break
        }
        
        print("시작일자: \(startDateYear ?? "없음")-\(startDateMonth ?? "없음")-\(startDateDay ?? "없음")")
        print("종료일자: \(endDateYear ?? "없음")-\(endDateMonth ?? "없음")-\(endDateDay ?? "없음")")
        
        // 유효성 검사 실행
        validateInputs()
//        validateInputsForSaveButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 모든 텍스트 필드 순서대로 배열화
        var allTextFields: [UITextField] = []
        
        // 텍스트 필드 탐색
        allTextFields.append(titleTextField)
        collectTextFields(from: startDateStackView, into: &allTextFields)
        collectTextFields(from: endDateStackView, into: &allTextFields)
        allTextFields.append(locationTextField)
        
        // 현재 텍스트 필드의 인덱스를 찾고 다음 텍스트 필드로 이동
        if let currentIndex = allTextFields.firstIndex(of: textField) {
            if currentIndex < allTextFields.count - 1 {
                let nextTextField = allTextFields[currentIndex + 1]
                nextTextField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        return true
    }
    
    /// `UIStackView` 안의 모든 텍스트 필드를 탐색하여 배열에 추가
    private func collectTextFields(from stackView: UIStackView, into textFields: inout [UITextField]) {
        for subview in stackView.arrangedSubviews {
            if let innerStackView = subview as? UIStackView {
                collectTextFields(from: innerStackView, into: &textFields)
            } else if let textField = subview as? UITextField {
                textFields.append(textField)
            }
        }
    }
    @objc func validateInputs() {
        let isTitleFilled = !(titleTextField.text?.isEmpty ?? true) // 제목 입력 여부
        let isLocationFilled = !(locationTextField.text?.isEmpty ?? true) // 여행지 입력 여부
        let isCompanionSelected = selectedCompanion != nil // 동행자 선택 여부
        let isStartDateValid = isValidDate(year: startDateYear ?? "0000", month: startDateMonth ?? "00", day: startDateDay ?? "00") // 시작일 유효성
        let isEndDateValid = isValidDate(year: endDateYear ?? "0000", month: endDateMonth ?? "00", day: endDateDay ?? "00") // 종료일 유효성

        // 모든 조건이 충족되었는지 확인
        let isAllValid = isTitleFilled && isLocationFilled && isCompanionSelected && isStartDateValid && isEndDateValid

        // "다음" 버튼의 상태와 색상 업데이트
        nextButton.isEnabled = isAllValid
        nextButton.backgroundColor = isAllValid
            ? UIColor(red: 0.459, green: 0.451, blue: 0.765, alpha: 1) // 활성화 색상
            : UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1) // 비활성화 색상
        nextButton.setTitleColor(isAllValid ? .white : UIColor(red: 0.541, green: 0.541, blue: 0.541, alpha: 1), for: .normal) // #8A8A8A
    }
    
    private func isValidDateField(_ text: String, type: String) -> Bool {
        switch type {
        case "YYYY":
            return text.count == 4 && Int(text) != nil
        case "MM":
            if let month = Int(text) {
                return month >= 1 && month <= 12
            }
            return false
        case "DD":
            if let day = Int(text) {
                return day >= 1 && day <= 31
            }
            return false
        default:
            return false
        }
    }
    
    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 현재 텍스트
        guard let currentText = textField.text else { return true }
        
        // 변경될 텍스트
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // 입력 중 상태 확인 (한국어 조합 등)
        if let markedTextRange = textField.markedTextRange {
            // 조합 중인 텍스트는 허용
            if textField.position(from: markedTextRange.start, offset: 0) != nil {
                return true
            }
        }
        // 삭제 동작 처리 (replacementString이 빈 문자열이면 삭제)
        if string.isEmpty { return true }
        
        // 길이 제한 및 유효성 검사
        switch textField.placeholder {
        case "YYYY":
            return updatedText.count <= 4 // 최대 4자
        case "MM":
            if updatedText.count <= 2, let month = Int(updatedText), month >= 1 && month <= 12 {
                return true
            }
            return false // 잘못된 입력
        case "DD":
            if updatedText.count <= 2, let day = Int(updatedText), day >= 1 && day <= 31 {
                return true
            }
            return false // 잘못된 입력
        default:
            return true // 제한 없음
        }
    }
    
    @objc func nextButtonTapped() {
        travelTitle = titleTextField.text ?? "없음"
        companion = selectedCompanion?.title(for: .normal) ?? "없음"
        startDate = "\(startDateYear ?? "0000")-\(startDateMonth ?? "00")-\(startDateDay ?? "00")"
        endDate = "\(endDateYear ?? "0000")-\(endDateMonth ?? "00")-\(endDateDay ?? "00")"
        location = locationTextField.text ?? "없음"

        let newRecord = TravelRecord(
            id: 0,
            pid: "",
            title: travelTitle,
            startDate: startDate,
            endDate: endDate,
            location: location,
            companion: companion,
            bottle: "",
            oneLine1: "",
            oneLine2: ""
        )
        TravelRecordManager.shared.addRecord(newRecord)

        // 서버에 데이터 전송
        TravelRecordManager.shared.sendRecordToServer(newRecord) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let postId = json["postId"] as? Int {
                        TravelRecordManager.shared.postId = postId
                        print("Received postId: \(postId)")
//                        self.navigateToStoryEditor()
                        self.navigateToNextScreen(recordID: String(newRecord.id))
                    } else {
                        self.showAlert(title: "오류", message: "postId를 응답에서 찾을 수 없습니다.")
                    }
                case .failure(let error):
                    print("Error sending record to server: \(error.localizedDescription)")
                    self.showAlert(title: "오류", message: "서버 전송 중 오류가 발생했습니다.")
                }
            }
        }
        self.navigateToNextScreen(recordID: String(newRecord.id))
    }
    
    
    private func isValidDate(year: String, month: String, day: String) -> Bool {
        guard let yearInt = Int(year), yearInt >= 1000, yearInt <= 9999 else { return false }
        guard let monthInt = Int(month), monthInt >= 1, monthInt <= 12 else { return false }
        guard let dayInt = Int(day), dayInt >= 1 else { return false }
        let daysInMonth: [Int: Int] = [
            1: 31, 2: (yearInt % 4 == 0 && (yearInt % 100 != 0 || yearInt % 400 == 0)) ? 29 : 28,
            3: 31, 4: 30, 5: 31, 6: 30,
            7: 31, 8: 31, 9: 30, 10: 31,
            11: 30, 12: 31
        ]
        return dayInt <= (daysInMonth[monthInt] ?? 0)
    }
    
    private func navigateToNextScreen(recordID: String) {
        let uploadViewController = UploadViewController()
        uploadViewController.recordID = recordID
        uploadViewController.modalPresentationStyle = .fullScreen
        uploadViewController.modalTransitionStyle = .crossDissolve
        present(uploadViewController, animated: true, completion: nil)
    }
    
    private func navigateToStoryEditor() {
        let storyEditorVC = UploadViewController()
        storyEditorVC.recordID = recordID
        print(recordID)
        storyEditorVC.modalPresentationStyle = .fullScreen
        storyEditorVC.modalTransitionStyle = .crossDissolve
        self.present(storyEditorVC, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 키보드 나타날 때
        @objc private func keyboardWillShow(_ notification: Notification) {
            guard locationTextField.isFirstResponder,  // locationTextField가 활성화된 경우에만 작동
                  let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

            let keyboardHeight = keyboardFrame.height
            let bottomSafeArea = view.safeAreaInsets.bottom
            let additionalOffset: CGFloat = 20 // 키보드와 텍스트필드 간격 추가

            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - bottomSafeArea + additionalOffset))
            }
        }
        
        // MARK: - 키보드 사라질 때
        @objc private func keyboardWillHide(_ notification: Notification) {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = .identity // 화면을 원래 위치로 복구
            }
        }
    
    // MARK: - Setup Date Field Observers
    private func setupDateFieldObservers() {
        let dateFields = getAllDateFields()
        dateFields.forEach { field in
            field.addTarget(self, action: #selector(dateFieldEditingChanged(_:)), for: .editingChanged)
        }
    }

    // MARK: - Date Field Editing Changed
    @objc private func dateFieldEditingChanged(_ textField: UITextField) {
        if let underline = textField.subviews.first(where: { $0 is UIView }) as? UIView {
            let text = textField.text ?? ""
            underline.backgroundColor = text.isEmpty
                ? UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1) // 기본 색상
                : UIColor(red: 0.82, green: 0.82, blue: 0.96, alpha: 1) // #D2D2F5
        }
    }

    // MARK: - Helper to Get All Date Fields
    private func getAllDateFields() -> [UITextField] {
        var dateFields: [UITextField] = []
        collectTextFields(from: startDateStackView, into: &dateFields)
        collectTextFields(from: endDateStackView, into: &dateFields)
        return dateFields
    }

    
}

extension CreateViewController: StopWritingViewControllerDelegate {
    func didStopWriting() {
        // MainViewController로 이동
        if let window = UIApplication.shared.windows.first {
            let mainVC = CreateViewController()
            let navController = UINavigationController(rootViewController: mainVC)
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
}
