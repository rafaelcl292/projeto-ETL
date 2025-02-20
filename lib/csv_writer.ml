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

(** Salva os dados em um banco SQLite.
    @param db_file Caminho do arquivo de banco de dados SQLite.
    @param table_name Nome da tabela onde os dados serão salvos.
    @param data
      Lista de listas de strings representando os dados a serem salvos.
    @return Unit (salva no banco sem retornar valor).
    @raise Failure se houver erro na interação com o banco de dados. *)
let save_to_sqlite db_file table_name data =
  let open Sqlite3 in
  (* Open database *)
  let& db = db_open db_file in

  try
    (* Determine number of columns from first row, if data is not empty *)
    let ncol = match data with [] -> 0 | row :: _ -> List.length row in

    (* Create table with dynamic number of columns named col0, col1, etc. *)
    let column_defs =
      List.init ncol (fun i -> Printf.sprintf "col%d TEXT" i)
      |> String.concat ", "
    in
    let create_sql =
      Printf.sprintf "CREATE TABLE IF NOT EXISTS %s (%s)" table_name column_defs
    in
    let rc = exec db create_sql in
    if not (Rc.is_success rc) then
      failwith
        (Printf.sprintf "Failed to create table %s: %s" table_name (errmsg db));

    (* Prepare insert statement with placeholders *)
    let placeholders = List.init ncol (fun _ -> "?") |> String.concat ", " in
    let insert_sql =
      Printf.sprintf "INSERT INTO %s VALUES (%s)" table_name placeholders
    in
    let stmt = prepare db insert_sql in

    (* Insert each row *)
    List.iter
      (fun row ->
        (* Reset statement for reuse *)
        let _ = reset stmt in
        (* Bind values - first parameter index is 1 *)
        List.iteri
          (fun i value ->
            let rc = bind_text stmt (i + 1) value in
            if not (Rc.is_success rc) then
              failwith (Printf.sprintf "Failed to bind value: %s" (errmsg db)))
          row;
        (* Execute the insert *)
        let rc = step stmt in
        if not (Rc.is_success rc) then
          failwith
            (Printf.sprintf "Failed to insert row into %s: %s" table_name
               (errmsg db)))
      data;

    (* Finalize statement *)
    let rc = finalize stmt in
    if not (Rc.is_success rc) then
      failwith (Printf.sprintf "Failed to finalize statement: %s" (errmsg db))
  with
  | SqliteError msg -> failwith ("SQLite error: " ^ msg)
  | exn ->
      (* Ensure statement is finalized if it exists before re-raising *)
      raise exn
