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

(** Lê um arquivo CSV via HTTP.
    @param url URL do arquivo CSV a ser lido.
    @return
      Promessa Lwt que resolve para uma lista de listas de strings representando
      o conteúdo do CSV.
    @raise Failure
      se houver erro na requisição HTTP ou no processamento dos dados. *)
let read_csv_from_url url =
  let open Lwt in
  let open Cohttp_lwt_unix in
  Lwt.catch
    (fun () ->
      Client.get (Uri.of_string url) >>= fun (resp, body) ->
      match Cohttp.Response.status resp with
      | `OK ->
          Cohttp_lwt.Body.to_string body >>= fun content ->
          let lines =
            String.split_on_char '\n' content |> List.filter (( <> ) "")
            (* Remove linhas vazias *)
          in
          Lwt.return (List.map (String.split_on_char ',') lines)
      | status ->
          Lwt.fail
            (Failure
               (Printf.sprintf "HTTP request failed with status: %s"
                  (Cohttp.Code.string_of_status status))))
    (fun exn -> Lwt.fail exn)
