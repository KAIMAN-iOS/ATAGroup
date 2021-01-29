import UIKit
import KCoordinatorKit
import PromiseKit
import ATAConfiguration

protocol GroupDatasource: class {
    func refresh() -> Promise<[Group]>
    func create(group: Group) -> Promise<Group>
    func update(group: Group) -> Promise<Group>
    func delete(group: Group) -> Promise<Bool>
    func add(member: GroupMember, to group: Group) -> Promise<GroupMember>
    func remove(member: GroupMember, from group: Group) -> Promise<Bool>
}

protocol GroupCoordinatorDelegate: class {
    func addNewGroup()
    func showDetail(for group: Group)
    func addNewMember(in group: Group)
}

class ATAGroupCoordinator<DeepLink>: Coordinator<DeepLink> {
    weak var dataSource: GroupDatasource!
    init(dataSource: GroupDatasource, configuration: ATAConfiguration, router: RouterType) {
        super.init(router: router)
        self.dataSource = dataSource
    }
}

extension ATAGroupCoordinator: GroupDatasource {
    func refresh() -> Promise<[Group]> { dataSource.refresh() }
    
    func create(group: Group) -> Promise<Group> {
        dataSource
            .create(group: group)
            .get { [weak self] group in
                self?.router.popModule(animated: true)
            }
    }
    
    func update(group: Group) -> Promise<Group> {
        dataSource
            .update(group: group)
//            .get { [weak self] group in
//                //TODO:
//            }
    }
    
    func delete(group: Group) -> Promise<Bool> {
        dataSource
            .delete(group: group)
            .get { [weak self] group in
                self?.router.popModule(animated: true)
            }
    }
    
    func add(member: GroupMember, to group: Group) -> Promise<GroupMember> {
        dataSource
            .add(member: member, to: group)
//            .get { [weak self] member in
//
//            }
    }
    
    func remove(member: GroupMember, from group: Group) -> Promise<Bool> {
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
    }
    
    func addNewMember(in group: Group) {
    }
}

extension String {
    func bundleLocale() -> String {
        NSLocalizedString(self, bundle: .module, comment: self)
    }
}



