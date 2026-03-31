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
       Crystal_2026.all
       ~bars:`Unicode);
  [%expect
    {|
    ┌────┬────────────────┬──────────────────────────┬────────────────┬────────────┬────────────┬──────────────────────────┐
    │ id │ short          │ precise                  │ label          │ resolution │ date       │ explanation              │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 1  │ Grand Theft Au │ Rockstar Games releases  │ gta            │            │            │                          │
    │    │ to VI is relea │ GTA VI for sale and is p │                │            │            │                          │
    │    │ sed            │ layable to the public.   │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 2  │ The GOP holds  │ After the 2026 Midterms, │ senate         │            │            │                          │
    │    │ 52 or more Sen │  the Republican party ho │                │            │            │                          │
    │    │ ate seats      │ lds 52 or more seats in  │                │            │            │                          │
    │    │                │ the U.S. Senate.         │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 3  │ Lionel Messi p │ Lionel Messi plays (star │ messi          │            │            │                          │
    │    │ lays in the Wo │ ts or substitutes) in at │                │            │            │                          │
    │    │ rld Cup        │  least one match for Arg │                │            │            │                          │
    │    │                │ entina in the 2026 FIFA  │                │            │            │                          │
    │    │                │ World Cup.               │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 4  │ Artemis II suc │ NASA’s Artemis II missio │ moon           │            │            │                          │
    │    │ cessfully flie │ n launches, carries a cr │                │            │            │                          │
    │    │ s around the m │ ew around the moon, and  │                │            │            │                          │
    │    │ oon            │ returns safely to Earth. │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 5  │ A participant  │ At least one participant │ stan           │            │            │                          │
    │    │ is a Top 0.05% │  is notified in their Sp │                │            │            │                          │
    │    │  Stan          │ otify Wrapped that they  │                │            │            │                          │
    │    │                │ are in the Top 0.05% (or │                │            │            │                          │
    │    │                │  higher) of listeners fo │                │            │            │                          │
    │    │                │ r a specific artist.     │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 6  │ Avengers: Doom │ The film Avengers: Dooms │ avengers       │            │            │                          │
    │    │ sday opens to  │ day earns more than $250 │                │            │            │                          │
    │    │ $250M Domestic │  million at the domestic │                │            │            │                          │
    │    │                │  box office in its openi │                │            │            │                          │
    │    │                │ ng weekend.              │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 7  │ The U.S. econo │ The National Bureau of E │ recession      │            │            │                          │
    │    │ my enters a re │ conomic Research declare │                │            │            │                          │
    │    │ cession        │ s a recession.           │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 8  │ The Sagrada Fa │ The central "Tower of Je │ jesus          │            │            │                          │
    │    │ mília complete │ sus Christ" is declared  │                │            │            │                          │
    │    │ s the "Jesus T │ structurally complete.   │                │            │            │                          │
    │    │ ower"          │                          │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 9  │ Apple announce │ Apple officially reveals │ iphone         │            │            │                          │
    │    │ s a foldable i │  a foldable smartphone m │                │            │            │                          │
    │    │ Phone          │ odel during their annual │                │            │            │                          │
    │    │                │  September keynote.      │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 10 │ BTS performs a │ The K-pop group BTS perf │ bts            │ Yes        │ 2026-03-21 │ BTS returned as a full g │
    │    │  reunion conce │ orms live together as a  │                │            │            │ roup with a globally str │
    │    │ rt             │ full group (seven member │                │            │            │ eamed concert on Netflix │
    │    │                │ s) following their milit │                │            │            │  from Gwanghwamun Square │
    │    │                │ ary service.             │                │            │            │  in Seoul on March 21, 2 │
    │    │                │                          │                │            │            │ 026.                     │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 11 │ The President  │ The House of Representat │ impeach        │            │            │                          │
    │    │ is impeached   │ ives votes to impeach th │                │            │            │                          │
    │    │                │ e President.             │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 12 │ LeBron James r │ LeBron James announces h │ lebron         │            │            │                          │
    │    │ etires         │ is retirement from profe │                │            │            │                          │
    │    │                │ ssional basketball.      │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 13 │ The Guggenheim │ The Guggenheim Abu Dhabi │ guggenheim     │            │            │                          │
    │    │  Abu Dhabi ope │  museum officially opens │                │            │            │                          │
    │    │ ns             │  its doors to the public │                │            │            │                          │
    │    │                │ .                        │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 14 │ Oscars Best Pi │ The winner of Best Pictu │ oscars         │ No         │ 2026-03-15 │ The Best Picture winner, │
    │    │ cture is a str │ re at the 98th Academy A │                │            │            │  One Battle After Anothe │
    │    │ eaming movie   │ wards is a film distribu │                │            │            │ r, is distributed by War │
    │    │                │ ted primarily by a strea │                │            │            │ ners Bros. Pictures      │
    │    │                │ ming service (e.g., Appl │                │            │            │                          │
    │    │                │ e, Netflix, Amazon).     │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 15 │ Eli Lilly's we │ The FDA officially appro │ orforglipron   │            │            │                          │
    │    │ ight loss pill │ ves Eli Lilly's oral GLP │                │            │            │                          │
    │    │  is FDA approv │ -1 agonist, orforglipron │                │            │            │                          │
    │    │ ed             │ , for chronic weight man │                │            │            │                          │
    │    │                │ agement.                 │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 16 │ We record 10,0 │ The collective running d │ strava         │            │            │                          │
    │    │ 00 miles run o │ istance recorded by all  │                │            │            │                          │
    │    │ n Strava       │ participants on Strava i │                │            │            │                          │
    │    │                │ n 2026 is at least 10,00 │                │            │            │                          │
    │    │                │ 0 miles.                 │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 17 │ The US Preside │ On July 4, 2026 (the 250 │ semiquincenten │            │            │                          │
    │    │ nt attends the │ th anniversary of the US │ nial           │            │            │                          │
    │    │  250th anniver │ ), the sitting US Presid │                │            │            │                          │
    │    │ sary           │ ent delivers a speech at │                │            │            │                          │
    │    │                │  Independence Hall in Ph │                │            │            │                          │
    │    │                │ iladelphia.              │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 18 │ A release date │ George R. R. Martin anno │ game of throne │            │            │                          │
    │    │  for The Winds │ unces the release date f │ s              │            │            │                          │
    │    │  of Winter is  │ or The Winds of Winter.  │                │            │            │                          │
    │    │ announced      │                          │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 19 │ USA wins more  │ The number of silver med │ medals         │ No         │ 2026-02-22 │ USA won twelve gold meda │
    │    │ silver medals  │ als the United States of │                │            │            │ ls and twelve silver med │
    │    │ than gold meda │  America wins exceeds th │                │            │            │ als.                     │
    │    │ ls             │ e number of gold medals  │                │            │            │                          │
    │    │                │ the country wins at the  │                │            │            │                          │
    │    │                │ 2026 Winter Olympics.    │                │            │            │                          │
    ├────┼────────────────┼──────────────────────────┼────────────────┼────────────┼────────────┼──────────────────────────┤
    │ 20 │ Participants v │ The group takes a collec │ korea          │            │            │                          │
    │    │ isit Korea mor │ tive total of more than  │                │            │            │                          │
    │    │ e than six tim │ six round-trips to South │                │            │            │                          │
    │    │ es             │  Korea in 2026.          │                │            │            │                          │
    └────┴────────────────┴──────────────────────────┴────────────────┴────────────┴────────────┴──────────────────────────┘
    |}]
;;
