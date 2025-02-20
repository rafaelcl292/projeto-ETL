(lang dune 3.17)

(name projeto_ETL)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name projeto_ETL)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  (ocaml (>= 5.3.0)))
 (tags
  ("ETL" "OCaml" "data processing")))
