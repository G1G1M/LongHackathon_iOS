import UIKit

protocol DeleteViewControllerDelegate: AnyObject {
    func didDelete()
}


class DeleteViewController: UIViewController {
    weak var delegate: DeleteViewControllerDelegate?
        var photoData: PhotoData? // 삭제할 데이터
    


    // MARK: - UI Elements
    
    private let overlayView: UIView = { // 모달창 배경을 위한 변수
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Drop Shadow 설정
        view.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        view.layer.shadowOpacity = 0.25 // 그림자 투명도 (25%)
        view.layer.shadowRadius = 4 // 그림자 블러 반경
        view.layer.shadowOffset = CGSize(width: 0, height: 4) // X, Y 위치
        
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "X_Button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let promptLabel: UILabel = {
        let label = UILabel()
        let text = "사진과 남긴 기록을\n삭제하시겠어요?"

        // Line height 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 27 - 18 // Line height - Font size (18)

        // Letter spacing 설정
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.font(.pretendardBold, ofSize: 18), // 폰트
                .foregroundColor: UIColor.black, // 텍스트 색상
                .kern: -0.3, // 자간
                .paragraphStyle: paragraphStyle // 줄 간격 스타일
            ]
        )
        label.attributedText = attributedString
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소하기", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3450980392, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)
        button.layer.cornerRadius = 5.9
        button.titleLabel?.font = UIFont.font(.pretendardSemiBold, ofSize: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Drop Shadow 설정
        button.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        button.layer.shadowOpacity = 0.25 // 그림자 투명도 (25%)
        button.layer.shadowRadius = 0.74 // 그림자 블러 반경
        button.layer.shadowOffset = CGSize(width: 0.37, height: 0.37) // X, Y 위치
        
        return button
    }()

    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제하기", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.7647058824, alpha: 1)
        button.layer.cornerRadius = 5.9
        button.titleLabel?.font = UIFont.font(.pretendardBold, ofSize: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Drop Shadow 설정
        button.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        button.layer.shadowOpacity = 0.25 // 그림자 투명도 (25%)
        button.layer.shadowRadius = 0.74 // 그림자 블러 반경
        button.layer.shadowOffset = CGSize(width: 0.37, height: 0.37) // X, Y 위치
        
        return button
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        setActions()
    }
    
    // MARK: - UI Setup
    
    private func setUI() {
        view.addSubview(overlayView)
        view.addSubview(containerView)
        containerView.addSubview(closeButton)
        containerView.addSubview(promptLabel)
        containerView.addSubview(stopButton)
        containerView.addSubview(continueButton)
    }
    
    // MARK: - Constraints
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // Overlay view (background)
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Container view
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 297),
            containerView.heightAnchor.constraint(equalToConstant: 278),
            
            // Close button (X_Button)
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 21),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -23),

            
            // Prompt label
            promptLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 63),
            promptLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),


            // Stop button
            stopButton.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 36),
            stopButton.centerXAnchor.constraint(equalTo: promptLabel.centerXAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: 239),
            stopButton.heightAnchor.constraint(equalToConstant: 38.32),
            
            // Continue button
            continueButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 9.68),
            continueButton.centerXAnchor.constraint(equalTo: stopButton.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 239),
            continueButton.heightAnchor.constraint(equalToConstant: 38.32),
        ])
    }

    
    private func setActions() {
        stopButton.addTarget(self, action: #selector(StopButtonTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(ContinueButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(CloseButtonTapped), for: .touchUpInside) // Close 버튼 액션 추가
    }
    
    @objc private func ContinueButtonTapped() {
        print("삭제 버튼 클릭됨")
        guard let photoData = photoData else {
            print("삭제할 데이터가 없습니다.")
            return
        }
        
        // 삭제 처리
//        DataManager.shared.deleteData(photoData: photoData)

        // 현재 화면을 닫고 SavedPhotosViewController로 돌아갑니다.
        if let presentingVC = presentingViewController as? SavedPhotosViewController {
            dismiss(animated: true) {
                // SavedPhotosViewController에 데이터 갱신 요청
//                presentingVC.refreshData()
            }
        } else {
            // 만약 SavedPhotosViewController를 찾을 수 없다면 새로 생성합니다.
            if let window = UIApplication.shared.windows.first {
                let savedPhotosVC = SavedPhotosViewController()
                savedPhotosVC.modalPresentationStyle = .fullScreen

                // DataManager에서 데이터를 갱신한 후 전달
                savedPhotosVC.savedData = DataManager.shared.loadData()

                let navigationController = UINavigationController(rootViewController: savedPhotosVC)
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }
    }

        @objc private func StopButtonTapped() {
            dismiss(animated: true, completion: nil)
        }

    @objc private func CloseButtonTapped() {
        print("Close 버튼 클릭됨")
        dismiss(animated: false, completion: nil) // 애니메이션 제거
    }
}

