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
    JSR load_coords_y
    JMP exit_subroutine

  sitdown:
    INC player_y
    JSR load_coords_y
    JMP exit_subroutine

  walk_left:  
    DEC player_x
    JSR turn_player_left
    JMP exit_subroutine
  
  walk_right:
    INC player_x
    JSR turn_player_right
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

.export update_player
.proc update_player
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    JSR read_joypad
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

.proc load_coords_y
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; Сохраняем координаты
  ; Верхний левый тайл
  LDA player_y
  STA $0204

  ; Правый верхний
  LDA player_y
  STA $0200

  ; Нижний левый
  LDA player_y
  CLC
  ADC #$08
  STA $020c

  ; Нижний правый
  LDA player_y
  CLC
  ADC #$08
  STA $0208

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc turn_player_left
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  ; Записываем аттрибуты тайлов игрока
  LDA #%01000001
  STA $0202
  STA $0206
  LDA #%01000000
  STA $020a
  STA $020e

  ; Сохраняем координаты
  ; Верхний левый тайл
  LDA player_y
  STA $0204
  LDA player_x
  STA $0207

  ; Правый верхний
  LDA player_y
  STA $0200
  LDA player_x
  CLC
  ADC #$08
  STA $0203

  ; Нижний левый
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  STA $020f

  ; Нижний правый
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  CLC
  ADC #$08
  STA $020b

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc turn_player_right
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  ; Записываем аттрибуты тайлов игрока
  LDA #%00000001
  STA $0202
  STA $0206
  LDA #%00000000
  STA $020a
  STA $020e

  ; Записываем номера тайлов игрока
  LDA #$10
  STA $0201
  LDA #$11
  STA $0205
  LDA #$20
  STA $0209
  LDA #$21
  STA $020d

  ; Сохраняем координаты
  ; Верхний левый тайл
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; Правый верхний
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; Нижний левый
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; Нижний правый
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc
