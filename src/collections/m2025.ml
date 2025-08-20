open! Core
open Crystal

let name = "2025"

let all =
  List.mapi
    ~f:(fun i create -> create ~id:(i + 1))
    [ Event.create
        ~short:"Nintendo announces a new Super Smash Bros. game"
        ~precise:
          "Nintendo announces a new Super Smash Bros. game on or before 2025-12-31."
        ~outcome:Pending
    ; Event.create
        ~short:"Zohran Mamdani wins the NYC mayoral election"
        ~precise:
          "Zohran Mamdani is elected Mayor of New York City in the 2025 election, as \
           confirmed by certified election results or a consensus of credible reporting."
        ~outcome:Pending
    ; Event.create
        ~short:
          "The top grossing domestic film of Q4 2025 is based on an original screenplay"
        ~precise:
          "The top grossing domestic film of Q4 2025 (October through December), \
           according to Box Office Mojo, is based on an original screenplay—meaning not \
           adapted from existing material—as determined by Oscar eligibility or expert \
           consensus (e.g., Writer's Branch of the Academy of Motion Picture Arts and \
           Sciences)."
        ~outcome:Pending
    ; Event.create
        ~short:"A young man wins the 2025 US Open Men's Singles tournament"
        ~precise:
          "The winner of the 2025 US Open Men's Singles Final is under 25 years old on \
           the day of the final match, as determined by official ATP birthdate records."
        ~outcome:Pending
    ; Event.create
        ~short:"Sam Bankman-Fried is pardoned"
        ~precise:
          "Sam Bankman-Fried receives a presidential pardon on or before 2025-12-31."
        ~outcome:Pending
    ; Event.create
        ~short:"More than five participants play chess on a random November date"
        ~precise:
          "On a randomly selected date in November 2025, more than five participants \
           confirm via group poll that they played at least one complete game of chess \
           on that date. Participants are those who attended the live event on \
           2025-08-09."
        ~outcome:Pending
    ; Event.create
        ~short:"There is an unplanned market closure"
        ~precise:
          "A National Market System stock exchange (e.g., NYSE or Nasdaq) is closed for \
           an unscheduled full-day trading halt on or before 2025-12-31, due to an \
           extraordinary event (e.g., natural disaster or death of a political figure)."
        ~outcome:Pending
    ; Event.create
        ~short:"Travis Kelce and Taylor Swift are engaged"
        ~precise:
          "Travis Kelce and Taylor Swift are reported to be engaged on or before \
           2025-12-31, via a consensus of credible media reporting or primary sources."
        ~outcome:Pending
    ; Event.create
        ~short:"Life is discovered beyond Earth"
        ~precise:
          "A credible space agency (e.g., NASA, ESA) confirms the discovery of life \
           beyond Earth on or before 2025-12-31, as reported by a consensus of \
           scientific or governmental sources."
        ~outcome:Pending
    ; Event.create
        ~short:"The Epstein files are released"
        ~precise:
          "The U.S. Department of Justice releases a collection of sealed or previously \
           unreleased documents related to Jeffrey Epstein on or before 2025-12-31, with \
           release confirmed by official sources or major media coverage."
        ~outcome:Pending
    ; Event.create
        ~short:"The Neom construction project is canceled"
        ~precise:
          "The Saudi government announces the cancellation of the Neom construction \
           project on or before 2025-12-31, confirmed via official statements or major \
           news outlets."
        ~outcome:Pending
    ; Event.create
        ~short:"Faker wins 2025 League of Legends World Championship"
        ~precise:
          "Lee \"Faker\" Sang-hyeok wins the 2025 League of Legends World Championship."
        ~outcome:Pending
    ; Event.create
        ~short:"California experiences a large earthquake"
        ~precise:
          "An earthquake with magnitude 7.0 or greater and an epicenter within \
           California occurs on or before 2025-12-31, as reported by the U.S. Geological \
           Survey (USGS)."
        ~outcome:Pending
    ; Event.create
        ~short:"Our most listened-to artist is a solo female artist"
        ~precise:
          "The artist with the most appearances across all participants' 2025 Spotify \
           Wrapped Top Artists lists is a solo female artist. Participants are those who \
           attended the live event on 2025-08-09."
        ~outcome:Pending
    ; Event.create
        ~short:"Jerome Powell remains Chair of the Federal Reserve"
        ~precise:
          "Jerome Powell is Chair of the Board of Governors of the Federal Reserve \
           System on 2025-12-31."
        ~outcome:Pending
    ; Event.create
        ~short:"Steve Harrington dies in the final season of Stranger Things"
        ~precise:
          "The character Steve Harrington dies in the fifth season of Stranger Things."
        ~outcome:Pending
    ; Event.create
        ~short:"A record is broken at the 2025 World Athletics Championships"
        ~precise:
          "At least one world record is broken at the 2025 World Athletics Championships \
           in Tokyo, confirmed by World Athletics."
        ~outcome:Pending
    ; Event.create
        ~short:"More than three participants change employment status"
        ~precise:
          "More than three participants hold different employment statuses on September \
           1 compared to December 31. A change in employment status includes switching \
           employers, becoming unemployed, or gaining employment. Participants are those \
           who attended the live event on 2025-08-09."
        ~outcome:Pending
    ; Event.create
        ~short:
          "The winner of the 2025 Breeders' Cup Classic has previously won a Breeders' \
           Cup race"
        ~precise:
          "The winner of the 2025 Breeders' Cup Classic is a horse that has previously \
           won any Breeders' Cup race in an earlier year, as confirmed by the official \
           race results published by the Breeders’ Cup or other recognized racing \
           authority."
        ~outcome:Pending
    ; Event.create
        ~short:"New York City has a white Christmas"
        ~precise:
          "At least one inch of snow is on the ground in Central Park on December 25, as \
           measured by the National Weather Service."
        ~outcome:Pending
    ]
;;

let%expect_test _ =
  let columns =
    let c = Ascii_table.Column.create in
    [ c "id" (fun event -> event |> Event.id |> Int.to_string)
    ; c "short" (fun event -> event |> Event.short)
    ; c "precise" (fun event -> event |> Event.precise)
    ; c "outcome" (fun event -> event |> Event.outcome |> Outcome.to_string)
    ]
  in
  print_endline
    (Ascii_table.to_string
       ~display:Ascii_table.Display.tall_box
       columns
       all
       ~bars:`Unicode);
  [%expect
    {|
    ┌────┬──────────────────────────────────┬──────────────────────────────────────┬─────────┐
    │ id │ short                            │ precise                              │ outcome │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 1  │ Nintendo announces a new Super S │ Nintendo announces a new Super Smash │ Pending │
    │    │ mash Bros. game                  │  Bros. game on or before 2025-12-31. │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 2  │ Zohran Mamdani wins the NYC mayo │ Zohran Mamdani is elected Mayor of N │ Pending │
    │    │ ral election                     │ ew York City in the 2025 election, a │         │
    │    │                                  │ s confirmed by certified election re │         │
    │    │                                  │ sults or a consensus of credible rep │         │
    │    │                                  │ orting.                              │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 3  │ The top grossing domestic film o │ The top grossing domestic film of Q4 │ Pending │
    │    │ f Q4 2025 is based on an origina │  2025 (October through December), ac │         │
    │    │ l screenplay                     │ cording to Box Office Mojo, is based │         │
    │    │                                  │  on an original screenplay—meaning │         │
    │    │                                  │  not adapted from existing material� │         │
    │    │                                  │ ��as determined by Oscar eligibility │         │
    │    │                                  │  or expert consensus (e.g., Writer's │         │
    │    │                                  │  Branch of the Academy of Motion Pic │         │
    │    │                                  │ ture Arts and Sciences).             │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 4  │ A young man wins the 2025 US Ope │ The winner of the 2025 US Open Men's │ Pending │
    │    │ n Men's Singles tournament       │  Singles Final is under 25 years old │         │
    │    │                                  │  on the day of the final match, as d │         │
    │    │                                  │ etermined by official ATP birthdate  │         │
    │    │                                  │ records.                             │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 5  │ Sam Bankman-Fried is pardoned    │ Sam Bankman-Fried receives a preside │ Pending │
    │    │                                  │ ntial pardon on or before 2025-12-31 │         │
    │    │                                  │ .                                    │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 6  │ More than five participants play │ On a randomly selected date in Novem │ Pending │
    │    │  chess on a random November date │ ber 2025, more than five participant │         │
    │    │                                  │ s confirm via group poll that they p │         │
    │    │                                  │ layed at least one complete game of  │         │
    │    │                                  │ chess on that date. Participants are │         │
    │    │                                  │  those who attended the live event o │         │
    │    │                                  │ n 2025-08-09.                        │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 7  │ There is an unplanned market clo │ A National Market System stock excha │ Pending │
    │    │ sure                             │ nge (e.g., NYSE or Nasdaq) is closed │         │
    │    │                                  │  for an unscheduled full-day trading │         │
    │    │                                  │  halt on or before 2025-12-31, due t │         │
    │    │                                  │ o an extraordinary event (e.g., natu │         │
    │    │                                  │ ral disaster or death of a political │         │
    │    │                                  │  figure).                            │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 8  │ Travis Kelce and Taylor Swift ar │ Travis Kelce and Taylor Swift are re │ Pending │
    │    │ e engaged                        │ ported to be engaged on or before 20 │         │
    │    │                                  │ 25-12-31, via a consensus of credibl │         │
    │    │                                  │ e media reporting or primary sources │         │
    │    │                                  │ .                                    │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 9  │ Life is discovered beyond Earth  │ A credible space agency (e.g., NASA, │ Pending │
    │    │                                  │  ESA) confirms the discovery of life │         │
    │    │                                  │  beyond Earth on or before 2025-12-3 │         │
    │    │                                  │ 1, as reported by a consensus of sci │         │
    │    │                                  │ entific or governmental sources.     │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 10 │ The Epstein files are released   │ The U.S. Department of Justice relea │ Pending │
    │    │                                  │ ses a collection of sealed or previo │         │
    │    │                                  │ usly unreleased documents related to │         │
    │    │                                  │  Jeffrey Epstein on or before 2025-1 │         │
    │    │                                  │ 2-31, with release confirmed by offi │         │
    │    │                                  │ cial sources or major media coverage │         │
    │    │                                  │ .                                    │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 11 │ The Neom construction project is │ The Saudi government announces the c │ Pending │
    │    │  canceled                        │ ancellation of the Neom construction │         │
    │    │                                  │  project on or before 2025-12-31, co │         │
    │    │                                  │ nfirmed via official statements or m │         │
    │    │                                  │ ajor news outlets.                   │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 12 │ Faker wins 2025 League of Legend │ Lee "Faker" Sang-hyeok wins the 2025 │ Pending │
    │    │ s World Championship             │  League of Legends World Championshi │         │
    │    │                                  │ p.                                   │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 13 │ California experiences a large e │ An earthquake with magnitude 7.0 or  │ Pending │
    │    │ arthquake                        │ greater and an epicenter within Cali │         │
    │    │                                  │ fornia occurs on or before 2025-12-3 │         │
    │    │                                  │ 1, as reported by the U.S. Geologica │         │
    │    │                                  │ l Survey (USGS).                     │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 14 │ Our most listened-to artist is a │ The artist with the most appearances │ Pending │
    │    │  solo female artist              │  across all participants' 2025 Spoti │         │
    │    │                                  │ fy Wrapped Top Artists lists is a so │         │
    │    │                                  │ lo female artist. Participants are t │         │
    │    │                                  │ hose who attended the live event on  │         │
    │    │                                  │ 2025-08-09.                          │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 15 │ Jerome Powell remains Chair of t │ Jerome Powell is Chair of the Board  │ Pending │
    │    │ he Federal Reserve               │ of Governors of the Federal Reserve  │         │
    │    │                                  │ System on 2025-12-31.                │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 16 │ Steve Harrington dies in the fin │ The character Steve Harrington dies  │ Pending │
    │    │ al season of Stranger Things     │ in the fifth season of Stranger Thin │         │
    │    │                                  │ gs.                                  │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 17 │ A record is broken at the 2025 W │ At least one world record is broken  │ Pending │
    │    │ orld Athletics Championships     │ at the 2025 World Athletics Champion │         │
    │    │                                  │ ships in Tokyo, confirmed by World A │         │
    │    │                                  │ thletics.                            │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 18 │ More than three participants cha │ More than three participants hold di │ Pending │
    │    │ nge employment status            │ fferent employment statuses on Septe │         │
    │    │                                  │ mber 1 compared to December 31. A ch │         │
    │    │                                  │ ange in employment status includes s │         │
    │    │                                  │ witching employers, becoming unemplo │         │
    │    │                                  │ yed, or gaining employment. Particip │         │
    │    │                                  │ ants are those who attended the live │         │
    │    │                                  │  event on 2025-08-09.                │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 19 │ The winner of the 2025 Breeders' │ The winner of the 2025 Breeders' Cup │ Pending │
    │    │  Cup Classic has previously won  │  Classic is a horse that has previou │         │
    │    │ a Breeders' Cup race             │ sly won any Breeders' Cup race in an │         │
    │    │                                  │  earlier year, as confirmed by the o │         │
    │    │                                  │ fficial race results published by th │         │
    │    │                                  │ e Breeders’ Cup or other recognize │         │
    │    │                                  │ d racing authority.                  │         │
    ├────┼──────────────────────────────────┼──────────────────────────────────────┼─────────┤
    │ 20 │ New York City has a white Christ │ At least one inch of snow is on the  │ Pending │
    │    │ mas                              │ ground in Central Park on December 2 │         │
    │    │                                  │ 5, as measured by the National Weath │         │
    │    │                                  │ er Service.                          │         │
    └────┴──────────────────────────────────┴──────────────────────────────────────┴─────────┘ |}]
;;
