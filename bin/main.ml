open Projeto_ETL.Csv_reader
open Projeto_ETL.Csv_writer
open Projeto_ETL.Data_processor
open Projeto_ETL.Utils
open Lwt

let () =
  Lwt_main.run
    ( (* Lê os dados via HTTP *)
      read_csv_from_url "http://localhost:8000/order.csv"
    >>= fun orders_data ->
      let orders_data = List.tl orders_data in
      read_csv_from_url "http://localhost:8000/order_item.csv"
      >>= fun items_data ->
      let items_data = List.tl items_data in
      (* Remove cabeçalho *)

      (* Processa os dados *)
      let orders = List.map order_of_list orders_data in
      let items = List.map order_item_of_list items_data in
      let result = process_data orders items "Complete" "O" in
      let csv_data =
        List.map
          (fun (id, amt, tax) ->
            [
              string_of_int id;
              Printf.sprintf "%.2f" amt;
              Printf.sprintf "%.2f" tax;
            ])
          result
      in

      (* Salva os resultados *)
      write_csv "output.csv" csv_data;
      save_to_sqlite "output.db" csv_data;

      (* Calcula e salva médias por mês/ano *)
      let grouped = group_by_month_year orders result in
      let averages = calculate_averages grouped in
      let avg_data =
        List.map
          (fun (key, avg_amt, avg_tax) ->
            [
              key; Printf.sprintf "%.2f" avg_amt; Printf.sprintf "%.2f" avg_tax;
            ])
          averages
      in
      write_csv "averages.csv" avg_data;
      save_to_sqlite "averages.db" avg_data;

      Lwt.return_unit )
