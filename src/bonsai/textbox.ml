open! Core
open Bonsai_web.Cont
open Bonsai.Let_syntax

let component graph =
  let text, set_text = Bonsai.state "default text" graph in
  let displayed, set_displayed = Bonsai.state "" graph in
  let%arr text = text
  and set_text = set_text
  and displayed = displayed
  and set_displayed = set_displayed in
  let open Vdom in
  Node.div
    [ Node.label [ Node.text "Textarea:" ]
    ; Node.textarea
        ~attrs:
          [ Attr.rows 4
          ; Attr.cols 40
          ; Attr.value text
          ; Attr.on_input (fun _event -> set_text)
          ]
        []
    ; Node.br ()
    ; Node.button
        ~attrs:
          [ Attr.on_click (fun _ -> set_displayed text)
          ; Attr.style (Css_gen.font_family [ "monospace" ])
          ]
          (* update displayed text *)
        [ Node.text "Update Div" ]
    ; Node.div [ Node.text displayed ] (* show the displayed text *)
    ]
;;
