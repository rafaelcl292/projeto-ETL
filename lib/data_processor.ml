(** Módulo para processamento de dados *)

open Types

(** Converte uma lista de strings em um record order.
    @param lst Lista de 5 strings: [id; client_id; order_date; status; origin].
    @return Um record do tipo order com os campos preenchidos.
    @raise Failure
      "Invalid order data" se a lista não tiver exatamente 5 elementos. *)
let order_of_list = function
  | [ id; client_id; order_date; status; origin ] ->
      {
        id = int_of_string id;
        client_id = int_of_string client_id;
        order_date;
        status;
        origin;
      }
  | _ -> failwith "Invalid order data"

(** Converte uma lista de strings em um record order_item.
    @param lst Lista de 5 strings: [order_id; product_id; quantity; price; tax].
    @return Um record do tipo order_item com os campos preenchidos.
    @raise Failure
      "Invalid order_item data" se a lista não tiver exatamente 5 elementos. *)
let order_item_of_list = function
  | [ order_id; product_id; quantity; price; tax ] ->
      {
        order_id = int_of_string order_id;
        product_id = int_of_string product_id;
        quantity = int_of_string quantity;
        price = float_of_string price;
        tax = float_of_string tax;
      }
  | _ -> failwith "Invalid order_item data"

(** Junta as tabelas order e order_item em uma estrutura combinada (inner join).
    @param orders Lista de pedidos (tipo order list).
    @param items Lista de itens (tipo order_item list).
    @return
      Lista de pedidos com seus itens associados (tipo order_with_items list).
*)
let join_orders_and_items orders items =
  List.map
    (fun order ->
      let order_items =
        List.filter (fun item -> item.order_id = order.id) items
      in
      { order; items = order_items })
    orders

(** Calcula o total_amount e total_taxes de um pedido com itens.
    @param order_with_items Pedido com seus itens (tipo order_with_items).
    @return
      Tupla (order_id, total_amount, total_taxes) onde:
      - order_id é o ID do pedido (int),
      - total_amount é a soma de quantity * price (float),
      - total_taxes é a soma de quantity * price * tax (float). *)
let calculate_totals order_with_items =
  let total_amount =
    List.fold_left
      (fun acc item -> acc +. (float_of_int item.quantity *. item.price))
      0.0 order_with_items.items
  in
  let total_taxes =
    List.fold_left
      (fun acc item ->
        acc +. (float_of_int item.quantity *. item.price *. item.tax))
      0.0 order_with_items.items
  in
  (order_with_items.order.id, total_amount, total_taxes)

(** Filtra pedidos com base em status e origin.
    @param orders Lista de pedidos com itens (tipo order_with_items list).
    @param status Status desejado (ex.: "Complete") (string).
    @param origin Origem desejada (ex.: "O") (string).
    @return Lista filtrada de pedidos que atendem aos critérios. *)
let filter_orders orders status origin =
  List.filter
    (fun order -> order.order.status = status && order.order.origin = origin)
    orders

(** Processa os dados e gera a saída esperada.
    @param orders Lista de pedidos (tipo order list).
    @param items Lista de itens (tipo order_item list).
    @param status Status para filtragem (string).
    @param origin Origem para filtragem (string).
    @return
      Lista de tuplas (order_id, total_amount, total_taxes) para os pedidos
      filtrados. *)
let process_data orders items status origin =
  let orders_with_items = join_orders_and_items orders items in
  let filtered_orders = filter_orders orders_with_items status origin in
  List.map calculate_totals filtered_orders
