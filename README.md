# An Exploration of the Benefits of Out-of-Order and Superscalar Execution on the Canonical 5-Stage RISC Processor

## By: (Marc Chmielewski)·(Oliver Rodas)·(Matthew Belissary)

## Overview

* The "Very Short" Version
  * Sand thinks faster when the sand is thinking about multiple, strictly independent things at the same time.
* The "Slightly Less Short" Version
  * For our ECE 552 final project, we implemented and simulated a 2-way superscalar, Out-of-Order Processor in a combination of Verilog and Python in an attempt to demonstrate that these optimization techniques could dramatically improve the performance of the canonical 5-stage RISC pipeline. This attempt was slightly limited in scope, but ultimately, very successful.
* [The "Very Long" Version](https://drive.google.com/file/d/1FXMGEEntYeA-QkG1ykiU_DDn_mcjVQP3/view?usp=sharing)

## About This Repo

The primary machinery used to generate the results in the paper (linked [here](https://drive.google.com/file/d/1FXMGEEntYeA-QkG1ykiU_DDn_mcjVQP3/view?usp=sharing) again for your convenience is located in the `Testing` directory of this repository. It includes several assembly files that can be run on the `in_order_simulator` and `superscalar_simulator` to simulate being run on a processor with the canonical pipeline and 2-way superscalar pipeline respectively. Each of these files also includes an `ooo` version thereof, which has been dynamically scheduled to optimize the degree of parallelization that can be exploited by these simulators. Both simulators include a "branch predictor" that will guess correctly ~90% of the time, and incur a 15 cycle penalty in the event of a miss, as well as simulation of branch logic, which will opt to take branches 60% of the time (and thus opt not to take branches 40% of the time). Both of these numbers have been derived from current industry reports of performance, code profiling, and the lecture slides, but do NOT strictly correlate to each-and-every usecase. In short, your code may vary and there is no substitute for good profiling! (I strongly recommend taking ECE 565 with Prof. Rogers if you're interested in this topic; he has several excellent slide decks about `gprof` and associated tools).

All of the Verilog components as well as their associated testbenches are located within the other namesake directories of the project. Please note that you will need the latest version of `iverilog` to "compile" these to netlists and I would advise downloading `gtkwave` or `WaveTrace` unless you're really good at reading VCD files by hand... ;)