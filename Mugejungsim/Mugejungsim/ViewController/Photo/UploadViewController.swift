import UIKit
import PhotosUI

protocol UploadViewControllerDelegate: AnyObject {
    func didTapBackButton()
}

class UploadViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UploadViewControllerDelegate {
    weak var delegate: UploadViewControllerDelegate?
    var recordID: String = ""
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "여행의 순간이 담긴\n사진을 업로드 해보세요!"
        label.textColor = #colorLiteral(red: 0.1879820824, green: 0.1879820824, blue: 0.1879820824, alpha: 1)
        label.numberOfLines = 2
        label.font = UIFont(name: "Pretendard-Bold", size: 25)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let outButton: UIButton = {
        let button = UIButton(type: .custom)
        if let originalImage = UIImage(named: "back_button")?.withRenderingMode(.alwaysOriginal) {
            button.setImage(originalImage, for: .normal)
        }
        button.addTarget(self, action: #selector(handleOutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.956299603, green: 0.9574014544, blue: 0.9907849431, alpha: 1) // 기본 배경색
        button.layer.cornerRadius = 10
        if let originalImage = UIImage(named: "gallery")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(originalImage, for: .normal)
        }
        button.tintColor = #colorLiteral(red: 0.462745098, green: 0.4509803922, blue: 0.7647058824, alpha: 1) // 기본 이미지 색상 (#7573C3)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        button.translatesAutoresizingMaskIntoConstraints = false

        // Drop shadow 설정
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15 // 투명도 15%
        button.layer.shadowOffset = CGSize(width: 1.95, height: 1.95) // 그림자 위치
        button.layer.shadowRadius = 2.6 // 블러 값
        button.layer.masksToBounds = false

        return button
    }()
    
    private let galleryLabel: UILabel = {
        let label = UILabel()
        label.text = "갤러리 업로드"
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = #colorLiteral(red: 0.1879820824, green: 0.1879820824, blue: 0.1879820824, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.956299603, green: 0.9574014544, blue: 0.9907849431, alpha: 1) // 기본 배경색
        button.layer.cornerRadius = 10
        if let originalImage = UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(originalImage, for: .normal)
        }
        button.tintColor = #colorLiteral(red: 0.462745098, green: 0.4509803922, blue: 0.7647058824, alpha: 1) // 기본 이미지 색상 (#7573C3)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        button.translatesAutoresizingMaskIntoConstraints = false

        // Drop shadow 설정
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15 // 투명도 15%
        button.layer.shadowOffset = CGSize(width: 1.95, height: 1.95) // 그림자 위치
        button.layer.shadowRadius = 2.6 // 블러 값
        button.layer.masksToBounds = false

        return button
    }()
    
    private let cameraLabel: UILabel = {
        let label = UILabel()
        label.text = "카메라 촬영"
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = #colorLiteral(red: 0.1879820824, green: 0.1879820824, blue: 0.1879820824, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var capturedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCustomNavigationBar()
        setupUI()
    }
    
    private func setupCustomNavigationBar() {
        let navBar = UIView()
        navBar.backgroundColor = .clear
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        let backButton = UIButton(type: .system)  // 왼쪽 고정
        backButton.setImage(UIImage(named: "back_button"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(navBar)
        navBar.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 48),
            
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 24),
        ])
    }
    
    @objc internal func didTapBackButton() {
            delegate?.didTapBackButton()
            dismiss(animated: true, completion: nil)
        }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(galleryButton)
        view.addSubview(galleryLabel)
        view.addSubview(cameraButton)
        view.addSubview(cameraLabel)
        
        NSLayoutConstraint.activate([
            
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 93),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Gallery Button Constraints
            galleryButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 53),
            galleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            galleryButton.widthAnchor.constraint(equalToConstant: 122),
            galleryButton.heightAnchor.constraint(equalToConstant: 122),
            
            // Gallery Label Constraints
            galleryLabel.topAnchor.constraint(equalTo: galleryButton.bottomAnchor, constant: 10),
            galleryLabel.centerXAnchor.constraint(equalTo: galleryButton.centerXAnchor),
            
            // Camera Button Constraints
            cameraButton.topAnchor.constraint(equalTo: galleryLabel.bottomAnchor, constant: 44),
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 122),
            cameraButton.heightAnchor.constraint(equalToConstant: 122),
            
            // Camera Label Constraints
            cameraLabel.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 10),
            cameraLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -184),
            cameraLabel.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor)
        ])
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = #colorLiteral(red: 0.462745098, green: 0.4509803922, blue: 0.7647058824, alpha: 1) // 배경색 변경
        sender.tintColor = .white // 이미지 색상 흰색
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        sender.backgroundColor = #colorLiteral(red: 0.956299603, green: 0.9574014544, blue: 0.9907849431, alpha: 1) // 원래 배경색 복구
        sender.tintColor = #colorLiteral(red: 0.462745098, green: 0.4509803922, blue: 0.7647058824, alpha: 1) // 원래 이미지 색상 복구
    }
    
    @objc func handleOutButton() {
        dismiss(animated: true)
    }
    
    @objc func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "카메라 오류", message: "이 기기에서 카메라를 사용할 수 없습니다.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            capturedImages.append(image)
            print("Captured Images: \(capturedImages)")  // 추가된 이미지를 확인
            navigateToStoryEditor(with: capturedImages)
        }
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
                                self?.navigateToStoryEditor(with: selectedImages)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func openGallery() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 25
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func navigateToStoryEditor(with images: [UIImage]) {
        let storyEditorVC = StoryEditorViewController()
        print("Passing images to StoryEditorVC: \(images)")  // 디버깅: 이미지 배열 확인

        storyEditorVC.recordID = self.recordID //
        storyEditorVC.images = images
        storyEditorVC.delegate = self // delegate 설정
        storyEditorVC.modalPresentationStyle = .fullScreen
        present(storyEditorVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
