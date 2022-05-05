; Константы адресов обращения к PPU
PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002 ; состояние PPU
OAMADDR = $2003 ; задание адреса для памяти с данными спрайтов
PPUSCROLL = $2005
PPUADDR = $2006 ; адрес записи в PPU
PPUDATA = $2007 ; данные для записи в PPU
OAMDMA = $4014 ; инициация передача всей страницы памяти
; Адреса отслеживания геймпадов
; 7 6 5 4 3 2 1 0
; A B SeStU D L R
JOYPAD1 = $4016
JOYPAD2 = $4017

CLEAR_NMI = $00
DEFAULT_CTRL = %10010010
DEFAULT_MASK = %00011110

DEFAULT_JUMP = $C0

VRAM_DOWN = $04
VBLANK_NMI = $80