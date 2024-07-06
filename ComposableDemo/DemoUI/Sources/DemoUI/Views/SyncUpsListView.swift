@preconcurrency import DemoModels
import DemoReducers
import Foundation
import ComposableArchitecture
import SwiftUI

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

    @Bindable var store: StoreOf<SyncUpsListReducer>

    var body: some View {
        List {
            ForEach(store.$syncUps.elements) { $syncUp in
                NavigationLink(
                    state: AppFeatureReducer.Path.State.detail(SyncUpDetailReducer.State(syncUp: $syncUp))
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
                initialState: SyncUpsListReducer.State(
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
                SyncUpsListReducer()
            }
        )
    }
}
