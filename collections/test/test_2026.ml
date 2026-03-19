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
    ┌────┬────────────────┬────────────────────────────┬────────────────┬────────────┬────────────┬────────────────────────┐
    │ id │ short          │ precise                    │ label          │ resolution │ date       │ explanation            │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 1  │ Grand Theft Au │ Rockstar Games releases GT │ gta            │            │            │                        │
    │    │ to VI is relea │ A VI for sale and is playa │                │            │            │                        │
    │    │ sed            │ ble to the public.         │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 2  │ The GOP holds  │ After the 2026 Midterms, t │ senate         │            │            │                        │
    │    │ 52 or more Sen │ he Republican party holds  │                │            │            │                        │
    │    │ ate seats      │ 52 or more seats in the U. │                │            │            │                        │
    │    │                │ S. Senate.                 │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 3  │ Lionel Messi p │ Lionel Messi plays (starts │ messi          │            │            │                        │
    │    │ lays in the Wo │  or substitutes) in at lea │                │            │            │                        │
    │    │ rld Cup        │ st one match for Argentina │                │            │            │                        │
    │    │                │  in the 2026 FIFA World Cu │                │            │            │                        │
    │    │                │ p.                         │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 4  │ Artemis II suc │ NASA’s Artemis II mission  │ moon           │            │            │                        │
    │    │ cessfully flie │ launches, carries a crew a │                │            │            │                        │
    │    │ s around the m │ round the moon, and return │                │            │            │                        │
    │    │ oon            │ s safely to Earth.         │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 5  │ A participant  │ At least one participant i │ stan           │            │            │                        │
    │    │ is a Top 0.05% │ s notified in their Spotif │                │            │            │                        │
    │    │  Stan          │ y Wrapped that they are in │                │            │            │                        │
    │    │                │  the Top 0.05% (or higher) │                │            │            │                        │
    │    │                │  of listeners for a specif │                │            │            │                        │
    │    │                │ ic artist.                 │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 6  │ Avengers: Doom │ The film Avengers: Doomsda │ avengers       │            │            │                        │
    │    │ sday opens to  │ y earns more than $250 mil │                │            │            │                        │
    │    │ $250M Domestic │ lion at the domestic box o │                │            │            │                        │
    │    │                │ ffice in its opening weeke │                │            │            │                        │
    │    │                │ nd.                        │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 7  │ The U.S. econo │ The National Bureau of Eco │ recession      │            │            │                        │
    │    │ my enters a re │ nomic Research declares a  │                │            │            │                        │
    │    │ cession        │ recession.                 │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 8  │ The Sagrada Fa │ The central "Tower of Jesu │ jesus          │ Yes        │ 2026-02-20 │ The Tower of Jesus Chr │
    │    │ mília complete │ s Christ" is declared stru │                │            │            │ ist at the Sagrada Fam │
    │    │ s the "Jesus T │ cturally complete.         │                │            │            │ ília was declared stru │
    │    │ ower"          │                            │                │            │            │ cturally complete.     │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 9  │ Apple announce │ Apple officially reveals a │ iphone         │            │            │                        │
    │    │ s a foldable i │  foldable smartphone model │                │            │            │                        │
    │    │ Phone          │  during their annual Septe │                │            │            │                        │
    │    │                │ mber keynote.              │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 10 │ BTS performs a │ The K-pop group BTS perfor │ bts            │            │            │                        │
    │    │  reunion conce │ ms live together as a full │                │            │            │                        │
    │    │ rt             │  group (seven members) fol │                │            │            │                        │
    │    │                │ lowing their military serv │                │            │            │                        │
    │    │                │ ice.                       │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 11 │ The President  │ The House of Representativ │ impeach        │            │            │                        │
    │    │ is impeached   │ es votes to impeach the Pr │                │            │            │                        │
    │    │                │ esident.                   │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 12 │ LeBron James r │ LeBron James announces his │ lebron         │            │            │                        │
    │    │ etires         │  retirement from professio │                │            │            │                        │
    │    │                │ nal basketball.            │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 13 │ The Guggenheim │ The Guggenheim Abu Dhabi m │ guggenheim     │            │            │                        │
    │    │  Abu Dhabi ope │ useum officially opens its │                │            │            │                        │
    │    │ ns             │  doors to the public.      │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 14 │ Oscars Best Pi │ The winner of Best Picture │ oscars         │ No         │ 2026-03-15 │ The Best Picture winne │
    │    │ cture is a str │  at the 98th Academy Award │                │            │            │ r was not a streaming  │
    │    │ eaming movie   │ s is a film distributed pr │                │            │            │ movie.                 │
    │    │                │ imarily by a streaming ser │                │            │            │                        │
    │    │                │ vice (e.g., Apple, Netflix │                │            │            │                        │
    │    │                │ , Amazon).                 │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 15 │ Eli Lilly's we │ The FDA officially approve │ orforglipron   │            │            │                        │
    │    │ ight loss pill │ s Eli Lilly's oral GLP-1 a │                │            │            │                        │
    │    │  is FDA approv │ gonist, orforglipron, for  │                │            │            │                        │
    │    │ ed             │ chronic weight management. │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 16 │ We record 10,0 │ The collective running dis │ strava         │            │            │                        │
    │    │ 00 miles run o │ tance recorded by all part │                │            │            │                        │
    │    │ n Strava       │ icipants on Strava in 2026 │                │            │            │                        │
    │    │                │  is at least 10,000 miles. │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 17 │ The US Preside │ On July 4, 2026 (the 250th │ semiquincenten │            │            │                        │
    │    │ nt attends the │  anniversary of the US), t │ nial           │            │            │                        │
    │    │  250th anniver │ he sitting US President de │                │            │            │                        │
    │    │ sary           │ livers a speech at Indepen │                │            │            │                        │
    │    │                │ dence Hall in Philadelphia │                │            │            │                        │
    │    │                │ .                          │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 18 │ A release date │ George R. R. Martin announ │ game of throne │            │            │                        │
    │    │  for The Winds │ ces the release date for T │ s              │            │            │                        │
    │    │  of Winter is  │ he Winds of Winter.        │                │            │            │                        │
    │    │ announced      │                            │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 19 │ USA wins more  │ The number of silver medal │ medals         │ No         │ 2026-02-22 │ USA won twelve gold me │
    │    │ silver medals  │ s the United States of Ame │                │            │            │ dals and twelve silver │
    │    │ than gold meda │ rica wins exceeds the numb │                │            │            │  medals.               │
    │    │ ls             │ er of gold medals the coun │                │            │            │                        │
    │    │                │ try wins at the 2026 Winte │                │            │            │                        │
    │    │                │ r Olympics.                │                │            │            │                        │
    ├────┼────────────────┼────────────────────────────┼────────────────┼────────────┼────────────┼────────────────────────┤
    │ 20 │ Participants v │ The group takes a collecti │ korea          │            │            │                        │
    │    │ isit Korea mor │ ve total of more than six  │                │            │            │                        │
    │    │ e than six tim │ round-trips to South Korea │                │            │            │                        │
    │    │ es             │  in 2026.                  │                │            │            │                        │
    └────┴────────────────┴────────────────────────────┴────────────────┴────────────┴────────────┴────────────────────────┘
    |}]
;;
