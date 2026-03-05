# Generalized Assignment Problem Benchmark

This repository provides a Julia/JuMP benchmark suite for modeling and solving standard Generalized Assignment Problem (GAP) instances, and reports problem-size and solver-performance statistics for well-known benchmark sets from the literature. Source links are provided in the Reference links section at the end of this file.

The **Generalized Assignment Problem (GAP)** assigns each job to exactly one agent while respecting agent capacity limits. Each assignment is characterized by:

- a **cost** `c[i,j]` to assign job `j` to agent `i`
- a **resource consumption** `r[i,j]`
- an agent capacity limit `b[i]`

The standard **Integer Linear Programming (ILP)** formulation is:

- minimize total assignment cost
- subject to each job being assigned exactly once
- and each agent's total resource usage not exceeding its capacity

---

This document summarizes:

- Instance-type dimensions (`m`, `n`)
- Constraint counts in the JuMP ILP
- Gurobi objective values obtained in our runs
- Source/reference links for the benchmark sets

---

## 1) Constraints (for all GAP instances)

For the standard GAP BLP model:

- `m` = number of agents = **number of inequality constraints** (`<=` capacity constraints)
- `n` = number of jobs = **number of equality constraints** (`==` assignment constraints)

So per instance:

- Inequalities = `m`
- Equalities = `n`
- Total linear constraints = `m + n`

---

## 2) Instance-type statistics

| Instance suffix | Inequalities (`m`) | Equalities (`n`) | Number of Binaries |
|---|---:|---:|---:|
| `*05100` | 5 | 100 | 500 |
| `*05200` | 5 | 200 | 1000 |
| `*10100` | 10 | 100 | 1000 |
| `*10200` | 10 | 200 | 2000 |
| `*10400` | 10 | 400 | 4000 |
| `*15900` | 15 | 900 | 13500 |
| `*20100` | 20 | 100 | 2000 |
| `*20200` | 20 | 200 | 4000 |
| `*20400` | 20 | 400 | 8000 |
| `*201600` | 20 | 1600 | 32000 |
| `*30900` | 30 | 900 | 27000 |
| `*40400` | 40 | 400 | 16000 |
| `*401600` | 40 | 1600 | 64000 |
| `*60900` | 60 | 900 | 54000 |
| `*801600` | 80 | 1600 | 128000 |

---

## 3) Optimal Objective-value

### 3.1 Proven optimal instances

Hardware: Apple M3 Pro, 36 GB unified memory, 12 CPU cores.
ILP Optimizer: **Gurobi 13.0.0**.

| Family | Instance | Objective | Runtime (s) |
|---|---|---:|---:|
| A | `a05100` | 1698 | <0.1 |
| A | `a05200` | 3235 | <0.1 |
| A | `a10100` | 1360 | <0.1 |
| A | `a10200` | 2623 | <0.1 |
| A | `a20100` | 1158 | <0.1 |
| A | `a20200` | 2339 | <0.1 |
| B | `b05100` | 1843 | <0.1 |
| B | `b05200` | 3552 | 0.12 |
| B | `b10100` | 1407 | <0.1 |
| B | `b10200` | 2827 | 0.27 |
| B | `b20100` | 1166 | <0.1 |
| B | `b20200` | 2339 | <0.1 |
| C | `c05100` | 1931 | <0.1 |
| C | `c05200` | 3456 | 0.12 |
| C | `c10100` | 1402 | 0.11 |
| C | `c10200` | 2806 | 0.26 |
| C | `c10400` | 5597 | 0.30 |
| C | `c15900` | 11341 | 3.88 |
| C | `c20100` | 1243 | <0.1 |
| C | `c201600` | 18803 | 7.35 |
| C | `c20200` | 2391 | 0.46 |
| C | `c20400` | 4782 | 2.59 |
| C | `c30900` | 9982 | 127.14 |
| C | `c40400` | 4244 | 2.71 |
| C | `c401600` | 17146 | pending |
| C | `c60900` | 9326 | pending |
| D | `d05100` | 6353 | 4.06 |
| D | `d05200` | 12742 | pending |
| D | `d10400` | 24961 | pending |
| E | `e05100` | 12681 | 2.25 |
| E | `e05200` | 24930 | 0.62 |
| E | `e10100` | 11577 | 6.43 |
| E | `e10200` | 23307 | 5.64 |
| E | `e20100` | 8436 | 7.82 |
| E | `e20200` | 22380 | 14.60 |

### 3.2 Best values found but not proven optimal (hits `TIME_LIMIT`)

| Family | Instance | Best objective found |
|---|---|---:|
| C | `c801600` | 16287 |
| D | `d10100` | 6347 |
| D | `d10200` | 12441 |
| D | `d15900` | 55417 |
| D | `d20100` | 6214 |
| D | `d201600` | 97851 |
| D | `d20200` | 12261 |
| D | `d20400` | 24600 |
| D | `d30900` | 54884 |
| D | `d401600` | 97143 |

> Note: For the larger and more challenging instances in the table above, time limits were applied; therefore, these entries report best incumbent values rather than certified optima. If you are able to obtain proven optimal solutions for these instances efficiently, please feel free to get in touch.

---

## 4) Reference links

### Benchmark format and datasets

- OR-Library GAP format/info:  
  <https://people.brunel.ac.uk/~mastjjb/jeb/orlib/gapinfo.html>
- Yagiura GAP page (A/B/C/D/E sets, minimization context):  
  <http://www.al.cm.is.nagoya-u.ac.jp/~yagiura/gap/>
- GAPLIB summary page (used for published optima/bounds reference):  
  <http://astarte.csr.unibo.it/gapdata/gapinstances.html>

---

> **Author**  
> For any questions or issues regarding this repository, please contact [Harsha Nagarajan](http://harshanagarajan.com) ([@harshangrjn](https://github.com/harshangrjn)). If you have additional challenging benchmark instances that could be valuable for this library, a pull request is welcome.
