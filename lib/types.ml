(** Módulo contendo os tipos de dados para o projeto ETL *)

type order = {
  id : int;
  client_id : int;
  order_date : string;
  status : string;
  origin : string;
}
(** Representa um pedido no sistema.
    @field id Identificador único do pedido (inteiro).
    @field client_id Identificador do cliente (inteiro).
    @field order_date Data do pedido no formato ISO 8601 (string).
    @field status Status do pedido: "Pending", "Complete" ou "Cancelled" (string).
    @field origin Origem do pedido: "P" (físico) ou "O" (online) (string). *)

type order_item = {
  order_id : int;
  product_id : int;
  quantity : int;
  price : float;
  tax : float;
}
(** Representa um item de um pedido.
    @field order_id Identificador do pedido ao qual pertence (inteiro).
    @field product_id Identificador do produto (inteiro).
    @field quantity Quantidade comprada (inteiro).
    @field price Preço unitário pago (float).
    @field tax Imposto percentual como decimal (ex.: 0.15 para 15%) (float). *)

type order_with_items = { order : order; items : order_item list }
(** Representa um pedido com seus itens associados.
    @field order O pedido (tipo order).
    @field items Lista de itens associados ao pedido (tipo order_item list). *)
