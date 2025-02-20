(** Módulo utilitário para cálculos adicionais *)

open Types

(** Extrai o mês e ano de uma data no formato ISO 8601.
    @param date String no formato "YYYY-MM-DDTHH:MM:SS" ou similar.
    @return Tupla (year, month) como strings (ex.: ("2024", "10")).
    @raise Failure
      "Invalid date format" se a data não puder ser separada em ano e mês. *)
let extract_month_year date =
  let parts = String.split_on_char '-' date in
  match parts with
  | year :: month :: _ -> (year, month)
  | _ -> failwith "Invalid date format"

(** Agrupa os totais de pedidos por mês e ano.
    @param orders Lista de pedidos (tipo order list).
    @param totals Lista de tuplas (order_id, total_amount, total_taxes).
    @return
      Tabela hash onde a chave é "YYYY-MM" e o valor é (soma_amount, soma_taxes,
      contagem). *)
let group_by_month_year orders totals =
  let map = Hashtbl.create 10 in
  List.iter
    (fun (order_id, total_amount, total_taxes) ->
      let order = List.find (fun o -> o.id = order_id) orders in
      let year, month = extract_month_year order.order_date in
      let key = year ^ "-" ^ month in
      match Hashtbl.find_opt map key with
      | Some (amount_sum, taxes_sum, count) ->
          Hashtbl.replace map key
            (amount_sum +. total_amount, taxes_sum +. total_taxes, count + 1)
      | None -> Hashtbl.add map key (total_amount, total_taxes, 1))
    totals;
  map

(** Calcula a média de receita e impostos por mês e ano.
    @param grouped_data Tabela hash gerada por group_by_month_year.
    @return
      Lista de tuplas (key, avg_amount, avg_taxes) onde:
      - key é "YYYY-MM" (string),
      - avg_amount é a média da receita (float),
      - avg_taxes é a média dos impostos (float). *)
let calculate_averages grouped_data =
  Hashtbl.fold
    (fun key (amount_sum, taxes_sum, count) acc ->
      let avg_amount = amount_sum /. float_of_int count in
      let avg_taxes = taxes_sum /. float_of_int count in
      (key, avg_amount, avg_taxes) :: acc)
    grouped_data []
