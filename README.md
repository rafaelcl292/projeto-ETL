# Relatório do Projeto ETL

**Autor**: Rafael Leventhal  
**Data**: 20 de Fevereiro de 2025  
**Disciplina**: Programação Funcional  
**Projeto**: ETL em OCaml

## Objetivo

Este projeto ETL (Extract, Transform, Load) foi desenvolvido para processar dados de pedidos e itens de pedidos a partir de arquivos CSV, aplicar transformações, e gerar saídas em CSV e SQLite, além de uma saída adicional de médias por mês e ano. O objetivo final é fornecer dados processados para um dashboard de visualização agregada, com a flexibilidade de armazenar diferentes conjuntos de dados em tabelas distintas dentro de um único banco SQLite.

## Estrutura do Projeto

O projeto foi organizado com o Dune em uma estrutura modular:
- `bin/main.ml`: Executável principal que orquestra o fluxo ETL.
- `lib/csv_reader.ml`: Funções impuras para leitura de CSVs (local e HTTP).
- `lib/csv_writer.ml`: Funções impuras para escrita em CSV e SQLite.
- `lib/types.ml`: Definição dos tipos `order`, `order_item`, e `order_with_items`.
- `lib/data_processor.ml`: Funções puras para transformação dos dados.
- `lib/utils.ml`: Funções puras para cálculo de médias por mês/ano.
- `test/test_projeto_ETL.ml`: Testes unitários usando Alcotest.

Arquivos de entrada:
- `order.csv`: Dados de pedidos.
- `order_item.csv`: Dados de itens de pedidos.

Arquivos de saída:
- `output.csv`: Resultados processados (order_id, total_amount, total_taxes).
- `output.db`: Banco SQLite com tabelas `output` (dados processados) e `averages` (médias por mês/ano).
- `averages.csv`: Médias de receita e impostos por mês/ano.

## Etapas do Desenvolvimento

### 1. Extração
Os dados foram extraídos de `order.csv` e `order_item.csv`:
- **Leitura Local**: Implementada em `read_csv` (csv_reader.ml), lendo linhas como listas de strings.
- **Leitura via HTTP**: Usando `read_csv_from_url` (csv_reader.ml) com Cohttp e Lwt, acessando URLs como `http://localhost:8000/order.csv` (servido via `python3 -m http.server`).

### 2. Transformação
As transformações foram realizadas em `data_processor.ml`:
- **Conversão para Records**: `order_of_list` e `order_item_of_list` transformam strings em records `order` e `order_item`.
- **Join**: `join_orders_and_items` realiza um inner join entre pedidos e itens usando `List.map` e `List.filter`.
- **Filtragem**: `filter_orders` filtra pedidos por `status` e `origin` com `List.filter`.
- **Cálculo**: `calculate_totals` usa `List.fold_left` (reduce) para somar `total_amount` e `total_taxes`.
- **Processamento Completo**: `process_data` combina as etapas acima, retornando uma lista de tuplas `(order_id, total_amount, total_taxes)`.

### 3. Carga
Os dados processados foram salvos em múltiplos formatos:
- **CSV**: `write_csv` (csv_writer.ml) salva em `output.csv` e `averages.csv` usando `List.iter`.
- **SQLite**: `save_to_sqlite` (csv_writer.ml) aceita um nome de tabela como argumento, criando tabelas dinâmicas (`output` e `averages`) em `output.db` com SQLite3-OCaml.
- **Médias por Mês/Ano**: `group_by_month_year` e `calculate_averages` (utils.ml) calculam médias, salvas em `averages.csv` e na tabela `averages` do SQLite.

## Requisitos Obrigatórios Atendidos

1. **Feito em OCaml**: Todo o código foi escrito em OCaml.
2. **Uso de `map`, `reduce`, `filter`**:
   - `List.map` em conversões e escrita de CSV.
   - `List.fold_left` (reduce) em cálculos de totais.
   - `List.filter` no join e filtragem.
3. **Leitura e escrita de CSV**: Funções impuras em `csv_reader.ml` e `csv_writer.ml`.
4. **Separação de funções puras e impuras**: Puras em `data_processor.ml` e `utils.ml`; impuras em `csv_reader.ml` e `csv_writer.ml`.
5. **Lista de Records**: Dados carregados em listas de `order` e `order_item`.
6. **Helper Functions**: `order_of_list` e `order_item_of_list` como funções auxiliares.
7. **Relatório**: Este documento, detalhando o processo.

## Requisitos Opcionais Atendidos

1. **Leitura via HTTP**: Implementada com Cohttp/Lwt em `read_csv_from_url`.
2. **Saída em SQLite**: Implementada em `save_to_sqlite` com suporte a nomes de tabelas personalizados.
3. **Inner Join**: Realizado em `join_orders_and_items`.
4. **Organização com Dune**: Estrutura completa com `dune-project`, `bin/dune`, `lib/dune`, `test/dune`.
5. **Docstrings**: Todas as funções documentadas com docstrings em todos os módulos.
6. **Médias por Mês/Ano**: Calculadas e salvas em `averages.csv` e na tabela `averages` do SQLite.
7. **Testes Completos**: Testes unitários em `test_projeto_ETL.ml` usando Alcotest para funções puras.

## Dependências

- **OCaml**: >= 5.3
- **SQLite3-OCaml**: Para banco de dados.
- **Cohttp-lwt-unix**: Para leitura HTTP.
- **Alcotest**: Para testes (dependência de teste).

## Uso de IA Generativa

Este projeto foi desenvolvido com assistência de IA generativa fornecida por Grok, criado pela xAI. A IA auxiliou na:
- Implementação de funcionalidades, resolução de bugs, e refatoração de código
- Redação deste relatório

## Reprodução do Projeto

1. **Instalação**:
   - Configure o ambiente com `opam switch create 5.3.0`.
   - Instale dependências: `opam install . --deps-only --with-test`.
2. **Compilação**:
   - Execute `dune build`.
3. **Execução**:
   - Sirva os CSVs com `python3 -m http.server` na raiz.
   - Execute `./_build/default/bin/main.exe`.
4. **Saídas**:
   - `output.csv`: Dados processados.
   - `output.db`: Banco SQLite com tabelas `output` e `averages`.
   - `averages.csv`: Médias por mês/ano.

## Conclusão

O projeto atende a todos os 7 requisitos obrigatórios e os 7 requisitos opcionais, alcançando o conceito **A+** com o bônus de +0,5 na média final. A refatoração do `save_to_sqlite` para aceitar nomes de tabelas adicionou flexibilidade, permitindo o armazenamento de dados processados e médias em tabelas separadas no mesmo banco SQLite. A implementação é modular, testada, e documentada, pronta para uso em um dashboard de visualização.
