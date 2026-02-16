;**********************************************************************************************;
; @description : Microchip 24LC024H Definition                                                 ;
;**********************************************************************************************;

.IFNDEF IC_24LC024H_DEFINE
.SET    IC_24LC024H_DEFINE = 1

;**********************************************************************************************;
; @section : Include File                                                                      ;
;**********************************************************************************************;

.INCLUDE "macro/registers.inc"
.INCLUDE "macro/config.inc"

;**********************************************************************************************;
; @section : Configuration Option Definition                                                   ;
;**********************************************************************************************;

; Pin Logic Level
.EQU IC_24LC024H_PIN_LOW  = 0
.EQU IC_24LC024H_PIN_HIGH = 1

; @brief Chip Address Input Pin Level
.EQU IC_24LC024H_CHIP_ADDRESS_PIN_LOW  = IC_24LC024H_PIN_LOW
.EQU IC_24LC024H_CHIP_ADDRESS_PIN_HIGH = IC_24LC024H_PIN_HIGH

.ENDIF
