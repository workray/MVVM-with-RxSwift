//
//  HomeViewController.swift
//  Vocal Voter
//
//  Created by Mobdev125 on 9/12/18.
//  Copyright © 2018 Mobdev125. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Material

class HomeViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var viewModel: HomeViewModel!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func bindViewModel() {
        assert(viewModel != nil)
        
        let input = HomeViewModel.Input(logoutTrigger: logoutButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.logout.drive().disposed(by: disposeBag)
    }

}
