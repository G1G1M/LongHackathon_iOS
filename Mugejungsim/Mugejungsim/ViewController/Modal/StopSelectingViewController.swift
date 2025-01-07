import UIKit

protocol StopSelectingViewControllerDelegate: AnyObject {
    func didStopSelecting()
}

class StopSelectingViewController: UIViewController {
    
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
        label.text = "한 줄 남기기를 그만두시겠어요?"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.font(.pretendardBold, ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let promptLabel2: UILabel = {
        let label = UILabel()
        label.text = "한 줄 남기기를 하지 않으면\n나만의 오브제도 만들 수 없어요!"
        label.numberOfLines = 2
        label.textColor = #colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.7647058824, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.font(.pretendardSemiBold, ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("그만두기", for: .normal)
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
        button.setTitle("이어서 쓰기", for: .normal)
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
        containerView.addSubview(promptLabel2)
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
            
            // Prompt2 label
            promptLabel2.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 10),
            promptLabel2.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Stop button
            stopButton.topAnchor.constraint(equalTo: promptLabel2.bottomAnchor, constant: 34),
            stopButton.centerXAnchor.constraint(equalTo: promptLabel2.centerXAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: 239),
            stopButton.heightAnchor.constraint(equalToConstant: 38.32),
            
            // Continue button
            continueButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 9.68),
            continueButton.centerXAnchor.constraint(equalTo: stopButton.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 239),
            continueButton.heightAnchor.constraint(equalToConstant: 38.32),
        ])
    }
    
    // MARK: - Actions
    
    private func setActions() {
        stopButton.addTarget(self, action: #selector(StopButtonTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(ContinueButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(CloseButtonTapped), for: .touchUpInside) // Close 버튼 액션 추가
    }
    
    @objc func StopButtonTapped() {
        print("그만두기 버튼 클릭됨")
        let myRecordVC = MyRecordsViewController()
        myRecordVC.modalPresentationStyle = .fullScreen
        myRecordVC.modalTransitionStyle = .crossDissolve
        
        // NavigationController 여부 확인
        if let navigationController = self.navigationController {
            navigationController.setViewControllers([myRecordVC], animated: true)
        } else {
            if let window = UIApplication.shared.windows.first {
                let navController = UINavigationController(rootViewController: myRecordVC)
                window.rootViewController = navController
                window.makeKeyAndVisible()
            } else {
            }
        }
    }
    
    @objc func ContinueButtonTapped() {
        print("이어서 하기 버튼 클릭됨")
        dismiss(animated: false, completion: nil)
    }
    
    @objc func CloseButtonTapped() {
        print("Close 버튼 클릭됨")
        dismiss(animated: false, completion: nil) // 화면 닫기
    }
}
