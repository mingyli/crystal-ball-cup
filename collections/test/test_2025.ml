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
    ; c "label" (fun event -> event |> Event.label)
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
    ┌────┬────────────────────┬────────────────────────┬────────────────┬────────────┬────────────┬────────────────────────┐
    │ id │ short              │ precise                │ label          │ resolution │ date       │ explanation            │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 1  │ Nintendo announces │ Nintendo announces a n │ smash          │            │            │                        │
    │    │  a new Super Smash │ ew Super Smash Bros. g │                │            │            │                        │
    │    │  Bros. game        │ ame on or before 2025- │                │            │            │                        │
    │    │                    │ 12-31.                 │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 2  │ Zohran Mamdani win │ Zohran Mamdani is elec │ zohran         │ Yes        │ 2025-11-04 │ Zohran Mamdani won the │
    │    │ s the NYC mayoral  │ ted Mayor of New York  │                │            │            │  New York City mayoral │
    │    │ election           │ City in the 2025 elect │                │            │            │  election.             │
    │    │                    │ ion, as confirmed by c │                │            │            │                        │
    │    │                    │ ertified election resu │                │            │            │                        │
    │    │                    │ lts or a consensus of  │                │            │            │                        │
    │    │                    │ credible reporting.    │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 3  │ The top grossing d │ The top grossing domes │ box office     │            │            │                        │
    │    │ omestic film of Q4 │ tic film of Q4 2025 (O │                │            │            │                        │
    │    │  2025 is based on  │ ctober through Decembe │                │            │            │                        │
    │    │ an original screen │ r), according to Box O │                │            │            │                        │
    │    │ play               │ ffice Mojo, is based o │                │            │            │                        │
    │    │                    │ n an original screenpl │                │            │            │                        │
    │    │                    │ ay—meaning not adapted │                │            │            │                        │
    │    │                    │  from existing materia │                │            │            │                        │
    │    │                    │ l—as determined by Osc │                │            │            │                        │
    │    │                    │ ar eligibility or expe │                │            │            │                        │
    │    │                    │ rt consensus (e.g., Wr │                │            │            │                        │
    │    │                    │ iter's Branch of the A │                │            │            │                        │
    │    │                    │ cademy of Motion Pictu │                │            │            │                        │
    │    │                    │ re Arts and Sciences). │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 4  │ A young man wins t │ The winner of the 2025 │ tennis         │ Yes        │ 2025-09-07 │ Carlos Alcaraz (born 2 │
    │    │ he 2025 US Open Me │  US Open Men's Singles │                │            │            │ 003-05-05, age 22 year │
    │    │ n's Singles tourna │  Final is under 25 yea │                │            │            │ s) defeated Jannik Sin │
    │    │ ment               │ rs old on the day of t │                │            │            │ ner to win the 2025 US │
    │    │                    │ he final match, as det │                │            │            │  Open Men's Singles to │
    │    │                    │ ermined by official AT │                │            │            │ urnament.              │
    │    │                    │ P birthdate records.   │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 5  │ Sam Bankman-Fried  │ Sam Bankman-Fried rece │ sbf            │            │            │                        │
    │    │ is pardoned        │ ives a presidential pa │                │            │            │                        │
    │    │                    │ rdon on or before 2025 │                │            │            │                        │
    │    │                    │ -12-31.                │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 6  │ More than five par │ On a randomly selected │ chess          │ No         │ 2025-11-18 │ One participant played │
    │    │ ticipants play che │  date in November 2025 │                │            │            │  chess on 2025-11-18.  │
    │    │ ss on a random Nov │ , more than five parti │                │            │            │                        │
    │    │ ember date         │ cipants confirm via gr │                │            │            │                        │
    │    │                    │ oup poll that they pla │                │            │            │                        │
    │    │                    │ yed at least one compl │                │            │            │                        │
    │    │                    │ ete game of chess on t │                │            │            │                        │
    │    │                    │ hat date. Participants │                │            │            │                        │
    │    │                    │  are those who attende │                │            │            │                        │
    │    │                    │ d the live event on 20 │                │            │            │                        │
    │    │                    │ 25-08-09.              │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 7  │ There is an unplan │ A National Market Syst │ stock market   │            │            │                        │
    │    │ ned market closure │ em stock exchange (e.g │                │            │            │                        │
    │    │                    │ ., NYSE or Nasdaq) is  │                │            │            │                        │
    │    │                    │ closed for an unschedu │                │            │            │                        │
    │    │                    │ led full-day trading h │                │            │            │                        │
    │    │                    │ alt on or before 2025- │                │            │            │                        │
    │    │                    │ 12-31, due to an extra │                │            │            │                        │
    │    │                    │ ordinary event (e.g.,  │                │            │            │                        │
    │    │                    │ natural disaster or de │                │            │            │                        │
    │    │                    │ ath of a political fig │                │            │            │                        │
    │    │                    │ ure).                  │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 8  │ Travis Kelce and T │ Travis Kelce and Taylo │ taylor swift   │ Yes        │ 2025-08-26 │ Travis Kelce and Taylo │
    │    │ aylor Swift are en │ r Swift are reported t │                │            │            │ r Swift were engaged,  │
    │    │ gaged              │ o be engaged on or bef │                │            │            │ as confirmed on Instag │
    │    │                    │ ore 2025-12-31, via a  │                │            │            │ ram.                   │
    │    │                    │ consensus of credible  │                │            │            │                        │
    │    │                    │ media reporting or pri │                │            │            │                        │
    │    │                    │ mary sources.          │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 9  │ Life is discovered │ A credible space agenc │ aliens         │            │            │                        │
    │    │  beyond Earth      │ y (e.g., NASA, ESA) co │                │            │            │                        │
    │    │                    │ nfirms the discovery o │                │            │            │                        │
    │    │                    │ f life beyond Earth on │                │            │            │                        │
    │    │                    │  or before 2025-12-31, │                │            │            │                        │
    │    │                    │  as reported by a cons │                │            │            │                        │
    │    │                    │ ensus of scientific or │                │            │            │                        │
    │    │                    │  governmental sources. │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 10 │ The Epstein files  │ The U.S. Department of │ epstein        │            │            │                        │
    │    │ are released       │  Justice releases a co │                │            │            │                        │
    │    │                    │ llection of sealed or  │                │            │            │                        │
    │    │                    │ previously unreleased  │                │            │            │                        │
    │    │                    │ documents related to J │                │            │            │                        │
    │    │                    │ effrey Epstein on or b │                │            │            │                        │
    │    │                    │ efore 2025-12-31, with │                │            │            │                        │
    │    │                    │  release confirmed by  │                │            │            │                        │
    │    │                    │ official sources or ma │                │            │            │                        │
    │    │                    │ jor media coverage.    │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 11 │ The Neom construct │ The Saudi government a │ neom           │            │            │                        │
    │    │ ion project is can │ nnounces the cancellat │                │            │            │                        │
    │    │ celed              │ ion of the Neom constr │                │            │            │                        │
    │    │                    │ uction project on or b │                │            │            │                        │
    │    │                    │ efore 2025-12-31, conf │                │            │            │                        │
    │    │                    │ irmed via official sta │                │            │            │                        │
    │    │                    │ tements or major news  │                │            │            │                        │
    │    │                    │ outlets.               │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 12 │ Faker wins 2025 Le │ Lee "Faker" Sang-hyeok │ faker          │ Yes        │ 2025-11-09 │ T1 beat KT Rolster 3-2 │
    │    │ ague of Legends Wo │  wins the 2025 League  │                │            │            │ .                      │
    │    │ rld Championship   │ of Legends World Champ │                │            │            │                        │
    │    │                    │ ionship.               │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 13 │ California experie │ An earthquake with mag │ earthquake     │            │            │                        │
    │    │ nces a large earth │ nitude 7.0 or greater  │                │            │            │                        │
    │    │ quake              │ and an epicenter withi │                │            │            │                        │
    │    │                    │ n California occurs on │                │            │            │                        │
    │    │                    │  or before 2025-12-31, │                │            │            │                        │
    │    │                    │  as reported by the U. │                │            │            │                        │
    │    │                    │ S. Geological Survey ( │                │            │            │                        │
    │    │                    │ USGS).                 │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 14 │ Our most listened- │ The artist with the mo │ spotify        │            │            │                        │
    │    │ to artist is a sol │ st appearances across  │                │            │            │                        │
    │    │ o female artist    │ all participants' 2025 │                │            │            │                        │
    │    │                    │  Spotify Wrapped Top A │                │            │            │                        │
    │    │                    │ rtists lists is a solo │                │            │            │                        │
    │    │                    │  female artist. Partic │                │            │            │                        │
    │    │                    │ ipants are those who a │                │            │            │                        │
    │    │                    │ ttended the live event │                │            │            │                        │
    │    │                    │  on 2025-08-09.        │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 15 │ Jerome Powell rema │ Jerome Powell is Chair │ jerome powell  │            │            │                        │
    │    │ ins Chair of the F │  of the Board of Gover │                │            │            │                        │
    │    │ ederal Reserve     │ nors of the Federal Re │                │            │            │                        │
    │    │                    │ serve System on 2025-1 │                │            │            │                        │
    │    │                    │ 2-31.                  │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 16 │ Steve Harrington d │ The character Steve Ha │ stranger thing │            │            │                        │
    │    │ ies in the final s │ rrington dies in the f │ s              │            │            │                        │
    │    │ eason of Stranger  │ ifth season of Strange │                │            │            │                        │
    │    │ Things             │ r Things.              │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 17 │ A record is broken │ At least one world rec │ world record   │ Yes        │ 2025-09-15 │ Armand "Mondo" Duplant │
    │    │  at the 2025 World │ ord is broken at the 2 │                │            │            │ is broke the pole vaul │
    │    │  Athletics Champio │ 025 World Athletics Ch │                │            │            │ t world record for the │
    │    │ nships             │ ampionships in Tokyo,  │                │            │            │  14th time, clearing 6 │
    │    │                    │ confirmed by World Ath │                │            │            │ .30 meters to capture  │
    │    │                    │ letics.                │                │            │            │ his third world champi │
    │    │                    │                        │                │            │            │ onship.                │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 18 │ More than three pa │ More than three partic │ jobs           │            │            │                        │
    │    │ rticipants change  │ ipants hold different  │                │            │            │                        │
    │    │ employment status  │ employment statuses on │                │            │            │                        │
    │    │                    │  September 1 compared  │                │            │            │                        │
    │    │                    │ to December 31. A chan │                │            │            │                        │
    │    │                    │ ge in employment statu │                │            │            │                        │
    │    │                    │ s includes switching e │                │            │            │                        │
    │    │                    │ mployers, becoming une │                │            │            │                        │
    │    │                    │ mployed, or gaining em │                │            │            │                        │
    │    │                    │ ployment. Participants │                │            │            │                        │
    │    │                    │  are those who attende │                │            │            │                        │
    │    │                    │ d the live event on 20 │                │            │            │                        │
    │    │                    │ 25-08-09.              │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 19 │ The winner of the  │ The winner of the 2025 │ horse race     │ No         │ 2025-11-01 │ Forever Young won the  │
    │    │ 2025 Breeders' Cup │  Breeders' Cup Classic │                │            │            │ 2025 Breeders' Cup Cla │
    │    │  Classic has previ │  is a horse that has p │                │            │            │ ssic, but had not prev │
    │    │ ously won a Breede │ reviously won any Bree │                │            │            │ iously won any Breeder │
    │    │ rs' Cup race       │ ders' Cup race in an e │                │            │            │ s' Cup race.           │
    │    │                    │ arlier year, as confir │                │            │            │                        │
    │    │                    │ med by the official ra │                │            │            │                        │
    │    │                    │ ce results published b │                │            │            │                        │
    │    │                    │ y the Breeders’ Cup or │                │            │            │                        │
    │    │                    │  other recognized raci │                │            │            │                        │
    │    │                    │ ng authority.          │                │            │            │                        │
    ├────┼────────────────────┼────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 20 │ New York City has  │ At least one inch of s │ christmas      │            │            │                        │
    │    │ a white Christmas  │ now is on the ground i │                │            │            │                        │
    │    │                    │ n Central Park on Dece │                │            │            │                        │
    │    │                    │ mber 25, as measured b │                │            │            │                        │
    │    │                    │ y the National Weather │                │            │            │                        │
    │    │                    │  Service.              │                │            │            │                        │
    └────┴────────────────────┴────────────────────────┴────────────────┴────────────┴────────────┴────────────────────────┘
    |}]
;;
