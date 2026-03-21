open! Core
open Crystal

let name = "2026"

let all =
  let pending label short precise = Event.create ~short ~precise ~label ~outcome:None in
  let no label short precise date explanation =
    Event.create
      ~label
      ~short
      ~precise
      ~outcome:(Some (Outcome.create No (Date.of_string date) explanation))
  in
  List.mapi
    ~f:(fun i f -> f ~id:(Event_id.of_int (i + 1)))
    [ pending
        "gta"
        "Grand Theft Auto VI is released"
        "Rockstar Games releases GTA VI for sale and is playable to the public."
    ; pending
        "senate"
        "The GOP holds 52 or more Senate seats"
        "After the 2026 Midterms, the Republican party holds 52 or more seats in the \
         U.S. Senate."
    ; pending
        "messi"
        "Lionel Messi plays in the World Cup"
        "Lionel Messi plays (starts or substitutes) in at least one match for Argentina \
         in the 2026 FIFA World Cup."
    ; pending
        "moon"
        "Artemis II successfully flies around the moon"
        "NASA’s Artemis II mission launches, carries a crew around the moon, and returns \
         safely to Earth."
    ; pending
        "stan"
        "A participant is a Top 0.05% Stan"
        "At least one participant is notified in their Spotify Wrapped that they are in \
         the Top 0.05% (or higher) of listeners for a specific artist."
    ; pending
        "avengers"
        "Avengers: Doomsday opens to $250M Domestic"
        "The film Avengers: Doomsday earns more than $250 million at the domestic box \
         office in its opening weekend."
    ; pending
        "recession"
        "The U.S. economy enters a recession"
        "The National Bureau of Economic Research declares a recession."
    ; pending
        "jesus"
        "The Sagrada Família completes the \"Jesus Tower\""
        "The central \"Tower of Jesus Christ\" is declared structurally complete."
    ; pending
        "iphone"
        "Apple announces a foldable iPhone"
        "Apple officially reveals a foldable smartphone model during their annual \
         September keynote."
    ; pending
        "bts"
        "BTS performs a reunion concert"
        "The K-pop group BTS performs live together as a full group (seven members) \
         following their military service."
    ; pending
        "impeach"
        "The President is impeached"
        "The House of Representatives votes to impeach the President."
    ; pending
        "lebron"
        "LeBron James retires"
        "LeBron James announces his retirement from professional basketball."
    ; pending
        "guggenheim"
        "The Guggenheim Abu Dhabi opens"
        "The Guggenheim Abu Dhabi museum officially opens its doors to the public."
    ; no
        "oscars"
        "Oscars Best Picture is a streaming movie"
        "The winner of Best Picture at the 98th Academy Awards is a film distributed \
         primarily by a streaming service (e.g., Apple, Netflix, Amazon)."
        "2026-03-15"
        "The Best Picture winner, One Battle After Another, is distributed by Warners \
         Bros. Pictures"
    ; pending
        "orforglipron"
        "Eli Lilly's weight loss pill is FDA approved"
        "The FDA officially approves Eli Lilly's oral GLP-1 agonist, orforglipron, for \
         chronic weight management."
    ; pending
        "strava"
        "We record 10,000 miles run on Strava"
        "The collective running distance recorded by all participants on Strava in 2026 \
         is at least 10,000 miles."
    ; pending
        "semiquincentennial"
        "The US President attends the 250th anniversary"
        "On July 4, 2026 (the 250th anniversary of the US), the sitting US President \
         delivers a speech at Independence Hall in Philadelphia."
    ; pending
        "game of thrones"
        "A release date for The Winds of Winter is announced"
        "George R. R. Martin announces the release date for The Winds of Winter."
    ; no
        "medals"
        "USA wins more silver medals than gold medals"
        "The number of silver medals the United States of America wins exceeds the \
         number of gold medals the country wins at the 2026 Winter Olympics."
        "2026-02-22"
        "USA won twelve gold medals and twelve silver medals."
    ; pending
        "korea"
        "Participants visit Korea more than six times"
        "The group takes a collective total of more than six round-trips to South Korea \
         in 2026."
    ]
;;

include Collection.Make (struct
    let name = name
    let all = all
  end)
