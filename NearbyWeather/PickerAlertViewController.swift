//
//  PickerAlertViewController.swift
//  NearbyWeather
//
//  Created by Lukas Prokein on 20/10/2018.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class PickerAlertViewController<T: Equatable>: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Types
    
    struct Choice<T: Equatable> {
        let id: T
        let title: String
    }
    
    typealias ChoiceIdSelectionCompletion = ((T) -> ())
    
    // MARK: - Internal Properties
    
    private let choices: [Choice<T>]
    private let alertTitle: String
    private var selectedChoiceId: T?
    private var onChoiceIdSelected: ChoiceIdSelectionCompletion
    
    // MARK: - Init
    
    init(title: String, choices: [Choice<T>], selectedChoiceId: T?, onChoiceIdSelected: @escaping ChoiceIdSelectionCompletion) {
        self.alertTitle = title
        self.choices = choices
        self.selectedChoiceId = selectedChoiceId
        self.onChoiceIdSelected = onChoiceIdSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Interface
    
    func present(by viewController: UIViewController) {
        let alert = UIAlertController(title: alertTitle, message: "\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 40, width: 270, height: 140))
        alert.view.addSubview(pickerView)
        pickerView.dataSource = self
        pickerView.delegate = self
        if let selectedChoiceId = selectedChoiceId, let idx = choices.firstIndex(where: { $0.id == selectedChoiceId }) {
            pickerView.selectRow(idx, inComponent: 0, animated: false)
        }
        
        alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: { [weak self] _ in
            guard let selectedChoiceId = self?.selectedChoiceId else { return }
            self?.onChoiceIdSelected(selectedChoiceId)
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return choices[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedChoiceId = choices[row].id
    }
}
