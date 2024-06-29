import ComposableArchitecture
import DemoModels
import DemoReducers
import SwiftUI

#warning("TODO: Move Views into separate package 💡")

// MARK: - Views

struct SyncUpFormView: View {

    @Bindable var store: StoreOf<SyncUpFormReducer>
    @FocusState var focus: SyncUpFormReducer.Field?

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $store.syncUp.title)
                    .focused($focus, equals: .title)
                HStack {
                    Slider(value: $store.syncUp.duration.minutes, in: 5...30, step: 1) {
                        Text("Length")
                    }
                    Spacer()
                    Text(store.syncUp.duration.formatted(.units()))
                }
                ThemePicker(selection: $store.syncUp.theme)
            } header: {
                Text("Sync-up Info")
            }

            Section {
                ForEach($store.syncUp.attendees) { $attendee in
                    TextField("Name", text: $attendee.name)
                        .focused($focus, equals: .attendee(attendee.id))
                }
                .onDelete { indices in
                    store.send(.onDeleteAttendees(indices))
                }

                Button("New attendee") {
                    store.send(.addAttendeeButtonTapped)
                }
            } header: {
                Text("Attendees")
            }
        }
        .bind($store.focus, to: $focus)
    }
}

struct ThemePicker: View {
    @Binding var selection: Theme

    var body: some View {
        Picker("Theme", selection: $selection) {
            ForEach(Theme.allCases) { theme in
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.mainColor)
                    Label(theme.name, systemImage: "paintpalette")
                        .padding(4)
                }
                .foregroundColor(theme.accentColor)
                .fixedSize(horizontal: false, vertical: true)
                .tag(theme)
            }
        }
    }
}

// MARK: - Convenience

extension Duration {
    fileprivate var minutes: Double {
        get { Double(components.seconds / 60) }
        set { self = .seconds(newValue * 60) }
    }
}

// MARK: - Previews

#Preview {
    SyncUpFormView(
        store: Store(
            initialState: SyncUpFormReducer.State(
                syncUp: SyncUp(
                    id: SyncUp.ID(),
                    attendees: [
                        Attendee(id: Attendee.ID(), name: "Blob"),
                        Attendee(id: Attendee.ID(), name: "Blob Jr."),
                        Attendee(id: Attendee.ID(), name: "Blob Sr.")
                    ],
                    title: "Point-Free Morning Sync"
                )
            )
        ) {
            SyncUpFormReducer()
        }
    )
}
