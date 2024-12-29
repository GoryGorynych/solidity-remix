// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract PackingExample {
    function packData(uint8 a, uint8 b) public pure returns (uint16) {
        // Сдвигаем `a` на 8 бит влево и объединяем с `b` с помощью побитового OR
        return (uint16(a) << 8) | uint16(b);
    }

    function unpackData(uint16 packed) public pure returns (uint8 a, uint8 b) {
        // Извлекаем `a` (старшие 8 бит)
        a = uint8(packed >> 8);
        // Извлекаем `b` (младшие 8 бит)
        b = uint8(packed & 0xFF); // Маска 0xFF оставляет только последние 8 бит
    }

}
