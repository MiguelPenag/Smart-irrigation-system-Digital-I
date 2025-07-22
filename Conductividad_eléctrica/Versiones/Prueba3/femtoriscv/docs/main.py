from machine import UART, Pin, ADC
from time import sleep

uart_fpga = None
#uart_usb = None
adc = None
uart_bt = None

def init():
    #global uart_usb
    global uart_fpga
    global adc
    global uart_bt
    # UART0: ahora libre
    #uart_usb = UART(1, baudrate=115200, tx=1, rx=3)#############Descomentar si se quieren ver datos en picocom
    # UART2: FPGA
    uart_fpga = UART(2, baudrate=57600, tx=17, rx=16)
    uart_bt   = UART(1, baudrate=9600, tx=5, rx=4)       # HC-06 (Bluetooth)
    # ADC en GPIO36
    adc = ADC(Pin(36))
    adc.atten(ADC.ATTN_11DB)

def bridge_uart():
    while True:
        ppm_int = int(min(((adc.read()*3.3/4095)/2.3)*1000, 1000))
        
        #uart_usb.write(b"[TX -> FPGA] ppm_int = " + str(ppm_int).encode() + b"\r\n")################## descomentar si se quiere usar picocom
        uart_bt.write(b"[TX -> FPGA] ppm_int = " + str(ppm_int).encode() + b"\r\n")
        uart_fpga.write(str(ppm_int) + "\r")
        #uart_fpga.write("0\r") 
        sleep(0.02) 
        if uart_fpga.any():
            data = uart_fpga.read()
            if data:
                #uart_usb.write(b"[RX <- FPGA] " + data + b"\r\n")#####Descomentar para ver datos en picocom
                uart_bt.write(b"[RX FPGA] " + data + b"\r\n")
            #uart_usb.write(uart_fpga.read())
        #if uart_usb.any():
            #uart_fpga.write(uart_usb.read())
        sleep(0.1)




def start():
    init()
    bridge_uart()

