open! Core

type t =
  { short : string
  ; precise : string
  }
[@@deriving fields, sexp]

let all =
  [ { short = "Nintendo announces a new Super Smash Bros."
    ; precise =
        "Nintendo announces a new Super Smash Bros. game on some date before 2026-01-01."
    }
  ; { short = "Zohran Mamdani wins the NYC mayoral election"
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
  ; { short = "A young adult wins the 2025 US Open Men's Singles tournament"
    ; precise =
        "The winner of the US Open tennis tournament is under 25 years of age, \
         determined on the date of the Men's Final."
    }
  ; { short = "Sam Bankman-Fried is pardoned"
    ; precise =
        "Sam Bankman-Fried receives a presidential pardon from the president on some \
         date before 2026-01-01."
    }
  ; { short = "More than five participants play chess on a random November date"
    ; precise =
        "On a randomly selected date in November, I will poll the group via mailing \
         list. If more than five respondents claim to have completed a full game of \
         chess in a specified twenty-four hour period, then this event resolves to true."
    }
  ; { short = "There is an unplanned market closure"
    ; precise =
        "A National Market System stock exchange, such as Nasdaq or NYSE, ceases trading \
         on some date before 2026-01-01, due to a reason such as natural disaster or \
         death of a major political figure."
    }
  ; { short = "Travis Kelce and Taylor Swift are engaged"
    ; precise =
        "Travis Kelce and Taylor Swift are engaged on some date before 2026-01-01 via \
         consensus of credible reporting or primary sources."
    }
  ; { short = "Life is discovered beyond Earth"
    ; precise =
        "A credible agency, such as NASA, confirms the discovery of life beyond Earth on \
         some date before 2026-01-01."
    }
  ; { short = "The Epstein files are released"
    ; precise =
        "The Department of Justice releases the Epstein files on some date before \
         2026-01-01."
    }
  ; { short = "The Neom construction project is canceled"
    ; precise =
        "Saudi Arabia announces the cancellation of the Neom construction project on \
         some date before 2026-01-01."
    }
  ; { short = "California experiences a large earthquake"
    ; precise =
        "On some date before 2026-01-01, an earthquake with epicenter in California and \
         a magnitude 7 or greater occurs, adjudicated by the United States Geological \
         Survey."
    }
  ; { short = "Our most listened-to artist is male"
    ; precise =
        "The artist with the highest number of occurrences across our 2025 Spotify \
         Wrapped Top Artists lists is male."
    }
  ]
;;
