
import ComposableArchitecture
import SwiftUI

#warning("Split Reducers / Views into separate files / packages ❔")

// MARK: - Reducer

@Reducer struct SyncUpForm {

    @ObservableState struct State: Equatable {
        var syncUp: SyncUp
    }

    enum Action: BindableAction {
        case addAttendeeButtonTapped
        case binding(BindingAction<State>)
        case onDeleteAttendees(IndexSet)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
                case .addAttendeeButtonTapped:
                    state.syncUp.attendees.append(
                        Attendee(id: Attendee.ID())
                    )
                    return .none

                case .binding:
                    return .none

                case let .onDeleteAttendees(indices):
                    state.syncUp.attendees.remove(atOffsets: indices)
                    if state.syncUp.attendees.isEmpty {
                        state.syncUp.attendees.append(
                            Attendee(id: Attendee.ID())
                        )
                    }
                    return .none
            }
        }
    }
}

// MARK: - Views

struct SyncUpFormView: View {

    @Bindable var store: StoreOf<SyncUpForm>

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $store.syncUp.title)
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
