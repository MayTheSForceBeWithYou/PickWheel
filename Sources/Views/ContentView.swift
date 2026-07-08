import SwiftUI

struct ContentView: View {
    @State private var vm = AppViewModel()

    var body: some View {
        Group {
            switch vm.authState {
            case .loading:
                ProgressView("Loading…")
            case .denied:
                AccessDeniedView {
                    vm.openSettings()
                }
            case .authorized:
                if let list = vm.selectedList {
                    WheelContainerView(vm: vm, list: list)
                } else {
                    ListPickerView(vm: vm)
                }
            }
        }
        .task { await vm.onAppear() }
    }
}
