from machine import UART, Pin, ADC
from time import sleep
import time
import network
from umqtt.simple import MQTTClient

# NETWORK
SSID = "HONOR"
PASSWORD = "juampi12"
# MQTT DEFINITIONS
MQTT_BROKER = "10.15.136.168"
CLIENT_ID = "SensorTDS"
TOPIC_LED = CLIENT_ID + "/led"
TOPIC_ADC = CLIENT_ID + "/adc"
TOPIC_UART = CLIENT_ID + "/uart"

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

def connect_mqtt():
    client = MQTTClient(CLIENT_ID, MQTT_BROKER)
    #client.set_callback(subscribe_callback)
    client.connect()
    #client.subscribe(TOPIC_LED)
    print(f"Conectado a {MQTT_BROKER}")
    return client


def connectSTA(ssid, pwd):
    sta_if = network.WLAN(network.STA_IF)
    if not sta_if.isconnected():
        print("connecting to network...")
        sta_if.active(True)
        sta_if.connect(ssid, pwd)
        while not sta_if.isconnected():
            pass
    print("network config:", sta_if.ifconfig())


def bridge_uart():
    # 1. Conectarse a una RED WIFI
    connectSTA(SSID, PASSWORD)
    # 2. Conectarse al broker mqtt y subscribirse a los topics
    mqtt_client = connect_mqtt()
    print("Esperando datos UART o mensajes MQTT...")
    while True:
        try:
            # 3. Verificar si existen mensajes de entrada por mqtt
            mqtt_client.check_msg()
        except Exception as e:
            print(e)
            # En el caso de desconectarse del broker, reintentar conexión
            mqtt_client = connect_mqtt()
        print("waiting")
        
        ppm_int = int(min(((adc.read()*3.3/4095)/2.3)*1000, 1000))
        
        #uart_usb.write(b"[TX -> FPGA] ppm_int = " + str(ppm_int).encode() + b"\r\n")################## descomentar si se quiere usar picocom
        uart_bt.write(b"[TX -> FPGA] ppm_int = " + str(ppm_int).encode() + b"\r\n")  ###decisiemens por metro --- 1ds/m=1ms/cm=640ppm
        uart_fpga.write(str(ppm_int) + "\r")
        #uart_fpga.write("0\r") 
        sleep(0.02) 
        if uart_fpga.any():
            data = uart_fpga.read()
            if data:
                #uart_usb.write(b"[RX <- FPGA] " + data + b"\r\n")#####Descomentar para ver datos en picocom
                uart_bt.write(b"[RX FPGA] " + data + b"\r\n")
                mqtt_client.publish(TOPIC_UART, data)
            #uart_usb.write(uart_fpga.read())
        #if uart_usb.any():
            #uart_fpga.write(uart_usb.read())
        sleep(0.1)




def start():
    init()
    bridge_uart()

