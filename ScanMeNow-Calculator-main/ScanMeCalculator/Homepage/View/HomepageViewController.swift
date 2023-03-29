//
//  HomepageViewController.swift
//  ScanMeCalculator
//
//  Created by Zein Rezky Chandra on 27/03/23.
//

import UIKit
import Combine

class HomepageViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var databaseSwitch: UISwitch!
    
    @IBOutlet weak var centreLabel: UILabel!
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var data = [InputResult]()
    
    let viewModel: HomepageViewModel
    
    // MARK: - Initializer
    
    init(viewModel: HomepageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HomepageViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        setupRightNavbarItem()
        setupObserver()
        setupTableView()
        
        viewModel.viewDidLoad()
    }
    
    // MARK: - Private Function
    
    private func setupObserver() {
        viewModel.isSaveToDatabaseStorage.sink { [weak self] isSaveToDatabase in
            self?.databaseSwitch.isOn = isSaveToDatabase
        }
        .store(in: &cancellables)
        
        viewModel.showAlertPublisher
            .sink { [weak self] alertInfo in
                guard let self = self else { return }
                Alert.showBasic(title: alertInfo.title, message: alertInfo.message, vc: self, handler: alertInfo.action)
            }
        .store(in: &cancellables)
        
        viewModel.inputResultData
            .sink { [weak self] data in
                self?.data = data
                self?.tableView.reloadData()
                self?.tableView.isHidden = data.isEmpty
            }
        .store(in: &cancellables)
    }
    
    private func setupNavbar() {
        title = "Scan Me! Calculator"
        
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setupRightNavbarItem() {
        let plusImage = UIImage(systemName: "plus")
        
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(plusImage, for: .normal)
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        plusButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        let plusBarButtonItem = UIBarButtonItem(customView: plusButton)
        
        navigationItem.rightBarButtonItem = plusBarButtonItem
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "InputResultCell", bundle: nil), forCellReuseIdentifier: "InputResultCell")
        tableView.dataSource = self
        
        centreLabel.text = "The data is empty"
    }
    
    // MARK: - @IBAction
    
    @IBAction func switchPressed(_ sender: Any) {
        viewModel.isSaveToDatabaseStorage.value.toggle()
    }
}

// MARK: - @objc Func

extension HomepageViewController {
    @objc func didTapPlusButton() {
        #if GreenBuiltInCamera || RedBuiltInCamera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            Alert.showBasic(title: "Error", message: "There is no camera detected", vc: self)
        }
        #elseif GreenCameraRoll || RedCameraRoll
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            Alert.showBasic(title: "Error", message: "Can't access camera roll", vc: self)
        }
        #endif
    }
}

// MARK: - ImagePickerControllerDelegate

extension HomepageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        switch picker.sourceType {
        case .camera:
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            
            viewModel.imageResources.send((image, picker.sourceType))
            
            dismiss(animated: true, completion: nil)
        case .photoLibrary:
            guard let selectedImage = info[.editedImage] as? UIImage else {
                return
            }
            
            viewModel.imageResources.send((selectedImage, picker.sourceType))
            
            dismiss(animated: true, completion: nil)
        default: break
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension HomepageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputResultCell", for: indexPath) as? InputResultCell
        cell?.model = data[indexPath.row]
        return cell ?? UITableViewCell(frame: .null)
    }
}
