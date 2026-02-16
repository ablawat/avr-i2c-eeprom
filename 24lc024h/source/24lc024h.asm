;**********************************************************************************************;
; @description : Microchip 24LC024H Source                                                     ;
;**********************************************************************************************;

;**********************************************************************************************;
; @section : Local Definition                                                                  ;
;**********************************************************************************************;

; @brief Device Data Buffer Size
.EQU IC_24LC024H_DATA_BUFF_SIZE = 16

; @brief Device Data Address Size
.EQU IC_24LC024H_DATA_ADDR_SIZE = 1

;**********************************************************************************************;
; @section : Data [FLASH]                                                                      ;
;**********************************************************************************************;

.DSEG

ic_24lc024h_data_addr: .BYTE    IC_24LC024H_DATA_ADDR_SIZE
ic_24lc024h_data_buff: .BYTE    IC_24LC024H_DATA_BUFF_SIZE

;**********************************************************************************************;
; @section : Code [FLASH]                                                                      ;
;**********************************************************************************************;

.CSEG

;**********************************************************************************************;
; @brief    : Reads Bytes from Memory
;
; @input    : XH:XL : 16-bit - a start pointer of data to read
; @input    : ARG1  :  8-bit - a length of data to read
; @input    : ARG2  :  8-bit - data word address on device
;
; @output   : none
;
; @use      : YH:YL, BUFFL, ARG3, TEMPL
;**********************************************************************************************;
ic_24lc024h_read:   ; save data length and pointer of data
                    mov     BUFFL, ARG1                         ; write into register
                    movw    Y, X                                ; write into register pair

                    ; load pointer of word address
                    ldi     XH, HIGH (ic_24lc024h_data_addr)
                    ldi     XL, LOW  (ic_24lc024h_data_addr)

                    ; store word address
                    st      X, ARG2                             ; write into word address

                    ; load write length and device address and transfer termination
                    ldi     ARG1, IC_24LC024H_DATA_ADDR_SIZE    ; get word address length
                    ldi     ARG2, IC_24LC024H_DEVICE_ADDRESS    ; get device address constant
                    ldi     ARG3, TWI_TRANSFER_CONTINUE         ; do not stop a transfer

                    ; send bytes into memory
                    rcall   twi0_write

                    ; restore data length
                    mov     ARG1, BUFFL                         ; read from register

                    ; load transfer termination
                    ldi     ARG3, TWI_TRANSFER_STOP             ; stop a transfer

                    ; receive bytes from memory
                    rcall   twi0_read

                    ; load pointer of data buffer
                    ldi     XH, HIGH (ic_24lc024h_data_buff)
                    ldi     XL, LOW  (ic_24lc024h_data_buff)

                    ; restore data length
                    mov     ARG1, BUFFL                         ; read from register

                    ; copy bytes from buffer at pointer
                    rcall   memory_copy

                    ret

;**********************************************************************************************;
; @brief    : Writes Bytes into Memory
;
; @input    : XH:XL : 16-bit - start pointer of data
; @input    : ARG1  :  5-bit - length of data
; @input    : ARG2  :  8-bit - data word address on device
;
; @output   : none
;
; @use      : YH:YL, BUFFH:BUFFL, TEMPH:TEMPL, ARG3
;**********************************************************************************************;
ic_24lc024h_write:      ; save data length and word address
                        movw    BUFFH:BUFFL, ARG1                   ; write into register pair

                        ; prepare data length and word address check
                        ldi     TEMPL, 5                            ; set five bits to check
                        ldi     TEMPH, 0xFF                         ; set address

ic_24lc024h_write_br1:  ; check length bit
                        lsr     ARG1                                ; get bit value
                        brcc    ic_24lc024h_write_br2               ; repeat when bit is cleared
                        brne    ic_24lc024h_write_err               ; reject when other bits are set

                        ; check word address
                        com     TEMPH                               ; set clear mask
                        and     ARG2, TEMPH                         ; clear bits
                        breq    ic_24lc024h_write_br9               ; accept when it is divisible by length
                        rjmp    ic_24lc024h_write_err               ; reject when it is not

ic_24lc024h_write_br2:  ; move to next length bit
                        lsl     TEMPH                               ; update word address check mask
                        dec     TEMPL                               ; decrease number of bits to check
                        brne    ic_24lc024h_write_br1               ; repeat when not all bits has been checked

ic_24lc024h_write_err:  ; set failure status
                        ldi     TEMPL, 0xEE                         ; set failure flag

                        ; terminate
                        rjmp    ic_24lc024h_write_end               ; go to end

ic_24lc024h_write_br9:  ; load pointer of word address
                        ldi     YH, HIGH (ic_24lc024h_data_addr)
                        ldi     YL, LOW  (ic_24lc024h_data_addr)

                        ; restore data length and word address
                        movw    ARG1, BUFFH:BUFFL                   ; read from register pair

                        ; store word address
                        st      Y+, ARG2                            ; write into word address

                        ; copy bytes from pointer into buffer
                        rcall   memory_copy

                        ; load pointer of write buffer
                        ldi     XH, HIGH (ic_24lc024h_data_addr)
                        ldi     XL, LOW  (ic_24lc024h_data_addr)

                        ; restore data length
                        mov     ARG1, BUFFL                         ; read from register

                        ; calculate write length
                        ldi     TEMPL, IC_24LC024H_DATA_ADDR_SIZE   ; get address size
                        add     ARG1, TEMPL                         ; add to data length

                        ; load device address
                        ldi     ARG2, IC_24LC024H_DEVICE_ADDRESS    ; get device address constant

                        ; load transfer termination
                        ldi     ARG3, TWI_TRANSFER_STOP             ; stop a transfer

                        ; send bytes into memory
                        rcall   twi0_write

ic_24lc024h_write_br5:  ; check 
                        rcall   twi0_check

                        ; wait until write operation is completed
                        cpi     TEMPL, 0x01                         ; check for success
                        brne    ic_24lc024h_write_br5               ; repeat when bus is not idle

                        ; set success status
                        ldi     TEMPL, 0xAA                         ; set success flag

ic_24lc024h_write_end:  ret
