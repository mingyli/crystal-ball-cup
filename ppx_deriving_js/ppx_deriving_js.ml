open Ppxlib
module List = ListLabels
open Ast_builder.Default

let js_conversion_expr ~loc _field_name field_type field_value =
  match field_type.ptyp_desc with
  | Ptyp_constr ({ txt = Lident "string"; _ }, []) ->
    [%expr Js.Unsafe.inject (Js.string [%e field_value])]
  | Ptyp_constr ({ txt = Lident "int"; _ }, []) ->
    [%expr Js.Unsafe.inject [%e field_value]]
  | Ptyp_constr ({ txt = Lident "float"; _ }, []) ->
    [%expr Js.Unsafe.inject [%e field_value]]
  | Ptyp_constr ({ txt = Lident "bool"; _ }, []) ->
    [%expr Js.Unsafe.inject (Js.bool [%e field_value])]
  | Ptyp_constr ({ txt = Lident "array"; _ }, [ inner_type ]) ->
    (match inner_type.ptyp_desc with
     | Ptyp_constr ({ txt = Lident "string"; _ }, []) ->
       [%expr
         let arr = Array.map (fun s -> Js.string s) [%e field_value] in
         Js.Unsafe.inject (Js.array arr)]
     | Ptyp_constr ({ txt = Lident "float"; _ }, []) ->
       [%expr Js.Unsafe.inject (Js.array [%e field_value])]
     | Ptyp_constr ({ txt = Lident "int"; _ }, []) ->
       [%expr Js.Unsafe.inject (Js.array [%e field_value])]
     | _ -> [%expr Js.Unsafe.inject (Js.array [%e field_value])])
  | Ptyp_constr ({ txt = Lident type_name; _ }, []) ->
    (* Assume it's a custom type with its own to_js function *)
    let to_js_name = type_name ^ "_to_js" in
    [%expr
      Js.Unsafe.inject
        ([%e pexp_ident ~loc { loc; txt = lident to_js_name }] [%e field_value])]
  | Ptyp_constr ({ txt = Ldot (module_path, type_name); _ }, []) ->
    (* Handle module-qualified types *)
    let to_js_name = type_name ^ "_to_js" in
    let qualified_to_js = Ldot (module_path, to_js_name) in
    [%expr
      Js.Unsafe.inject
        ([%e pexp_ident ~loc { loc; txt = qualified_to_js }] [%e field_value])]
  | _ ->
    (* Default: assume direct injection *)
    [%expr Js.Unsafe.inject [%e field_value]]
;;

let to_js_impl ~type_name (fields : label_declaration list) =
  let loc = Location.none in
  let param_name = "t" in
  let param_pat = ppat_var ~loc { loc; txt = param_name } in
  let param_expr = pexp_ident ~loc { loc; txt = lident param_name } in
  let function_name = if type_name = "t" then "to_js" else type_name ^ "_to_js" in
  let field_exprs =
    List.map fields ~f:(fun ld ->
      let field_name = ld.pld_name.txt in
      let field_access = pexp_field ~loc param_expr { loc; txt = lident field_name } in
      let js_field_name = field_name in
      let conversion_expr = js_conversion_expr ~loc field_name ld.pld_type field_access in
      [%expr
        [%e pexp_constant ~loc (Pconst_string (js_field_name, loc, None))]
      , [%e conversion_expr]])
  in
  let obj_array = pexp_array ~loc field_exprs in
  let to_js_body = [%expr Js.Unsafe.obj [%e obj_array]] in
  let return_type = ptyp_constr ~loc { loc; txt = lident type_name } [] in
  let _js_return_type = [%type: [%t return_type] Js.t] in
  pstr_value
    ~loc
    Nonrecursive
    [ { pvb_pat = ppat_var ~loc { loc; txt = function_name }
      ; pvb_expr = pexp_fun ~loc Nolabel None param_pat to_js_body
      ; pvb_attributes = []
      ; pvb_loc = loc
      }
    ]
;;

let to_js_intf ~type_name (_fields : label_declaration list) =
  let loc = Location.none in
  let param_type = ptyp_constr ~loc { loc; txt = lident type_name } [] in
  let return_type = [%type: [%t param_type] Js.t] in
  let function_name = if type_name = "t" then "to_js" else type_name ^ "_to_js" in
  psig_value
    ~loc
    { pval_name = { loc; txt = function_name }
    ; pval_type = ptyp_arrow ~loc Nolabel param_type return_type
    ; pval_attributes = []
    ; pval_loc = loc
    ; pval_prim = []
    }
;;

let generate_impl ~ctxt (_rec_flag, type_declarations) =
  let loc = Expansion_context.Deriver.derived_item_loc ctxt in
  List.map type_declarations ~f:(fun (td : type_declaration) ->
    match td with
    | { ptype_kind = Ptype_abstract | Ptype_variant _ | Ptype_open; ptype_loc; _ } ->
      let ext =
        Location.error_extensionf ~loc:ptype_loc "Cannot derive js for non record types"
      in
      [ Ast_builder.Default.pstr_extension ~loc ext [] ]
    | { ptype_kind = Ptype_record fields; ptype_name; _ } ->
      [ to_js_impl ~type_name:ptype_name.txt fields ])
  |> List.concat
;;

let generate_intf ~ctxt (_rec_flag, type_declarations) =
  let loc = Expansion_context.Deriver.derived_item_loc ctxt in
  List.map type_declarations ~f:(fun (td : type_declaration) ->
    match td with
    | { ptype_kind = Ptype_abstract | Ptype_variant _ | Ptype_open; ptype_loc; _ } ->
      let ext =
        Location.error_extensionf ~loc:ptype_loc "Cannot derive js for non record types"
      in
      [ Ast_builder.Default.psig_extension ~loc ext [] ]
    | { ptype_kind = Ptype_record fields; ptype_name; _ } ->
      [ to_js_intf ~type_name:ptype_name.txt fields ])
  |> List.concat
;;

let impl_generator = Deriving.Generator.V2.make_noarg generate_impl
let intf_generator = Deriving.Generator.V2.make_noarg generate_intf

let js_deriver =
  Deriving.add "js" ~str_type_decl:impl_generator ~sig_type_decl:intf_generator
;;
