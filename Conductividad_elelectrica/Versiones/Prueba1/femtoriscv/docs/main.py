from machine import UART
from time import sleep

uart_fpga = None
uart_usb = None

# ADC en GPIO36
#adc = ADC(Pin(36))
#adc.atten(ADC.ATTN_11DB)

def init():
    global uart_usb
    global uart_fpga
    # UART0: ahora libre
    uart_usb = UART(1, baudrate=115200, tx=1, rx=3)
    # UART2: FPGA
    uart_fpga = UART(2, baudrate=57600, tx=17, rx=16)

def bridge_uart():
    while True:
        #ppm_int = int(min(((adc.read()*3.3/4095)/2.3)*1000, 1000))
        #uart_fpga.write(str(ppm_int) + "\r")
        uart_fpga.write("700\r") 
        sleep(0.02) 
        if uart_fpga.any():
            uart_usb.write(uart_fpga.read())
        #if uart_usb.any():
            #uart_fpga.write(uart_usb.read())
        sleep(0.1)




def start():
    init()
    bridge_uart()

