.include "constants.inc"

.segment "ZEROPAGE"
  .importzp player_x, player_y

.segment "CODE"
.export read_joypad
.proc read_joypad
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    ; Сброс геймпада
    LDA #$01
    STA JOYPAD1
    LDA #$00
    STA JOYPAD1

  ; Чтение кнопок
  read_a:
    LDA $4016
    JMP read_b
    
  read_b:
    LDA $4016
    JMP read_select

  read_select:
    LDA $4016
    JMP read_start
  
  read_start:
    LDA $4016
    JMP read_up

  read_up:
    LDA $4016
    AND #%00000001
    BNE jump
    BEQ read_down

  read_down:
    LDA $4016
    AND #%00000001
    BNE sitdown
    BEQ read_left

  read_left:
    LDA $4016
    AND #%00000001
    BNE walk_left
    BEQ read_right

  read_right:
    LDA $4016
    AND #%00000001
    BNE walk_right
    BEQ exit_subroutine

  ; Реализация их выполнения
  jump:
  DEC player_y
  JMP exit_subroutine

  sitdown:
  INC player_y
  JMP exit_subroutine

  walk_left:  
  DEC player_x
  JMP exit_subroutine
  
  walk_right:
  INC player_x
  JMP exit_subroutine

  exit_subroutine:
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP
    RTS
.endproc