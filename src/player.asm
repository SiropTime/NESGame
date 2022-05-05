.include "constants.inc"

.segment "ZEROPAGE"
  .importzp player_x, player_y, tmp_x, gravity, jump

.segment "RODATA"
  .import collision_map, bit_mask

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
  if_nothing:
    JMP exit_subroutine

  ; Реализация их выполнения
  jump:
    
    JSR make_jump
    JMP exit_subroutine

  sitdown:
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
    
    JSR check_collision
    JSR load_coords_y 
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

.proc make_jump
  LDA jump
  CMP #DEFAULT_JUMP
  BEQ make_jump
  BNE exit_subroutine
  make_jump:
    DEC jump
    DEC player_y
    JMP exit_subroutine
  

  exit_subroutine:
    RTS
.endproc

.proc sitdown
.endproc

.proc check_collision
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_x ; Загружаем левую к. X игрока
  ADC #$10
  LSR 
  LSR
  LSR ; 6 раз делаем логический сдвиг вправо
  LSR ; тем самым деля на 64
  LSR
  LSR 
  STA tmp_x ; сохраняем во временную переменную

  LDA player_y ; Загружаем верхнюю к. Y игрока
  ADC #$10
  LSR 
  LSR ; делим на 8 тройным логическим сдвигом
  LSR ; В аккумуляторе остаётся необхожимое значение

  ASL ; Умножаем на 4 арифметическим сдвигом влево
  ASL
  ADC tmp_x ; Складываем с X
  TAY

  LDA collision_map, Y
  AND bit_mask, X
  BEQ gravity_inc
  BNE gravity_stop_inc

  gravity_inc: ; Передаём, что пока не столкнулись
    LDA #$01 
    STA gravity
    JMP exit_subroutine
  gravity_stop_inc: ; А здесь, что столкнулись
    LDA #$00
    STA gravity
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

  LDA jump
  CMP #DEFAULT_JUMP
  BEQ saving
  CMP #$00
  BEQ go_down
  BPL continue_jump
  BNE saving
  go_down:
    INC player_y
    LDA gravity
    CMP #$00
    BEQ return_jump
    JMP saving
  continue_jump:
    DEC jump
    DEC player_y
    LDA jump
    CMP #$00
    BEQ go_down
    JMP saving
  return_jump:
    LDA #DEFAULT_JUMP
    STA jump
  ; Сохраняем координаты
  saving:
    
    ; Верхний правый тайл
    LDA player_y
    STA $0204

    ; Левый верхний
    LDA player_y
    STA $0200

    ; Нижний правый
    LDA player_y
    CLC
    ADC #$08
    STA $020c

    ; Нижний левый
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
