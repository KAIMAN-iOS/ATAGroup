//
//  ViewController.swift
//  ios-example
//
//  Created by GG on 29/01/2021.
//

import UIKit
import ATAGroup
import ATAConfiguration
import PromiseKit
import KCoordinatorKit
import Ampersand

class Configuration: ATAConfiguration {
    var logo: UIImage? { nil }
    var palette: Palettable { Palette() }
}

class Palette: Palettable {
    var action: UIColor { #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1) }
    var confirmation: UIColor { #colorLiteral(red: 0.3411764801, green: 0.721568644, blue: 0.650980413, alpha: 1) }
    var alert: UIColor { #colorLiteral(red: 0.8313725591, green: 0.2156862766, blue: 0.180392161, alpha: 1) }
    var primary: UIColor { #colorLiteral(red: 0.8313725591, green: 0.2156862766, blue: 0.180392161, alpha: 1) }
    var secondary: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    var mainTexts: UIColor { #colorLiteral(red: 0.09803921729, green: 0.09803921729, blue: 0.09803921729, alpha: 1)}
    var secondaryTexts: UIColor { #colorLiteral(red: 0.1879811585, green: 0.1879865527, blue: 0.1879836619, alpha: 1) }
    var textOnPrimary: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
    var inactive: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    var placeholder: UIColor { #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) }
    var lightGray: UIColor { #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) }
}

class ViewController: UIViewController {

    var groups: [Group] = [Group.testGroup1, Group.testGroup2]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let configurationURL = Bundle.main.url(forResource: "Poppins", withExtension: "json")!
        UIFont.registerApplicationFont(withConfigurationAt: configurationURL)
    }

    var coord: ATAGroupCoordinator<Int>!
    @IBAction func show(_ sender: Any) {
        coord = ATAGroupCoordinator<Int>(groups: groups, dataSource: self, configuration: Configuration(), router: Router(navigationController: navigationController!))
        navigationController?.pushViewController(coord.toPresentable(), animated: true)
    }
    
}

extension ViewController: GroupDatasource {
    func refresh() -> Promise<[Group]> {
        Promise<[Group]>.init { resolver in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                self.groups.append(Group.testGroup3)
                self.groups.append(Group.testGroup4)
                resolver.fulfill(self.groups)
            }
        }
    }
    
    func create(group: Group) -> Promise<Group> {
        Promise<Group>.init { resolver in
            
        }
    }
    
    func update(group: Group) -> Promise<Group> {
        Promise<Group>.init { resolver in
            
        }
    }
    
    func delete(group: Group) -> Promise<Bool> {
        Promise<Bool>.init { resolver in
            
        }
    }
    
    func add(member: GroupMember, to group: Group) -> Promise<GroupMember> {
        Promise<GroupMember>.init { resolver in
            
        }
    }
    
    func remove(member: GroupMember, from group: Group) -> Promise<Bool> {
        Promise<Bool>.init { resolver in
            
        }
    }
    
    
}

