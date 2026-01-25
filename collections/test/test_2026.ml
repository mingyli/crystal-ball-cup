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
    ┌────┬────────────────┬─────────────────────────────────────────────┬────────────────┬────────────┬──────┬─────────────┐
    │ id │ short          │ precise                                     │ label          │ resolution │ date │ explanation │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 1  │ Grand Theft Au │ Rockstar Games releases GTA VI for sale and │ gta            │            │      │             │
    │    │ to VI is relea │  is playable to the public.                 │                │            │      │             │
    │    │ sed            │                                             │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 2  │ The GOP holds  │ After the 2026 Midterms, the Republican par │ senate         │            │      │             │
    │    │ 52 or more Sen │ ty holds 52 or more seats in the U.S. Senat │                │            │      │             │
    │    │ ate seats      │ e.                                          │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 3  │ Lionel Messi p │ Lionel Messi plays (starts or substitutes)  │ messi          │            │      │             │
    │    │ lays in the Wo │ in at least one match for Argentina in the  │                │            │      │             │
    │    │ rld Cup        │ 2026 FIFA World Cup.                        │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 4  │ Artemis II suc │ NASA’s Artemis II mission launches, carries │ moon           │            │      │             │
    │    │ cessfully flie │  a crew around the moon, and returns safely │                │            │      │             │
    │    │ s around the m │  to Earth.                                  │                │            │      │             │
    │    │ oon            │                                             │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 5  │ A participant  │ At least one participant is notified in the │ stan           │            │      │             │
    │    │ is a Top 0.05% │ ir Spotify Wrapped that they are in the Top │                │            │      │             │
    │    │  Stan          │  0.05% (or higher) of listeners for a speci │                │            │      │             │
    │    │                │ fic artist.                                 │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 6  │ Avengers: Doom │ The film Avengers: Doomsday earns more than │ avengers       │            │      │             │
    │    │ sday opens to  │  $250 million at the domestic box office in │                │            │      │             │
    │    │ $250M Domestic │  its opening weekend.                       │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 7  │ The U.S. econo │ The National Bureau of Economic Research de │ recession      │            │      │             │
    │    │ my enters a re │ clares a recession.                         │                │            │      │             │
    │    │ cession        │                                             │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 8  │ The Sagrada Fa │ The central "Tower of Jesus Christ" is decl │ jesus          │            │      │             │
    │    │ mília complete │ ared structurally complete.                 │                │            │      │             │
    │    │ s the "Jesus T │                                             │                │            │      │             │
    │    │ ower"          │                                             │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 9  │ Apple announce │ Apple officially reveals a foldable smartph │ iphone         │            │      │             │
    │    │ s a foldable i │ one model during their annual September key │                │            │      │             │
    │    │ Phone          │ note.                                       │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 10 │ BTS performs a │ The K-pop group BTS performs live together  │ bts            │            │      │             │
    │    │  reunion conce │ as a full group (seven members) following t │                │            │      │             │
    │    │ rt             │ heir military service.                      │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 11 │ The President  │ The House of Representatives votes to impea │ impeach        │            │      │             │
    │    │ is impeached   │ ch the President.                           │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 12 │ LeBron James r │ LeBron James announces his retirement from  │ lebron         │            │      │             │
    │    │ etires         │ professional basketball.                    │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 13 │ The Guggenheim │ The Guggenheim Abu Dhabi museum officially  │ guggenheim     │            │      │             │
    │    │  Abu Dhabi ope │ opens its doors to the public.              │                │            │      │             │
    │    │ ns             │                                             │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 14 │ Oscars Best Pi │ The winner of Best Picture at the 98th Acad │ oscars         │            │      │             │
    │    │ cture is a str │ emy Awards is a film distributed primarily  │                │            │      │             │
    │    │ eaming movie   │ by a streaming service (e.g., Apple, Netfli │                │            │      │             │
    │    │                │ x, Amazon).                                 │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 15 │ Eli Lilly's we │ The FDA officially approves Eli Lilly's ora │ orforglipron   │            │      │             │
    │    │ ight loss pill │ l GLP-1 agonist, orforglipron, for chronic  │                │            │      │             │
    │    │  is FDA approv │ weight management.                          │                │            │      │             │
    │    │ ed             │                                             │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 16 │ We record 10,0 │ The collective running distance recorded by │ strava         │            │      │             │
    │    │ 00 miles run o │  all participants on Strava in 2026 is at l │                │            │      │             │
    │    │ n Strava       │ east 10,000 miles.                          │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 17 │ The US Preside │ On July 4, 2026 (the 250th anniversary of t │ semiquincenten │            │      │             │
    │    │ nt attends the │ he US), the sitting US President delivers a │ nial           │            │      │             │
    │    │  250th anniver │  speech at Independence Hall in Philadelphi │                │            │      │             │
    │    │ sary           │ a.                                          │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 18 │ A release date │ George R. R. Martin announces the release d │ game of throne │            │      │             │
    │    │  for The Winds │ ate for The Winds of Winter.                │ s              │            │      │             │
    │    │  of Winter is  │                                             │                │            │      │             │
    │    │ announced      │                                             │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 19 │ USA wins more  │ The number of silver medals the United Stat │ medals         │            │      │             │
    │    │ silver medals  │ es of America wins exceeds the number of go │                │            │      │             │
    │    │ than gold meda │ ld medals the country wins at the 2026 Wint │                │            │      │             │
    │    │ ls             │ er Olympics.                                │                │            │      │             │
    ├────┼────────────────┼─────────────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 20 │ Participants v │ The group takes a collective total of more  │ korea          │            │      │             │
    │    │ isit Korea mor │ than six round-trips to South Korea in 2026 │                │            │      │             │
    │    │ e than six tim │ .                                           │                │            │      │             │
    │    │ es             │                                             │                │            │      │             │
    └────┴────────────────┴─────────────────────────────────────────────┴────────────────┴────────────┴──────┴─────────────┘
    |}]
;;
