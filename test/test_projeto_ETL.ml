(** Módulo de testes para o projeto ETL usando Alcotest *)

open Alcotest
open Projeto_ETL.Types
open Projeto_ETL.Data_processor
open Projeto_ETL.Utils

(* Funções auxiliares para criar dados de teste *)
let sample_order =
  {
    id = 1;
    client_id = 100;
    order_date = "2024-10-02T03:05:39";
    status = "Complete";
    origin = "O";
  }

let sample_item1 =
  { order_id = 1; product_id = 200; quantity = 2; price = 10.0; tax = 0.15 }

let sample_item2 =
  { order_id = 1; product_id = 201; quantity = 3; price = 20.0; tax = 0.10 }

(* Testes para data_processor.ml *)
let test_order_of_list () =
  let input = [ "1"; "100"; "2024-10-02T03:05:39"; "Complete"; "O" ] in
  let expected = sample_order in
  check
    (module struct
      type t = order

      let equal a b =
        a.id = b.id && a.client_id = b.client_id
        && a.order_date = b.order_date
        && a.status = b.status && a.origin = b.origin

      let pp fmt v =
        Format.fprintf fmt "id=%d, client_id=%d, date=%s, status=%s, origin=%s"
          v.id v.client_id v.order_date v.status v.origin
    end)
    "same order" expected (order_of_list input)

let test_order_item_of_list () =
  let input = [ "1"; "200"; "2"; "10.0"; "0.15" ] in
  let expected = sample_item1 in
  check
    (module struct
      type t = order_item

      let equal a b =
        a.order_id = b.order_id
        && a.product_id = b.product_id
        && a.quantity = b.quantity && a.price = b.price && a.tax = b.tax

      let pp fmt v =
        Format.fprintf fmt
          "order_id=%d, product_id=%d, quantity=%d, price=%f, tax=%f" v.order_id
          v.product_id v.quantity v.price v.tax
    end)
    "same order_item" expected (order_item_of_list input)

let test_join_orders_and_items () =
  let orders = [ sample_order ] in
  let items = [ sample_item1; sample_item2 ] in
  let expected =
    [ { order = sample_order; items = [ sample_item1; sample_item2 ] } ]
  in
  check
    (list
       (module struct
         type t = order_with_items

         let equal a b = a.order = b.order && a.items = b.items

         let pp fmt v =
           Format.fprintf fmt "order=%d, items=%d" v.order.id
             (List.length v.items)
       end))
    "same join" expected
    (join_orders_and_items orders items)

let test_calculate_totals () =
  let input =
    { order = sample_order; items = [ sample_item1; sample_item2 ] }
  in
  let expected = (1, 80.0, 9.0) in
  (* 2*10 + 3*20 = 80; 2*10*0.15 + 3*20*0.10 = 3 + 6 = 9 *)
  check
    (triple int (float 0.0001) (float 0.0001))
    "same totals" expected (calculate_totals input)

let test_filter_orders () =
  let order2 = { sample_order with id = 2; status = "Pending" } in
  let input =
    [
      { order = sample_order; items = [ sample_item1 ] };
      { order = order2; items = [ sample_item2 ] };
    ]
  in
  let expected = [ { order = sample_order; items = [ sample_item1 ] } ] in
  check
    (list
       (module struct
         type t = order_with_items

         let equal a b = a.order = b.order && a.items = b.items

         let pp fmt v =
           Format.fprintf fmt "order=%d, items=%d" v.order.id
             (List.length v.items)
       end))
    "same filtered" expected
    (filter_orders input "Complete" "O")

let test_process_data () =
  let orders = [ sample_order ] in
  let items = [ sample_item1; sample_item2 ] in
  let expected = [ (1, 80.0, 9.0) ] in
  (* Corrigido de 11.0 para 9.0 *)
  check
    (list (triple int (float 0.0001) (float 0.0001)))
    "same processed" expected
    (process_data orders items "Complete" "O")

(* Testes para utils.ml *)
let test_extract_month_year () =
  let input = "2024-10-02T03:05:39" in
  let expected = ("2024", "10") in
  check (pair string string) "same date" expected (extract_month_year input)

let test_group_by_month_year () =
  let orders = [ sample_order ] in
  let totals = [ (1, 80.0, 11.0) ] in
  let result = group_by_month_year orders totals in
  let expected = (80.0, 11.0, 1) in
  check
    (triple (float 0.0001) (float 0.0001) int)
    "same grouped" expected
    (Hashtbl.find result "2024-10")

let test_calculate_averages () =
  let grouped = Hashtbl.create 1 in
  Hashtbl.add grouped "2024-10" (80.0, 11.0, 1);
  let expected = [ ("2024-10", 80.0, 11.0) ] in
  check
    (list (triple string (float 0.0001) (float 0.0001)))
    "same averages" expected
    (calculate_averages grouped)

(* Configuração e execução dos testes *)
let () =
  let open Alcotest in
  run "Projeto ETL Tests"
    [
      ( "Data Processor",
        [
          test_case "Order of list" `Quick test_order_of_list;
          test_case "Order item of list" `Quick test_order_item_of_list;
          test_case "Join orders and items" `Quick test_join_orders_and_items;
          test_case "Calculate totals" `Quick test_calculate_totals;
          test_case "Filter orders" `Quick test_filter_orders;
          test_case "Process data" `Quick test_process_data;
        ] );
      ( "Utils",
        [
          test_case "Extract month year" `Quick test_extract_month_year;
          test_case "Group by month year" `Quick test_group_by_month_year;
          test_case "Calculate averages" `Quick test_calculate_averages;
        ] );
    ]
