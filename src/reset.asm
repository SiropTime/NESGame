.include "constants.inc"

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler ; прерывание для резета или первого включения
    SEI ; задание бита игнорирования прерывания.
    ; нужен чтобы процессор не прерывался пока инициализируется
    CLD ; отключение режима двоично-десятичного кода
    LDX #$00 ; устанавливаем отключение отрисовки лишнего мусора при инициализации
    STX PPUCTRL ; загружаем обновлённую маску в PPUCTRL
    STX PPUMASK ; загружаем обновлённую маску в PPUMASK
  vblankwait:
    BIT PPUSTATUS ; получем состояние ППУ
    BPL vblankwait ; пока он не инициализируется окончательно
    JMP main ; переходим к главной программе
.endproc