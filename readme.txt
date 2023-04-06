MSE 352 
Project 2
Dr. Amr Marzouk
April 6, 2023

Christopher Van Vugt 301448322
Aqeeb

Contributions:

Christopher:

LED Animation

    For the LED animation I worked on turning on the LEDs in EdSim one at a time from left to right this was to mimic a loading bar.
    To accomplish this I had to create a 0.625 second delay as there are 8 LEDs and the delay is meant to take 5 seconds. To create a 
    0.625 second delay I used timer zero in mode 1 which is a 16 bit timer. This timer counts from 0-65535 11 times which takes about 
    0.625 seconds on a 11.059 MHz clock. 

UART

    The UART is first initialized by clearing SM0 and setting SM1. When SM1 is set the UART runs in 8 bit mode. I setup the UART to
    recieve and transmit data even though in this project we are only using it to transmit data. This is accomplished by setting REN 
    high allowing the 8051 to recieve data over the serial port. After that SMOD in PCON needs to be set to double the baudrate so that 
    19,200 can be achieved. This will double the baudrate from 9600


LCD Display


Aqeeb: