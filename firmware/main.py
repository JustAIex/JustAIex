# Ballgreifer - Steuerung fuer Raspberry Pi Pico (MicroPython)
# Taster druecken -> Greifer schliesst, nochmal druecken -> Greifer oeffnet.
#
# Anschluesse:  Servo-Signal (orange) -> GP15
#               Taster zwischen GP14 und GND
from machine import Pin, PWM
import time

SERVO_PIN = 15
TASTER_PIN = 14

# --- Hier einstellen -------------------------------------------------
WINKEL_AUF = 60     # Servowinkel fuer "offen"       (0..180)
WINKEL_ZU = 120     # Servowinkel fuer "geschlossen" (0..180)
SCHRITT_MS = 8      # Pause pro Grad: groesser = langsamer
# ---------------------------------------------------------------------

servo = PWM(Pin(SERVO_PIN))
servo.freq(50)
taster = Pin(TASTER_PIN, Pin.IN, Pin.PULL_UP)
led = Pin(25, Pin.OUT)


def setze_winkel(grad):
    puls_us = 500 + grad * 2000 / 180          # 0,5 ms .. 2,5 ms
    servo.duty_u16(int(puls_us * 65535 / 20000))


def fahre(von, nach):
    richtung = 1 if nach > von else -1
    for grad in range(von, nach + richtung, richtung):
        setze_winkel(grad)
        time.sleep_ms(SCHRITT_MS)


geschlossen = False
setze_winkel(WINKEL_AUF)        # beim Einschalten: offen

while True:
    if taster.value() == 0:                     # gedrueckt
        if geschlossen:
            fahre(WINKEL_ZU, WINKEL_AUF)
        else:
            fahre(WINKEL_AUF, WINKEL_ZU)
        geschlossen = not geschlossen
        led.value(geschlossen)
        while taster.value() == 0:              # auf Loslassen warten
            time.sleep_ms(10)
        time.sleep_ms(80)                       # entprellen
    time.sleep_ms(10)
