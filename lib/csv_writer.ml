(** Módulo para escrita de arquivos CSV *)

(** Escreve uma lista de listas de strings em um arquivo CSV.
    @param file_path Caminho do arquivo CSV a ser escrito.
    @param data
      Lista de listas de strings, onde cada sublista representa uma linha do
      CSV.
    @return Unit (escreve no arquivo sem retornar valor). *)
let write_csv file_path data =
  let oc = open_out file_path in
  List.iter
    (fun row ->
      let line = String.concat "," row in
      output_string oc (line ^ "\n"))
    data;
  close_out oc

(** Salva os dados em um banco SQLite - a ser implementado.
    @param db_file Caminho do arquivo de banco de dados SQLite.
    @param data
      Lista de listas de strings representando os dados a serem salvos.
    @return Unit (salva no banco sem retornar valor).
    @raise Failure
      "SQLite support not yet implemented" até que a funcionalidade seja
      implementada. *)
let save_to_sqlite db_file data =
  (* TODO: Implementar usando sqlite3 *)
  ignore db_file;
  ignore data;
  failwith "SQLite support not yet implemented"
