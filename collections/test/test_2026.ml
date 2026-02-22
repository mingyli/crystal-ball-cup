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
    ┌────┬────────────────┬────────────────────────────────────┬────────────────┬────────────┬────────────┬────────────────┐
    │ id │ short          │ precise                            │ label          │ resolution │ date       │ explanation    │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 1  │ Grand Theft Au │ Rockstar Games releases GTA VI for │ gta            │            │            │                │
    │    │ to VI is relea │  sale and is playable to the publi │                │            │            │                │
    │    │ sed            │ c.                                 │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 2  │ The GOP holds  │ After the 2026 Midterms, the Repub │ senate         │            │            │                │
    │    │ 52 or more Sen │ lican party holds 52 or more seats │                │            │            │                │
    │    │ ate seats      │  in the U.S. Senate.               │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 3  │ Lionel Messi p │ Lionel Messi plays (starts or subs │ messi          │            │            │                │
    │    │ lays in the Wo │ titutes) in at least one match for │                │            │            │                │
    │    │ rld Cup        │  Argentina in the 2026 FIFA World  │                │            │            │                │
    │    │                │ Cup.                               │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 4  │ Artemis II suc │ NASA’s Artemis II mission launches │ moon           │            │            │                │
    │    │ cessfully flie │ , carries a crew around the moon,  │                │            │            │                │
    │    │ s around the m │ and returns safely to Earth.       │                │            │            │                │
    │    │ oon            │                                    │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 5  │ A participant  │ At least one participant is notifi │ stan           │            │            │                │
    │    │ is a Top 0.05% │ ed in their Spotify Wrapped that t │                │            │            │                │
    │    │  Stan          │ hey are in the Top 0.05% (or highe │                │            │            │                │
    │    │                │ r) of listeners for a specific art │                │            │            │                │
    │    │                │ ist.                               │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 6  │ Avengers: Doom │ The film Avengers: Doomsday earns  │ avengers       │            │            │                │
    │    │ sday opens to  │ more than $250 million at the dome │                │            │            │                │
    │    │ $250M Domestic │ stic box office in its opening wee │                │            │            │                │
    │    │                │ kend.                              │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 7  │ The U.S. econo │ The National Bureau of Economic Re │ recession      │            │            │                │
    │    │ my enters a re │ search declares a recession.       │                │            │            │                │
    │    │ cession        │                                    │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 8  │ The Sagrada Fa │ The central "Tower of Jesus Christ │ jesus          │            │            │                │
    │    │ mília complete │ " is declared structurally complet │                │            │            │                │
    │    │ s the "Jesus T │ e.                                 │                │            │            │                │
    │    │ ower"          │                                    │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 9  │ Apple announce │ Apple officially reveals a foldabl │ iphone         │            │            │                │
    │    │ s a foldable i │ e smartphone model during their an │                │            │            │                │
    │    │ Phone          │ nual September keynote.            │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 10 │ BTS performs a │ The K-pop group BTS performs live  │ bts            │            │            │                │
    │    │  reunion conce │ together as a full group (seven me │                │            │            │                │
    │    │ rt             │ mbers) following their military se │                │            │            │                │
    │    │                │ rvice.                             │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 11 │ The President  │ The House of Representatives votes │ impeach        │            │            │                │
    │    │ is impeached   │  to impeach the President.         │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 12 │ LeBron James r │ LeBron James announces his retirem │ lebron         │            │            │                │
    │    │ etires         │ ent from professional basketball.  │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 13 │ The Guggenheim │ The Guggenheim Abu Dhabi museum of │ guggenheim     │            │            │                │
    │    │  Abu Dhabi ope │ ficially opens its doors to the pu │                │            │            │                │
    │    │ ns             │ blic.                              │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 14 │ Oscars Best Pi │ The winner of Best Picture at the  │ oscars         │            │            │                │
    │    │ cture is a str │ 98th Academy Awards is a film dist │                │            │            │                │
    │    │ eaming movie   │ ributed primarily by a streaming s │                │            │            │                │
    │    │                │ ervice (e.g., Apple, Netflix, Amaz │                │            │            │                │
    │    │                │ on).                               │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 15 │ Eli Lilly's we │ The FDA officially approves Eli Li │ orforglipron   │            │            │                │
    │    │ ight loss pill │ lly's oral GLP-1 agonist, orforgli │                │            │            │                │
    │    │  is FDA approv │ pron, for chronic weight managemen │                │            │            │                │
    │    │ ed             │ t.                                 │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 16 │ We record 10,0 │ The collective running distance re │ strava         │            │            │                │
    │    │ 00 miles run o │ corded by all participants on Stra │                │            │            │                │
    │    │ n Strava       │ va in 2026 is at least 10,000 mile │                │            │            │                │
    │    │                │ s.                                 │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 17 │ The US Preside │ On July 4, 2026 (the 250th anniver │ semiquincenten │            │            │                │
    │    │ nt attends the │ sary of the US), the sitting US Pr │ nial           │            │            │                │
    │    │  250th anniver │ esident delivers a speech at Indep │                │            │            │                │
    │    │ sary           │ endence Hall in Philadelphia.      │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 18 │ A release date │ George R. R. Martin announces the  │ game of throne │            │            │                │
    │    │  for The Winds │ release date for The Winds of Wint │ s              │            │            │                │
    │    │  of Winter is  │ er.                                │                │            │            │                │
    │    │ announced      │                                    │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 19 │ USA wins more  │ The number of silver medals the Un │ medals         │ No         │ 2026-02-22 │ USA won twelve │
    │    │ silver medals  │ ited States of America wins exceed │                │            │            │  gold medals a │
    │    │ than gold meda │ s the number of gold medals the co │                │            │            │ nd twelve silv │
    │    │ ls             │ untry wins at the 2026 Winter Olym │                │            │            │ er medals.     │
    │    │                │ pics.                              │                │            │            │                │
    ├────┼────────────────┼────────────────────────────────────┼────────────────┼────────────┼────────────┼────────────────┤
    │ 20 │ Participants v │ The group takes a collective total │ korea          │            │            │                │
    │    │ isit Korea mor │  of more than six round-trips to S │                │            │            │                │
    │    │ e than six tim │ outh Korea in 2026.                │                │            │            │                │
    │    │ es             │                                    │                │            │            │                │
    └────┴────────────────┴────────────────────────────────────┴────────────────┴────────────┴────────────┴────────────────┘
    |}]
;;
