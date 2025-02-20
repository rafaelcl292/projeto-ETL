(** Módulo para leitura de arquivos CSV *)

(** Lê um arquivo CSV local e retorna uma lista de listas de strings.
    @param file_path Caminho do arquivo CSV a ser lido.
    @return
      Lista onde cada elemento é uma linha do CSV, representada como uma lista
      de strings (campos separados por vírgula). *)
let read_csv file_path =
  let ic = open_in file_path in
  let rec loop acc =
    try
      let line = input_line ic in
      let fields = String.split_on_char ',' line in
      loop (fields :: acc)
    with End_of_file -> List.rev acc
  in
  let data = loop [] in
  close_in ic;
  data

(** Lê um arquivo CSV via HTTP - a ser implementado.
    @param url URL do arquivo CSV a ser lido.
    @return Lista de listas de strings representando o conteúdo do CSV.
    @raise Failure
      "HTTP support not yet implemented" até que a funcionalidade seja
      implementada. *)
let read_csv_from_url url =
  (* TODO: Implementar usando Cohttp *)
  ignore url;
  failwith "HTTP support not yet implemented"
