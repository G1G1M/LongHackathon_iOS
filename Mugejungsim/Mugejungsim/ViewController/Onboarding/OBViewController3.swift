import UIKit

class OBViewController3: UIViewController {

    // dot1 이미지 뷰
    private let dotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dots3")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "여행의 추억을 유리병 속\n편지의 색으로 확인 해보세요!"
        label.textAlignment = .center
        label.font = UIFont.font(.pretendardBold, ofSize: 22)
        label.numberOfLines = 2
        label.textColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let placeholderView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "OB3") // "OB2"라는 이미지 파일 추가
        imageView.contentMode = .scaleAspectFit // 이미지 비율 유지하며 맞추기
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true // 이미지가 라운드 영역을 벗어나지 않도록
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("여행 기록 만들기", for: .normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.7647058824, alpha: 1)
        button.layer.cornerRadius = 8
        button.addShadow() // Drop shadow 추가
        button.titleLabel?.font = UIFont.font(.pretendardSemiBold , ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false) // 내비게이션 바 숨기기
        setupUI()
    }

    private func setupUI() {
        view.addSubview(dotImageView)
        view.addSubview(titleLabel)
        view.addSubview(placeholderView)
        view.addSubview(nextButton)

        NSLayoutConstraint.activate([
            // Dot Image View Constraints
            dotImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 98),
            dotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotImageView.widthAnchor.constraint(equalToConstant: 50),
            dotImageView.heightAnchor.constraint(equalToConstant: 10),

            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: dotImageView.bottomAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), // 화면 좌측 여백
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16), // 화면 우측 여백


            // Placeholder View Constraints
            placeholderView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.widthAnchor.constraint(equalToConstant: 242),
            placeholderView.heightAnchor.constraint(equalToConstant: 498),

            // Next Button Constraints
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 327),
            nextButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        // 액션 연결
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    @objc private func nextButtonTapped() {
        let mainViewController = MyRecordsViewController()
        mainViewController.modalPresentationStyle = .fullScreen // 전체 화면 표시
        mainViewController.modalTransitionStyle = .coverVertical // 아래에서 위로 올라오는 스타일

        self.present(mainViewController, animated: true, completion: nil)

    }
}
