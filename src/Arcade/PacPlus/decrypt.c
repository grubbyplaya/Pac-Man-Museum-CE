#include <stdio.h>
#include <stdint.h>

uint8_t bitswap(uint8_t e, uint8_t tbl[]) {
    return     ((e >> tbl[0] & 1) << 7) |
               ((e >> tbl[1] & 1) << 6) |
               ((e >> tbl[2] & 1) << 5) |
               ((e >> tbl[3] & 1) << 4) |
               ((e >> tbl[4] & 1) << 3) |
               ((e >> tbl[5] & 1) << 2) |
               ((e >> tbl[6] & 1) << 1) |
               ((e >> tbl[7] & 1) << 0);
}

uint8_t pacplus_decrypt(int addr, uint8_t e)
{
	uint8_t swap_xor_table[6][9] =
	{
		{ 7,6,5,4,3,2,1,0, 0x00 },
		{ 7,6,5,4,3,2,1,0, 0x28 },
		{ 6,1,3,2,5,7,0,4, 0x96 },
		{ 6,1,5,2,3,7,0,4, 0xbe },
		{ 0,3,7,6,4,2,1,5, 0xd5 },
		{ 0,3,4,6,7,2,1,5, 0xdd }
	};
	
	int picktable[32] =
	{
		0,2,4,2,4,0,4,2,2,0,2,2,4,0,4,2,
		2,2,4,0,4,2,4,0,0,4,0,4,4,2,4,2
	};
	
	uint32_t method = 0;
	uint8_t *tbl;

	/* pick method from bits 0 2 5 7 9 of the address */
	method = picktable[
		(addr & 0x001) |
		((addr & 0x004) >> 1) |
		((addr & 0x020) >> 3) |
		((addr & 0x080) >> 4) |
		((addr & 0x200) >> 5)];

	/* switch method if bit 11 of the address is set */
	if ((addr & 0x800) == 0x800)
		method ^= 1;

	tbl = swap_xor_table[method];
	return bitswap(e, tbl) ^ tbl[8];
}

void pacplus_decode()
{
	uint8_t ROM[0x4000] = {};   // put Pac-Man Plus ROM here as raw bytes
	uint8_t NROM[0x4000];
	for (int i = 0; i < 0x4000; i++)
	{
		NROM[i] = pacplus_decrypt(i, ROM[i]);
		printf("$%02X, ", NROM[i]);
	}
	
	// to build the console output as a decrypted Pac-Plus ROM (pacplus.bin),
	// save the final output onto a .asm file, remove the final comma,
	// and build the file using an assembler.
}

int main() {
    printf(".db ");
    pacplus_decode();
    return 0;
}