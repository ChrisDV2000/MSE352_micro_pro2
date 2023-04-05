# MSE352_micro_pro2
Door Security Microcontroller Program for a 8051


## Project S-51 Definition

### Description
In this project, you will design a door access security system using the EDSIM51Links to an external site. simulator for the 8051 microcontroller. The general purpose of the project is to prompt the user to enter a passcode, access will be granted if the passcode matches the passcode previously saved in memory, and denied otherwise.
User requirements
- [x] Your system should show "Enter Passcode" on the LCD and send the same message via UART (19200, 8N1).
- [x] User enters a 4-digit passcode followed by a # 
- [x] Build a nice animation on the LEDs for 5 seconds to imitate processing delay.
- [x] If the passcode was entered correctly, the system will show "Access Granted"  on the LCD and UART.
Optional: You can also imitate a door opening animation on the LEDs or LCD here.
- [x] If the passcode was entered incorrectly, the system will show "Access Denied" on the LCD and UART.
 - [ ] If the passcode was entered incorrectly 3-times in a row, the system will go in "LOCK DOWN" mode and show that on LCD and UART for 3 minutes before allowing the user to try again. 

### Deliverables
- Professional grade assembly code, fully commented and structured
- Readme.txt file that includes developers, how they contributed to the project, what your implementation is capable of, what it is not implemented, and a list of known bugs.
- A screen recording of your system showing the requirements
- Interviews will be during the project submission and demonstration in the lab.
