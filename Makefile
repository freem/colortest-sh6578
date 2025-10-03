AS = asm6f
INFILE = colortest.asm
OUTFILE = colortest-sh6578
EXTENSION_NES := .nes
EXTENSION_BIN := .bin

.phony: all, nes, headerless clean

all: nes headerless

# NES 2.0 target
nes:
	$(AS) $(INFILE) $(OUTFILE)$(EXTENSION_NES)

# headerless target (e.g. for MAME or chip burning)
headerless:
	$(AS) -d_NO_HEADER $(INFILE) $(OUTFILE)$(EXTENSION_BIN)

clean:
	rm -f $(OUTFILE)$(EXTENSION_NES) $(OUTFILE)$(EXTENSION_BIN)
