# Virus.MSX.obscure

## Overview

This MSX assembly boot sector virus is designed to be **resident in memory** and automatically spreads itself to the boot sector of a new floppy disk if one is inserted in either drive `A:` or `B:`. It checks for floppy disk insertion every 2 seconds and copies itself to the boot sector of the other disk, allowing the program to replicate itself across multiple disks.

### Features:
- **Memory Resident**: The program stays resident after execution and checks for floppy disk insertions periodically.
- **Floppy Disk Spread**: When a floppy disk is inserted in drive `A:` or `B:`, the program copies itself to the boot sector of the other drive’s disk (if a disk is present).
- **Automatic Boot Sector Copy**: The program overwrites the boot sector (`$0200`) of the detected floppy disk and replicates itself there.

## How It Works

1. **Initialization**:
    - The program is loaded into memory starting at address `$100H` and sets up its stack pointer at the top of RAM.
    - It then enters a loop where it checks for floppy disk insertions.

2. **Main Loop**:
    - Every 2 seconds, the program checks whether a floppy disk has been inserted into either drive `A:` or `B:`.
    - If a disk is detected in one drive, it checks the other drive for a disk.

3. **Copying to the Boot Sector**:
    - If both drives `A:` and `B:` have floppy disks inserted, the program copies itself to the boot sector (`$0200`) of the other drive. This action spreads the program to both drives, enabling it to run on any inserted disk.

4. **Memory Resident**:
    - The program uses MSX-DOS system calls to allocate memory and stays resident in memory, continuing to monitor the floppy drives for insertions.

## BIOS Calls Used

- **$1A** (`CALL $0010`): Check for floppy disk insertion in drive `A:`.
- **$1B** (`CALL $0010`): Check for floppy disk insertion in drive `B:`.
- **$0026**: Copy data from memory to the floppy disk (used to copy the program to the boot sector).

## Assembly Code Breakdown

- **Initialization (`Init`)**: 
    - Sets up the stack and prepares the system for execution.
    - Ensures the program remains resident by allocating memory at address `$8000`.
  
- **Stay Resident (`StayResident`)**: 
    - The program copies itself into memory at a specified location so it can stay resident and continue execution after it finishes.

- **Main Loop (`MainLoop`)**: 
    - The program constantly checks for floppy disk insertions in both drives (`A:` and `B:`). If a disk is detected in one drive, it will attempt to copy itself to the other drive’s boot sector.
  
- **Floppy Disk Check (`CheckFloppy`)**: 
    - The program checks whether a disk is inserted in both `A:` and `B:` drives. If a disk is detected in one, the program copies itself to the other.

- **Copying to Boot Sector (`CopyToBootA`, `CopyToBootB`)**: 
    - If a disk is inserted into one drive, the program copies itself to the boot sector (`$0200`) of the other drive’s disk.

- **Delay (`Delay`)**: 
    - Introduces a 2-second delay between each check to avoid overwhelming the system with continuous checks.

## Assembly Code
its in obscure.asm
