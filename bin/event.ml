open! Core

type t =
  { short : string
  ; precise : string
  }
[@@deriving fields, sexp]

let all =
  [ { short = "Zohran Mamdani wins the NYC mayoral election"
    ; precise =
        "Zohran Mamdani is elected mayor in the 2025 New York City election on some date \
         before 2026-01-01 via consensus of credible reporting and official information \
         from New York City."
    }
  ; { short =
        "The top grossing domestic film of 2025Q4 is based on an original screenplay"
    ; precise =
        "The top grossing domestic film of October, November, or December, according to \
         Box Office Mojo, is based on an original screenplay. \n\n\
         An original screenplay is defined as one not based upon previously published \
         material, adjudicated by the Writer's Branch of the Academy of Motion Picture \
         Arts and Sciences."
    }
  ; { short = "The winner of the 2025 US Open Men's Singles tournament is under 25"
    ; precise =
        "The winner of the US Open tennis tournament is under 25 years of age, \
         determined on the date of the Men's Final."
    }
  ; { short = "Sam Bankman-Fried is pardoned"
    ; precise =
        "Sam Bankman-Fried receives a presidential pardon from President Donald Trump on \
         some date before 2026-01-01."
    }
  ; { short = "A major U.S. political figure dies"
    ; precise =
        "The death of a major political figure causes a National Market System stock \
         exchange, such as Nasdaq or NYSE, to cease trading on some date before \
         2026-01-01."
    }
  ; { short = "More than five participants play chess on a random November date"
    ; precise =
        "On a randomly selected date in November, I will poll the group via mailing \
         list. If more than five respondents claim to have completed a full game of \
         chess in a specified twenty-four hour period, then this event resolves to true."
    }
  ]
;;
