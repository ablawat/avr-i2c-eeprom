                .INCLUDE "peripheral/clkctrl/include/clkctrl.inc"
                .INCLUDE "peripheral/port/include/porta.inc"
                .INCLUDE "peripheral/port/include/portb.inc"
                .INCLUDE "peripheral/portmux/include/portmux.inc"
                .INCLUDE "peripheral/usart/include/usart0.inc"
                .INCLUDE "peripheral/twi/include/twi0.inc"

                .INCLUDE "24lc024h/include/24lc024h.inc"

                .DSEG
                .ORG    INTERNAL_SRAM_START

                .EQU    STRING_SIZE = 16
                .EQU    BUFFER_SIZE = 3

string:         .BYTE   STRING_SIZE
buffer:         .BYTE   BUFFER_SIZE

                .CSEG

                ; initialize clock controller
                rcall   clkctrl_init

                ; initialize PORT multiplexer
                rcall   portmux_init

                ; initialize PORTA and PORTB
                ldi     ARG1, 0
                rcall   port_init
                ldi     ARG1, 1
                rcall   port_init

                ; initialize and enable USART0
                clr     ARG1
                rcall   usart_init
                rcall   usart_enable

                ; initialize and enable TWI0
                rcall   twi0_init
                rcall   twi0_enable

                ; initialize string
                ldi     r16, 0xAA
                sts     string + 0, r16
                ldi     r16, 0xAA
                sts     string + 1, r16
                ldi     r16, 0xAA
                sts     string + 2, r16
                ldi     r16, 0xAA
                sts     string + 3, r16
                ldi     r16, 0xAA
                sts     string + 4, r16
                ldi     r16, 0xAA
                sts     string + 5, r16
                ldi     r16, 0xAA
                sts     string + 6, r16
                ldi     r16, 0xAA
                sts     string + 7, r16
                ldi     r16, 0xAA
                sts     string + 8, r16
                ldi     r16, 0xAA
                sts     string + 9, r16
                ldi     r16, 0xAA
                sts     string + 10, r16
                ldi     r16, 0xAA
                sts     string + 11, r16
                ldi     r16, 0xAA
                sts     string + 12, r16
                ldi     r16, 0xAA
                sts     string + 13, r16
                ldi     r16, 0xAA
                sts     string + 14, r16
                ldi     r16, 0xAA
                sts     string + 15, r16

loop:           ; load pointer of command buffer
                ldi     XH, HIGH (buffer)
                ldi     XL, LOW  (buffer)

                ; setup input channel
                clr     ARG1                ; use USART0
                ldi     ARG2, BUFFER_SIZE   ; get command size

                ; receive input command
                rcall   usart_read

                ; load pointer of command buffer
                ldi     XH, HIGH (buffer)
                ldi     XL, LOW  (buffer)

                ; decode received command
                ld      TEMPL, X+           ; get command type
                ld      BUFFL, X+           ; get word address
                ld      BUFFH, X+           ; get length

                ; check for read command
                cpi     TEMPL, 0xA5         ; check command value
                breq    read                ; handle read

                ; check for write command
                cpi     TEMPL, 0x3C         ; check command value
                breq    write               ; handle write

                rjmp    loop

read:           ; load pointer of data buffer
                ldi     XH, HIGH (string)
                ldi     XL, LOW  (string)

                ; restore length and word address
                mov     ARG1, BUFFH
                mov     ARG2, BUFFL

                ; read bytes from EEPROM
                rcall   ic_24lc024h_read

                ; load pointer of data buffer
                ldi     XH, HIGH (string)
                ldi     XL, LOW  (string)

                ; setup output channel
                clr     ARG1
                mov     ARG2, BUFFH

                ; send data bytes
                rcall   usart_write

                rjmp    loop

write:          ; load pointer of data buffer
                ldi     XH, HIGH (string)
                ldi     XL, LOW  (string)

                ; setup input channel
                clr     ARG1
                mov     ARG2, BUFFH

                ; receive input data
                rcall   usart_read

                ; load pointer of data buffer
                ldi     XH, HIGH (string)
                ldi     XL, LOW  (string)

                ; restore length and word address
                mov     ARG1, BUFFH
                mov     ARG2, BUFFL

                ; write bytes into EEPROM
                rcall   ic_24lc024h_write

                ; load pointer of data buffer
                ldi     XH, HIGH (string)
                ldi     XL, LOW  (string)

                ; setup output channel
                clr     ARG1
                ldi     ARG2, 1

                ; send data bytes
                rcall   usart_write

                rjmp    loop

                .INCLUDE "peripheral/clkctrl/source/clkctrl.asm"
                .INCLUDE "peripheral/port/source/port.asm"
                .INCLUDE "peripheral/portmux/source/portmux.asm"
                .INCLUDE "peripheral/usart/source/usart.asm"
                .INCLUDE "peripheral/twi/source/twi0.asm"
                .INCLUDE "utils/memory.asm"
                .INCLUDE "24lc024h/source/24lc024h.asm"
