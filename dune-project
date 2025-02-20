(lang dune 3.17)
(name projeto_ETL)
(generate_opam_files true)
(source (github rafaelcl292/projeto-ETL))
(authors "Rafael Leventhal <rafaelcl@al.insper.edu.br>")
(maintainers "Rafael Leventhal <rafaelcl@al.insper.edu.br>")
(license MIT)
(package
 (name projeto_ETL)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  (ocaml (>= 5.3))
  sqlite3
  (alcotest :with-test))
 (tags ("ETL" "OCaml" "data processing")))
