import Foundation
import ComposableArchitecture
import SwiftUI

#warning("TODO: Split Reducers / Storage / Views into separate files / packages ❔")

// MARK: - Reducer

@Reducer struct SyncUpsList {

    @ObservableState struct State: Equatable {
        @Shared(.syncUps) var syncUps: IdentifiedArrayOf<SyncUp> = []
        @Presents var addSyncUp: SyncUpForm.State?
    }

    enum Action {
        case addSyncUpButtonTapped
        case addSyncUp(PresentationAction<SyncUpForm.Action>)
        case confirmAddButtonTapped
        case discardButtonTapped
        case onDelete(IndexSet)
        case syncUpTapped(id: SyncUp.ID)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .addSyncUpButtonTapped:
                state.addSyncUp = SyncUpForm.State(syncUp: SyncUp(id: SyncUp.ID(uuid())))
                return .none
            case .addSyncUp:
                return .none
            case .confirmAddButtonTapped:
                guard let newSyncUp = state.addSyncUp?.syncUp else { return .none }
                state.addSyncUp = nil
                state.syncUps.append(newSyncUp)
                return .none
            case .discardButtonTapped:
                state.addSyncUp = nil
                return .none
            case let .onDelete(indexSet):
                state.syncUps.remove(atOffsets: indexSet)
                return .none
            case .syncUpTapped:
                return .none
            }
        }
        .ifLet(\.$addSyncUp, action: \.addSyncUp) {
            SyncUpForm()
        }
    }
}

// MARK: - Storage

extension PersistenceReaderKey
    where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<SyncUp>>> {
    static var syncUps: Self {
        PersistenceKeyDefault(
            .fileStorage(.documentsDirectory.appending(component: "sync-ups.json")),
            []
        )
    }
}

// MARK: - Card View

struct CardView: View {

    let syncUp: SyncUp

    var body: some View {
        VStack(alignment: .leading) {
            Text(syncUp.title)
                .font(.headline)

            Spacer()

            HStack {
                Label("\(syncUp.attendees.count)", systemImage: "person.3")
                Spacer()
                Label(syncUp.duration.formatted(.units()), systemImage: "clock")
                    .labelStyle(.trailingIcon)
            }
            .font(.caption)
        }
        .padding()
        .foregroundColor(syncUp.theme.accentColor)
    }
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self { Self() }
}

// MARK: - List View

struct SyncUpsListView: View {

    @Bindable var store: StoreOf<SyncUpsList>

    var body: some View {
        List {
            ForEach(store.$syncUps.elements) { $syncUp in
                NavigationLink(
                    state: AppFeature.Path.State.detail(SyncUpDetail.State(syncUp: $syncUp))
                ) {
                    CardView(syncUp: syncUp)
                }
                .listRowBackground(syncUp.theme.mainColor)
            }
            .onDelete { indexSet in
                store.send(.onDelete(indexSet))
            }
        }
        .sheet(item: $store.scope(state: \.addSyncUp, action: \.addSyncUp)) { addSyncUpStore in
            NavigationStack {
                SyncUpFormView(store: addSyncUpStore)
                    .navigationTitle("New sync-up")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Discard") {
                                store.send(.discardButtonTapped)
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                store.send(.confirmAddButtonTapped)
                            }
                        }
                    }
            }
        }
        .toolbar {
            Button {
                store.send(.addSyncUpButtonTapped)
            } label: {
                Image(systemName: "plus")
            }
        }
        .navigationTitle("Daily Sync-ups")
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        SyncUpsListView(
            store: Store(
                initialState: SyncUpsList.State(
                    syncUps: [
                        SyncUp(
                            id: SyncUp.ID(),
                            attendees: [
                                Attendee(id: Attendee.ID(), name: "Blob"),
                                Attendee(id: Attendee.ID(), name: "Blob Jr."),
                                Attendee(id: Attendee.ID(), name: "Blob Sr.")
                            ],
                            title: "Point-Free Morning Sync"
                        )
                    ]
                )
            ) {
                SyncUpsList()
            }
        )
    }
}
