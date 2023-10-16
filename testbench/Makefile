# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

# Author: Robert Balas (balasr@iis.ee.ethz.ch)

VCS = vcs
ROOT = /home/piaodeng/code/jtag_pulp
SRC = $(ROOT)/src/bscell.sv \
      $(ROOT)/src/jtag_enable.sv \
      $(ROOT)/src/jtag_enable_synch.sv \
      $(ROOT)/src/jtagreg.sv \
      $(ROOT)/src/jtag_rst_synch.sv \
      $(ROOT)/src/jtag_sync.sv \
      $(ROOT)/src/axi_bus.sv \
      $(ROOT)/src/tap_top.v \
      $(ROOT)/testbench/tb_jtag.sv


# $(ROOT)/src/jtag_axi_wrap.sv \

.PHONY: build clean

build:
        $(VCS) -sverilog -debug_acc+all -debug=1 -timescale=1ns/1ps $(SRC) -l com.log

clean:
        rm -rf work transcript compile.tcl
