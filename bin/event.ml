open! Core

type t =
  { short : string
  ; precise : string
  }
[@@deriving fields, sexp]

let all =
  [ { short = "New Super Smash Bros. game announced"
    ; precise = "Nintendo announces a new Super Smash Bros. game on or before 2025-12-31."
    }
  ; { short = "Zohran Mamdani wins the NYC mayoral election"
    ; precise =
        "Zohran Mamdani is elected Mayor of New York City in the 2025 election, as \
         confirmed by certified election results or a consensus of credible reporting."
    }
  ; { short =
        "The top grossing domestic film of Q4 2025 is based on an original screenplay"
    ; precise =
        "The top grossing domestic film of Q4 2025 (October through December), according \
         to Box Office Mojo, is based on an original screenplay—meaning not adapted from \
         existing material—as determined by Oscar eligibility or expert consensus (e.g. \
         Writer's Branch of the Academy of Motion Picture Arts and Sciences)."
    }
  ; { short = "A young man wins the 2025 US Open Men's Singles tournament"
    ; precise =
        "The winner of the 2025 US Open Men's Singles Final is under 25 years old on the \
         day of the final match, as determined by official ATP birthdate records."
    }
  ; { short = "Sam Bankman-Fried is pardoned"
    ; precise =
        "Sam Bankman-Fried receives a presidential pardon on some date on or before \
         2025-12-31."
    }
  ; { short = "More than five participants play chess on a random November date"
    ; precise =
        "On a randomly selected date in November 2025, more than five participants \
         confirm via group poll that they played at least one complete game of chess on \
         that date."
    }
  ; { short = "There is an unplanned market closure"
    ; precise =
        "A National Market System stock exchange (e.g. NYSE or Nasdaq) is closed for an \
         unscheduled full-day trading halt on or before 2025-12-31, due to an \
         extraordinary event (e.g., natural disaster or death of a political figure)."
    }
  ; { short = "Travis Kelce and Taylor Swift are engaged"
    ; precise =
        "Travis Kelce and Taylor Swift are reported to be engaged on or before \
         2025-12-31, via a consensus of credible media reporting or primary sources."
    }
  ; { short = "Life is discovered beyond Earth"
    ; precise =
        "A credible space agency (e.g. NASA, ESA) confirms the discovery of life beyond \
         Earth on or before 2025-12-31, as reported by a consensus of scientific or \
         governmental sources."
    }
  ; { short = "The Epstein files are released"
    ; precise =
        "The U.S. Department of Justice releases a collection of sealed or previously \
         unreleased documents related to Jeffrey Epstein on or before 2025-12-31, with \
         release confirmed by official sources or major media coverage."
    }
  ; { short = "The Neom construction project is canceled"
    ; precise =
        "The Saudi government announces the cancellation of the Neom construction \
         project on or before 2025-12-31, confirmed via official statements or major \
         news outlets."
    }
  ; { short = "California experiences a large earthquake"
    ; precise =
        "An earthquake with magnitude 7.0 or greater and an epicenter within California \
         occurs on or before 2025-12-31, as reported by the U.S. Geological Survey \
         (USGS)."
    }
  ; { short = "Our most listened-to artist is a solo female artist"
    ; precise =
        "Across all participants’ 2025 Spotify Wrapped Top Artists lists, the artist \
         with the highest total number of appearances is a solo female artist."
    }
  ; { short = "New York City has a white Christmas"
    ; precise =
        "At least one inch of snow is on the ground in Central Park on December 25, as \
         measured by the National Weather Service."
    }
  ; { short = "Jerome Powell remains Chair of the Federal Reserve"
    ; precise =
        "Jerome Powell is Chair of the Board of Governors of the Federal Reserve System \
         on 2025-12-31."
    }
  ; { short = "Steve Harrington dies in the final season of Stranger Things"
    ; precise =
        "The character Steve Harrington dies in the fifth season of Stranger Things."
    }
  ; { short = "A record is broken at the 2025 World Athletics Championships"
    ; precise =
        "At least one world record is broken at the 2025 World Athletics Championships \
         in Tokyo, confirmed by World Athletics."
    }
  ; { short = "More than three participants change employment status"
    ; precise =
        "More than three participants hold different employment statuses on December 31 \
         compared to September 1."
    }
  ]
;;
