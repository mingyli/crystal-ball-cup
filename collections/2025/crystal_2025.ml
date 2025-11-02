open! Core
open Crystal

let name = "2025"

let all =
  List.mapi
    ~f:(fun i create -> create ~id:(Event_id.of_int (i + 1)))
    [ Event.create
        ~short:"Nintendo announces a new Super Smash Bros. game"
        ~precise:
          "Nintendo announces a new Super Smash Bros. game on or before 2025-12-31."
        ~label:"smash"
        ~outcome:None
    ; Event.create
        ~short:"Zohran Mamdani wins the NYC mayoral election"
        ~precise:
          "Zohran Mamdani is elected Mayor of New York City in the 2025 election, as \
           confirmed by certified election results or a consensus of credible reporting."
        ~label:"zohran"
        ~outcome:None
    ; Event.create
        ~short:
          "The top grossing domestic film of Q4 2025 is based on an original screenplay"
        ~precise:
          "The top grossing domestic film of Q4 2025 (October through December), \
           according to Box Office Mojo, is based on an original screenplay—meaning not \
           adapted from existing material—as determined by Oscar eligibility or expert \
           consensus (e.g., Writer's Branch of the Academy of Motion Picture Arts and \
           Sciences)."
        ~label:"box office"
        ~outcome:None
    ; Event.create
        ~short:"A young man wins the 2025 US Open Men's Singles tournament"
        ~precise:
          "The winner of the 2025 US Open Men's Singles Final is under 25 years old on \
           the day of the final match, as determined by official ATP birthdate records."
        ~label:"tennis"
        ~outcome:
          (Some
             (Outcome.create
                Yes
                (Date.of_string "2025-09-07")
                "Carlos Alcaraz (born 2003-05-05, age 22 years) defeated Jannik Sinner \
                 to win the 2025 US Open Men's Singles tournament."))
    ; Event.create
        ~short:"Sam Bankman-Fried is pardoned"
        ~precise:
          "Sam Bankman-Fried receives a presidential pardon on or before 2025-12-31."
        ~label:"sbf"
        ~outcome:None
    ; Event.create
        ~short:"More than five participants play chess on a random November date"
        ~precise:
          "On a randomly selected date in November 2025, more than five participants \
           confirm via group poll that they played at least one complete game of chess \
           on that date. Participants are those who attended the live event on \
           2025-08-09."
        ~label:"chess"
        ~outcome:None
    ; Event.create
        ~short:"There is an unplanned market closure"
        ~precise:
          "A National Market System stock exchange (e.g., NYSE or Nasdaq) is closed for \
           an unscheduled full-day trading halt on or before 2025-12-31, due to an \
           extraordinary event (e.g., natural disaster or death of a political figure)."
        ~label:"stock market"
        ~outcome:None
    ; Event.create
        ~short:"Travis Kelce and Taylor Swift are engaged"
        ~precise:
          "Travis Kelce and Taylor Swift are reported to be engaged on or before \
           2025-12-31, via a consensus of credible media reporting or primary sources."
        ~label:"taylor swift"
        ~outcome:
          (Some
             (Outcome.create
                Yes
                (Date.of_string "2025-08-26")
                "Travis Kelce and Taylor Swift were engaged, as confirmed on Instagram."))
    ; Event.create
        ~short:"Life is discovered beyond Earth"
        ~precise:
          "A credible space agency (e.g., NASA, ESA) confirms the discovery of life \
           beyond Earth on or before 2025-12-31, as reported by a consensus of \
           scientific or governmental sources."
        ~label:"aliens"
        ~outcome:None
    ; Event.create
        ~short:"The Epstein files are released"
        ~precise:
          "The U.S. Department of Justice releases a collection of sealed or previously \
           unreleased documents related to Jeffrey Epstein on or before 2025-12-31, with \
           release confirmed by official sources or major media coverage."
        ~label:"epstein"
        ~outcome:None
    ; Event.create
        ~short:"The Neom construction project is canceled"
        ~precise:
          "The Saudi government announces the cancellation of the Neom construction \
           project on or before 2025-12-31, confirmed via official statements or major \
           news outlets."
        ~label:"neom"
        ~outcome:None
    ; Event.create
        ~short:"Faker wins 2025 League of Legends World Championship"
        ~precise:
          "Lee \"Faker\" Sang-hyeok wins the 2025 League of Legends World Championship."
        ~label:"faker"
        ~outcome:None
    ; Event.create
        ~short:"California experiences a large earthquake"
        ~precise:
          "An earthquake with magnitude 7.0 or greater and an epicenter within \
           California occurs on or before 2025-12-31, as reported by the U.S. Geological \
           Survey (USGS)."
        ~label:"earthquake"
        ~outcome:None
    ; Event.create
        ~short:"Our most listened-to artist is a solo female artist"
        ~precise:
          "The artist with the most appearances across all participants' 2025 Spotify \
           Wrapped Top Artists lists is a solo female artist. Participants are those who \
           attended the live event on 2025-08-09."
        ~label:"spotify"
        ~outcome:None
    ; Event.create
        ~short:"Jerome Powell remains Chair of the Federal Reserve"
        ~precise:
          "Jerome Powell is Chair of the Board of Governors of the Federal Reserve \
           System on 2025-12-31."
        ~label:"jerome powell"
        ~outcome:None
    ; Event.create
        ~short:"Steve Harrington dies in the final season of Stranger Things"
        ~precise:
          "The character Steve Harrington dies in the fifth season of Stranger Things."
        ~label:"stranger things"
        ~outcome:None
    ; Event.create
        ~short:"A record is broken at the 2025 World Athletics Championships"
        ~precise:
          "At least one world record is broken at the 2025 World Athletics Championships \
           in Tokyo, confirmed by World Athletics."
        ~label:"world record"
        ~outcome:
          (Some
             (Outcome.create
                Yes
                (Date.of_string "2025-09-15")
                "Armand \"Mondo\" Duplantis broke the pole vault world record for the \
                 14th time, clearing 6.30 meters to capture his third world \
                 championship."))
    ; Event.create
        ~short:"More than three participants change employment status"
        ~precise:
          "More than three participants hold different employment statuses on September \
           1 compared to December 31. A change in employment status includes switching \
           employers, becoming unemployed, or gaining employment. Participants are those \
           who attended the live event on 2025-08-09."
        ~label:"jobs"
        ~outcome:None
    ; Event.create
        ~short:
          "The winner of the 2025 Breeders' Cup Classic has previously won a Breeders' \
           Cup race"
        ~precise:
          "The winner of the 2025 Breeders' Cup Classic is a horse that has previously \
           won any Breeders' Cup race in an earlier year, as confirmed by the official \
           race results published by the Breeders’ Cup or other recognized racing \
           authority."
        ~label:"horse race"
        ~outcome:
          (Some
             (Outcome.create
                No
                (Date.of_string "2025-11-01")
                "Forever Young won the 2025 Breeders' Cup Classic, but had not \
                 previously won any Breeders' Cup race."))
    ; Event.create
        ~short:"New York City has a white Christmas"
        ~precise:
          "At least one inch of snow is on the ground in Central Park on December 25, as \
           measured by the National Weather Service."
        ~label:"christmas"
        ~outcome:None
    ]
;;

include Collection.Make (struct
    let name = name
    let all = all
  end)
