; File: sh6578.inc
; SH6578-specific defines.

; This chipset is also known as "UM6578" (manufactured by UMC)
; and "NT6578" (manufactured by Novatek). The SH6578 (manufactured by
; Sino Wealth) is the only version that has a readily available datasheet.

; Supposedly, there is also a "HA6578", but I can only find one reference to it:
; http://www2a.biglobe.ne.jp/~mizuki/lifelog/3.htm

; $2008 - Color Select & PNT Start Address
; 76543210
; |xxx||x|
; |   || +-- BG nametable start address (GA13; 0=$0000 1=$2000)
; |   ++---- Sprite pattern table start address (GA13,GA12; 0=$0000, 1=$1000, 2=$2000, 3=$3000)
; +--------- BG number of colors (0=4 colors, 1=16 colors)
;
; If BG nametables start at $2000, only $2000-$27FF can be used,
; as the PPU has a big hole from $2800-$7FFF in its memory map.
SH6578_VIDEOCTRL = $2008
SH6578_VIDEOCTRL_FLAG_NAMETABLE_0000 = $00 ; _______0
SH6578_VIDEOCTRL_FLAG_NAMETABLE_2000 = $01 ; _______1
SH6578_VIDEOCTRL_FLAG_SPRITES_0000   = $00 ; ____00__
SH6578_VIDEOCTRL_FLAG_SPRITES_1000   = $04 ; ____01__
SH6578_VIDEOCTRL_FLAG_SPRITES_2000   = $08 ; ____10__
SH6578_VIDEOCTRL_FLAG_SPRITES_3000   = $0C ; ____11__
SH6578_VIDEOCTRL_FLAG_BG_16_COLORS   = $80 ; 1_______

; $2040-$207F - Color Palette Table
SH6578_PALSTART   = $2040
SH6578_SPRITEPALS = $2050

; $4020 - Timing Setting Control (write-only), Keyboard Input Port (read-only)
; [write]
; 76543210
; |0|00000
; | +------- "Keyboard/PS2 Mouse Clock trigger control"
; |          (0=data sync with clock rising edge, 1=data sync with clock falling edge)
; +--------- Enable control bits of $4048 D5 and D6 (0=disabled, 1=enabled)
;            (This is related to system DMA functionality.)
SH6578_TIMING_CONTROL = $4020

; $4021 - Keyboard Output Port
SH6578_KBOUT = $4021

; $4022 - Keyboard Data Control
; 76543210
; |????|0|
; |    | +-- Data Direction (0=Keyboard to System, 1=System to Keyboard)
; |    +---- IRQ enable for sending command
; +--------- "Software drives signal of keyboard CLK directly"
;
; UM6578 register docs say something different:
; 76543210
; |xxxxxx|
; |      +-- Data Direction (0=Keyboard to System, 1=System to Keyboard)
; +--------- Keyboard Clock Control
;            0 = "Keyboard inhibit and UM6576 prepare to send data"
;            1 = UM6576 ready to receive data
; where the "x" bits are marked as "reserved"
SH6578_KBCTRL = $4022
SH6578_KBCTRL_FLAG_DATA_KB_TO_SYSTEM = $00 ; _______0
SH6578_KBCTRL_FLAG_DATA_SYSTEM_TO_KB = $01 ; _______1
SH6578_KBCTRL_FLAG_CLOCK_SYSTEM_SEND = $00 ; 0_______
SH6578_KBCTRL_FLAG_CLOCK_SYSTEM_RECV = $80 ; 1_______

; $4023 - Joystick/Mouse Control
; 76543210
; xxxxxxx|
;        +--- (0=Joystick, 1=Mouse)
SH6578_JOYMOUSE = $4023

; $4024 - Mouse Port (read-only), Mouse Baud Rate Setting (write-only)
; SH6578 documentation says you should write $A3 for NTSC and $A9 for PAL.
SH6578_MOUSEDATA = $4024

; $4025 - Printer Port (write-only)
SH6578_PRINTER = $4025

; $4026 - External I/O Port
; 76543210
; |____|||
;    |  |+-- "Connect with /CS of RTC"
;    |  +--- Mouse Reset signal (0=normal, 1=reset)
;    +------ "EIO7-EIO2", "Reseved bits for application by user"
; "This port contains all 8 bits, all can be set as input/output.
; Each data line has a pull high resistor."
; The first two bits correspond to the reference application circuit described
; in the datasheet. Actual usage may vary depending on hardware used.
SH6578_EXTIO = $4026

; $4027 - DAC Data Register
SH6578_DAC = $4027

; ($4028-$4030 not documented; do they exist?)

; $4031 - Initial Setup
; You will need to write $65 and $76 (in order) to $4031 to enable expanded
; functionality. Though the datasheet says "must execute the write-instruction
; within two instruction cycles", the game "Birdie Nest" only writes these
; values after doing some initial hardware setup (including VBlank waits).
; Perhaps they mean the two writes need to happen consecutively, as opposed
; to needing to do them immediately at Reset.
SH6578_SETUP = $4031

; $4032 - IRQ Mask & Clear
; All bits are active low.
; Writing 1 to a bit clears the flag and ignores the interrupt.
; 76543210
; |||||||x
; ||||||+-- INT1/IRQ1
; |||||+--- INT2/IRQ2 ("for printer")
; ||||+---- INT3/FDD
; |||+----- INT4/RTC
; ||+------ Keyboard
; |+------- Mouse
; +-------- Timer
SH6578_IRQMASK = $4032

; $4033 - IRQ Status (read-only)
; All bits are active high.
; 76543210
; |||||||x
; ||||||+-- INT1/IRQ1
; |||||+--- INT2/IRQ2
; ||||+---- INT3/FDD
; |||+----- INT4/RTC
; ||+------ Keyboard
; |+------- Mouse
; +-------- Timer
SH6578_IRQSTATUS = $4033

SH6578_IRQFLAG_HIGH_IRQ1     = $02
SH6578_IRQFLAG_HIGH_IRQ2     = $04
SH6578_IRQFLAG_HIGH_FDD      = $08
SH6578_IRQFLAG_HIGH_RTC      = $10
SH6578_IRQFLAG_HIGH_KEYBOARD = $20
SH6578_IRQFLAG_HIGH_MOUSE    = $40
SH6578_IRQFLAG_HIGH_TIMER    = $80

; $4034 - Timer Control
; 76543210
; |||x|__|
; |||   |
; |||   +-- Timer Prescale
; ||+------ Base Clock Select (0=system clock (1.7898MHz), 1=hblank (15625Hz))
; |+------- Timer Auto-Load (0=one-shot, 1=continuous)
; +-------- Timer Enable (0=disabled, 1=enabled)
SH6578_TIMERCTRL = $4034
; Timer period = base clock * (prescale+1) * (timer present value+1)

; $4035 - Timer Present Value (write-only)
SH6578_TIMERVAL_SET = $4035

; $4036 - Timer Current Value (read-only)
SH6578_TIMERVAL_CUR = $4036

; ($4037-$403F not documented; do they exist?)

; The Program Bank Select registers work in 4KB banks.
; Values given are the initial values (mainly pertaining to the three lowest bits),
; which are constant at power on.
; "On application CKT, XA16-XA20 of SH6578 are connected with A15-A19 of ROM."
; $4040 - Program Bank 0 Select ($8000-$8FFF)
; 76543210
; |||||000
; |||||+++-- A14-A12
; +++++----- XA20-XA16
SH6578_PRGBANK0 = $4040

; $4041 - Program Bank 1 Select ($9000-$9FFF)
; 76543210
; |||||001
; |||||+++-- A14-A12
; +++++----- XA20-XA16
SH6578_PRGBANK1 = $4041

; $4042 - Program Bank 2 Select ($A000-$AFFF)
; 76543210
; |||||010
; |||||+++-- A14-A12
; +++++----- XA20-XA16
SH6578_PRGBANK2 = $4042

; $4043 - Program Bank 3 Select ($B000-$BFFF)
; 76543210
; |||||011
; |||||+++-- A14-A12
; +++++----- XA20-XA16
SH6578_PRGBANK3 = $4043

; $4044 - Program Bank 4 Select ($C000-$CFFF)
; 76543210
; |||||100
; |||||+++-- A14-A12
; +++++----- XA20-XA16
SH6578_PRGBANK4 = $4044

; $4045 - Program Bank 5 Select ($D000-$DFFF)
; 76543210
; |||||101
; |||||+++-- A14-A12
; +++++----- XA20-XA16
SH6578_PRGBANK5 = $4045

; $4046 - Program Bank 6 Select ($E000-$EFFF)
; 76543210
; |||||110
; |||||+++-- A14-A12
; +++++----- XA20-XA16
SH6578_PRGBANK6 = $4046

; $4047 - Program Bank 7 Select ($F000-$FFFF)
; 76543210
; |||||111
; |||||+++-- A14-A12
; +++++----- XA20-XA16
SH6578_PRGBANK7 = $4047

; $4048 - DMA Control
; todo: this is a little more complicated than the SH6578 docs let on
; 76543210
; |||00000
; ||+------- Destination Select (0=VRAM, 1=work RAM)
; |+-------- Transfer Rate (0=890KB/s, 1=1.78MB/s)
; +--------- DMA enable (1=enable)

; UM6578 gives a different layout:
; 76543210
; |||xxxxx
; |++------- DMA Mode Selection
; |          0 = double cycle from system bus to VRAM
; |          1 = single cycle from system bus to VRAM
; |          2,3 = double cycle from system bus to system bus
; +--------- DMA Enable (write) or DMA Status Flag (read)
; When enabling DMA...
; "DMA wil trigged by V-Blanking automatically, or start immediately if the PPU is Off."
SH6578_DMACTRL = $4048

SH6578_DMA_FLAG_DEST_VRAM = $00
SH6578_DMA_FLAG_DEST_WRAM = $20
SH6578_DMA_FLAG_RATE_FAST = $40
SH6578_DMA_FLAG_ENABLE = $80

; $4049 - DMA Bank Select
; (low 5 bits only; equivalent to upper bits (XA20 to XA16) in Program Bank Select)
SH6578_DMABANK = $4049

; $404A - DMA Source Address Low
; $404B - DMA Source Address High
SH6578_DMASRC_LO = $404A
SH6578_DMASRC_HI = $404B

; $404C - DMA Destination Address Low
; $404D - DMA Destination Address High
SH6578_DMADEST_LO = $404C
SH6578_DMADEST_HI = $404D

; $404E - DMA Length Low
; $404F - DMA Length High (d7 is reserved)
SH6578_DMALEN_LO = $404E
SH6578_DMALEN_HI = $404F

; ($4050-$407F not documented; do they exist?)

; Peripherals can be added at $4080-$43XX

; $4080 - RTC address port (write-only)
SH6578_RTCADDR = $4080

; $4081 - RTC data port
SH6578_RTCDATA = $4081

; $41xx-$43xx - Super I/O Address
; "SH6578 has a super I/O (UM82C863) interfact CKT which can connect with
; UM82C863 directly for extending functions of a floppy disk, printer, RS232, etc."

; apparently there is a "LCD testing module" that reponds to registers $4400 and $4480

; Furthermore... I'm just gonna copy this directly, unedited (i.e. typos are not mine):
;CPUSpeedSet		.equ	$FFDA		; CPU speed selection register for PAL-B TV system.
						; After system reset, the system clock for CPU is Xtal/15,
						; user can write data($FEh) to this port for switch system
						; clock slow down to Xtal/16 for meet PAL-B TV system,
						; and change the waveform of PHI2 signal from CPU, which
						; will change to 50%-50% duty circle.
