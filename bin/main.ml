open Projeto_ETL.Csv_reader
open Projeto_ETL.Csv_writer
open Projeto_ETL.Data_processor

let () =
  let orders_data = read_csv "order.csv" in
  let orders_data = List.tl orders_data in
  let items_data = read_csv "order_item.csv" in
  let items_data = List.tl items_data in
  let orders = List.map order_of_list orders_data in
  let items = List.map order_item_of_list items_data in
  let result = process_data orders items "Complete" "O" in
  let csv_data =
    List.map
      (fun (id, amt, tax) ->
        [
          string_of_int id; Printf.sprintf "%.2f" amt; Printf.sprintf "%.2f" tax;
        ])
      result
  in
  write_csv "output.csv" csv_data
