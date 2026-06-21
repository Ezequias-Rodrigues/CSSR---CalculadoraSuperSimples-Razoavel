# Calculadora de Lógica Proposicional em Prolog

Uma calculadora de lógica proposicional desenvolvida em Prolog que permite:

* Avaliar expressões lógicas.
* Gerar tabelas verdade.
* Identificar tautologias, contradições e contingências.
* Simplificar expressões por regras algébricas.
* Simplificar expressões utilizando minimização tabular.

## Funcionalidades

### Operadores suportados

| Operador  | Significado       |
| --------- | ----------------- |
| `not`     | Negação (¬)       |
| `and`     | Conjunção (∧)     |
| `or`      | Disjunção (∨)     |
| `implies` | Implicação (⇒)    |
| `xnor`    | Bicondicional (↔) |
| `xor`     | Ou Exclusivo (⊕)  |
| `nand`    | E Negado (↑)      |
| `nor`     | Ou Negado (↓)     |

### Exemplos

```prolog
p and q
```

```prolog
not p or q
```

```prolog
(p and q) implies r
```

```prolog
(p xor q) and not r
```

```prolog
(p xnor q) or (r nand s)
```

## Como executar

Carregue o arquivo no SWI-Prolog:

```prolog
[main].
```

Em seguida execute:

```prolog
start.
```

Nota: o terminal buga inconsistentemente(letra sobre letra, cursor voltando pro começo etc) ao digitar, porém o código funciona do mesmo jeito.
## Saída

Para cada expressão o programa:

1. Exibe a expressão interpretada.
2. Gera a tabela verdade completa.
3. Classifica a expressão como:

   * Tautologia
   * Contradição
   * Contingência
4. Apresenta uma simplificação heurística.
5. Apresenta uma simplificação obtida pelas linhas verdadeiras.

## Observações

* Parênteses são suportados e recomendados em expressões complexas.
* O operador `xor` possui precedência maior que `and`.
* A simplificação heurística procura reduzir o tamanho da expressão.
* A simplificação tabular utiliza apenas negação, conjunção e disjunção para obter uma forma reduzida.
* O desempenho diminui rapidamente conforme aumenta a quantidade de variáveis, devido ao crescimento exponencial da tabela verdade.

## Exemplo de uso

Entrada:

```prolog
(a and b) or (a and not b)
```

Saída simplificada:

```prolog
a
```


