open! Core
open Crystal

let%expect_test _ =
  let columns =
    let c = Ascii_table.Column.create in
    let outcome_field f =
      fun event ->
      match Event.outcome event with
      | None -> ""
      | Some outcome -> f outcome
    in
    [ c "id" (fun event -> event |> Event.id |> Event_id.to_string)
    ; c "short" (fun event -> event |> Event.short)
    ; c "precise" (fun event -> event |> Event.precise)
    ]
    @ [ c
          "resolution"
          (outcome_field (fun outcome ->
             Outcome.resolution outcome |> Resolution.to_string))
      ; c "date" (outcome_field (fun outcome -> Outcome.date outcome |> Date.to_string))
      ; c "explanation" (outcome_field (fun outcome -> Outcome.explanation outcome))
      ]
  in
  print_endline
    (Ascii_table.to_string
       ~limit_width_to:120
       ~display:Ascii_table.Display.tall_box
       columns
       Crystal_2025.all
       ~bars:`Unicode);
  [%expect
    {|
    ┌────┬─────────────────────────┬──────────────────────────────┬────────────┬────────────┬──────────────────────────────┐
    │ id │ short                   │ precise                      │ resolution │ date       │ explanation                  │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 1  │ Nintendo announces a ne │ Nintendo announces a new Sup │            │            │                              │
    │    │ w Super Smash Bros. gam │ er Smash Bros. game on or be │            │            │                              │
    │    │ e                       │ fore 2025-12-31.             │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 2  │ Zohran Mamdani wins the │ Zohran Mamdani is elected Ma │            │            │                              │
    │    │  NYC mayoral election   │ yor of New York City in the  │            │            │                              │
    │    │                         │ 2025 election, as confirmed  │            │            │                              │
    │    │                         │ by certified election result │            │            │                              │
    │    │                         │ s or a consensus of credible │            │            │                              │
    │    │                         │  reporting.                  │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 3  │ The top grossing domest │ The top grossing domestic fi │            │            │                              │
    │    │ ic film of Q4 2025 is b │ lm of Q4 2025 (October throu │            │            │                              │
    │    │ ased on an original scr │ gh December), according to B │            │            │                              │
    │    │ eenplay                 │ ox Office Mojo, is based on  │            │            │                              │
    │    │                         │ an original screenplay—meani │            │            │                              │
    │    │                         │ ng not adapted from existing │            │            │                              │
    │    │                         │  material—as determined by O │            │            │                              │
    │    │                         │ scar eligibility or expert c │            │            │                              │
    │    │                         │ onsensus (e.g., Writer's Bra │            │            │                              │
    │    │                         │ nch of the Academy of Motion │            │            │                              │
    │    │                         │  Picture Arts and Sciences). │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 4  │ A young man wins the 20 │ The winner of the 2025 US Op │ Yes        │ 2025-09-07 │ Carlos Alcaraz (born 2003-05 │
    │    │ 25 US Open Men's Single │ en Men's Singles Final is un │            │            │ -05, age 22 years) defeated  │
    │    │ s tournament            │ der 25 years old on the day  │            │            │ Jannik Sinner to win the 202 │
    │    │                         │ of the final match, as deter │            │            │ 5 US Open Men's Singles tour │
    │    │                         │ mined by official ATP birthd │            │            │ nament.                      │
    │    │                         │ ate records.                 │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 5  │ Sam Bankman-Fried is pa │ Sam Bankman-Fried receives a │            │            │                              │
    │    │ rdoned                  │  presidential pardon on or b │            │            │                              │
    │    │                         │ efore 2025-12-31.            │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 6  │ More than five particip │ On a randomly selected date  │            │            │                              │
    │    │ ants play chess on a ra │ in November 2025, more than  │            │            │                              │
    │    │ ndom November date      │ five participants confirm vi │            │            │                              │
    │    │                         │ a group poll that they playe │            │            │                              │
    │    │                         │ d at least one complete game │            │            │                              │
    │    │                         │  of chess on that date. Part │            │            │                              │
    │    │                         │ icipants are those who atten │            │            │                              │
    │    │                         │ ded the live event on 2025-0 │            │            │                              │
    │    │                         │ 8-09.                        │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 7  │ There is an unplanned m │ A National Market System sto │            │            │                              │
    │    │ arket closure           │ ck exchange (e.g., NYSE or N │            │            │                              │
    │    │                         │ asdaq) is closed for an unsc │            │            │                              │
    │    │                         │ heduled full-day trading hal │            │            │                              │
    │    │                         │ t on or before 2025-12-31, d │            │            │                              │
    │    │                         │ ue to an extraordinary event │            │            │                              │
    │    │                         │  (e.g., natural disaster or  │            │            │                              │
    │    │                         │ death of a political figure) │            │            │                              │
    │    │                         │ .                            │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 8  │ Travis Kelce and Taylor │ Travis Kelce and Taylor Swif │ Yes        │ 2025-08-26 │ Travis Kelce and Taylor Swif │
    │    │  Swift are engaged      │ t are reported to be engaged │            │            │ t were engaged, as confirmed │
    │    │                         │  on or before 2025-12-31, vi │            │            │  on Instagram.               │
    │    │                         │ a a consensus of credible me │            │            │                              │
    │    │                         │ dia reporting or primary sou │            │            │                              │
    │    │                         │ rces.                        │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 9  │ Life is discovered beyo │ A credible space agency (e.g │            │            │                              │
    │    │ nd Earth                │ ., NASA, ESA) confirms the d │            │            │                              │
    │    │                         │ iscovery of life beyond Eart │            │            │                              │
    │    │                         │ h on or before 2025-12-31, a │            │            │                              │
    │    │                         │ s reported by a consensus of │            │            │                              │
    │    │                         │  scientific or governmental  │            │            │                              │
    │    │                         │ sources.                     │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 10 │ The Epstein files are r │ The U.S. Department of Justi │            │            │                              │
    │    │ eleased                 │ ce releases a collection of  │            │            │                              │
    │    │                         │ sealed or previously unrelea │            │            │                              │
    │    │                         │ sed documents related to Jef │            │            │                              │
    │    │                         │ frey Epstein on or before 20 │            │            │                              │
    │    │                         │ 25-12-31, with release confi │            │            │                              │
    │    │                         │ rmed by official sources or  │            │            │                              │
    │    │                         │ major media coverage.        │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 11 │ The Neom construction p │ The Saudi government announc │            │            │                              │
    │    │ roject is canceled      │ es the cancellation of the N │            │            │                              │
    │    │                         │ eom construction project on  │            │            │                              │
    │    │                         │ or before 2025-12-31, confir │            │            │                              │
    │    │                         │ med via official statements  │            │            │                              │
    │    │                         │ or major news outlets.       │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 12 │ Faker wins 2025 League  │ Lee "Faker" Sang-hyeok wins  │            │            │                              │
    │    │ of Legends World Champi │ the 2025 League of Legends W │            │            │                              │
    │    │ onship                  │ orld Championship.           │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 13 │ California experiences  │ An earthquake with magnitude │            │            │                              │
    │    │ a large earthquake      │  7.0 or greater and an epice │            │            │                              │
    │    │                         │ nter within California occur │            │            │                              │
    │    │                         │ s on or before 2025-12-31, a │            │            │                              │
    │    │                         │ s reported by the U.S. Geolo │            │            │                              │
    │    │                         │ gical Survey (USGS).         │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 14 │ Our most listened-to ar │ The artist with the most app │            │            │                              │
    │    │ tist is a solo female a │ earances across all particip │            │            │                              │
    │    │ rtist                   │ ants' 2025 Spotify Wrapped T │            │            │                              │
    │    │                         │ op Artists lists is a solo f │            │            │                              │
    │    │                         │ emale artist. Participants a │            │            │                              │
    │    │                         │ re those who attended the li │            │            │                              │
    │    │                         │ ve event on 2025-08-09.      │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 15 │ Jerome Powell remains C │ Jerome Powell is Chair of th │            │            │                              │
    │    │ hair of the Federal Res │ e Board of Governors of the  │            │            │                              │
    │    │ erve                    │ Federal Reserve System on 20 │            │            │                              │
    │    │                         │ 25-12-31.                    │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 16 │ Steve Harrington dies i │ The character Steve Harringt │            │            │                              │
    │    │ n the final season of S │ on dies in the fifth season  │            │            │                              │
    │    │ tranger Things          │ of Stranger Things.          │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 17 │ A record is broken at t │ At least one world record is │ Yes        │ 2025-09-15 │ Armand "Mondo" Duplantis bro │
    │    │ he 2025 World Athletics │  broken at the 2025 World At │            │            │ ke the pole vault world reco │
    │    │  Championships          │ hletics Championships in Tok │            │            │ rd for the 14th time, cleari │
    │    │                         │ yo, confirmed by World Athle │            │            │ ng 6.30 meters to capture hi │
    │    │                         │ tics.                        │            │            │ s third world championship.  │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 18 │ More than three partici │ More than three participants │            │            │                              │
    │    │ pants change employment │  hold different employment s │            │            │                              │
    │    │  status                 │ tatuses on September 1 compa │            │            │                              │
    │    │                         │ red to December 31. A change │            │            │                              │
    │    │                         │  in employment status includ │            │            │                              │
    │    │                         │ es switching employers, beco │            │            │                              │
    │    │                         │ ming unemployed, or gaining  │            │            │                              │
    │    │                         │ employment. Participants are │            │            │                              │
    │    │                         │  those who attended the live │            │            │                              │
    │    │                         │  event on 2025-08-09.        │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 19 │ The winner of the 2025  │ The winner of the 2025 Breed │            │            │                              │
    │    │ Breeders' Cup Classic h │ ers' Cup Classic is a horse  │            │            │                              │
    │    │ as previously won a Bre │ that has previously won any  │            │            │                              │
    │    │ eders' Cup race         │ Breeders' Cup race in an ear │            │            │                              │
    │    │                         │ lier year, as confirmed by t │            │            │                              │
    │    │                         │ he official race results pub │            │            │                              │
    │    │                         │ lished by the Breeders’ Cup  │            │            │                              │
    │    │                         │ or other recognized racing a │            │            │                              │
    │    │                         │ uthority.                    │            │            │                              │
    ├────┼─────────────────────────┼──────────────────────────────┼────────────┼────────────┼──────────────────────────────┤
    │ 20 │ New York City has a whi │ At least one inch of snow is │            │            │                              │
    │    │ te Christmas            │  on the ground in Central Pa │            │            │                              │
    │    │                         │ rk on December 25, as measur │            │            │                              │
    │    │                         │ ed by the National Weather S │            │            │                              │
    │    │                         │ ervice.                      │            │            │                              │
    └────┴─────────────────────────┴──────────────────────────────┴────────────┴────────────┴──────────────────────────────┘
    |}]
;;
