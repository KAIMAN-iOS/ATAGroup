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
    var currentUserEmail: String { get }
}

protocol GroupCoordinatorDelegate: NSObjectProtocol {
    func addNewGroup()
    func showDetail(for group: Group)
    func addNewMember(in group: Group)
    func delete(group: Group, completion: @escaping ((Bool) -> Void))
    func delete(member: GroupMember, from group: Group, completion: @escaping ((Bool) -> Void))
}

public class ATAGroupCoordinator<DeepLink>: Coordinator<DeepLink> {
    weak var dataSource: GroupDatasource!
    var controller: GroupListViewController!
    private var availableGroupTypes: [GroupType] = []
    public init(groups: [Group],
                availableGroupTypes: [GroupType],
                dataSource: GroupDatasource,
                configuration: ATAConfiguration,
                router: RouterType) {
        super.init(router: router)
        self.availableGroupTypes = availableGroupTypes
        self.dataSource = dataSource
        controller = GroupListViewController.create(groups: groups, configuration: configuration, delegate: self, groupDataSource: dataSource)
        
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
    public var currentUserEmail: String { dataSource.currentUserEmail }
    
    func add(_ email: String, to group: Group, completion: (() -> Void)?) {
        add(member: email, to: group)
            .ensure { [weak self] in
                (self?.router.navigationController.topViewController ?? self?.controller)?.dismiss(animated: true, completion: nil)
            }
            .done { [weak self] member in
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
//                (self?.router.navigationController.topViewController as? GroupListViewController)?.didAdd(group)
            }
    }
    
    public func update(group: Group) -> Promise<Group> {
        dataSource
            .update(group: group)
            .get { [weak self] group in
                self?.router.popModule(animated: true)
                (self?.router.navigationController.topViewController as? GroupListViewController)?.didUpdate(group)
            }
    }
    
    public func delete(group: Group) -> Promise<Bool> {
        dataSource
            .delete(group: group)
            .get { [weak self] success in
                if self?.router.navigationController.topViewController is GroupListViewController == false {
                    self?.router.popModule(animated: true)
                }
                (self?.router.navigationController.topViewController as? GroupListViewController)?.didDelete(group)
            }
    }
    
    public func add(member: String, to group: Group) -> Promise<GroupMember> {
        dataSource
            .add(member: member, to: group)
            .get { [weak self] member in
                self?.router.popModule(animated: true)
                (self?.router.navigationController.topViewController as? GroupListViewController)?.didAdd(member: member, to: group)
            }
    }
    
    public func remove(member: GroupMember, from group: Group) -> Promise<Bool> {
        dataSource
            .remove(member: member, from: group)
            .get { [weak self] success in
                self?.router.popModule(animated: true)
                (self?.router.navigationController.topViewController as? GroupListViewController)?.didRemove(member: member, from: group)
            }
    }
}

extension ATAGroupCoordinator: AddGroupDelegate {
    func create(_ group: Group, completion: (() -> Void)?) {
        create(group: group)
            .done { [weak self] group in
                guard let listController = self?.router.navigationController.topViewController as? GroupListViewController else { return }
                listController.didAdd(group)
            }.catch { error in
                completion?()
            }
    }
}

extension ATAGroupCoordinator: GroupCoordinatorDelegate {
    func addNewGroup() {
        let ctrl: AddGroupViewController = AddGroupViewController.create(groupTypes: availableGroupTypes, delegate: self)
        router.push(ctrl, animated: true, completion: nil)
    }
    
    func showDetail(for group: Group) {
        let ctrl = GroupDetailViewController.create(group: group, delegate: self, memberDelegate: self, groupDataSource: dataSource)
        router.push(ctrl, animated: true, completion: nil)
    }
    
    func addNewMember(in group: Group) {
        let ctrl: AddMemberViewController = AddMemberViewController.create(group: group, delegate: self)
        presentController(ctrl)
    }
    
    func delete(group: Group, completion: @escaping ((Bool) -> Void)) {
        delete(group: group)
            .done { success in
                completion(success)
            }.catch { error in
                completion(false)
            }
    }
    
    func delete(member: GroupMember, from group: Group, completion: @escaping ((Bool) -> Void)) {
        remove(member: member, from: group)
            .done { success in
                completion(success)
            }.catch { error in
                completion(false)
            }
    }
}

extension String {
    func bundleLocale() -> String {
        NSLocalizedString(self, bundle: .module, comment: self)
    }
}

extension Group {
    var adminEmail: String? { members.first(where: {$0.isAdmin ?? false})?.email }
}
