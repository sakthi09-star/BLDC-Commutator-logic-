# BLDC Motor Commutation Controller

6-step trapezoidal commutation logic for 3-phase BLDC motor using Hall sensor feedback.

## Overview
This Verilog module implements electronic commutation for a 3-phase BLDC motor. It decodes 3-bit Hall sensor inputs to generate the correct 6-step switching sequence for the inverter bridge. Replaces mechanical brushes with MOSFET/IGBT control.

## Features
- **6-Step 120° Commutation**: Standard trapezoidal drive sequence
- **Hall Sensor Decoding**: Maps `hall[2:0]` to `out[5:0]` for AH,AL,BH,BL,CH,CL
- **Direction Control**: `dir` input selects CW/CCW rotation
- **Enable & Brake**: `en` for run/coast, `brake` for active low-side braking
- **Shoot-Through Protection**: Logic ensures high-side and low-side of same phase are never ON
- **Synchronous Design**: All outputs registered on `clk` for glitch-free operation
- **Self-Checking Testbench**: Cycles through all valid Hall states + tests direction change

## 6-Step Commutation Table - CW Rotation
| Step | Hall[2:0] | OUT AH,AL,BH,BL,CH,CL | Active Phases |
| --- | --- | --- | --- |
| 1 | 101 | 100001 | A+ C- |
| 2 | 100 | 100010 | A+ B- |
| 3 | 110 | 001010 | C+ B- |
| 4 | 010 | 011000 | C+ A- |
| 5 | 011 | 010100 | B+ A- |
| 6 | 001 | 000101 | B+ C- |

*For CCW, sequence reverses: 6→5→4→3→2→1*

## Module Interface
```verilog
module bldc_commutator (
  input  wire       clk,      // System clock
  input  wire       rst_n,    // Active low reset  
  input  wire [2:0] hall,     // Hall sensors: Hc,Hb,Ha
  input  wire       dir,      // 1=CW, 0=CCW
  input  wire       en,       // Motor enable
  input  wire       brake,    // Active brake
  output reg  [5:0] out       // Gate signals: AH,AL,BH,BL,CH,CL
);# BLDC-Commutator-logic-
six step BLDC commutation logic using hall sensors. Verilog RTL, synthesized for FPGA. 
