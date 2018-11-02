###################################################################

# Created by write_sdc on Thu Oct  4 13:00:38 2018

###################################################################
set sdc_version 1.7

set_wire_load_model -name 3K_hvratio_1_4 -library NangateOpenCellLibrary
create_clock [get_ports Clk]  -period 1.5  -waveform {0 0.75}
set_max_delay 1.5  -from [list [get_ports Clk] [get_ports Rst] [get_ports {Idata[31]}]           \
[get_ports {Idata[30]}] [get_ports {Idata[29]}] [get_ports {Idata[28]}]        \
[get_ports {Idata[27]}] [get_ports {Idata[26]}] [get_ports {Idata[25]}]        \
[get_ports {Idata[24]}] [get_ports {Idata[23]}] [get_ports {Idata[22]}]        \
[get_ports {Idata[21]}] [get_ports {Idata[20]}] [get_ports {Idata[19]}]        \
[get_ports {Idata[18]}] [get_ports {Idata[17]}] [get_ports {Idata[16]}]        \
[get_ports {Idata[15]}] [get_ports {Idata[14]}] [get_ports {Idata[13]}]        \
[get_ports {Idata[12]}] [get_ports {Idata[11]}] [get_ports {Idata[10]}]        \
[get_ports {Idata[9]}] [get_ports {Idata[8]}] [get_ports {Idata[7]}]           \
[get_ports {Idata[6]}] [get_ports {Idata[5]}] [get_ports {Idata[4]}]           \
[get_ports {Idata[3]}] [get_ports {Idata[2]}] [get_ports {Idata[1]}]           \
[get_ports {Idata[0]}] [get_ports {Ddataout[31]}] [get_ports {Ddataout[30]}]   \
[get_ports {Ddataout[29]}] [get_ports {Ddataout[28]}] [get_ports               \
{Ddataout[27]}] [get_ports {Ddataout[26]}] [get_ports {Ddataout[25]}]          \
[get_ports {Ddataout[24]}] [get_ports {Ddataout[23]}] [get_ports               \
{Ddataout[22]}] [get_ports {Ddataout[21]}] [get_ports {Ddataout[20]}]          \
[get_ports {Ddataout[19]}] [get_ports {Ddataout[18]}] [get_ports               \
{Ddataout[17]}] [get_ports {Ddataout[16]}] [get_ports {Ddataout[15]}]          \
[get_ports {Ddataout[14]}] [get_ports {Ddataout[13]}] [get_ports               \
{Ddataout[12]}] [get_ports {Ddataout[11]}] [get_ports {Ddataout[10]}]          \
[get_ports {Ddataout[9]}] [get_ports {Ddataout[8]}] [get_ports {Ddataout[7]}]  \
[get_ports {Ddataout[6]}] [get_ports {Ddataout[5]}] [get_ports {Ddataout[4]}]  \
[get_ports {Ddataout[3]}] [get_ports {Ddataout[2]}] [get_ports {Ddataout[1]}]  \
[get_ports {Ddataout[0]}]]  -to [list [get_ports {Iaddr[31]}] [get_ports {Iaddr[30]}] [get_ports          \
{Iaddr[29]}] [get_ports {Iaddr[28]}] [get_ports {Iaddr[27]}] [get_ports        \
{Iaddr[26]}] [get_ports {Iaddr[25]}] [get_ports {Iaddr[24]}] [get_ports        \
{Iaddr[23]}] [get_ports {Iaddr[22]}] [get_ports {Iaddr[21]}] [get_ports        \
{Iaddr[20]}] [get_ports {Iaddr[19]}] [get_ports {Iaddr[18]}] [get_ports        \
{Iaddr[17]}] [get_ports {Iaddr[16]}] [get_ports {Iaddr[15]}] [get_ports        \
{Iaddr[14]}] [get_ports {Iaddr[13]}] [get_ports {Iaddr[12]}] [get_ports        \
{Iaddr[11]}] [get_ports {Iaddr[10]}] [get_ports {Iaddr[9]}] [get_ports         \
{Iaddr[8]}] [get_ports {Iaddr[7]}] [get_ports {Iaddr[6]}] [get_ports           \
{Iaddr[5]}] [get_ports {Iaddr[4]}] [get_ports {Iaddr[3]}] [get_ports           \
{Iaddr[2]}] [get_ports {Iaddr[1]}] [get_ports {Iaddr[0]}] [get_ports Denable]  \
[get_ports Drd] [get_ports Dwd] [get_ports {Daddr[31]}] [get_ports             \
{Daddr[30]}] [get_ports {Daddr[29]}] [get_ports {Daddr[28]}] [get_ports        \
{Daddr[27]}] [get_ports {Daddr[26]}] [get_ports {Daddr[25]}] [get_ports        \
{Daddr[24]}] [get_ports {Daddr[23]}] [get_ports {Daddr[22]}] [get_ports        \
{Daddr[21]}] [get_ports {Daddr[20]}] [get_ports {Daddr[19]}] [get_ports        \
{Daddr[18]}] [get_ports {Daddr[17]}] [get_ports {Daddr[16]}] [get_ports        \
{Daddr[15]}] [get_ports {Daddr[14]}] [get_ports {Daddr[13]}] [get_ports        \
{Daddr[12]}] [get_ports {Daddr[11]}] [get_ports {Daddr[10]}] [get_ports        \
{Daddr[9]}] [get_ports {Daddr[8]}] [get_ports {Daddr[7]}] [get_ports           \
{Daddr[6]}] [get_ports {Daddr[5]}] [get_ports {Daddr[4]}] [get_ports           \
{Daddr[3]}] [get_ports {Daddr[2]}] [get_ports {Daddr[1]}] [get_ports           \
{Daddr[0]}] [get_ports {Ddatain[31]}] [get_ports {Ddatain[30]}] [get_ports     \
{Ddatain[29]}] [get_ports {Ddatain[28]}] [get_ports {Ddatain[27]}] [get_ports  \
{Ddatain[26]}] [get_ports {Ddatain[25]}] [get_ports {Ddatain[24]}] [get_ports  \
{Ddatain[23]}] [get_ports {Ddatain[22]}] [get_ports {Ddatain[21]}] [get_ports  \
{Ddatain[20]}] [get_ports {Ddatain[19]}] [get_ports {Ddatain[18]}] [get_ports  \
{Ddatain[17]}] [get_ports {Ddatain[16]}] [get_ports {Ddatain[15]}] [get_ports  \
{Ddatain[14]}] [get_ports {Ddatain[13]}] [get_ports {Ddatain[12]}] [get_ports  \
{Ddatain[11]}] [get_ports {Ddatain[10]}] [get_ports {Ddatain[9]}] [get_ports   \
{Ddatain[8]}] [get_ports {Ddatain[7]}] [get_ports {Ddatain[6]}] [get_ports     \
{Ddatain[5]}] [get_ports {Ddatain[4]}] [get_ports {Ddatain[3]}] [get_ports     \
{Ddatain[2]}] [get_ports {Ddatain[1]}] [get_ports {Ddatain[0]}] [get_ports     \
{DataOut[31]}] [get_ports {DataOut[30]}] [get_ports {DataOut[29]}] [get_ports  \
{DataOut[28]}] [get_ports {DataOut[27]}] [get_ports {DataOut[26]}] [get_ports  \
{DataOut[25]}] [get_ports {DataOut[24]}] [get_ports {DataOut[23]}] [get_ports  \
{DataOut[22]}] [get_ports {DataOut[21]}] [get_ports {DataOut[20]}] [get_ports  \
{DataOut[19]}] [get_ports {DataOut[18]}] [get_ports {DataOut[17]}] [get_ports  \
{DataOut[16]}] [get_ports {DataOut[15]}] [get_ports {DataOut[14]}] [get_ports  \
{DataOut[13]}] [get_ports {DataOut[12]}] [get_ports {DataOut[11]}] [get_ports  \
{DataOut[10]}] [get_ports {DataOut[9]}] [get_ports {DataOut[8]}] [get_ports    \
{DataOut[7]}] [get_ports {DataOut[6]}] [get_ports {DataOut[5]}] [get_ports     \
{DataOut[4]}] [get_ports {DataOut[3]}] [get_ports {DataOut[2]}] [get_ports     \
{DataOut[1]}] [get_ports {DataOut[0]}]]
