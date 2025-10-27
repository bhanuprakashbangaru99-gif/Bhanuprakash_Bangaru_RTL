# Bhanuprakash_Bangaru_RTL
# UART RX Mini-Lab (Phinity Take-Home)

## Overview
This repository contains my RTL mini-lab submission for the Phinity hardware RL environment.  
The project implements a UART receiver (`uart_rx.v`) with three difficulty tiers (Easy / Medium / Hard) designed for LLM reward shaping.

## Folder Structure
- **rtl/** – contains the Verilog source files (easy, medium, hard)
- **tb/** – contains the Verilog testbench files
- **screenshots/** – waveform captures showing test results
- **README.md** – documentation
- **TAKEHOME_Answers.pdf** – my written answers to all questions

## Difficulty Tiers
| Version | Description | Pass Rate | Key Modification |
|----------|--------------|------------|------------------|
| **Easy** | Correct UART RX (mid-bit sampling) | 100% | `-2` reloads (ideal sampling) |
| **Medium** | Early data sampling (1 tick early) | 10–30% | `-3` reloads in data phase only |
| **Hard** | Early start re-check + early data sampling | 0% | `-5` recheck + `-3` data reloads |

## Simulation Instructions
1. Open any version of `uart_rx.v` + `uart_rx_tb.v` in **EDA Playground** (Verilog 2001 / Icarus Verilog).
2. Set top module = `uart_rx_tb`.
3. Check “Open EPWave after run” to see waveforms.
