import UIKit
// ThumbnailCell 클래스에는 테두리 관련 메서드 제거
class ThumbnailCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 3.3 // 둥근 테두리 설정
        iv.layer.masksToBounds = true // 둥근 테두리 적용
        return iv
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal) // X 버튼 이미지
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        
        // 이미지 뷰 레이아웃
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // 삭제 버튼 레이아웃
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -4.12),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 4.84),
            deleteButton.widthAnchor.constraint(equalToConstant: 19.82),
            deleteButton.heightAnchor.constraint(equalToConstant: 19.82)
        ])
        
        contentView.bringSubviewToFront(deleteButton) // 삭제 버튼이 항상 최상단에 있도록 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
