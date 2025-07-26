use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Event {
    pub short: String,
    pub precise: String,
}

impl Event {
    pub fn new<S: Into<String>, P: Into<String>>(
        short: S,
        precise: P,
    ) -> Event {
        Event {
            short: short.into(),
            precise: precise.into(),
        }
    }
}

/// A compile-time-friendly representation of an Event.
pub struct ConstEvent {
    pub short: &'static str,
    pub precise: &'static str,
}

/// The canonical list of events, defined at compile time.
pub const EVENTS: &[ConstEvent] = &[
    ConstEvent {
        short: "Zohran Mamdani will win the NYC mayoral election",
        precise: "Zohran Mamdani is elected mayor in the 2025 New York City \
                  election on some date before 2026-01-01 via consensus of \
                  credible reporting and official information from New York \
                  City.",
    },
    ConstEvent {
        short: "The top grossing domestic film of Q4 is based on an original \
                screenplay",
        precise: "The top grossing domestic film of month October, November, \
                  or December according to Box Office Mojo is based on an \
                  original screenplay, where an original screenplay is \
                  defined as one not based upon previously published \
                  material, adjudicated by the Writer's Branch of the Academy \
                  of Motion Picture Arts and Sciences.",
    },
    ConstEvent {
        short: "The death of a major U.S. political figure causes a stock \
                market closure",
        precise: "A major political figure dies, causing any major stock \
                  exchange, such as NASDAQ or NYSE, to cease trading on \
                 some date before 2026-01-01.",
    },
];
