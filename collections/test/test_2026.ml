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
    ┌────┬──────────────────────┬───────────────────────────────────────┬────────────────┬────────────┬──────┬─────────────┐
    │ id │ short                │ precise                               │ label          │ resolution │ date │ explanation │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 1  │ Grand Theft Auto VI  │ Rockstar Games releases GTA VI for sa │ gta            │            │      │             │
    │    │ is released          │ le to the public.                     │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 2  │ The GOP holds 52 or  │ After the 2026 Midterms, the Republic │ senate         │            │      │             │
    │    │ more Senate seats    │ an party holds 52 or more seats in th │                │            │      │             │
    │    │                      │ e U.S. Senate.                        │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 3  │ Lionel Messi plays i │ Lionel Messi plays (starts or substit │ messi          │            │      │             │
    │    │ n the World Cup      │ utes) in at least one match for Argen │                │            │      │             │
    │    │                      │ tina in the 2026 FIFA World Cup.      │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 4  │ Artemis II successfu │ NASA’s Artemis II mission launches, c │ moon           │            │      │             │
    │    │ lly flies around the │ arries a crew around the moon, and re │                │            │      │             │
    │    │  moon                │ turns safely to Earth.                │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 5  │ A participant is a T │ At least one participant is notified  │ stan           │            │      │             │
    │    │ op 0.05% Stan        │ in their Spotify Wrapped that they ar │                │            │      │             │
    │    │                      │ e in the Top 0.05% (or higher) of lis │                │            │      │             │
    │    │                      │ teners for a specific artist.         │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 6  │ Avengers: Doomsday o │ The film Avengers: Doomsday earns mor │ avengers       │            │      │             │
    │    │ pens to $250M Domest │ e than $250 million at the domestic b │                │            │      │             │
    │    │ ic                   │ ox office in its opening weekend.     │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 7  │ The U.S. economy ent │ The National Bureau of Economic Resea │ recession      │            │      │             │
    │    │ ers a recession      │ rch declares a recession.             │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 8  │ The Sagrada Família  │ The central "Tower of Jesus Christ" i │ jesus          │            │      │             │
    │    │ completes the "Jesus │ s declared structurally complete.     │                │            │      │             │
    │    │  Tower"              │                                       │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 9  │ Apple announces a fo │ Apple officially reveals a foldable s │ iphone         │            │      │             │
    │    │ ldable iPhone        │ martphone model during their annual S │                │            │      │             │
    │    │                      │ eptember keynote.                     │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 10 │ BTS performs a reuni │ The K-pop group BTS performs live tog │ bts            │            │      │             │
    │    │ on concert           │ ether as a full group (seven members) │                │            │      │             │
    │    │                      │  following their military service.    │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 11 │ The President is imp │ The House of Representatives votes to │ impeach        │            │      │             │
    │    │ eached               │  impeach the President.               │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 12 │ LeBron James retires │ LeBron James announces his retirement │ lebron         │            │      │             │
    │    │                      │  from professional basketball.        │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 13 │ The Guggenheim Abu D │ The Guggenheim Abu Dhabi museum offic │ guggenheim     │            │      │             │
    │    │ habi opens           │ ially opens its doors to the public.  │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 14 │ Oscars Best Picture  │ The winner of Best Picture at the 98t │ oscars         │            │      │             │
    │    │ is a streaming movie │ h Academy Awards is a film distribute │                │            │      │             │
    │    │                      │ d primarily by a streaming service (e │                │            │      │             │
    │    │                      │ .g., Apple, Netflix, Amazon).         │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 15 │ Eli Lilly's weight l │ The FDA officially approves Eli Lilly │ orforglipron   │            │      │             │
    │    │ oss pill is FDA appr │ 's oral GLP-1 agonist, orforglipron,  │                │            │      │             │
    │    │ oved                 │ for chronic weight management.        │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 16 │ We record 10,000 mil │ The collective running distance recor │ strava         │            │      │             │
    │    │ es run on Strava     │ ded by all participants on Strava in  │                │            │      │             │
    │    │                      │ 2026 exceeds 10,000 miles.            │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 17 │ The US President att │ On July 4, 2026 (the 250th anniversar │ semiquincenten │            │      │             │
    │    │ ends the Semiquincen │ y of the US), the sitting US Presiden │ nial           │            │      │             │
    │    │ tennial in Philly    │ t delivers a speech at Independence H │                │            │      │             │
    │    │                      │ all in Philadelphia.                  │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 18 │ A release date for T │ George R. R. Martin announces the rel │ game of throne │            │      │             │
    │    │ he Winds of Winter i │ ease date for The Winds of Winter.    │ s              │            │      │             │
    │    │ s announced          │                                       │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 19 │ USA wins more silver │ The number of silver medals the Unite │ medals         │            │      │             │
    │    │  medals than gold me │ d States of America wins exceeds the  │                │            │      │             │
    │    │ dals at the 2026 Win │ number of gold medals the country win │                │            │      │             │
    │    │ ter Olympics         │ s at the 2026 Winter Olympics.        │                │            │      │             │
    ├────┼──────────────────────┼───────────────────────────────────────┼────────────────┼────────────┼──────┼─────────────┤
    │ 20 │ Participants visit K │ The group takes a collective total of │ korea          │            │      │             │
    │    │ orea more than six t │  more than six round-trips to South K │                │            │      │             │
    │    │ imes                 │ orea in 2026.                         │                │            │      │             │
    └────┴──────────────────────┴───────────────────────────────────────┴────────────────┴────────────┴──────┴─────────────┘
    |}]
;;
