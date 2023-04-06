MSE 352 
Project 2
Dr. Amr Marzouk
April 6, 2023

Christopher Van Vugt 301448322
Aqeeb

Contributions:

Christopher:

    System Clock:

        In order to use a baudrate of 19,200 a clock cycle of 11.059 MHz needs to be used.

    LED Animation

        For the LED animation I worked on turning on the LEDs in EdSim one at a time from left to right this was to mimic a loading bar.
        To accomplish this I had to create a 0.625 second delay as there are 8 LEDs and the delay is meant to take 5 seconds. A 5 second 
        delay on the simulator took quite a while to run so we made the decision to switch it to a 2 second delay which worked out to 0.25 
        seconds per LED. I used a polling method to create the delay using a little bit of math to determine how long the delay should take.
        This resulted in a few loops counting to 115,198 this value was calculated using the 11.059 MHz clock cycle divided by 24 because 1 
        machine cycle takes 24 clock cycles. This value gives the period of one machine cycle and from there it's a simple matter of dividing 
        the delay time by 1 machine cycle and you end up with 115,198 as the total number of machine cycles necessary to achieve a delay of 
        0.25 seconds. Taking the factors of 115,198 we were able to come up with a 3 values to store in the registers to loop through. This
        is then called 8 times with a LED being turned on at the end of each delay.

    UART

        The UART is first initialized by clearing SM0 and setting SM1. When SM1 is set the UART runs in 8 bit mode. I setup the UART to
        recieve and transmit data even though in this project we are only using it to transmit data. This is accomplished by setting REN 
        high allowing the 8051 to recieve data over the serial port. After that SMOD in PCON needs to be set to double the baudrate so that 
        19,200 can be achieved. This will double the baudrate from 9600 to achieve a full 19,200 baudrate. From there timer 1 gets put in mode
        2 which is an 8 bit auto reload timer. TH1 is set to 253 so that the timer resets every 13 microseconds and TL1 is also set to 253
        so that it resets to 13 microseconds on the first iteration as well. The timer is then started and the UART is ready to transmit and 
        recieve data. 

        To transmit data the data is moved to the accumulator using the MOVC command which takes data from a location pointed to by the Data 
        Pointer and stores it in the accumulator. The value in the accumulator is then moved to the SBUF register and then a loop checks for the 
        TI flag to be set. Once the TI flag is set the data has been transmitted so the TI flag can be cleared and the function can move on to
        the next value stored that is to be transmitted. 


    LCD Display

        Setup

            To setup the LCD display first we turn off the seven segment displays which also use port 1 by setting pin P0.7 low. Then we clear
            the register select (RS) pin which indicates that the data should be used to configure the LCD. From there we set 4 bit mode by sending
            a high nibble set which looks like a 0010 on pins 1.4-1.7. Then a clock cycle is called by setting pin 1.2 high and low creating a
            falling edge on pin 1.2. This high nibble is called twice to set the device to 4 bit mode followed by a low nibble set. The LCD has 
            an internal buffer built in that allows it to do internal computations after 8 bits or sent. We need to wait for that buffer to clear
            because it prevents data from being sent to it during the buffer period. Due to the way the simulator is wired we set a 25 cycle buffer 
            delay. Normally the busy flag would be polled or put on an interrupt but it is not connected to the 8051 simulator so a delay is the best
            we can do. After the function set is called the LCD can be turned on and the cursor can be turned on as well. This is done by sending 0x0F
            to the LCD. The next set of instructions tells the LCD how to behave when it recieves data. We want it to increment its position without a 
            shift. This is performed with a 0x06 sent to the LCD. After that the LCD is ready for data entry which is accomplished by setting the RS
            pin to 1 placing the LCD in write mode.

        Use

            To use the LCD display in 4 bit mode a character is loaded into port 1 bit by bit from the accumulator. Since only 4 bits can be
            used to transmit data and we have 8 bits to transmit we send the data in two 4 bit chuncks on P1.4-P1.7 with two clock cycles. We then wait 
            for the busy flag to clear and the LCD display displays the character.

Aqeeb: