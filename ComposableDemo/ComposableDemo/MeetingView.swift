
import SwiftUI

struct MeetingView: View {

    let meeting: Meeting
    let syncUp: SyncUp

    var body: some View {
        Form {
            Section {
                ForEach(syncUp.attendees) { attendee in
                    Text(attendee.name)
                }
            } header: {
                Text("Attendees")
            }
            Section {
                Text(meeting.transcript)
            } header: {
                Text("Transcript")
            }
        }
        .navigationTitle(Text(meeting.date, style: .date))
    }
}

// MARK: - Preview

#warning("TODO: Figure out mocks to be reused 💡")

#Preview {
    MeetingView(
        meeting: Meeting(
            id: Meeting.ID(),
            date: Date(),
            transcript: ""
        ),
        syncUp: SyncUp(
            id: SyncUp.ID(),
            attendees: [
                Attendee(id: Attendee.ID(), name: "Blob"),
                Attendee(id: Attendee.ID(), name: "Blob Jr."),
                Attendee(id: Attendee.ID(), name: "Blob Sr."),
            ],
            title: "Point-Free Morning Sync"
        )
    )
}
