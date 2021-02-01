import UIKit
import KCoordinatorKit
import PromiseKit
import ATAConfiguration
import FittedSheets

public protocol GroupDatasource: NSObjectProtocol {
    func refresh() -> Promise<[Group]>
    func create(group: Group) -> Promise<Group>
    func update(group: Group) -> Promise<Group>
    func delete(group: Group) -> Promise<Bool>
    func add(member: String, to group: Group) -> Promise<GroupMember>
    func remove(member: GroupMember, from group: Group) -> Promise<Bool>
}

protocol GroupCoordinatorDelegate: NSObjectProtocol {
    func addNewGroup()
    func showDetail(for group: Group)
    func addNewMember(in group: Group)
}

public class ATAGroupCoordinator<DeepLink>: Coordinator<DeepLink> {
    weak var dataSource: GroupDatasource!
    var controller: GroupListViewController!
    public init(groups: [Group],
         dataSource: GroupDatasource,
         configuration: ATAConfiguration,
         router: RouterType) {
        super.init(router: router)
        self.dataSource = dataSource
        controller = GroupListViewController.create(groups: groups, configuration: configuration, delegate: self)
        
        dataSource
            .refresh()
            .done { [weak self] groups in
                self?.controller.update(groups)
            }.catch { [weak self] error in
                //TODO
                self?.controller.refreshComplete()
            }
    }
    
    public override func toPresentable() -> UIViewController {
        controller
    }
    
    func presentController(_ controllerToPresent: UIViewController,
                           blurEffect: UIBlurEffect = .init(style: .dark)) {
        let options = SheetOptions(useFullScreenMode: false, shrinkPresentingViewController: false)
        let sheet = SheetViewController(controller: controllerToPresent, sizes: [.intrinsic], options: options)
        sheet.cornerRadius = 25.0
        sheet.allowPullingPastMaxHeight = false
        sheet.overlayColor = .clear
        sheet.blurEffect = blurEffect
        sheet.hasBlurBackground = true
        (router.navigationController.topViewController ?? controller).present(sheet, animated: true, completion: nil)
    }
}

extension ATAGroupCoordinator: AddMemberDelegate {
    func add(_ email: String, to group: Group, completion: (() -> Void)?) {
        add(member: email, to: group)
            .done { [weak self] member in
                (self?.router.navigationController.topViewController ?? self?.controller)?.dismiss(animated: true, completion: nil)
                guard let detailController = self?.router.navigationController.topViewController as? GroupDetailViewController else { return }
                detailController.didAdd(member)
            }.catch { error in
                completion?()
            }
    }
}

extension ATAGroupCoordinator: GroupDatasource {
    public func refresh() -> Promise<[Group]> { dataSource.refresh() }
    
    public func create(group: Group) -> Promise<Group> {
        dataSource
            .create(group: group)
            .get { [weak self] group in
                self?.router.popModule(animated: true)
            }
    }
    
    public func update(group: Group) -> Promise<Group> {
        dataSource
            .update(group: group)
//            .get { [weak self] group in
//                //TODO:
//            }
    }
    
    public func delete(group: Group) -> Promise<Bool> {
        dataSource
            .delete(group: group)
            .get { [weak self] group in
                self?.router.popModule(animated: true)
            }
    }
    
    public func add(member: String, to group: Group) -> Promise<GroupMember> {
        dataSource
            .add(member: member, to: group)
//            .get { [weak self] member in
//
//            }
    }
    
    public func remove(member: GroupMember, from group: Group) -> Promise<Bool> {
        dataSource
            .remove(member: member, from: group)
//            .get { [weak self] member in
//                
//            }
    }
}

extension ATAGroupCoordinator: GroupCoordinatorDelegate {
    func addNewGroup() {
    }
    
    func showDetail(for group: Group) {
        let ctrl = GroupDetailViewController.create(group: group, delegate: self)
        router.push(ctrl, animated: true, completion: nil)
    }
    
    func addNewMember(in group: Group) {
        let ctrl: AddMemberViewController = AddMemberViewController.create(group: group, delegate: self)
        presentController(ctrl)
    }
}

extension String {
    func bundleLocale() -> String {
        NSLocalizedString(self, bundle: .module, comment: self)
    }
}



