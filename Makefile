PRODUCT    = stub
PART       = 5CSEBA6U23I7
FAMILY     = "Cyclone V"
BOARDFILE  = PINS
TOP_MODULE = top

QPATH ?= /opt/intelFPGA/20.1/quartus/bin

QC   = $(QPATH)/quartus_sh
QP   = $(QPATH)/quartus_pgm
QM   = $(QPATH)/quartus_map
QF   = $(QPATH)/quartus_fit
QA   = $(QPATH)/quartus_asm
QS   = $(QPATH)/quartus_sta
ECHO = echo
Q   ?= @

STAMP = echo done >

QCFLAGS = --flow compile
QPFLAGS =
QMFLAGS = --read_settings_files=on $(addprefix --source=,$(SRCS))
QFFLAGS = --part=$(PART) --read_settings_files=on

SRCS = top.sv

ASSIGN = $(PRODUCT).qsf $(PRODUCT).qpf

map: smart.log $(PRODUCT).map.rpt
fit: smart.log $(PRODUCT).fit.rpt
asm: smart.log $(PRODUCT).asm.rpt
sta: smart.log $(PRODUCT).sta.rpt
smart: smart.log

all: $(PRODUCT)

$(ASSIGN):
	$(Q)$(ECHO) "Generating assignment files."
	$(QC) --prepare -f $(FAMILY) -t $(TOP_MODULE) $(PRODUCT)
	echo >> $(PRODUCT).qsf
	cat $(BOARDFILE) >> $(PRODUCT).qsf

smart.log: $(ASSIGN)
	$(Q)$(ECHO) "Generating smart.log."
	$(QC) --determine_smart_action $(PRODUCT) > smart.log

$(PRODUCT): smart.log $(PRODUCT).asm.rpt $(PRODUCT).sta.rpt

$(PRODUCT).map.rpt: map.chg $(SRCS) $(ASSIGN)
	$(QM) $(QMFLAGS) $(PRODUCT)
	$(STAMP) fit.chg

$(PRODUCT).fit.rpt: fit.chg $(PRODUCT).map.rpt
	$(QF) $(QFFLAGS) $(PRODUCT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PRODUCT).sof $(PRODUCT).asm.rpt: asm.chg $(PRODUCT).fit.rpt
	$(QA) $(PRODUCT)

$(PRODUCT).sta.rpt: sta.chg $(PRODUCT).fit.rpt
	$(QS) $(PRODUCT)

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg

clean:
	$(Q)$(ECHO) "Cleaning."
	rm -rf db incremental_db
	rm -f smart.log *.rpt *.sof *.chg *.qsf *.qpf *.summary *.smsg *.pin *.jdi *.sld c5_pin_model_dump.txt

prog: $(PRODUCT).sof
	$(Q)$(ECHO) "Programming."
	$(QP) --no_banner --mode=JTAG -o "P;$(PRODUCT).sof@2"
